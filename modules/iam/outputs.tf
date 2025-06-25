################################################################################
# Kompass Compute controller IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the controller IAM role"
  value       = try(aws_iam_role.controller[0].name, null)
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the controller IAM role"
  value       = try(aws_iam_role.controller[0].arn, null)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the controller IAM role"
  value       = try(aws_iam_role.controller[0].unique_id, null)
}

################################################################################
# Policy
################################################################################

output "iam_policy_name" {
  description = "The name of the controller IAM policy"
  value       = try(aws_iam_policy.controller[0].name, null)
}

output "iam_policy_arn" {
  description = "The Amazon Resource Name (ARN) specifying the controller IAM policy"
  value       = try(aws_iam_policy.controller[0].arn, null)
}

output "iam_policy_policy_id" {
  description = "The Policy ID of the controller IAM policy"
  value       = try(aws_iam_policy.controller[0].policy_id, null)
}

################################################################################
# Pod Identity
################################################################################

output "namespace" {
  description = "Namespace associated with the Kompass Compute Pod Identity"
  value       = var.namespace
}

output "service_account_name" {
  description = "Service Account associated with the Kompass Compute Pod Identity"
  value       = var.service_account_name
}
