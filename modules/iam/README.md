# Zesty Kompass Compute AWS IAM Role Module

This Terraform module creates and manages IAM roles and policies for the Zesty Kompass Compute controller.

Note: This module should not be used directly, but rather as a sub-module of the `zesty-co/compute/kompass` module.

## Features

- Creates and manages IAM roles for multiple Kompass Compute controllers:
  - Hiberscaler controller
  - Image Size Calculator controller
  - Snapshooter controller
  - Telemetry Manager controller
- Configures IAM permissions for each controller
- Supports both EKS Pod Identity and IRSA (IAM Roles for Service Accounts)

## Usage

```hcl
module "iam_controller" {
  source  = "zesty-co/compute/kompass//modules/iam"
  version = ">= 1.0.0, < 2.0.0"

  create = true

  iam_role_name        = "kompass-compute-controller"
  iam_role_description = "IAM role for Kompass Compute controller"
  iam_policy_name      = "kompass-compute-controller-policy"
  cluster_name         = "my-eks-cluster"
  namespace            = "zesty-system"
  service_account_name = "kompass-compute-controller"

  # Enable Pod Identity or IRSA as needed
  enable_pod_identity = true
  enable_irsa         = false

  # Optional: Custom tags
  tags = {
    Environment = "dev"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_pod_identity_association.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.controller_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.controller_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.hiberscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.image_size_calculator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshooter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.telemetry_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Create Kompass Compute resources | `bool` | `true` | no |
| <a name="input_create_pod_identity_association"></a> [create\_pod\_identity\_association](#input\_create\_pod\_identity\_association) | Determines whether to create pod identity association | `bool` | `true` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Determines whether to enable support for IAM roles for service accounts | `bool` | `false` | no |
| <a name="input_enable_pod_identity"></a> [enable\_pod\_identity](#input\_enable\_pod\_identity) | Determines whether to enable support for EKS pod identity | `bool` | `true` | no |
| <a name="input_iam_policy_description"></a> [iam\_policy\_description](#input\_iam\_policy\_description) | Kompass Compute IAM policy description | `string` | `"Zesty Kompass Computer Controller IAM policy"` | no |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name of the Kompass Compute IAM policy | `string` | `"KompassCompute"` | no |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | Path of the Kompass Compute IAM policy | `string` | `"/"` | no |
| <a name="input_iam_policy_statements"></a> [iam\_policy\_statements](#input\_iam\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any` | `[]` | no |
| <a name="input_iam_policy_use_name_prefix"></a> [iam\_policy\_use\_name\_prefix](#input\_iam\_policy\_use\_name\_prefix) | Determines whether the name of the Kompass Compute IAM policy (`iam_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Kompass Compute IAM role description | `string` | `"Zesty Kompass Computer Controller IAM role"` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 for the Kompass Compute IAM role | `number` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the Kompass Compute IAM role | `string` | `"KompassCompute"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the Kompass Compute IAM role | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary_arn"></a> [iam\_role\_permissions\_boundary\_arn](#input\_iam\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the Kompass Compute IAM role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Policies to attach to the Kompass Compute IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add the the Kompass Compute IAM role | `map(any)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the name of the Kompass Compute IAM role (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_use_hiberscaler_policy"></a> [iam\_use\_hiberscaler\_policy](#input\_iam\_use\_hiberscaler\_policy) | Determines whether to use the default Hiberscaler IAM policy | `bool` | `false` | no |
| <a name="input_iam_use_image_size_calculator_policy"></a> [iam\_use\_image\_size\_calculator\_policy](#input\_iam\_use\_image\_size\_calculator\_policy) | Determines whether to use the default ImageSizeCalculator IAM policy | `bool` | `false` | no |
| <a name="input_iam_use_snapshooter_policy"></a> [iam\_use\_snapshooter\_policy](#input\_iam\_use\_snapshooter\_policy) | Determines whether to use the default Snapshooter IAM policy | `bool` | `false` | no |
| <a name="input_iam_use_telemetry_manager_policy"></a> [iam\_use\_telemetry\_manager\_policy](#input\_iam\_use\_telemetry\_manager\_policy) | Determines whether to use the default Telemetry Manager IAM policy | `bool` | `false` | no |
| <a name="input_irsa_assume_role_condition_test"></a> [irsa\_assume\_role\_condition\_test](#input\_irsa\_assume\_role\_condition\_test) | Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role | `string` | `"StringEquals"` | no |
| <a name="input_irsa_namespace_service_accounts"></a> [irsa\_namespace\_service\_accounts](#input\_irsa\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br/>  "zesty-system:"<br/>]</pre> | no |
| <a name="input_irsa_oidc_provider_arn"></a> [irsa\_oidc\_provider\_arn](#input\_irsa\_oidc\_provider\_arn) | OIDC provider arn used in trust policy for IAM roles for service accounts | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to associate with the Kompass Compute Pod Identity | `string` | `"zesty-system"` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Service account to associate with the Kompass Compute Pod Identity | `string` | `""` | no |
| <a name="input_sqs_queue_name"></a> [sqs\_queue\_name](#input\_sqs\_queue\_name) | Name of the SQS queue to use for Kompass Compute | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_policy_arn"></a> [iam\_policy\_arn](#output\_iam\_policy\_arn) | The Amazon Resource Name (ARN) specifying the controller IAM policy |
| <a name="output_iam_policy_name"></a> [iam\_policy\_name](#output\_iam\_policy\_name) | The name of the controller IAM policy |
| <a name="output_iam_policy_policy_id"></a> [iam\_policy\_policy\_id](#output\_iam\_policy\_policy\_id) | The Policy ID of the controller IAM policy |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the controller IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the controller IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the controller IAM role |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace associated with the Kompass Compute Pod Identity |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Service Account associated with the Kompass Compute Pod Identity |
<!-- END_TF_DOCS -->