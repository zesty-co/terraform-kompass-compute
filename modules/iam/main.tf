/**
 * # Zesty Kompass Compute AWS IAM Role Module
 *
 * This Terraform module creates and manages IAM roles and policies for the Zesty Kompass Compute controller.
 *
 * ## Features
 *
 * - Creates and manages IAM roles for multiple Kompass Compute controllers:
 *   - Hiberscaler controller
 *   - Image Size Calculator controller
 *   - Snapshooter controller
 *   - Telemetry Manager controller
 * - Configures IAM permissions for each controller
 * - Supports both EKS Pod Identity and IRSA (IAM Roles for Service Accounts)
 *
 * ## Usage
 *
 * ```hcl
 * module "iam_controller" {
 *   source = "path/to/module"
 *
 *   create = true
 *
 *   iam_role_name        = "kompass-compute-controller"
 *   iam_role_description = "IAM role for Kompass Compute controller"
 *   iam_policy_name      = "kompass-compute-controller-policy"
 *   cluster_name         = "my-eks-cluster"
 *   namespace            = "zesty-system"
 *   service_account_name = "kompass-compute-controller"
 *
 *   # Enable Pod Identity or IRSA as needed
 *   enable_pod_identity = true
 *   enable_irsa         = true
 *
 *   # Optional: Custom tags
 *   tags = {
 *     Environment = "dev"
 *   }
 * }
 * ```
 *
 */

data "aws_region" "current" {
  count = var.create ? 1 : 0
}
data "aws_partition" "current" {
  count = var.create ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.create ? 1 : 0
}

locals {
  region     = try(data.aws_region.current[0].name, null)
  account_id = try(data.aws_caller_identity.current[0].account_id, null)
  partition  = try(data.aws_partition.current[0].partition, null)

  use_hiberscaler_policy           = var.create && var.iam_use_hiberscaler_policy
  use_snapshooter_policy           = var.create && var.iam_use_snapshooter_policy
  use_telemetry_manager_policy     = var.create && var.iam_use_telemetry_manager_policy
  use_image_size_calculator_policy = var.create && var.iam_use_image_size_calculator_policy
  irsa_oidc_provider_url           = replace(var.irsa_oidc_provider_arn, "/^(.*provider/)/", "")

  # Tags used for all resources
  tags = {
    Zesty = "true"
  }
}

################################################################################
# Kompass Compute IAM Role
################################################################################

data "aws_iam_policy_document" "controller_assume_role" {
  count = var.create ? 1 : 0

  # Pod Identity
  dynamic "statement" {
    for_each = var.enable_pod_identity ? [1] : []

    content {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]

      principals {
        type        = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }
    }
  }

  # IAM Roles for Service Accounts (IRSA)
  dynamic "statement" {
    for_each = var.enable_irsa ? [1] : []

    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [var.irsa_oidc_provider_arn]
      }

      condition {
        test     = var.irsa_assume_role_condition_test
        variable = "${local.irsa_oidc_provider_url}:sub"
        values   = [for sa in var.irsa_namespace_service_accounts : "system:serviceaccount:${sa}"]
      }

      # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
      condition {
        test     = var.irsa_assume_role_condition_test
        variable = "${local.irsa_oidc_provider_url}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "controller" {
  count = var.create ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : var.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${var.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.controller_assume_role[0].json
  max_session_duration  = var.iam_role_max_session_duration
  permissions_boundary  = var.iam_role_permissions_boundary_arn
  force_detach_policies = true

  tags = merge(
    local.tags,
    var.tags,
    var.iam_role_tags
  )
}

resource "aws_iam_policy" "controller" {
  count = var.create ? 1 : 0

  name        = var.iam_policy_use_name_prefix ? null : var.iam_policy_name
  name_prefix = var.iam_policy_use_name_prefix ? "${var.iam_policy_name}-" : null
  path        = var.iam_policy_path
  description = var.iam_policy_description
  policy      = data.aws_iam_policy_document.controller[0].json

  tags = merge(
    local.tags,
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "controller" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.controller[0].name
  policy_arn = aws_iam_policy.controller[0].arn
}

resource "aws_iam_role_policy_attachment" "controller_additional" {
  for_each = { for k, v in var.iam_role_policies : k => v if var.create }

  role       = aws_iam_role.controller[0].name
  policy_arn = each.value
}

################################################################################
# Pod Identity Association
################################################################################

resource "aws_eks_pod_identity_association" "controller" {
  count = var.create && var.enable_pod_identity && var.create_pod_identity_association ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.controller[0].arn

  tags = merge(
    local.tags,
    var.tags,
  )
}
