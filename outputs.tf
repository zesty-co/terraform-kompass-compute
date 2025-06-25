################################################################################
# Kompass Compute controller IAM Roles
################################################################################

output "iam_hiberscaler_role_name" {
  description = "The name of the Hiberscaler controller IAM role"
  value       = module.iam_hiberscaler.iam_role_name
}

output "iam_hiberscaler_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Hiberscaler controller IAM role"
  value       = module.iam_hiberscaler.iam_role_arn
}

output "iam_hiberscaler_role_unique_id" {
  description = "Stable and unique string identifying the Hiberscaler controller IAM role"
  value       = module.iam_hiberscaler.iam_role_unique_id
}

################################################################################
# Snapshooter controller IAM Role
################################################################################

output "iam_snapshooter_role_name" {
  description = "The name of the Snapshooter controller IAM role"
  value       = module.iam_snapshooter.iam_role_name
}

output "iam_snapshooter_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Snapshooter controller IAM role"
  value       = module.iam_snapshooter.iam_role_arn
}

output "iam_snapshooter_role_unique_id" {
  description = "Stable and unique string identifying the Snapshooter controller IAM role"
  value       = module.iam_snapshooter.iam_role_unique_id
}

################################################################################
# Telemetry Manager controller IAM Role
################################################################################

output "iam_telemetry_manager_role_name" {
  description = "The name of the Telemetry Manager controller IAM role"
  value       = module.iam_telemetry_manager.iam_role_name
}

output "iam_telemetry_manager_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Telemetry Manager controller IAM role"
  value       = module.iam_telemetry_manager.iam_role_arn
}

output "iam_telemetry_manager_role_unique_id" {
  description = "Stable and unique string identifying the Telemetry Manager controller IAM role"
  value       = module.iam_telemetry_manager.iam_role_unique_id
}

################################################################################
# Image Size Calculator controller IAM Role
################################################################################

output "iam_image_size_calculator_role_name" {
  description = "The name of the Image Size Calculator controller IAM role"
  value       = module.iam_image_size_calculator.iam_role_name
}

output "iam_image_size_calculator_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Image Size Calculator controller IAM role"
  value       = module.iam_image_size_calculator.iam_role_arn
}

output "iam_image_size_calculator_role_unique_id" {
  description = "Stable and unique string identifying the Image Size Calculator controller IAM role"
  value       = module.iam_image_size_calculator.iam_role_unique_id
}

################################################################################
# Hiberscaler Policy
################################################################################

output "iam_hiberscaler_policy_name" {
  description = "The name of the Hiberscaler controller IAM policy"
  value       = module.iam_hiberscaler.iam_policy_name
}

output "iam_hiberscaler_policy_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Hiberscaler controller IAM policy"
  value       = module.iam_hiberscaler.iam_role_arn
}

output "iam_hiberscaler_policy_policy_id" {
  description = "The Policy ID of the Hiberscaler controller IAM policy"
  value       = module.iam_hiberscaler.iam_policy_policy_id
}

################################################################################
# Snapshooter Policy
################################################################################

output "iam_snapshooter_policy_name" {
  description = "The name of the Snapshooter controller IAM policy"
  value       = module.iam_snapshooter.iam_policy_name
}

output "iam_snapshooter_policy_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Snapshooter controller IAM policy"
  value       = module.iam_snapshooter.iam_policy_arn
}

output "iam_snapshooter_policy_policy_id" {
  description = "The Policy ID of the Snapshooter controller IAM policy"
  value       = module.iam_snapshooter.iam_policy_policy_id
}

################################################################################
# Image Size Calculator Policy
################################################################################

output "iam_image_size_calculator_policy_name" {
  description = "The name of the Image Size Calculator controller IAM policy"
  value       = module.iam_image_size_calculator.iam_policy_name
}

output "iam_image_size_calculator_policy_arn" {
  description = "The Amazon Resource Name (ARN) specifying the Image Size Calculator controller IAM policy"
  value       = module.iam_image_size_calculator.iam_policy_arn
}

output "iam_image_size_calculator_policy_policy_id" {
  description = "The Policy ID of the Image Size Calculator controller IAM policy"
  value       = module.iam_image_size_calculator.iam_policy_policy_id
}

################################################################################
# Pod Identity
################################################################################

output "namespace" {
  description = "Namespace associated with the Kompass Compute Pod Identity"
  value       = var.namespace
}

output "hiberscaler_service_account_name" {
  description = "Service Account associated with the Kompass Compute Hiberscaler Pod Identity"
  value       = module.iam_hiberscaler.service_account_name
}

output "snapshooter_service_account_name" {
  description = "Service Account associated with the Kompass Compute Snapshooter Pod Identity"
  value       = module.iam_snapshooter.service_account_name
}

output "telemetry_manager_service_account_name" {
  description = "Service Account associated with the Kompass Compute Telemetry Manager Pod Identity"
  value       = module.iam_telemetry_manager.service_account_name
}

output "image_size_calculator_service_account_name" {
  description = "Service Account associated with the Kompass Compute Image Size Calculator Pod Identity"
  value       = module.iam_image_size_calculator.service_account_name
}

################################################################################
# Node Termination Queue
################################################################################

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = try(aws_sqs_queue.this[0].arn, null)
}

output "queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = try(aws_sqs_queue.this[0].name, null)
}

output "queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = try(aws_sqs_queue.this[0].url, null)
}

################################################################################
# Node Termination Event Rules
################################################################################

output "event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = aws_cloudwatch_event_rule.this
}

################################################################################
# S3 VPC Endpoint
################################################################################

output "vpc_endpoint" {
  description = "Full resource object and attributes for the S3 VPC endpoint created"
  value       = try(aws_vpc_endpoint.this[0], null)
}

output "vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.this[0].id, null)
}

output "vpc_endpoint_arn" {
  description = "Amazon Resource Name (ARN) of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.this[0].arn, null)
}

output "vpc_endpoint_network_interface_ids" {
  description = "Network interface IDs of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.this[0].network_interface_ids, null)
}

output "vpc_endpoint_network_interface_ipv4" {
  description = "IPv4 addresses of the network interfaces for the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.this[0].subnet_configuration[*].ipv4, null)
}

output "vpc_endpoint_network_interface_ipv6" {
  description = "IPv6 addresses of the network interfaces for the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.this[0].subnet_configuration[*].ipv6, null)
}

################################################################################
# Security Group
################################################################################

output "vpc_endpoint_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

################################################################################
# Helm Chart values
################################################################################
locals {
  helm_values_irsa = var.enable_irsa ? {
    hiberscaler = {
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.iam_hiberscaler.iam_role_arn
        }
      }
    }
    imageSizeCalculator = {
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.iam_image_size_calculator.iam_role_arn
        }
      }
    }
    snapshooter = {
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.iam_snapshooter.iam_role_arn
        }
      }
    }
    telemetryManager = {
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.iam_telemetry_manager.iam_role_arn
        }
      }
    }
  } : {}
  helm_values_infra = {
    qubexConfig = {
      infraConfig = {
        aws = {
          spotFailuresQueueUrl = try(aws_sqs_queue.this[0].url, null)
          s3VpcEndpointID      = try(aws_vpc_endpoint.this[0].id, null)
        }
      }
    }
  }
  helm_values = merge(
    local.helm_values_irsa,
    local.helm_values_infra,
  )
}

output "helm_values" {
  description = "Map of Helm chart values for ECR pull through cache"
  value       = local.helm_values
}

output "helm_values_yaml" {
  description = "YAML encoded Helm chart values for ECR pull through cache"
  value       = yamlencode(local.helm_values)
}
