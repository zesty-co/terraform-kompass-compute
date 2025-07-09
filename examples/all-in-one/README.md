<!-- BEGIN_TF_DOCS -->
# All-in-One Example

This example demonstrates how to deploy the Kompass Compute service on an EKS cluster
using Terraform. It includes the creation of ECR pull-through cache rules, IAM roles, SQS queues,
and the deployment of the Kompass Compute Helm chart.

Note: It is recommended to deploy `ecr` module only once per region.
ECR pull-through cache rules are regional resources, and creating them multiple times
is not necessary and may lead to conflicts.

## Prerequisites

- Docker and GitHub Container Registry credentials stored in AWS Secrets Manager
- An existing EKS cluster
- A VPC with subnets
- Zesty Kompass Insight installed in the EKS cluster

## Configuration

The example uses the following variables:

- `cluster_name`: The name of the EKS cluster.
- `vpc_id`: The ID of the VPC where the EKS cluster is deployed.
- `subnet_ids`: A list of subnet IDs where S3 VPC endpoints will be created.
- `vpc_endpoints_ingress_cidr_block`: The CIDR block for ingress traffic to the VPC endpoints.
- `dockerhub_secret_arn`: The ARN of the AWS Secrets Manager secret for Docker Hub credentials.
- `ghcr_secret_arn`: The ARN of the AWS Secrets Manager secret for GitHub Container Registry credentials.
- `helm_values_yaml`: Additional Helm values to customize the deployment.

## Image registry secrets

The example uses existing AWS Secrets Manager secrets for Docker Hub and GitHub Container Registry credentials.
These secrets are used to authenticate with the respective registries when pulling images.
The secrets should be created in the format expected by the ECR pull-through cache rules.

Check the [ECR module documentation](../../modules/ecr/README.md) for more details on how to create these secrets.

## Provider Configuration

For Helm provider version 3 and above:

```hcl
provider "aws" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}
```

For Helm provider version 2:

