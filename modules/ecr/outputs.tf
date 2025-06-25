################################################################################
# ECR Pull Through Cache Secrets
################################################################################
output "secrets" {
  description = "Map of created ECR pull through cache secrets"
  value       = aws_secretsmanager_secret.this
}

output "secret_arns" {
  description = "Map of created ECR pull through cache secret ARNs"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_version_ids" {
  description = "Map of created ECR pull through cache secret version IDs"
  value       = { for k, v in aws_secretsmanager_secret_version.this : k => aws_secretsmanager_secret_version.this[k].version_id }
}

output "secret_version_arns" {
  description = "Map of created ECR pull through cache secret version ARNs"
  value       = { for k, v in aws_secretsmanager_secret_version.this : k => aws_secretsmanager_secret_version.this[k].id }
}

################################################################################
# The ECR Pull Through Cache Rules
################################################################################
output "ecr_pull_through_cache_rules" {
  description = "Map of created ECR pull through cache rules"
  value       = aws_ecr_pull_through_cache_rule.this
}

output "ecr_pull_through_cache_rule_prefixes" {
  description = "Map of ECR pull through cache rule prefixes"
  value       = { for k, v in aws_ecr_pull_through_cache_rule.this : k => "${v.registry_id}.dkr.ecr.${local.region}.amazonaws.com/${v.ecr_repository_prefix}" }
}

output "ecr_pull_through_cache_rule_ids" {
  description = "Map of created ECR pull through cache rule IDs"
  value       = { for k, v in aws_ecr_pull_through_cache_rule.this : k => v.id }
}

################################################################################
# Helm Chart values
################################################################################
locals {
  helm_values = {
    cachePullMappings = { for k, v in aws_ecr_pull_through_cache_rule.this : k => [{
      proxyAddress = "${v.registry_id}.dkr.ecr.${local.region}.amazonaws.com/${v.ecr_repository_prefix}"
      }]
    }
  }
}

output "helm_values" {
  description = "Map of Helm chart values for ECR pull through cache"
  value       = local.helm_values
}

output "helm_values_yaml" {
  description = "YAML encoded Helm chart values for ECR pull through cache"
  value       = yamlencode(local.helm_values)
}
