/**
 * # Zesty Kompass Compute AWS ECR Pull-Through Cache Module
 *
 * This Terraform module creates and manages AWS ECR Pull-Through Cache Rules and their associated secrets in AWS Secrets Manager.
 *
 * Note: It is recommended to deploy this module only once per region.
 * ECR pull-through cache rules are regional resources, and creating them multiple times
 * is not necessary and may lead to conflicts.
 *
 * ## Features
 *
 * - Creates ECR Pull-Through Cache Rules for various registries
 * - Manages authentication credentials in AWS Secrets Manager
 *
 * ## Usage
 *
 * ```hcl
 * module "ecr" {
 *   source  = "zesty-co/compute/kompass//modules/ecr"
 *   version = "~> 1.0.0"
 *
 *   # Basic configuration with default public registries
 *   # By default, creates rules for dockerhub, ghcr, kubernetes-registry, etc.
 *
 *   # It is required to provide `dockerhub` and `ghcr` secrets if you want to use them.
 *   # You can provide secret ARN or secret content in format: "{\"username\":\"USERNAME\",\"accessToken\":\"TOKEN\"}"
 *   registries = {
 *     dockerhub = {
 *       secret_arn = "aws:secretsmanager:REGION:ACCOUNT_ID:secret:ecr-pullthroughcache/dockerhub"
 *       // secret_content = jsonencode({
 *       //   username    = "your-username"
 *       //   accessToken = "your-access-token"
 *       // })
 *     }
 *     ghcr = {
 *       secret_arn = "aws:secretsmanager:REGION:ACCOUNT_ID:secret:ecr-pullthroughcache/ghcr"
 *       // secret_content = jsonencode({
 *       //   username    = "your-username"
 *       //   accessToken = "your-access-token"
 *       // })
 *     }
 *   }
 * }
 * ```
 *
 * ## ECR Secrets
 *
 * This module can use existing secrets or create new ones in AWS Secrets Manager for the ECR Pull-Through Cache Rules.
 * You can specify the secrets using either `secret_arn` or `secret_content`.
 *
 * Format of the `secret_content` or secret in AWS Secrets Manager should be a JSON string containing the `username` and `accessToken` fields:
 *
 * ```json
 * {
 *   "username": "your-username",
 *   "accessToken": "your-access-token"
 * }
 * ```
 *
 * ## Disable ECR Pull-Through Cache Rule Creation
 *
 * To disable the creation of the ECR Pull-Through Cache Rule, set the `create` variable to `false`:
 *
 * ```hcl
 * registries = {
 *   dockerhub = {
 *     create = false
 *   }
 * }
 * ```
 *
 * ## Passing values to Helm Chart
 *
 * The module outputs a `helm_values_yaml` variable that can be used to pass values to the Helm chart.
 * This variable contains the necessary configuration for the ECR Pull-Through Cache Rules.
 * You can use it in your Helm chart as follows:
 *
 * ```hcl
 * resource "helm_release" "kompass_compute" {
 *   repository = "https://zesty-co.github.io/kompass-compute"
 *   chart      = "kompass-compute"
 *   name       = "kompass-compute"
 *   namespace  = "zesty-system"
 *
 *   values = [
 *     module.ecr.helm_values_yaml,
 *   ]
 * }
 * ```
 *
 * The `helm_values_yaml` can be also accessed using the `terraform_remote_state` data source
 * or generated directly in the module like this:
 *
 * ```hcl
 * data "aws_region" "current" {}
 * data "aws_caller_identity" "current" {}
 * locals {
 *   ecr_helm_values_yaml = jsonencode({
 *     cachePullMappings = {
 *       dockerhub: [{
 *         proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-dockerhub""
 *       }],
 *       ghcr: [{
 *         proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-ghcr"
 *       }],
 *       ecr: [{
 *         proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-ecr"
 *       }],
 *       k8s: [{
 *         proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-k8s"
 *       }],
 *       quay: [{
 *         proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-quay"
 *       }],
 *     }
 *   })
 * }
 * ```
 *
 * The generated YAML can look like this:
 *
 * ```yaml
 * cachePullMappings:
 *   dockerhub:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-dockerhub"
 *   ghcr:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-ghcr"
 *   ecr:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-ecr"
 *   k8s:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-k8s"
 *   quay:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-quay"
 * ```
 *
 * Name of the ECR repository will be in the format `zesty-{registry_name}` where `{registry_name}` is the key from the `registries` map (e.g., `zesty-dockerhub`, `zesty-ghcr`, etc.).
 * It can be overridden by setting the `ecr_pull_through_rule_name_prefix` variable in the module configuration,
 * or by using the `ecr_repository_prefix_override` field in the `registries` map for each registry.
 *
 */

