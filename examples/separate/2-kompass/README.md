<!-- BEGIN_TF_DOCS -->
# Kompass Compute Deployment Example

This example demonstrates how to deploy the Zesty Kompass Compute service on an Amazon EKS cluster
using Terraform. It requires the ECR Pull-Through Cache Rules to be created for Docker Hub and GitHub Container Registry.

## Prerequisites

- An existing EKS cluster
- A VPC with subnets
- Zesty Kompass Infra installed in the EKS cluster

## Configuration

The example uses the following variables:

- `cluster_name`: The name of the EKS cluster.
- `vpc_id`: The ID of the VPC where the EKS cluster is deployed.
- `subnet_ids`: A list of subnet IDs where S3 VPC endpoints will be created.
- `vpc_endpoints_ingress_cidr_block`: The CIDR block for ingress traffic to the VPC endpoints.
- `helm_values_yaml`: Additional Helm values to customize the deployment.

## ECR Pull-Through Cache Rules

Before deploying Kompass Compute, ensure that the ECR Pull-Through Cache Rules for Docker Hub and GitHub Container Registry are created.

Kompass Compute requires information from the ECR module. The output can be accessed using the `terraform_remote_state`
data source like, or it can be generated directly in the module.

Check the [ECR module documentation](../../../modules/ecr/README.md) for more details on how to use this variable.

## Provider Configuration

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kompass_compute"></a> [kompass\_compute](#module\_kompass\_compute) | ../../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.kompass_compute](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_helm_values_yaml"></a> [helm\_values\_yaml](#input\_helm\_values\_yaml) | YAML configuration for Helm values | `string` | `"{}"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to associate with the S3 VPC Endpoint | `list(string)` | n/a | yes |
| <a name="input_vpc_endpoints_ingress_cidr_block"></a> [vpc\_endpoints\_ingress\_cidr\_block](#input\_vpc\_endpoints\_ingress\_cidr\_block) | CIDR block for ingress rules on the VPC Endpoint security group | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the EKS cluster is deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
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