```hcl
provider "aws" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/ecr | n/a |
| <a name="module_kompass_compute"></a> [kompass\_compute](#module\_kompass\_compute) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.kompass_compute](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_dockerhub_secret_arn"></a> [dockerhub\_secret\_arn](#input\_dockerhub\_secret\_arn) | ARN of the Docker Hub secret in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_ghcr_secret_arn"></a> [ghcr\_secret\_arn](#input\_ghcr\_secret\_arn) | ARN of the GitHub Container Registry secret in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_helm_values_yaml"></a> [helm\_values\_yaml](#input\_helm\_values\_yaml) | YAML configuration for Helm values | `string` | `"{}"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to associate with the S3 VPC Endpoint | `list(string)` | n/a | yes |
| <a name="input_vpc_endpoints_ingress_cidr_block"></a> [vpc\_endpoints\_ingress\_cidr\_block](#input\_vpc\_endpoints\_ingress\_cidr\_block) | CIDR block for ingress rules on the VPC Endpoint security group | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the EKS cluster is deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_helm_values"></a> [ecr\_helm\_values](#output\_ecr\_helm\_values) | ECR Module: Map of Helm chart values for ECR pull through cache. |
| <a name="output_ecr_helm_values_yaml"></a> [ecr\_helm\_values\_yaml](#output\_ecr\_helm\_values\_yaml) | ECR Module: YAML encoded Helm chart values for ECR pull through cache. |
| <a name="output_ecr_pull_through_cache_rule_ids"></a> [ecr\_pull\_through\_cache\_rule\_ids](#output\_ecr\_pull\_through\_cache\_rule\_ids) | ECR Module: Map of created ECR pull through cache rule IDs. |
| <a name="output_ecr_pull_through_cache_rule_prefixes"></a> [ecr\_pull\_through\_cache\_rule\_prefixes](#output\_ecr\_pull\_through\_cache\_rule\_prefixes) | ECR Module: Map of ECR pull through cache rule prefixes. |
| <a name="output_ecr_pull_through_cache_rules"></a> [ecr\_pull\_through\_cache\_rules](#output\_ecr\_pull\_through\_cache\_rules) | ECR Module: Map of created ECR pull through cache rules. |
| <a name="output_ecr_secret_arns"></a> [ecr\_secret\_arns](#output\_ecr\_secret\_arns) | ECR Module: Map of created ECR pull through cache secret ARNs. |
| <a name="output_ecr_secret_version_arns"></a> [ecr\_secret\_version\_arns](#output\_ecr\_secret\_version\_arns) | ECR Module: Map of created ECR pull through cache secret version ARNs. |
| <a name="output_ecr_secret_version_ids"></a> [ecr\_secret\_version\_ids](#output\_ecr\_secret\_version\_ids) | ECR Module: Map of created ECR pull through cache secret version IDs. |
| <a name="output_ecr_secrets"></a> [ecr\_secrets](#output\_ecr\_secrets) | ECR Module: Map of created ECR pull through cache secrets. |
| <a name="output_kompass_compute_helm_values"></a> [kompass\_compute\_helm\_values](#output\_kompass\_compute\_helm\_values) | n/a |
| <a name="output_kompass_compute_helm_values_yaml"></a> [kompass\_compute\_helm\_values\_yaml](#output\_kompass\_compute\_helm\_values\_yaml) | n/a |
| <a name="output_kompass_compute_hiberscaler_service_account_name"></a> [kompass\_compute\_hiberscaler\_service\_account\_name](#output\_kompass\_compute\_hiberscaler\_service\_account\_name) | Kompass Compute Module: Service Account for Hiberscaler Pod Identity. |
| <a name="output_kompass_compute_iam_hiberscaler_policy_arn"></a> [kompass\_compute\_iam\_hiberscaler\_policy\_arn](#output\_kompass\_compute\_iam\_hiberscaler\_policy\_arn) | Kompass Compute Module: The ARN of the Hiberscaler controller IAM policy. |
| <a name="output_kompass_compute_iam_hiberscaler_policy_id"></a> [kompass\_compute\_iam\_hiberscaler\_policy\_id](#output\_kompass\_compute\_iam\_hiberscaler\_policy\_id) | Kompass Compute Module: The Policy ID of the Hiberscaler controller IAM policy. |
| <a name="output_kompass_compute_iam_hiberscaler_policy_name"></a> [kompass\_compute\_iam\_hiberscaler\_policy\_name](#output\_kompass\_compute\_iam\_hiberscaler\_policy\_name) | Kompass Compute Module: The name of the Hiberscaler controller IAM policy. |
| <a name="output_kompass_compute_iam_hiberscaler_role_arn"></a> [kompass\_compute\_iam\_hiberscaler\_role\_arn](#output\_kompass\_compute\_iam\_hiberscaler\_role\_arn) | Kompass Compute Module: The ARN of the Hiberscaler controller IAM role. |
| <a name="output_kompass_compute_iam_hiberscaler_role_name"></a> [kompass\_compute\_iam\_hiberscaler\_role\_name](#output\_kompass\_compute\_iam\_hiberscaler\_role\_name) | Kompass Compute Module: The name of the Hiberscaler controller IAM role. |
| <a name="output_kompass_compute_iam_hiberscaler_role_unique_id"></a> [kompass\_compute\_iam\_hiberscaler\_role\_unique\_id](#output\_kompass\_compute\_iam\_hiberscaler\_role\_unique\_id) | Kompass Compute Module: Stable and unique string identifying the Hiberscaler controller IAM role. |
| <a name="output_kompass_compute_iam_image_size_calculator_policy_arn"></a> [kompass\_compute\_iam\_image\_size\_calculator\_policy\_arn](#output\_kompass\_compute\_iam\_image\_size\_calculator\_policy\_arn) | Kompass Compute Module: The ARN of the Image Size Calculator controller IAM policy. |
| <a name="output_kompass_compute_iam_image_size_calculator_policy_id"></a> [kompass\_compute\_iam\_image\_size\_calculator\_policy\_id](#output\_kompass\_compute\_iam\_image\_size\_calculator\_policy\_id) | Kompass Compute Module: The Policy ID of the Image Size Calculator controller IAM policy. |
| <a name="output_kompass_compute_iam_image_size_calculator_policy_name"></a> [kompass\_compute\_iam\_image\_size\_calculator\_policy\_name](#output\_kompass\_compute\_iam\_image\_size\_calculator\_policy\_name) | Kompass Compute Module: The name of the Image Size Calculator controller IAM policy. |
| <a name="output_kompass_compute_iam_image_size_calculator_role_arn"></a> [kompass\_compute\_iam\_image\_size\_calculator\_role\_arn](#output\_kompass\_compute\_iam\_image\_size\_calculator\_role\_arn) | Kompass Compute Module: The ARN of the Image Size Calculator controller IAM role. |
| <a name="output_kompass_compute_iam_image_size_calculator_role_name"></a> [kompass\_compute\_iam\_image\_size\_calculator\_role\_name](#output\_kompass\_compute\_iam\_image\_size\_calculator\_role\_name) | Kompass Compute Module: The name of the Image Size Calculator controller IAM role. |
| <a name="output_kompass_compute_iam_image_size_calculator_role_unique_id"></a> [kompass\_compute\_iam\_image\_size\_calculator\_role\_unique\_id](#output\_kompass\_compute\_iam\_image\_size\_calculator\_role\_unique\_id) | Kompass Compute Module: Stable and unique string identifying the Image Size Calculator controller IAM role. |
| <a name="output_kompass_compute_iam_snapshooter_policy_arn"></a> [kompass\_compute\_iam\_snapshooter\_policy\_arn](#output\_kompass\_compute\_iam\_snapshooter\_policy\_arn) | Kompass Compute Module: The ARN of the Snapshooter controller IAM policy. |
| <a name="output_kompass_compute_iam_snapshooter_policy_id"></a> [kompass\_compute\_iam\_snapshooter\_policy\_id](#output\_kompass\_compute\_iam\_snapshooter\_policy\_id) | Kompass Compute Module: The Policy ID of the Snapshooter controller IAM policy. |
| <a name="output_kompass_compute_iam_snapshooter_policy_name"></a> [kompass\_compute\_iam\_snapshooter\_policy\_name](#output\_kompass\_compute\_iam\_snapshooter\_policy\_name) | Kompass Compute Module: The name of the Snapshooter controller IAM policy. |
| <a name="output_kompass_compute_iam_snapshooter_role_arn"></a> [kompass\_compute\_iam\_snapshooter\_role\_arn](#output\_kompass\_compute\_iam\_snapshooter\_role\_arn) | Kompass Compute Module: The ARN of the Snapshooter controller IAM role. |
| <a name="output_kompass_compute_iam_snapshooter_role_name"></a> [kompass\_compute\_iam\_snapshooter\_role\_name](#output\_kompass\_compute\_iam\_snapshooter\_role\_name) | Kompass Compute Module: The name of the Snapshooter controller IAM role. |
| <a name="output_kompass_compute_iam_snapshooter_role_unique_id"></a> [kompass\_compute\_iam\_snapshooter\_role\_unique\_id](#output\_kompass\_compute\_iam\_snapshooter\_role\_unique\_id) | Kompass Compute Module: Stable and unique string identifying the Snapshooter controller IAM role. |
| <a name="output_kompass_compute_iam_telemetry_manager_role_arn"></a> [kompass\_compute\_iam\_telemetry\_manager\_role\_arn](#output\_kompass\_compute\_iam\_telemetry\_manager\_role\_arn) | Kompass Compute Module: The ARN of the Telemetry Manager controller IAM role. |
| <a name="output_kompass_compute_iam_telemetry_manager_role_name"></a> [kompass\_compute\_iam\_telemetry\_manager\_role\_name](#output\_kompass\_compute\_iam\_telemetry\_manager\_role\_name) | Kompass Compute Module: The name of the Telemetry Manager controller IAM role. |
| <a name="output_kompass_compute_iam_telemetry_manager_role_unique_id"></a> [kompass\_compute\_iam\_telemetry\_manager\_role\_unique\_id](#output\_kompass\_compute\_iam\_telemetry\_manager\_role\_unique\_id) | Kompass Compute Module: Stable and unique string identifying the Telemetry Manager controller IAM role. |
| <a name="output_kompass_compute_image_size_calculator_service_account_name"></a> [kompass\_compute\_image\_size\_calculator\_service\_account\_name](#output\_kompass\_compute\_image\_size\_calculator\_service\_account\_name) | Kompass Compute Module: Service Account for Image Size Calculator Pod Identity. |
| <a name="output_kompass_compute_namespace"></a> [kompass\_compute\_namespace](#output\_kompass\_compute\_namespace) | Kompass Compute Module: Namespace associated with the Kompass Compute Pod Identity. |
| <a name="output_kompass_compute_snapshooter_service_account_name"></a> [kompass\_compute\_snapshooter\_service\_account\_name](#output\_kompass\_compute\_snapshooter\_service\_account\_name) | Kompass Compute Module: Service Account for Snapshooter Pod Identity. |
| <a name="output_kompass_compute_telemetry_manager_service_account_name"></a> [kompass\_compute\_telemetry\_manager\_service\_account\_name](#output\_kompass\_compute\_telemetry\_manager\_service\_account\_name) | Kompass Compute Module: Service Account for Telemetry Manager Pod Identity. |
<!-- END_TF_DOCS -->