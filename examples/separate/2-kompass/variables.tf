variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  nullable    = false
}

variable "helm_values_yaml" {
  description = "YAML configuration for Helm values"
  type        = string
  default     = "{}"
  nullable    = false
}
