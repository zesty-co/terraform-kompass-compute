variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  nullable    = false
}

variable "dockerhub_secret_arn" {
  description = "ARN of the Docker Hub secret in AWS Secrets Manager"
  type        = string
  nullable    = false
}

variable "ghcr_secret_arn" {
  description = "ARN of the GitHub Container Registry secret in AWS Secrets Manager"
  type        = string
  nullable    = false
}

variable "helm_values_yaml" {
  description = "YAML configuration for Helm values"
  type        = string
  default     = "{}"
  nullable    = false
}
