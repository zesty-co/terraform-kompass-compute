/**
 * # Kompass Compute Deployment Example
 *
 * This example demonstrates how to deploy the Zesty Kompass Compute service on an Amazon EKS cluster
 * using Terraform. It requires the ECR Pull-Through Cache Rules to be created for Docker Hub and GitHub Container Registry.
 *
 * ## Prerequisites
 *
 * - An existing EKS cluster
 * - A VPC with subnets
 * - Zesty Kompass Infra installed in the EKS cluster
 *
 * ## Configuration
 *
 * The example uses the following variables:
 *
 * - `cluster_name`: The name of the EKS cluster.
 * - `helm_values_yaml`: Additional Helm values to customize the deployment.
 *
 * Other parameters like, `vpc_id`, `subnet_ids`, `vpc_endpoints_ingress_cidr_block`, are discovered from the EKS cluster using data sources.
 * Instead of relying on the discovered values, they can also be passed as variables.
 *
 * ## ECR Pull-Through Cache Rules
 *
 * Before deploying Kompass Compute, ensure that the ECR Pull-Through Cache Rules for Docker Hub and GitHub Container Registry are created.
 *
 * Kompass Compute requires information from the ECR module. The output can be accessed using the `terraform_remote_state`
 * data source like, or it can be generated directly in the module.
 *
 * Check the [ECR module documentation](../../../modules/ecr/README.md) for more details on how to use this variable.
 *
 * ## Provider Configuration
 *
 * For Helm provider version 3 and above:
 *
 * ```hcl
 * provider "aws" {}
 *
 * data "aws_eks_cluster" "eks_cluster" {
 *   name = var.cluster_name
 * }
 *
 * provider "helm" {
 *   kubernetes = {
 *     host                   = data.aws_eks_cluster.eks_cluster.endpoint
 *     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
 *
 *     exec = {
 *       api_version = "client.authentication.k8s.io/v1beta1"
 *       command     = "aws"
 *       # This requires the awscli to be installed locally where Terraform is executed
 *       args = ["eks", "get-token", "--cluster-name", var.cluster_name]
 *     }
 *   }
 * }
 * ```
 *
 * For Helm provider version 2:
 *
 * ```hcl
 * provider "aws" {}
 *
 * data "aws_eks_cluster" "eks_cluster" {
 *   name = var.cluster_name
 * }
 *
 * provider "helm" {
 *   kubernetes {
 *     host                   = data.aws_eks_cluster.eks_cluster.endpoint
 *     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
 *
 *     exec {
 *       api_version = "client.authentication.k8s.io/v1beta1"
 *       command     = "aws"
 *       # This requires the awscli to be installed locally where Terraform is executed
 *       args = ["eks", "get-token", "--cluster-name", var.cluster_name]
 *     }
 *   }
 * }
 * ```
 *
 */

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

locals {
  vpc_id     = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  vpc_cidr   = data.aws_vpc.this.cidr_block
  subnet_ids = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
locals {
  ecr_helm_values_yaml = jsonencode({
    cachePullMappings = {
      dockerhub : [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-dockerhub"
      }],
      ghcr : [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-ghcr"
      }],
      ecr : [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-ecr"
      }],
      k8s : [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-k8s"
      }],
      quay : [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-quay"
      }],
    }
  })
}

# Creates IAM roles and policies, SQS queues, and other resources for Kompass Compute.
module "kompass_compute" {
  source = "../../../"

  cluster_name = var.cluster_name
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids

  vpc_endpoint_security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [local.vpc_cidr]
    }
  }
}

# Deploys the Kompass Compute Helm chart to the EKS cluster.
resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  name       = "kompass-compute"
  namespace  = "zesty-system"

  # Get values from the ECR module, Kompass Compute module, and user-defined values
  values = [
    local.ecr_helm_values_yaml,
    module.kompass_compute.helm_values_yaml,
    var.helm_values_yaml,
  ]

  depends_on = [
    # Prevents from removing IAM roles and policies while deleting the Helm release
    module.kompass_compute,
  ]
}
