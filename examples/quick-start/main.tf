/*
* # Quick Start
* This example shows how to install Kompass Compute with the most basic setup.
* It deploys 3 components:
* 1. The Kompass Compute module, which creates the cloud resources for Kompass Compute.
* 2. The Kompass Compute Helm chart.
* 3. The CRDs of the Kompass Compute Helm chart, through a separate chart, according to the helm best practices.
*
* Before applying the module, ensure that the providers target the correct EKS cluster, and AWS account.
*
* You need to ensure the following:
*
* 1. The AWS provider is configured to target the correct AWS account.
* By default the module will use the accounted configured in your local aws cli.
* It can be overriden by modifying the `aws` provider configuration inside [providers.tf](./providers.tf).
* 2. The name of the EKS cluster is provided in the `cluster_name` variable through a tfvars or env var.
* See [variables.tf](./variables.tf) for more details.
* 3. You have the helm binary installed and available in your PATH and the helm provider is configured correctly.
*
* The module works in the following order:
*
* 1. Scrapes the EKS cluster for information.
* 2. Creates the cloud resources for Kompass Compute.
* 3. Deploys the CRDs of the Kompass Compute Helm chart, through a separate chart, according to the helm best practices.
* 4. Deploys the Kompass Compute Helm chart, providing it with knowledge about the deployed cloud resources.
*/
locals {
  vpc_id     = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  vpc_cidr   = data.aws_vpc.this.cidr_block
  subnet_ids = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

# Creates the cloud resources for Kompass Compute.
module "kompass_compute" {
  source  = "zesty-co/compute/kompass"
  version = "~> 1.0.0"
  # source = "../../"

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

# The CRDs are managed by a separate chart, according to the helm best practices.
resource "helm_release" "kompass_compute_crd" {
  repository = "https://zesty-co.github.io/kompass-compute"
  # If you want to specify the exact version of the chart:
  # version    = "0.1.7"
  chart     = "kompass-compute-crd"
  name      = "kompass-compute-crd"
  namespace = "zesty-system"
}

resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  # If you want to specify the exact version of the chart:
  # version    = "0.1.7"
  name      = "kompass-compute"
  namespace = "zesty-system"

  values = [
    # Provide the helm chart with knowledge about the deployed cloud resources.
    module.kompass_compute.helm_values_yaml,
  ]

  depends_on = [
    # Prevents from removing IAM roles and policies while deleting the Helm release
    module.kompass_compute,
    helm_release.kompass_compute_crd,
  ]
}
