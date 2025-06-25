variable "create" {
  description = "Create Kompass Compute resources"
  type        = bool
  default     = true
  nullable    = false
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
  nullable    = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = true
}

################################################################################
# Kompass Compute IAM Role
################################################################################

variable "iam_role_name" {
  description = "Name of the Kompass Compute IAM role"
  type        = string
  default     = "KompassCompute"
  nullable    = false
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the name of the Kompass Compute IAM role (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_path" {
  description = "Path of the Kompass Compute IAM role"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_role_description" {
  description = "Kompass Compute IAM role description"
  type        = string
  default     = "Zesty Kompass Computer Controller IAM role"
  nullable    = false
}

variable "iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200 for the Kompass Compute IAM role"
  type        = number
  default     = null
  nullable    = true
}

variable "iam_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the Kompass Compute IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role_tags" {
  description = "A map of additional tags to add the the Kompass Compute IAM role"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "iam_policy_name" {
  description = "Name of the Kompass Compute IAM policy"
  type        = string
  default     = "KompassCompute"
  nullable    = false
}

variable "iam_policy_use_name_prefix" {
  description = "Determines whether the name of the Kompass Compute IAM policy (`iam_policy_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_policy_path" {
  description = "Path of the Kompass Compute IAM policy"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_policy_description" {
  description = "Kompass Compute IAM policy description"
  type        = string
  default     = "Zesty Kompass Computer Controller IAM policy"
  nullable    = false
}

variable "iam_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
  nullable    = false
}

variable "iam_use_hiberscaler_policy" {
  description = "Determines whether to use the default Hiberscaler IAM policy"
  type        = bool
  default     = false
  nullable    = false
}

variable "iam_use_snapshooter_policy" {
  description = "Determines whether to use the default Snapshooter IAM policy"
  type        = bool
  default     = false
  nullable    = false
}

variable "iam_use_telemetry_manager_policy" {
  description = "Determines whether to use the default Telemetry Manager IAM policy"
  type        = bool
  default     = false
  nullable    = false
}

variable "iam_use_image_size_calculator_policy" {
  description = "Determines whether to use the default ImageSizeCalculator IAM policy"
  type        = bool
  default     = false
  nullable    = false
}

variable "iam_role_policies" {
  description = "Policies to attach to the Kompass Compute IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

variable "enable_irsa" {
  description = "Determines whether to enable support for IAM roles for service accounts"
  type        = bool
  default     = false
  nullable    = false
}

variable "irsa_oidc_provider_arn" {
  description = "OIDC provider arn used in trust policy for IAM roles for service accounts"
  type        = string
  default     = ""
  nullable    = false
}

variable "irsa_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["zesty-system:"]
  nullable    = false

  validation {
    condition     = !var.create || !var.enable_irsa || alltrue([for ns in var.irsa_namespace_service_accounts : length(ns) > 0])
    error_message = "Namespace:ServiceAccount pairs must be provided"
  }

  validation {
    condition     = !var.create || !var.enable_irsa || alltrue([for ns in var.irsa_namespace_service_accounts : strcontains(ns, ":")])
    error_message = "Namespace:ServiceAccount pairs must be in the format 'namespace:serviceaccount'"
  }

  validation {
    condition     = !var.create || !var.enable_irsa || alltrue([for ns in var.irsa_namespace_service_accounts : length(split(":", ns)) == 2])
    error_message = "Namespace:ServiceAccount pairs must be in the format 'namespace:serviceaccount'"
  }

  validation {
    condition     = !var.create || !var.enable_irsa || alltrue([for ns in var.irsa_namespace_service_accounts : length(split(":", ns)[0]) > 0])
    error_message = "Namespace must be provided"
  }

  validation {
    condition     = !var.create || !var.enable_irsa || alltrue([for ns in var.irsa_namespace_service_accounts : length(split(":", ns)[1]) > 0])
    error_message = "ServiceAccount must be provided"
  }
}

variable "irsa_assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
  nullable    = false
}

################################################################################
# Pod Identity Association
################################################################################

variable "enable_pod_identity" {
  description = "Determines whether to enable support for EKS pod identity"
  type        = bool
  default     = true
  nullable    = false
}

variable "create_pod_identity_association" {
  description = "Determines whether to create pod identity association"
  type        = bool
  default     = true
  nullable    = false
}

variable "namespace" {
  description = "Namespace to associate with the Kompass Compute Pod Identity"
  type        = string
  default     = "zesty-system"
  nullable    = false

  validation {
    condition     = length(var.namespace) > 0
    error_message = "Namespace name must be provided"
  }
}

variable "service_account_name" {
  description = "Service account to associate with the Kompass Compute Pod Identity"
  type        = string
  default     = "" # TODO: To change
  nullable    = false

  validation {
    condition     = length(var.service_account_name) > 0
    error_message = "Service account name must be provided"
  }
}

################################################################################
# SQS Queue
################################################################################

variable "sqs_queue_name" {
  description = "Name of the SQS queue to use for Kompass Compute"
  type        = string
  default     = null
  nullable    = true
}
