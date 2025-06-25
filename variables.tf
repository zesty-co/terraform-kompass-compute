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
# Kompass Compute Hiberscaler IAM Role
################################################################################

variable "create_hiberscaler_iam_role" {
  description = "Determines whether an Hiberscaler IAM role is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_hiberscaler_role_name" {
  description = "Name of the Hiberscaler IAM role"
  type        = string
  default     = "KompassComputeHiberscaler"
  nullable    = false
}

variable "iam_hiberscaler_role_use_name_prefix" {
  description = "Determines whether the name of the Hiberscaler IAM role (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_hiberscaler_role_path" {
  description = "Path of the Hiberscaler IAM role"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_hiberscaler_role_description" {
  description = "Hiberscaler IAM role description"
  type        = string
  default     = "Zesty Kompass Computer Hiberscaler Controller IAM role"
  nullable    = false
}

variable "iam_hiberscaler_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200 for the Hiberscaler IAM role"
  type        = number
  default     = null
  nullable    = true
}

variable "iam_hiberscaler_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the Hiberscaler IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_hiberscaler_role_tags" {
  description = "A map of additional tags to add the the Hiberscaler IAM role"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "iam_hiberscaler_policy_name" {
  description = "Name of the Hiberscaler IAM policy"
  type        = string
  default     = "KompassComputeHiberscaler"
  nullable    = false
}

variable "iam_hiberscaler_policy_use_name_prefix" {
  description = "Determines whether the name of the Hiberscaler IAM policy (`iam_policy_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_hiberscaler_policy_path" {
  description = "Path of the Hiberscaler IAM policy"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_hiberscaler_policy_description" {
  description = "Hiberscaler IAM policy description"
  type        = string
  default     = "Zesty Kompass Computer Hiberscaler Controller IAM policy"
  nullable    = false
}

variable "iam_hiberscaler_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
  nullable    = false
}

variable "iam_hiberscaler_role_policies" {
  description = "Policies to attach to the Hiberscaler IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Kompass Compute Snapshooter IAM Role
################################################################################

variable "create_snapshooter_iam_role" {
  description = "Determines whether a Snapshooter IAM role is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_snapshooter_role_name" {
  description = "Name of the Snapshooter IAM role"
  type        = string
  default     = "KompassComputeSnapshooter"
  nullable    = false
}

variable "iam_snapshooter_role_use_name_prefix" {
  description = "Determines whether the name of the Snapshooter IAM role (`iam_snapshooter_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_snapshooter_role_path" {
  description = "Path of the Snapshooter IAM role"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_snapshooter_role_description" {
  description = "Snapshooter IAM role description"
  type        = string
  default     = "Zesty Kompass Computer Snapshooter Controller IAM role"
  nullable    = false
}

variable "iam_snapshooter_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200 for the Snapshooter IAM role"
  type        = number
  default     = null
  nullable    = true
}

variable "iam_snapshooter_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the Snapshooter IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_snapshooter_role_tags" {
  description = "A map of additional tags to add the the Snapshooter IAM role"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "iam_snapshooter_policy_name" {
  description = "Name of the Snapshooter IAM policy"
  type        = string
  default     = "KompassComputeSnapshooter"
  nullable    = false
}

variable "iam_snapshooter_policy_use_name_prefix" {
  description = "Determines whether the name of the Snapshooter IAM policy (`iam_snapshooter_policy_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_snapshooter_policy_path" {
  description = "Path of the Snapshooter IAM policy"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_snapshooter_policy_description" {
  description = "Snapshooter IAM policy description"
  type        = string
  default     = "Zesty Kompass Computer Snapshooter Controller IAM policy"
  nullable    = false
}

variable "iam_snapshooter_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
  nullable    = false
}

variable "iam_snapshooter_role_policies" {
  description = "Policies to attach to the Snapshooter IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Kompass Compute Telemetry Manager IAM Role
################################################################################

variable "create_telemetry_manager_iam_role" {
  description = "Determines whether a Telemetry Manager IAM role is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_telemetry_manager_role_name" {
  description = "Name of the Telemetry Manager IAM role"
  type        = string
  default     = "KompassComputeTelemetryManager"
  nullable    = false
}

variable "iam_telemetry_manager_role_use_name_prefix" {
  description = "Determines whether the name of the Telemetry Manager IAM role (`iam_telemetry_manager_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_telemetry_manager_role_path" {
  description = "Path of the Telemetry Manager IAM role"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_telemetry_manager_role_description" {
  description = "Telemetry Manager IAM role description"
  type        = string
  default     = "Zesty Kompass Computer Telemetry Manager Controller IAM role"
  nullable    = false
}

variable "iam_telemetry_manager_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200 for the Telemetry Manager IAM role"
  type        = number
  default     = null
  nullable    = true
}

variable "iam_telemetry_manager_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the Telemetry Manager IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_telemetry_manager_role_tags" {
  description = "A map of additional tags to add the the Telemetry Manager IAM role"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "iam_telemetry_manager_policy_name" {
  description = "Name of the Telemetry Manager IAM policy"
  type        = string
  default     = "KompassComputeTelemetryManager"
  nullable    = false
}

variable "iam_telemetry_manager_policy_use_name_prefix" {
  description = "Determines whether the name of the Telemetry Manager IAM policy (`iam_telemetry_manager_policy_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_telemetry_manager_policy_path" {
  description = "Path of the Telemetry Manager IAM policy"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_telemetry_manager_policy_description" {
  description = "Telemetry Manager IAM policy description"
  type        = string
  default     = "Zesty Kompass Computer Telemetry Manager Controller IAM policy"
  nullable    = false
}

variable "iam_telemetry_manager_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
  nullable    = false
}

variable "iam_telemetry_manager_role_policies" {
  description = "Policies to attach to the Telemetry Manager IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Kompass Compute Image Size Calculator IAM Role
################################################################################

variable "create_image_size_calculator_iam_role" {
  description = "Determines whether an Image Size Calculator IAM role is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_image_size_calculator_role_name" {
  description = "Name of the Image Size Calculator IAM role"
  type        = string
  default     = "KompassComputeImageSizeCalculator"
  nullable    = false
}

variable "iam_image_size_calculator_role_use_name_prefix" {
  description = "Determines whether the name of the Image Size Calculator IAM role (`iam_image_size_calculator_role_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_image_size_calculator_role_path" {
  description = "Path of the Image Size Calculator IAM role"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_image_size_calculator_role_description" {
  description = "Image Size Calculator IAM role description"
  type        = string
  default     = "Zesty Kompass Computer Image Size Calculator Controller IAM role"
  nullable    = false
}

variable "iam_image_size_calculator_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200 for the Image Size Calculator IAM role"
  type        = number
  default     = null
  nullable    = true
}

variable "iam_image_size_calculator_role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the Image Size Calculator IAM role"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_image_size_calculator_role_tags" {
  description = "A map of additional tags to add the the Image Size Calculator IAM role"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "iam_image_size_calculator_policy_name" {
  description = "Name of the Image Size Calculator IAM policy"
  type        = string
  default     = "KompassComputeImageSizeCalculator"
  nullable    = false
}

variable "iam_image_size_calculator_policy_use_name_prefix" {
  description = "Determines whether the name of the Image Size Calculator IAM policy (`iam_image_size_calculator_policy_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_image_size_calculator_policy_path" {
  description = "Path of the Image Size Calculator IAM policy"
  type        = string
  default     = "/"
  nullable    = false
}

variable "iam_image_size_calculator_policy_description" {
  description = "Image Size Calculator IAM policy description"
  type        = string
  default     = "Zesty Kompass Computer Image Size Calculator Controller IAM policy"
  nullable    = false
}

variable "iam_image_size_calculator_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
  nullable    = false
}

variable "iam_image_size_calculator_role_policies" {
  description = "Policies to attach to the Image Size Calculator IAM role in `{'static_name' = 'policy_arn'}` format"
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

variable "irsa_hiberscaler_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["zesty-system:kompass-compute-hiberscaler"]
  nullable    = false
}

variable "irsa_snapshooter_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["zesty-system:kompass-compute-snapshooter"]
  nullable    = false
}

variable "irsa_telemetry_manager_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["zesty-system:kompass-compute-telemetry-manager"]
  nullable    = false
}

variable "irsa_image_size_calculator_namespace_service_accounts" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["zesty-system:kompass-compute-image-size-calculator"]
  nullable    = false
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
  description = "Namespace to associate with the Hiberscaler Pod Identity"
  type        = string
  default     = "zesty-system"
  nullable    = false
}

variable "hiberscaler_service_account_name" {
  description = "Service account to associate with the Hiberscaler Pod Identity"
  type        = string
  default     = "kompass-compute-hiberscaler"
  nullable    = false
}

variable "snapshooter_service_account_name" {
  description = "Service account to associate with the Snapshooter Pod Identity"
  type        = string
  default     = "kompass-compute-snapshooter"
  nullable    = false
}

variable "telemetry_manager_service_account_name" {
  description = "Service account to associate with the Telemetry Manager Pod Identity"
  type        = string
  default     = "kompass-compute-telemetry-manager"
  nullable    = false
}

variable "image_size_calculator_service_account_name" {
  description = "Service account to associate with the Image Size Calculator Pod Identity"
  type        = string
  default     = "kompass-compute-image-size-calculator"
  nullable    = false
}

################################################################################
# Node Termination Queue
################################################################################

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = true
  nullable    = false
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
  nullable    = true
}

variable "queue_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  type        = bool
  default     = true
  nullable    = false
}

variable "queue_kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
  nullable    = true
}

variable "queue_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again"
  type        = number
  default     = null
  nullable    = true
}

################################################################################
# Event Bridge Rules
################################################################################

variable "rule_name_prefix" {
  description = "Prefix used for all event bridge rules"
  type        = string
  default     = "ZestyKompassCompute"
  nullable    = false
}

################################################################################
# S3 VPC Endpoint
################################################################################

variable "create_s3_vpc_endpoint" {
  description = "Determines whether S3 VPC Endpoint will be created"
  type        = bool
  default     = true
  nullable    = false
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.create || !var.create_s3_vpc_endpoint || var.vpc_id != null
    error_message = "`vpc_id` must be provided when `create` is true and `create_s3_vpc_endpoints` is true."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the S3 VPC Endpoint"
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = !var.create || !var.create_s3_vpc_endpoint || length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided for `subnet_ids`."
  }
}

variable "vpc_endpoint_policy" {
  description = "Policy to attach to the S3 VPC Endpoint"
  type        = string
  default     = null
  nullable    = true
}

variable "vpc_endpoint_private_dns_enabled" {
  description = "Determines whether private DNS is enabled for the S3 VPC Endpoint"
  type        = bool
  default     = false
  nullable    = false
}

variable "vpc_endpoint_ip_address_type" {
  description = "IP address type for the S3 VPC Endpoint"
  type        = string
  default     = "ipv4"
  nullable    = false

  validation {
    condition     = !var.create || !var.create_s3_vpc_endpoint || contains(["ipv4", "dualstack", "ipv6"], var.vpc_endpoint_ip_address_type)
    error_message = "`ip_address_type` must be either 'ipv4', 'dualstack', or 'ipv6' when `create` is true and `create_s3_vpc_endpoints` is true."
  }
}

variable "vpc_endpoint_security_group_ids" {
  description = "Default security group IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "vpc_endpoint_dns_options" {
  description = "DNS options for the S3 VPC Endpoint"
  type = object({
    dns_record_ip_type                             = optional(string, null)
    private_dns_only_for_inbound_resolver_endpoint = optional(bool, null)
  })
  default  = {}
  nullable = false
}

variable "vpc_endpoint_timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
  type = object({
    create = optional(string, "10m")
    update = optional(string, "10m")
    delete = optional(string, "10m")
  })
  default  = {}
  nullable = false
}

variable "vpc_endpoint_tags" {
  description = "A map of additional tags to add to the S3 VPC Endpoint"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Security Group
################################################################################

variable "create_s3_vpc_endpoint_security_group" {
  description = "Determines if a S3 VPC Endpoint security group is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "vpc_endpoint_security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = "zesty-kompass-compute-s3-vpc-endpoint"
  nullable    = false
}

variable "vpc_endpoint_security_group_use_name_prefix" {
  description = "Determines whether the name of the security group (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "vpc_endpoint_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Zesty Kompass Compute S3 VPC Endpoint Security Group"
  nullable    = false
}

variable "vpc_endpoint_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type = map(object({
    description              = optional(string, null)
    protocol                 = optional(string, "tcp")
    from_port                = optional(number, 443)
    to_port                  = optional(number, 443)
    type                     = optional(string, "ingress")
    cidr_blocks              = optional(list(string), null)
    ipv6_cidr_blocks         = optional(list(string), null)
    prefix_list_ids          = optional(list(string), null)
    self                     = optional(bool, null)
    source_security_group_id = optional(string, null)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = !var.create || !var.create_s3_vpc_endpoint || !var.create_s3_vpc_endpoint_security_group || length(var.vpc_endpoint_security_group_rules) > 0
    error_message = "At least one security group rule must be provided for `security_group_rules`."
  }
}

variable "vpc_endpoint_security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
  nullable    = false
}
