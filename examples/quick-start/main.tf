locals {
  vpc_id     = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  vpc_cidr   = data.aws_vpc.this.cidr_block
  subnet_ids = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

# Creates the cloud resources for Kompass Compute.
module "kompass_compute" {
  source  = "zesty-co/compute/kompass"
  version = ">= 1.0.0, < 2.0.0"
  # source = "../../"

  cluster_name = var.cluster_name
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids

  irsa_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn

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

    # Custom values for the helm chart.
    var.helm_values_yaml,
  ]

  depends_on = [
    # Prevents from removing IAM roles and policies while deleting the Helm release
    module.kompass_compute,
    helm_release.kompass_compute_crd,
  ]
}
