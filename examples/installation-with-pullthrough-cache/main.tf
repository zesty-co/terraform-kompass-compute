locals {
  vpc_id       = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  vpc_cidr     = data.aws_vpc.this.cidr_block
  subnet_ids   = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
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

module "ecr" {
  source  = "zesty-co/compute/kompass//modules/ecr"
  version = "~> 1.0.0"

  ecr_pull_through_rule_name_prefix = "${var.cluster_name}-"
}

# Deploy the Kompass Compute Helm chart.
resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  name       = "kompass-compute"
  namespace  = "zesty-system"

  values = [
    # Provide the helm chart with knowledge about the deployed cloud resources.
    module.kompass_compute.helm_values_yaml,
    module.ecr.helm_values_yaml,
  ]

  depends_on = [
    # Prevents from removing IAM roles and policies while deleting the Helm release
    module.kompass_compute,
    module.ecr,
  ]
}