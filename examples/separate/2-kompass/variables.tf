variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  nullable    = false
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster is deployed"
  type        = string
  nullable    = false
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the S3 VPC Endpoint"
  type        = list(string)
  nullable    = false
}

variable "vpc_endpoints_ingress_cidr_block" {
  description = "CIDR block for ingress rules on the VPC Endpoint security group"
  type        = string
  nullable    = false
}

variable "helm_values_yaml" {
  description = "YAML configuration for Helm values"
  type        = string
  default     = "{}"
  nullable    = false
}
