/**
 * # All-in-One Example
 *
 * This example demonstrates how to deploy the Kompass Compute service on an EKS cluster
 * using Terraform. It includes the creation of ECR pull-through cache rules, IAM roles, SQS queues,
 * and the deployment of the Kompass Compute Helm chart.
 *
 * Note: It is highly recommended to deploy `ecr` module only once per region.
 * ECR pull-through cache rules are regional resources, and creating them multiple times
 * is not necessary and may lead to conflicts.
 *
 * ## Prerequisites
 *
 * - Docker and GitHub Container Registry credentials stored in AWS Secrets Manager
 * - An existing EKS cluster
 * - A VPC with subnets
 * - Zesty Kompass Infra installed in the EKS cluster
 *
 * ## Configuration
 *
 * The example uses the following variables:
 *
 * - `cluster_name`: The name of the EKS cluster.
 * - `vpc_id`: The ID of the VPC where the EKS cluster is deployed.
 * - `subnet_ids`: A list of subnet IDs where S3 VPC endpoints will be created.
 * - `vpc_endpoints_ingress_cidr_block`: The CIDR block for ingress traffic to the VPC endpoints.
 * - `dockerhub_secret_arn`: The ARN of the AWS Secrets Manager secret for Docker Hub credentials.
 * - `ghcr_secret_arn`: The ARN of the AWS Secrets Manager secret for GitHub Container Registry credentials.
 * - `helm_values_yaml`: Additional Helm values to customize the deployment.
 *
 * ## Image registry secrets
 *
 * The example uses existing AWS Secrets Manager secrets for Docker Hub and GitHub Container Registry credentials.
 * These secrets are used to authenticate with the respective registries when pulling images.
 * The secrets should be created in the format expected by the ECR pull-through cache rules.
 *
 * Check the [ECR module documentation](../../modules/ecr/README.md) for more details on how to create these secrets.
 *
 * ## Provider Configuration
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

# Creates ECR pull-through cache rules and manages authentication credentials in AWS Secrets Manager.
module "ecr" {
  source = "../../modules/ecr"

  ecr_pull_through_rule_name_prefix = "${var.cluster_name}-"

  registries = {
    "dockerhub" = {
      secret_arn = var.dockerhub_secret_arn
    },
    "ghcr" = {
      secret_arn = var.ghcr_secret_arn
    }
  }
}

# Creates IAM roles and policies, SQS queues, and other resources for Kompass Compute.
module "kompass_compute" {
  source = "../../"

  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids

  vpc_endpoint_security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [var.vpc_endpoints_ingress_cidr_block]
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
    module.ecr.helm_values_yaml,
    module.kompass_compute.helm_values_yaml,
    var.helm_values_yaml,
  ]

  depends_on = [
    # Prevents from removing IAM roles and policies while deleting the Helm release.
    # `module.kompass_compute` module will be deleted after the Helm release is deleted.
    module.kompass_compute,
  ]
}
