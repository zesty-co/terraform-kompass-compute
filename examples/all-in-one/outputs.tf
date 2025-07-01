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

################################################################################
# Kompass Compute Module IAM Roles
################################################################################

output "kompass_compute_iam_hiberscaler_role_name" {
  description = "Kompass Compute Module: The name of the Hiberscaler controller IAM role."
  value       = module.kompass_compute.iam_hiberscaler_role_name
}

output "kompass_compute_iam_hiberscaler_role_arn" {
  description = "Kompass Compute Module: The ARN of the Hiberscaler controller IAM role."
  value       = module.kompass_compute.iam_hiberscaler_role_arn
}

output "kompass_compute_iam_hiberscaler_role_unique_id" {
  description = "Kompass Compute Module: Stable and unique string identifying the Hiberscaler controller IAM role."
  value       = module.kompass_compute.iam_hiberscaler_role_unique_id
}

output "kompass_compute_iam_snapshooter_role_name" {
  description = "Kompass Compute Module: The name of the Snapshooter controller IAM role."
  value       = module.kompass_compute.iam_snapshooter_role_name
}

output "kompass_compute_iam_snapshooter_role_arn" {
  description = "Kompass Compute Module: The ARN of the Snapshooter controller IAM role."
  value       = module.kompass_compute.iam_snapshooter_role_arn
}

output "kompass_compute_iam_snapshooter_role_unique_id" {
  description = "Kompass Compute Module: Stable and unique string identifying the Snapshooter controller IAM role."
  value       = module.kompass_compute.iam_snapshooter_role_unique_id
}

output "kompass_compute_iam_telemetry_manager_role_name" {
  description = "Kompass Compute Module: The name of the Telemetry Manager controller IAM role."
  value       = module.kompass_compute.iam_telemetry_manager_role_name
}

output "kompass_compute_iam_telemetry_manager_role_arn" {
  description = "Kompass Compute Module: The ARN of the Telemetry Manager controller IAM role."
  value       = module.kompass_compute.iam_telemetry_manager_role_arn
}

output "kompass_compute_iam_telemetry_manager_role_unique_id" {
  description = "Kompass Compute Module: Stable and unique string identifying the Telemetry Manager controller IAM role."
  value       = module.kompass_compute.iam_telemetry_manager_role_unique_id
}

output "kompass_compute_iam_image_size_calculator_role_name" {
  description = "Kompass Compute Module: The name of the Image Size Calculator controller IAM role."
  value       = module.kompass_compute.iam_image_size_calculator_role_name
}

output "kompass_compute_iam_image_size_calculator_role_arn" {
  description = "Kompass Compute Module: The ARN of the Image Size Calculator controller IAM role."
  value       = module.kompass_compute.iam_image_size_calculator_role_arn
}

output "kompass_compute_iam_image_size_calculator_role_unique_id" {
  description = "Kompass Compute Module: Stable and unique string identifying the Image Size Calculator controller IAM role."
  value       = module.kompass_compute.iam_image_size_calculator_role_unique_id
}

################################################################################
# Kompass Compute Module IAM Policies
################################################################################

output "kompass_compute_iam_hiberscaler_policy_name" {
  description = "Kompass Compute Module: The name of the Hiberscaler controller IAM policy."
  value       = module.kompass_compute.iam_hiberscaler_policy_name
}

output "kompass_compute_iam_hiberscaler_policy_arn" {
  description = "Kompass Compute Module: The ARN of the Hiberscaler controller IAM policy."
  value       = module.kompass_compute.iam_hiberscaler_policy_arn
}

output "kompass_compute_iam_hiberscaler_policy_id" {
  description = "Kompass Compute Module: The Policy ID of the Hiberscaler controller IAM policy."
  value       = module.kompass_compute.iam_hiberscaler_policy_policy_id
}

output "kompass_compute_iam_snapshooter_policy_name" {
  description = "Kompass Compute Module: The name of the Snapshooter controller IAM policy."
  value       = module.kompass_compute.iam_snapshooter_policy_name
}

output "kompass_compute_iam_snapshooter_policy_arn" {
  description = "Kompass Compute Module: The ARN of the Snapshooter controller IAM policy."
  value       = module.kompass_compute.iam_snapshooter_policy_arn
}

output "kompass_compute_iam_snapshooter_policy_id" {
  description = "Kompass Compute Module: The Policy ID of the Snapshooter controller IAM policy."
  value       = module.kompass_compute.iam_snapshooter_policy_policy_id
}

output "kompass_compute_iam_image_size_calculator_policy_name" {
  description = "Kompass Compute Module: The name of the Image Size Calculator controller IAM policy."
  value       = module.kompass_compute.iam_image_size_calculator_policy_name
}

output "kompass_compute_iam_image_size_calculator_policy_arn" {
  description = "Kompass Compute Module: The ARN of the Image Size Calculator controller IAM policy."
  value       = module.kompass_compute.iam_image_size_calculator_policy_arn
}

output "kompass_compute_iam_image_size_calculator_policy_id" {
  description = "Kompass Compute Module: The Policy ID of the Image Size Calculator controller IAM policy."
  value       = module.kompass_compute.iam_image_size_calculator_policy_policy_id
}

################################################################################
# Kompass Compute Module Pod Identity
################################################################################

output "kompass_compute_namespace" {
  description = "Kompass Compute Module: Namespace associated with the Kompass Compute Pod Identity."
  value       = module.kompass_compute.namespace
}

output "kompass_compute_hiberscaler_service_account_name" {
  description = "Kompass Compute Module: Service Account for Hiberscaler Pod Identity."
  value       = module.kompass_compute.hiberscaler_service_account_name
}

output "kompass_compute_snapshooter_service_account_name" {
  description = "Kompass Compute Module: Service Account for Snapshooter Pod Identity."
  value       = module.kompass_compute.snapshooter_service_account_name
}

output "kompass_compute_telemetry_manager_service_account_name" {
  description = "Kompass Compute Module: Service Account for Telemetry Manager Pod Identity."
  value       = module.kompass_compute.telemetry_manager_service_account_name
}

output "kompass_compute_image_size_calculator_service_account_name" {
  description = "Kompass Compute Module: Service Account for Image Size Calculator Pod Identity."
  value       = module.kompass_compute.image_size_calculator_service_account_name
}

################################################################################
# Kompass Compute Module Helm Values
################################################################################

output "kompass_compute_helm_values" {
  value = module.kompass_compute.helm_values
}

output "kompass_compute_helm_values_yaml" {
  value = module.kompass_compute.helm_values_yaml
}
