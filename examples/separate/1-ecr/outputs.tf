output "ecr_secrets" {
  description = "ECR Module: Map of created ECR pull through cache secrets."
  value       = module.ecr.secrets
}

output "ecr_secret_arns" {
  description = "ECR Module: Map of created ECR pull through cache secret ARNs."
  value       = module.ecr.secret_arns
}

output "ecr_secret_version_ids" {
  description = "ECR Module: Map of created ECR pull through cache secret version IDs."
  value       = module.ecr.secret_version_ids
}

output "ecr_secret_version_arns" {
  description = "ECR Module: Map of created ECR pull through cache secret version ARNs."
  value       = module.ecr.secret_version_arns
}

output "ecr_pull_through_cache_rules" {
  description = "ECR Module: Map of created ECR pull through cache rules."
  value       = module.ecr.ecr_pull_through_cache_rules
}

output "ecr_pull_through_cache_rule_prefixes" {
  description = "ECR Module: Map of ECR pull through cache rule prefixes."
  value       = module.ecr.ecr_pull_through_cache_rule_prefixes
}

output "ecr_pull_through_cache_rule_ids" {
  description = "ECR Module: Map of created ECR pull through cache rule IDs."
  value       = module.ecr.ecr_pull_through_cache_rule_ids
}

output "ecr_helm_values" {
  description = "ECR Module: Map of Helm chart values for ECR pull through cache."
  value       = module.ecr.helm_values
}

output "ecr_helm_values_yaml" {
  description = "ECR Module: YAML encoded Helm chart values for ECR pull through cache."
  value       = module.ecr.helm_values_yaml
}