data "aws_region" "current" {
  count = var.create ? 1 : 0
}

locals {
  region = try(data.aws_region.current[0].name, null)

  # Default ECR pull-through cache rules
  default_registries = {
    "ecr" = {
      create                = true
      upstream_registry_url = "public.ecr.aws"
    },
    "k8s" = {
      create                = true
      upstream_registry_url = "registry.k8s.io"
    },
    "quay" = {
      create                = true
      upstream_registry_url = "quay.io"
    },
    "dockerhub" = {
      create                = false
      upstream_registry_url = "registry-1.docker.io"
    },
    "ghcr" = {
      create                = false
      upstream_registry_url = "ghcr.io"
    }
  }

  # Merge the default registries with the user-defined registries
  registries = {
    for k in nonsensitive(keys(merge(local.default_registries, var.registries))) : k => {
      create                         = nonsensitive(coalesce(try(var.registries[k].create, null), try(local.default_registries[k].create, true)))
      upstream_registry_url          = nonsensitive(try(coalesce(try(var.registries[k].upstream_registry_url, null), try(local.default_registries[k].upstream_registry_url, null)), null))
      ecr_repository_prefix_override = nonsensitive(try(coalesce(try(var.registries[k].ecr_repository_prefix_override, null), try(local.default_registries[k].ecr_repository_prefix_override, null)), null))
      secret_arn                     = nonsensitive(try(coalesce(try(var.registries[k].secret_arn, null), try(local.default_registries[k].secret_arn, null)), null))
      secret_content                 = try(coalesce(try(var.registries[k].secret_content, null), try(local.default_registries[k].secret_content, null)), null)
      secret_name_prefix_override    = nonsensitive(try(coalesce(try(var.registries[k].secret_name_prefix_override, null), try(local.default_registries[k].secret_name_prefix_override, null)), null))
    }
  }

  # Create list of registry keys for which secrets should be created.
  # The list contains nonsensitive keys to ensure that sensitive values are not exposed.
  registry_keys_for_secrets = nonsensitive([
    for k, registry in local.registries : k
    if var.create &&
    try(registry.create, false) &&
    try(registry.secret_content, null) != null &&
    try(registry.secret_arn, null) == null
  ])

  # Create a map of secrets to create
  secrets_to_create = {
    for k in local.registry_keys_for_secrets : k => {
      name_prefix             = nonsensitive(coalesce(try(local.registries[k].secret_name_prefix_override, null), "${var.secret_name_prefix}${k}-"))
      description             = nonsensitive("Secret for ECR Pull Through Cache Rule for: ${local.registries[k].upstream_registry_url}")
      registry                = nonsensitive(local.registries[k].upstream_registry_url) # For tagging
      recovery_window_in_days = nonsensitive(var.secret_recovery_window_in_days)
      content                 = local.registries[k].secret_content
    }
  }

  # Process registries to determine which pull-through cache rules to create and their credential ARNs
  pull_through_rules = {
    for k, reg_config in local.registries : k => {
      ecr_repository_prefix = nonsensitive(coalesce(reg_config.ecr_repository_prefix_override, "${var.ecr_pull_through_rule_name_prefix}${k}"))
      upstream_registry_url = nonsensitive(reg_config.upstream_registry_url)
      credential_arn = nonsensitive(reg_config.secret_arn) != null ? nonsensitive(reg_config.secret_arn) : (
        nonsensitive(lookup(local.secrets_to_create, k, null) != null) ? aws_secretsmanager_secret.this[k].arn : null
      )
    } if var.create && nonsensitive(reg_config.create)
  }

  # Tags used for all resources
  tags = {
    Zesty = "true"
  }
}

################################################################################
# ECR Pull Through Cache Secrets
################################################################################

resource "aws_secretsmanager_secret" "this" {
  for_each = local.secrets_to_create

  description             = each.value.description
  name_prefix             = each.value.name_prefix
  recovery_window_in_days = each.value.recovery_window_in_days

  tags = merge(
    local.tags,
    {
      Registry = each.value.registry
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.secrets_to_create

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.content
}

################################################################################
# The ECR Pull Through Cache Rules
################################################################################

resource "aws_ecr_pull_through_cache_rule" "this" {
  for_each = local.pull_through_rules

  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
  credential_arn        = each.value.credential_arn
}
