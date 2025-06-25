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
