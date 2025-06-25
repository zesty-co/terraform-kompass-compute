variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = true
}

################################################################################
# The ECR Pull Through Cache Rule Names
################################################################################

variable "ecr_pull_through_rule_name_prefix" {
  description = "Prefix for the ECR Pull Through Cache Rule name (e.g., 'myorg-'). The registry key will be appended (e.g., 'myorg-dockerhub')."
  type        = string
  default     = "zesty-"
  nullable    = false
}

################################################################################
# ECR Pull Through Cache Secrets
################################################################################

variable "secret_name_prefix" {
  description = "Prefix for the Secret name (e.g., 'ecr-pullthroughcache/myorg-'). The registry key will be appended (e.g., 'ecr-pullthroughcache/myorg-dockerhub-')."
  type        = string
  default     = "ecr-pullthroughcache/zesty-"
  nullable    = false
}

variable "secret_recovery_window_in_days" {
  description = "Recovery window in days for the secret"
  type        = number
  default     = 30
  nullable    = false
}

################################################################################
# ECR Registry Configurations
################################################################################

variable "registries" {
  description = "A map of configurations for ECR pull-through cache rules and their associated secrets. The map key (e.g., 'dockerhub', 'ghcr') is used in naming resources and outputs."
  type = map(object({
    # Whether to create the pull-through rule for this registry.
    create = optional(bool, true)

    # The URL of the upstream registry (e.g., "registry-1.docker.io", "ghcr.io").
    upstream_registry_url = optional(string, null)

    # Optional: Override for the ECR repository prefix. If null, uses var.ecr_pull_through_rule_name_prefix + key.
    ecr_repository_prefix_override = optional(string, null)

    # Secret configuration:
    # - If 'secret_arn' is provided, it will be used.
    # - If 'secret_content' is provided (and 'secret_arn' is not), a new secret will be created.
    # - If neither is provided, the rule will be created without credentials (for public registries).
    secret_arn     = optional(string, null)
    secret_content = optional(string, null)

    # Optional: Override for the secret name prefix. If null, uses var.secret_name_prefix + key + "-".
    secret_name_prefix_override = optional(string, null)
  }))

  # By default, all registries are created with sensible defaults.
  # - ecr -> public.ecr.aws
  # - k8s -> registry.k8s.io
  # - quay -> quay.io
  # - dockerhub -> registry-1.docker.io
  # - ghcr -> ghcr.io
  default = {}

  # Mark the entire variable as sensitive to protect secret_content
  sensitive = true

  validation {
    # Ensure that for each registry, secret_arn and secret_content are not both provided with non-null/non-empty values.
    condition = alltrue([
      for k, v in var.registries :
      !(v.secret_arn != null && v.secret_content != null)
    ])
    error_message = "For each registry, 'secret_arn' and 'secret_content' are mutually exclusive. Please provide only one or neither."
  }

  validation {
    # Ensure upstream_registry_url is not empty when create is true
    condition = alltrue([
      for k, v in var.registries :
      !v.create || (v.create && v.upstream_registry_url != "")
    ])
    error_message = "When create is true, upstream_registry_url must not be empty."
  }
}
