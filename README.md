# Zesty Kompass Compute Module

This module enables installing Kompass Compute in an EKS cluster.

It creates IAM roles, policies, SQS queues, and related resources for the Kompass Compute controller.

The Terraform installation also passes information to Helm and deploys resources in the cluster. If your environment requires that cluster resources be deployed directly with a Helm install, that option is also described.

## Contents

- [Prerequisites](#prerequisites)
- [Installation options](#installation-options)
  - [Quick start installation](#quick-start-installation)
  - [Detailed installation](#detailed-installation)
    - [Provider configuration](#provider-configuration)
    - [Invocation](#invocation)
  - [Deploy the Helm chart directly](#deploy-the-helm-chart-directly)
- [Deployed AWS resources](#deployed-aws-resources)
- [Advanced configuration](#advanced-configuration)
  - [ECR pull through cache](#ecr-pull-through-cache)
  - [Pass values to the Helm chart](#pass-values-to-the-helm-chart)
  - [Use IAM Roles for Service Accounts (IRSA)](#use-iam-roles-for-service-accounts-irsa)
  - [Disable S3 VPC interface endpoint creation](#disable-s3-vpc-interface-endpoint-creation)
- [API reference](#requirements)

## Prerequisites

- Kubernetes v1.28, or later
- Helm v3.2.0, or later
- [Kompass](https://github.com/zesty-co/kompass) installed in the cluster
- Pod Identity enabled in the cluster (alternatively, see [Use IAM Roles for Service Accounts (IRSA)](#use-iam-roles-for-service-accounts-irsa))

## Installation options

You can install Kompass Compute in these ways:

- Use Terraform to deploy both cloud and cluster resources with either of these methods:
  - [Quick start installation](#quick-start-installation): Copy the quick start code to your filesystem, change as needed, then apply.
  - [Detailed installation](#detailed-installation): Copy the quick start code to your filesystem, follow the installation details to apply the code to your environment, then apply.
- Use Terraform to deploy only the cloud resources, and use Helm to deploy the cluster resources:
  1. Deploy the cloud resources (only) using either of the options above.
  2. Deploy the cluster resources using Helm.

        Before you begin, see the instructions in [Deploy the Helm chart directly](#deploy-the-helm-chart-directly).

### Quick start installation

You can find everything needed to install in the [quick-start folder](https://github.com/zesty-co/terraform-kompass-compute/tree/main/examples/quick-start).

Ensure that you configure the providers and the variables, as described.

Copy the quick-start code to your filesystem. Customize it as needed for your environment, then apply it.

### Detailed installation

For the most basic installation, create a Terraform configuration with the following components:

1. A provider configuration section that describes:
    - **AWS provider**: gets cluster information
    - **Helm provider**: deploys the Kompass Compute Helm chart
2. Invocation of the **kompass-compute** module that installs all required AWS resources and the helm_release resource to deploy the Kompass Compute Helm chart.

The output of the kompass-compute module includes a values.yaml file that gives the kompass-compute helm chart knowledge about the location of the deployed cloud resources.  
The following configurations do all the required data transfer.

#### Provider configuration

The following sample code configures the necessary providers. If your setup is different, you will need to adjust the configuration accordingly.

##### Helm provider version 3

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

##### Helm provider version 2

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

#### Invocation

The following sample code deploys the Kompass Compute module and the Kompass Compute Helm chart.

```hcl
locals {
  cluster_name = "cluster-name"
  vpc_id       = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  vpc_cidr     = data.aws_vpc.this.cidr_block
  subnet_ids   = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

# Creates the cloud resources for Kompass Compute.
module "kompass_compute" {
  source  = "zesty-co/compute/kompass"
  version = ">= 1.0.0, < 2.0.0"

  cluster_name = local.cluster_name
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids

  irsa_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn

  vpc_endpoint_security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [local.vpc_cidr]
    }
  }
}

# The CRDs are managed by a separate chart, according to the helm best practices.
resource "helm_release" "kompass_compute_crd" {
  repository = "https://zesty-co.github.io/kompass-compute"
  # If you want to specify the exact version of the chart:
  # version    = "0.1.7"
  chart     = "kompass-compute-crd"
  name      = "kompass-compute-crd"
  namespace = "zesty-system"
}

resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  # If you want to specify the exact version of the chart:
  # version    = "0.1.7"
  name       = "kompass-compute"
  namespace  = "zesty-system"

  values = [
    # Provide the helm chart with knowledge about the deployed cloud resources.
    module.kompass_compute.helm_values_yaml,
  ]

  depends_on = [
    # Prevents from removing IAM roles and policies while deleting the Helm release
    module.kompass_compute,
    helm_release.kompass_compute_crd,
  ]
}
```

### Deploy the Helm chart directly

Instead of installing the Helm charts using Terraform, you can install them through a GitOps tool, such as ArgoCD, after first using Terraform to deploy the cloud resources.

The Helm chart requires information about cloud resources deployed by the kompass-compute Terraform module, such as SQS queues, S3 VPC endpoints, IAM roles, and ECR pull through cache rules. You can get this information from the values.yaml file which is returned after using Terraform to deploy the cloud resources.

**To deploy the Helm chart directly:**

1. Use Terraform to deploy the cloud resources with either the [Quick start installation](#quick-start-installation) or [Detailed installation](#detailed-installation) methods.  
    Skip the Helm installation by commenting or removing the sections that begin with resource "helm_release".
    1. Retrieve values.yaml from the Terraform module directory by running `terraform output -raw helm_values_yaml > values.yaml`
    2. Install the Helm charts as described in [Kompass Compute Helm Charts](https://github.com/zesty-co/kompass-compute) and provide the retrieved values.yaml.

## Deployed AWS resources

- IAM roles for various components of the Kompass Compute controller:
  - Hiberscaler
  - Image Size Calculator
  - Snapshooter
  - Telemetry Manager
- SQS queue for spot instance termination notifications
- CloudWatch event rules for spot instance interruptions
- S3 VPC endpoint for secure access to S3
- Security groups for VPC endpoints
- EKS Pod Identity or IRSA (IAM Roles for Service Accounts) resources configs

## Advanced configuration

This section describes the following advanced configuration options:

- [ECR pull through cache](#ecr-pull-through-cache)
- [Pass values to the Helm chart](#pass-values-to-the-helm-chart)
- [Use IAM Roles for Service Accounts (IRSA)](#use-iam-roles-for-service-accounts-irsa)
- [Disable S3 VPC interface endpoint creation](#disable-s3-vpc-interface-endpoint-creation)
- [API reference](#requirements)

### ECR pull through cache

Caching the images on all Hibernated nodes can increase network costs.

To reduce network costs, it's recommended to configure an ECR pull through cache and configure the nodes to pull images through it, thus only downloading each image from the internet once.

**To configure ECR pull through cache:**

- Create ECR pull through rules using the `ecr` module:

```hcl
module "ecr" {
  source  = "zesty-co/compute/kompass//modules/ecr"
  version = ">= 1.0.0, < 2.0.0"

  ecr_pull_through_rule_name_prefix = "<Cluster Name>-"

  # By default the ecr module creates an ECR pull through cache rule for each of the supported registries.
  # If you want to disable the creation of the ECR pull through cache rule for a specific registry, set the `create` variable to `false`.
  # If you want to specify credentials for a specific registry to access private images or avoid rate limits, set the `secret_arn` variable to the ARN of the secret, or `secret_content` to the content of the secret.

  # registries = {
  #   "dockerhub" = {
  #     create = false
  #     secret_arn = "<Dockerhub Secret ARN>"
         # If you want to create a secret out of credentials, instead of using an existing secret
         secret_content = jsonencode({
           username    = "your-username"
           accessToken = "your-access-token"
         })
  #   },
  #   "ghcr" = {
  #     secret_arn = "<GitHub Container Registry Secret ARN>"
  #     # secret_content = ... # If you want to create a secret out of credentials, instead of using an existing secret
  #   }
  # }
}
```

> Note: It is recommended to deploy `ecr` module only once per region. ECR pull through cache rules are regional resources, and creating them multiple times is not necessary and may lead to conflicts.

- Connect the Helm chart to the provided ECR repository by providing the values.yaml to the Helm chart:

```hcl
resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  name       = "kompass-compute"
  namespace  = "zesty-system"

  values = [
    module.kompass_compute.helm_values_yaml,
    module.ecr.helm_values_yaml,
    # Add any additional values here, such as the values.yaml provided by the kompass-compute module
  ]
}
```

### Pass values to the Helm chart

The `kompass_compute` module and the `ecr` module output a `helm_values_yaml` variable that can be used to pass values to the Helm chart.

These variables inform the controllers of the location of the deployed cloud resources, such as SQS queues, S3 VPC endpoints, IAM roles, and ECR pull through cache rules. You can use it in your Helm chart as follows:

```hcl
resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  name       = "kompass-compute"
  namespace  = "zesty-system"

  values = [
    module.ecr.helm_values_yaml,
    module.kompass_compute.helm_values_yaml,
    # Add any additional values here
  ]
}
```

The `helm_values_yaml` can also be accessed using the `terraform_remote_state` data source if you want to access it from a separate terraform module.

The `helm_values_yaml` from ECR module contains the ECR pull through cache rules configuration, and has the following structure:

```yaml
cachePullMappings:
  dockerhub:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-dockerhub"
  ghcr:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-ghcr"
```

Name of the ECR repository will be in the format `zesty-{registry_name}` where `{registry_name}` is the key from the `registries` map (e.g., `zesty-dockerhub`, `zesty-ghcr`, etc.). It can be overridden by setting the `ecr_pull_through_rule_name_prefix` variable in the module configuration, or by using the `ecr_repository_prefix_override` field in the `registries` map for each registry.

The `helm_values_yaml` from the Kompass Compute module contains the necessary configuration for the Kompass Compute controller. It has the following structure:

```yaml
qubexConfig:
  infraConfig:
    aws:
      spotFailuresQueueUrl: "https://sqs.us-west-2.amazonaws.com/123456789012/ZestyKompassCompute-cluster-name"
      s3VpcEndpointID: "vpce-1234567890abcdef0"
```

### Use IAM Roles for Service Accounts (IRSA)

By default, the module creates Pod Identity roles for the Kompass Compute controller components.

To use IRSA (IAM Roles for Service Accounts) instead, set the `enable_irsa` variable to `true` and provide the OIDC provider ARN using the `irsa_oidc_provider_arn` variable.
The OIDC provider ARN can be retrieved using the `aws_iam_openid_connect_provider` data source.

Optionally, you can disable Pod Identity by setting `enable_pod_identity` to `false`.

```hcl
data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

module "kompass_compute" {
  source  = "zesty-co/compute/kompass"
  version = ">= 1.0.0, < 2.0.0"

  cluster_name = "cluster-name"

  enable_pod_identity    = false
  enable_irsa            = true
  irsa_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn
}
```

### Disable S3 VPC interface endpoint creation

By default, an S3 VPC interface endpoint is created to allow the Kompass Compute controller to inexpensively access securely stored container images. Images are not downloaded from the public internet, but rather from the S3 VPC Interface Endpoint.

If you have an S3 VPC gateway endpoint or any other reason to disable the creation of the S3 VPC interface endpoint, set the `create_s3_vpc_endpoint` variable to `false`:

```hcl
module "kompass_compute" {
  source  = "zesty-co/compute/kompass"
  version = ">= 1.0.0, < 2.0.0"

  cluster_name           = "cluster-name"
  create_s3_vpc_endpoint = false
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_hiberscaler"></a> [iam\_hiberscaler](#module\_iam\_hiberscaler) | ./modules/iam | n/a |
| <a name="module_iam_image_size_calculator"></a> [iam\_image\_size\_calculator](#module\_iam\_image\_size\_calculator) | ./modules/iam | n/a |
| <a name="module_iam_snapshooter"></a> [iam\_snapshooter](#module\_iam\_snapshooter) | ./modules/iam | n/a |
| <a name="module_iam_telemetry_manager"></a> [iam\_telemetry\_manager](#module\_iam\_telemetry\_manager) | ./modules/iam | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_iam_policy_document.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc_endpoint_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | `""` | no |
| <a name="input_create"></a> [create](#input\_create) | Create Kompass Compute resources | `bool` | `true` | no |
| <a name="input_create_hiberscaler_iam_role"></a> [create\_hiberscaler\_iam\_role](#input\_create\_hiberscaler\_iam\_role) | Determines whether an Hiberscaler IAM role is created | `bool` | `true` | no |
| <a name="input_create_image_size_calculator_iam_role"></a> [create\_image\_size\_calculator\_iam\_role](#input\_create\_image\_size\_calculator\_iam\_role) | Determines whether an Image Size Calculator IAM role is created | `bool` | `true` | no |
| <a name="input_create_pod_identity_association"></a> [create\_pod\_identity\_association](#input\_create\_pod\_identity\_association) | Determines whether to create pod identity association | `bool` | `true` | no |
| <a name="input_create_s3_vpc_endpoint"></a> [create\_s3\_vpc\_endpoint](#input\_create\_s3\_vpc\_endpoint) | Determines whether S3 VPC Endpoint will be created | `bool` | `true` | no |
| <a name="input_create_s3_vpc_endpoint_security_group"></a> [create\_s3\_vpc\_endpoint\_security\_group](#input\_create\_s3\_vpc\_endpoint\_security\_group) | Determines if a S3 VPC Endpoint security group is created | `bool` | `true` | no |
| <a name="input_create_snapshooter_iam_role"></a> [create\_snapshooter\_iam\_role](#input\_create\_snapshooter\_iam\_role) | Determines whether a Snapshooter IAM role is created | `bool` | `true` | no |
| <a name="input_create_telemetry_manager_iam_role"></a> [create\_telemetry\_manager\_iam\_role](#input\_create\_telemetry\_manager\_iam\_role) | Determines whether a Telemetry Manager IAM role is created | `bool` | `true` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Determines whether to enable support for IAM roles for service accounts | `bool` | `false` | no |
| <a name="input_enable_pod_identity"></a> [enable\_pod\_identity](#input\_enable\_pod\_identity) | Determines whether to enable support for EKS pod identity | `bool` | `true` | no |
| <a name="input_enable_spot_termination"></a> [enable\_spot\_termination](#input\_enable\_spot\_termination) | Determines whether to enable native spot termination handling | `bool` | `true` | no |
| <a name="input_hiberscaler_service_account_name"></a> [hiberscaler\_service\_account\_name](#input\_hiberscaler\_service\_account\_name) | Service account to associate with the Hiberscaler Pod Identity | `string` | `"kompass-compute-hiberscaler"` | no |
| <a name="input_iam_hiberscaler_policy_description"></a> [iam\_hiberscaler\_policy\_description](#input\_iam\_hiberscaler\_policy\_description) | Hiberscaler IAM policy description | `string` | `"Zesty Kompass Computer Hiberscaler Controller IAM policy"` | no |
| <a name="input_iam_hiberscaler_policy_name"></a> [iam\_hiberscaler\_policy\_name](#input\_iam\_hiberscaler\_policy\_name) | Name of the Hiberscaler IAM policy | `string` | `"KompassComputeHiberscaler"` | no |
| <a name="input_iam_hiberscaler_policy_path"></a> [iam\_hiberscaler\_policy\_path](#input\_iam\_hiberscaler\_policy\_path) | Path of the Hiberscaler IAM policy | `string` | `"/"` | no |
| <a name="input_iam_hiberscaler_policy_statements"></a> [iam\_hiberscaler\_policy\_statements](#input\_iam\_hiberscaler\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any` | `[]` | no |
| <a name="input_iam_hiberscaler_policy_use_name_prefix"></a> [iam\_hiberscaler\_policy\_use\_name\_prefix](#input\_iam\_hiberscaler\_policy\_use\_name\_prefix) | Determines whether the name of the Hiberscaler IAM policy (`iam_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_hiberscaler_role_description"></a> [iam\_hiberscaler\_role\_description](#input\_iam\_hiberscaler\_role\_description) | Hiberscaler IAM role description | `string` | `"Zesty Kompass Computer Hiberscaler Controller IAM role"` | no |
| <a name="input_iam_hiberscaler_role_max_session_duration"></a> [iam\_hiberscaler\_role\_max\_session\_duration](#input\_iam\_hiberscaler\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 for the Hiberscaler IAM role | `number` | `null` | no |
| <a name="input_iam_hiberscaler_role_name"></a> [iam\_hiberscaler\_role\_name](#input\_iam\_hiberscaler\_role\_name) | Name of the Hiberscaler IAM role | `string` | `"KompassComputeHiberscaler"` | no |
| <a name="input_iam_hiberscaler_role_path"></a> [iam\_hiberscaler\_role\_path](#input\_iam\_hiberscaler\_role\_path) | Path of the Hiberscaler IAM role | `string` | `"/"` | no |
| <a name="input_iam_hiberscaler_role_permissions_boundary_arn"></a> [iam\_hiberscaler\_role\_permissions\_boundary\_arn](#input\_iam\_hiberscaler\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the Hiberscaler IAM role | `string` | `null` | no |
| <a name="input_iam_hiberscaler_role_policies"></a> [iam\_hiberscaler\_role\_policies](#input\_iam\_hiberscaler\_role\_policies) | Policies to attach to the Hiberscaler IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_hiberscaler_role_tags"></a> [iam\_hiberscaler\_role\_tags](#input\_iam\_hiberscaler\_role\_tags) | A map of additional tags to add the the Hiberscaler IAM role | `map(any)` | `{}` | no |
| <a name="input_iam_hiberscaler_role_use_name_prefix"></a> [iam\_hiberscaler\_role\_use\_name\_prefix](#input\_iam\_hiberscaler\_role\_use\_name\_prefix) | Determines whether the name of the Hiberscaler IAM role (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_image_size_calculator_policy_description"></a> [iam\_image\_size\_calculator\_policy\_description](#input\_iam\_image\_size\_calculator\_policy\_description) | Image Size Calculator IAM policy description | `string` | `"Zesty Kompass Computer Image Size Calculator Controller IAM policy"` | no |
| <a name="input_iam_image_size_calculator_policy_name"></a> [iam\_image\_size\_calculator\_policy\_name](#input\_iam\_image\_size\_calculator\_policy\_name) | Name of the Image Size Calculator IAM policy | `string` | `"KompassComputeImageSizeCalculator"` | no |
| <a name="input_iam_image_size_calculator_policy_path"></a> [iam\_image\_size\_calculator\_policy\_path](#input\_iam\_image\_size\_calculator\_policy\_path) | Path of the Image Size Calculator IAM policy | `string` | `"/"` | no |
| <a name="input_iam_image_size_calculator_policy_statements"></a> [iam\_image\_size\_calculator\_policy\_statements](#input\_iam\_image\_size\_calculator\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any` | `[]` | no |
| <a name="input_iam_image_size_calculator_policy_use_name_prefix"></a> [iam\_image\_size\_calculator\_policy\_use\_name\_prefix](#input\_iam\_image\_size\_calculator\_policy\_use\_name\_prefix) | Determines whether the name of the Image Size Calculator IAM policy (`iam_image_size_calculator_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_image_size_calculator_role_description"></a> [iam\_image\_size\_calculator\_role\_description](#input\_iam\_image\_size\_calculator\_role\_description) | Image Size Calculator IAM role description | `string` | `"Zesty Kompass Computer Image Size Calculator Controller IAM role"` | no |
| <a name="input_iam_image_size_calculator_role_max_session_duration"></a> [iam\_image\_size\_calculator\_role\_max\_session\_duration](#input\_iam\_image\_size\_calculator\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 for the Image Size Calculator IAM role | `number` | `null` | no |
| <a name="input_iam_image_size_calculator_role_name"></a> [iam\_image\_size\_calculator\_role\_name](#input\_iam\_image\_size\_calculator\_role\_name) | Name of the Image Size Calculator IAM role | `string` | `"KompassComputeImageSizeCalculator"` | no |
| <a name="input_iam_image_size_calculator_role_path"></a> [iam\_image\_size\_calculator\_role\_path](#input\_iam\_image\_size\_calculator\_role\_path) | Path of the Image Size Calculator IAM role | `string` | `"/"` | no |
| <a name="input_iam_image_size_calculator_role_permissions_boundary_arn"></a> [iam\_image\_size\_calculator\_role\_permissions\_boundary\_arn](#input\_iam\_image\_size\_calculator\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the Image Size Calculator IAM role | `string` | `null` | no |
| <a name="input_iam_image_size_calculator_role_policies"></a> [iam\_image\_size\_calculator\_role\_policies](#input\_iam\_image\_size\_calculator\_role\_policies) | Policies to attach to the Image Size Calculator IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_image_size_calculator_role_tags"></a> [iam\_image\_size\_calculator\_role\_tags](#input\_iam\_image\_size\_calculator\_role\_tags) | A map of additional tags to add the the Image Size Calculator IAM role | `map(any)` | `{}` | no |
| <a name="input_iam_image_size_calculator_role_use_name_prefix"></a> [iam\_image\_size\_calculator\_role\_use\_name\_prefix](#input\_iam\_image\_size\_calculator\_role\_use\_name\_prefix) | Determines whether the name of the Image Size Calculator IAM role (`iam_image_size_calculator_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_snapshooter_policy_description"></a> [iam\_snapshooter\_policy\_description](#input\_iam\_snapshooter\_policy\_description) | Snapshooter IAM policy description | `string` | `"Zesty Kompass Computer Snapshooter Controller IAM policy"` | no |
| <a name="input_iam_snapshooter_policy_name"></a> [iam\_snapshooter\_policy\_name](#input\_iam\_snapshooter\_policy\_name) | Name of the Snapshooter IAM policy | `string` | `"KompassComputeSnapshooter"` | no |
| <a name="input_iam_snapshooter_policy_path"></a> [iam\_snapshooter\_policy\_path](#input\_iam\_snapshooter\_policy\_path) | Path of the Snapshooter IAM policy | `string` | `"/"` | no |
| <a name="input_iam_snapshooter_policy_statements"></a> [iam\_snapshooter\_policy\_statements](#input\_iam\_snapshooter\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any` | `[]` | no |
| <a name="input_iam_snapshooter_policy_use_name_prefix"></a> [iam\_snapshooter\_policy\_use\_name\_prefix](#input\_iam\_snapshooter\_policy\_use\_name\_prefix) | Determines whether the name of the Snapshooter IAM policy (`iam_snapshooter_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_snapshooter_role_description"></a> [iam\_snapshooter\_role\_description](#input\_iam\_snapshooter\_role\_description) | Snapshooter IAM role description | `string` | `"Zesty Kompass Computer Snapshooter Controller IAM role"` | no |
| <a name="input_iam_snapshooter_role_max_session_duration"></a> [iam\_snapshooter\_role\_max\_session\_duration](#input\_iam\_snapshooter\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 for the Snapshooter IAM role | `number` | `null` | no |
| <a name="input_iam_snapshooter_role_name"></a> [iam\_snapshooter\_role\_name](#input\_iam\_snapshooter\_role\_name) | Name of the Snapshooter IAM role | `string` | `"KompassComputeSnapshooter"` | no |
| <a name="input_iam_snapshooter_role_path"></a> [iam\_snapshooter\_role\_path](#input\_iam\_snapshooter\_role\_path) | Path of the Snapshooter IAM role | `string` | `"/"` | no |
| <a name="input_iam_snapshooter_role_permissions_boundary_arn"></a> [iam\_snapshooter\_role\_permissions\_boundary\_arn](#input\_iam\_snapshooter\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the Snapshooter IAM role | `string` | `null` | no |
| <a name="input_iam_snapshooter_role_policies"></a> [iam\_snapshooter\_role\_policies](#input\_iam\_snapshooter\_role\_policies) | Policies to attach to the Snapshooter IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_snapshooter_role_tags"></a> [iam\_snapshooter\_role\_tags](#input\_iam\_snapshooter\_role\_tags) | A map of additional tags to add the the Snapshooter IAM role | `map(any)` | `{}` | no |
| <a name="input_iam_snapshooter_role_use_name_prefix"></a> [iam\_snapshooter\_role\_use\_name\_prefix](#input\_iam\_snapshooter\_role\_use\_name\_prefix) | Determines whether the name of the Snapshooter IAM role (`iam_snapshooter_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_telemetry_manager_policy_description"></a> [iam\_telemetry\_manager\_policy\_description](#input\_iam\_telemetry\_manager\_policy\_description) | Telemetry Manager IAM policy description | `string` | `"Zesty Kompass Computer Telemetry Manager Controller IAM policy"` | no |
| <a name="input_iam_telemetry_manager_policy_name"></a> [iam\_telemetry\_manager\_policy\_name](#input\_iam\_telemetry\_manager\_policy\_name) | Name of the Telemetry Manager IAM policy | `string` | `"KompassComputeTelemetryManager"` | no |
| <a name="input_iam_telemetry_manager_policy_path"></a> [iam\_telemetry\_manager\_policy\_path](#input\_iam\_telemetry\_manager\_policy\_path) | Path of the Telemetry Manager IAM policy | `string` | `"/"` | no |
| <a name="input_iam_telemetry_manager_policy_statements"></a> [iam\_telemetry\_manager\_policy\_statements](#input\_iam\_telemetry\_manager\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed | `any` | `[]` | no |
| <a name="input_iam_telemetry_manager_policy_use_name_prefix"></a> [iam\_telemetry\_manager\_policy\_use\_name\_prefix](#input\_iam\_telemetry\_manager\_policy\_use\_name\_prefix) | Determines whether the name of the Telemetry Manager IAM policy (`iam_telemetry_manager_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_iam_telemetry_manager_role_description"></a> [iam\_telemetry\_manager\_role\_description](#input\_iam\_telemetry\_manager\_role\_description) | Telemetry Manager IAM role description | `string` | `"Zesty Kompass Computer Telemetry Manager Controller IAM role"` | no |
| <a name="input_iam_telemetry_manager_role_max_session_duration"></a> [iam\_telemetry\_manager\_role\_max\_session\_duration](#input\_iam\_telemetry\_manager\_role\_max\_session\_duration) | Maximum API session duration in seconds between 3600 and 43200 for the Telemetry Manager IAM role | `number` | `null` | no |
| <a name="input_iam_telemetry_manager_role_name"></a> [iam\_telemetry\_manager\_role\_name](#input\_iam\_telemetry\_manager\_role\_name) | Name of the Telemetry Manager IAM role | `string` | `"KompassComputeTelemetryManager"` | no |
| <a name="input_iam_telemetry_manager_role_path"></a> [iam\_telemetry\_manager\_role\_path](#input\_iam\_telemetry\_manager\_role\_path) | Path of the Telemetry Manager IAM role | `string` | `"/"` | no |
| <a name="input_iam_telemetry_manager_role_permissions_boundary_arn"></a> [iam\_telemetry\_manager\_role\_permissions\_boundary\_arn](#input\_iam\_telemetry\_manager\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the Telemetry Manager IAM role | `string` | `null` | no |
| <a name="input_iam_telemetry_manager_role_policies"></a> [iam\_telemetry\_manager\_role\_policies](#input\_iam\_telemetry\_manager\_role\_policies) | Policies to attach to the Telemetry Manager IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_iam_telemetry_manager_role_tags"></a> [iam\_telemetry\_manager\_role\_tags](#input\_iam\_telemetry\_manager\_role\_tags) | A map of additional tags to add the the Telemetry Manager IAM role | `map(any)` | `{}` | no |
| <a name="input_iam_telemetry_manager_role_use_name_prefix"></a> [iam\_telemetry\_manager\_role\_use\_name\_prefix](#input\_iam\_telemetry\_manager\_role\_use\_name\_prefix) | Determines whether the name of the Telemetry Manager IAM role (`iam_telemetry_manager_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_image_size_calculator_service_account_name"></a> [image\_size\_calculator\_service\_account\_name](#input\_image\_size\_calculator\_service\_account\_name) | Service account to associate with the Image Size Calculator Pod Identity | `string` | `"kompass-compute-image-size-calculator"` | no |
| <a name="input_irsa_assume_role_condition_test"></a> [irsa\_assume\_role\_condition\_test](#input\_irsa\_assume\_role\_condition\_test) | Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role | `string` | `"StringEquals"` | no |
| <a name="input_irsa_hiberscaler_namespace_service_accounts"></a> [irsa\_hiberscaler\_namespace\_service\_accounts](#input\_irsa\_hiberscaler\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br/>  "zesty-system:kompass-compute-hiberscaler"<br/>]</pre> | no |
| <a name="input_irsa_image_size_calculator_namespace_service_accounts"></a> [irsa\_image\_size\_calculator\_namespace\_service\_accounts](#input\_irsa\_image\_size\_calculator\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br/>  "zesty-system:kompass-compute-image-size-calculator"<br/>]</pre> | no |
| <a name="input_irsa_oidc_provider_arn"></a> [irsa\_oidc\_provider\_arn](#input\_irsa\_oidc\_provider\_arn) | OIDC provider arn used in trust policy for IAM roles for service accounts | `string` | `""` | no |
| <a name="input_irsa_snapshooter_namespace_service_accounts"></a> [irsa\_snapshooter\_namespace\_service\_accounts](#input\_irsa\_snapshooter\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br/>  "zesty-system:kompass-compute-snapshooter"<br/>]</pre> | no |
| <a name="input_irsa_telemetry_manager_namespace_service_accounts"></a> [irsa\_telemetry\_manager\_namespace\_service\_accounts](#input\_irsa\_telemetry\_manager\_namespace\_service\_accounts) | List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts | `list(string)` | <pre>[<br/>  "zesty-system:kompass-compute-telemetry-manager"<br/>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to associate with the Hiberscaler Pod Identity | `string` | `"zesty-system"` | no |
| <a name="input_queue_kms_data_key_reuse_period_seconds"></a> [queue\_kms\_data\_key\_reuse\_period\_seconds](#input\_queue\_kms\_data\_key\_reuse\_period\_seconds) | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again | `number` | `null` | no |
| <a name="input_queue_kms_master_key_id"></a> [queue\_kms\_master\_key\_id](#input\_queue\_kms\_master\_key\_id) | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK | `string` | `null` | no |
| <a name="input_queue_managed_sse_enabled"></a> [queue\_managed\_sse\_enabled](#input\_queue\_managed\_sse\_enabled) | Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys | `bool` | `true` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the SQS queue | `string` | `null` | no |
| <a name="input_rule_name_prefix"></a> [rule\_name\_prefix](#input\_rule\_name\_prefix) | Prefix used for all event bridge rules | `string` | `"ZestyKompassCompute"` | no |
| <a name="input_snapshooter_service_account_name"></a> [snapshooter\_service\_account\_name](#input\_snapshooter\_service\_account\_name) | Service account to associate with the Snapshooter Pod Identity | `string` | `"kompass-compute-snapshooter"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to associate with the S3 VPC Endpoint | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_telemetry_manager_service_account_name"></a> [telemetry\_manager\_service\_account\_name](#input\_telemetry\_manager\_service\_account\_name) | Service account to associate with the Telemetry Manager Pod Identity | `string` | `"kompass-compute-telemetry-manager"` | no |
| <a name="input_vpc_endpoint_dns_options"></a> [vpc\_endpoint\_dns\_options](#input\_vpc\_endpoint\_dns\_options) | DNS options for the S3 VPC Endpoint | <pre>object({<br/>    dns_record_ip_type                             = optional(string, null)<br/>    private_dns_only_for_inbound_resolver_endpoint = optional(bool, null)<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_endpoint_ip_address_type"></a> [vpc\_endpoint\_ip\_address\_type](#input\_vpc\_endpoint\_ip\_address\_type) | IP address type for the S3 VPC Endpoint | `string` | `"ipv4"` | no |
| <a name="input_vpc_endpoint_policy"></a> [vpc\_endpoint\_policy](#input\_vpc\_endpoint\_policy) | Policy to attach to the S3 VPC Endpoint | `string` | `null` | no |
| <a name="input_vpc_endpoint_private_dns_enabled"></a> [vpc\_endpoint\_private\_dns\_enabled](#input\_vpc\_endpoint\_private\_dns\_enabled) | Determines whether private DNS is enabled for the S3 VPC Endpoint | `bool` | `false` | no |
| <a name="input_vpc_endpoint_security_group_description"></a> [vpc\_endpoint\_security\_group\_description](#input\_vpc\_endpoint\_security\_group\_description) | Description of the security group created | `string` | `"Zesty Kompass Compute S3 VPC Endpoint Security Group"` | no |
| <a name="input_vpc_endpoint_security_group_ids"></a> [vpc\_endpoint\_security\_group\_ids](#input\_vpc\_endpoint\_security\_group\_ids) | Default security group IDs to associate with the VPC endpoints | `list(string)` | `[]` | no |
| <a name="input_vpc_endpoint_security_group_name"></a> [vpc\_endpoint\_security\_group\_name](#input\_vpc\_endpoint\_security\_group\_name) | Name to use on security group created | `string` | `"zesty-kompass-compute-s3-vpc-endpoint"` | no |
| <a name="input_vpc_endpoint_security_group_rules"></a> [vpc\_endpoint\_security\_group\_rules](#input\_vpc\_endpoint\_security\_group\_rules) | Security group rules to add to the security group created | <pre>map(object({<br/>    description              = optional(string, null)<br/>    protocol                 = optional(string, "tcp")<br/>    from_port                = optional(number, 443)<br/>    to_port                  = optional(number, 443)<br/>    type                     = optional(string, "ingress")<br/>    cidr_blocks              = optional(list(string), null)<br/>    ipv6_cidr_blocks         = optional(list(string), null)<br/>    prefix_list_ids          = optional(list(string), null)<br/>    self                     = optional(bool, null)<br/>    source_security_group_id = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_endpoint_security_group_tags"></a> [vpc\_endpoint\_security\_group\_tags](#input\_vpc\_endpoint\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_security_group_use_name_prefix"></a> [vpc\_endpoint\_security\_group\_use\_name\_prefix](#input\_vpc\_endpoint\_security\_group\_use\_name\_prefix) | Determines whether the name of the security group (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_vpc_endpoint_tags"></a> [vpc\_endpoint\_tags](#input\_vpc\_endpoint\_tags) | A map of additional tags to add to the S3 VPC Endpoint | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_timeouts"></a> [vpc\_endpoint\_timeouts](#input\_vpc\_endpoint\_timeouts) | Define maximum timeout for creating, updating, and deleting VPC endpoint resources | <pre>object({<br/>    create = optional(string, "10m")<br/>    update = optional(string, "10m")<br/>    delete = optional(string, "10m")<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the endpoint will be used | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_rules"></a> [event\_rules](#output\_event\_rules) | Map of the event rules created and their attributes |
| <a name="output_helm_values"></a> [helm\_values](#output\_helm\_values) | Map of Helm chart values for ECR pull through cache |
| <a name="output_helm_values_yaml"></a> [helm\_values\_yaml](#output\_helm\_values\_yaml) | YAML encoded Helm chart values for ECR pull through cache |
| <a name="output_hiberscaler_service_account_name"></a> [hiberscaler\_service\_account\_name](#output\_hiberscaler\_service\_account\_name) | Service Account associated with the Kompass Compute Hiberscaler Pod Identity |
| <a name="output_iam_hiberscaler_policy_arn"></a> [iam\_hiberscaler\_policy\_arn](#output\_iam\_hiberscaler\_policy\_arn) | The Amazon Resource Name (ARN) specifying the Hiberscaler controller IAM policy |
| <a name="output_iam_hiberscaler_policy_name"></a> [iam\_hiberscaler\_policy\_name](#output\_iam\_hiberscaler\_policy\_name) | The name of the Hiberscaler controller IAM policy |
| <a name="output_iam_hiberscaler_policy_policy_id"></a> [iam\_hiberscaler\_policy\_policy\_id](#output\_iam\_hiberscaler\_policy\_policy\_id) | The Policy ID of the Hiberscaler controller IAM policy |
| <a name="output_iam_hiberscaler_role_arn"></a> [iam\_hiberscaler\_role\_arn](#output\_iam\_hiberscaler\_role\_arn) | The Amazon Resource Name (ARN) specifying the Hiberscaler controller IAM role |
| <a name="output_iam_hiberscaler_role_name"></a> [iam\_hiberscaler\_role\_name](#output\_iam\_hiberscaler\_role\_name) | The name of the Hiberscaler controller IAM role |
| <a name="output_iam_hiberscaler_role_unique_id"></a> [iam\_hiberscaler\_role\_unique\_id](#output\_iam\_hiberscaler\_role\_unique\_id) | Stable and unique string identifying the Hiberscaler controller IAM role |
| <a name="output_iam_image_size_calculator_policy_arn"></a> [iam\_image\_size\_calculator\_policy\_arn](#output\_iam\_image\_size\_calculator\_policy\_arn) | The Amazon Resource Name (ARN) specifying the Image Size Calculator controller IAM policy |
| <a name="output_iam_image_size_calculator_policy_name"></a> [iam\_image\_size\_calculator\_policy\_name](#output\_iam\_image\_size\_calculator\_policy\_name) | The name of the Image Size Calculator controller IAM policy |
| <a name="output_iam_image_size_calculator_policy_policy_id"></a> [iam\_image\_size\_calculator\_policy\_policy\_id](#output\_iam\_image\_size\_calculator\_policy\_policy\_id) | The Policy ID of the Image Size Calculator controller IAM policy |
| <a name="output_iam_image_size_calculator_role_arn"></a> [iam\_image\_size\_calculator\_role\_arn](#output\_iam\_image\_size\_calculator\_role\_arn) | The Amazon Resource Name (ARN) specifying the Image Size Calculator controller IAM role |
| <a name="output_iam_image_size_calculator_role_name"></a> [iam\_image\_size\_calculator\_role\_name](#output\_iam\_image\_size\_calculator\_role\_name) | The name of the Image Size Calculator controller IAM role |
| <a name="output_iam_image_size_calculator_role_unique_id"></a> [iam\_image\_size\_calculator\_role\_unique\_id](#output\_iam\_image\_size\_calculator\_role\_unique\_id) | Stable and unique string identifying the Image Size Calculator controller IAM role |
| <a name="output_iam_snapshooter_policy_arn"></a> [iam\_snapshooter\_policy\_arn](#output\_iam\_snapshooter\_policy\_arn) | The Amazon Resource Name (ARN) specifying the Snapshooter controller IAM policy |
| <a name="output_iam_snapshooter_policy_name"></a> [iam\_snapshooter\_policy\_name](#output\_iam\_snapshooter\_policy\_name) | The name of the Snapshooter controller IAM policy |
| <a name="output_iam_snapshooter_policy_policy_id"></a> [iam\_snapshooter\_policy\_policy\_id](#output\_iam\_snapshooter\_policy\_policy\_id) | The Policy ID of the Snapshooter controller IAM policy |
| <a name="output_iam_snapshooter_role_arn"></a> [iam\_snapshooter\_role\_arn](#output\_iam\_snapshooter\_role\_arn) | The Amazon Resource Name (ARN) specifying the Snapshooter controller IAM role |
| <a name="output_iam_snapshooter_role_name"></a> [iam\_snapshooter\_role\_name](#output\_iam\_snapshooter\_role\_name) | The name of the Snapshooter controller IAM role |
| <a name="output_iam_snapshooter_role_unique_id"></a> [iam\_snapshooter\_role\_unique\_id](#output\_iam\_snapshooter\_role\_unique\_id) | Stable and unique string identifying the Snapshooter controller IAM role |
| <a name="output_iam_telemetry_manager_role_arn"></a> [iam\_telemetry\_manager\_role\_arn](#output\_iam\_telemetry\_manager\_role\_arn) | The Amazon Resource Name (ARN) specifying the Telemetry Manager controller IAM role |
| <a name="output_iam_telemetry_manager_role_name"></a> [iam\_telemetry\_manager\_role\_name](#output\_iam\_telemetry\_manager\_role\_name) | The name of the Telemetry Manager controller IAM role |
| <a name="output_iam_telemetry_manager_role_unique_id"></a> [iam\_telemetry\_manager\_role\_unique\_id](#output\_iam\_telemetry\_manager\_role\_unique\_id) | Stable and unique string identifying the Telemetry Manager controller IAM role |
| <a name="output_image_size_calculator_service_account_name"></a> [image\_size\_calculator\_service\_account\_name](#output\_image\_size\_calculator\_service\_account\_name) | Service Account associated with the Kompass Compute Image Size Calculator Pod Identity |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace associated with the Kompass Compute Pod Identity |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | The ARN of the SQS queue |
| <a name="output_queue_name"></a> [queue\_name](#output\_queue\_name) | The name of the created Amazon SQS queue |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | The URL for the created Amazon SQS queue |
| <a name="output_snapshooter_service_account_name"></a> [snapshooter\_service\_account\_name](#output\_snapshooter\_service\_account\_name) | Service Account associated with the Kompass Compute Snapshooter Pod Identity |
| <a name="output_telemetry_manager_service_account_name"></a> [telemetry\_manager\_service\_account\_name](#output\_telemetry\_manager\_service\_account\_name) | Service Account associated with the Kompass Compute Telemetry Manager Pod Identity |
| <a name="output_vpc_endpoint"></a> [vpc\_endpoint](#output\_vpc\_endpoint) | Full resource object and attributes for the S3 VPC endpoint created |
| <a name="output_vpc_endpoint_arn"></a> [vpc\_endpoint\_arn](#output\_vpc\_endpoint\_arn) | Amazon Resource Name (ARN) of the S3 VPC endpoint |
| <a name="output_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#output\_vpc\_endpoint\_id) | ID of the S3 VPC endpoint |
| <a name="output_vpc_endpoint_network_interface_ids"></a> [vpc\_endpoint\_network\_interface\_ids](#output\_vpc\_endpoint\_network\_interface\_ids) | Network interface IDs of the S3 VPC endpoint |
| <a name="output_vpc_endpoint_network_interface_ipv4"></a> [vpc\_endpoint\_network\_interface\_ipv4](#output\_vpc\_endpoint\_network\_interface\_ipv4) | IPv4 addresses of the network interfaces for the S3 VPC endpoint |
| <a name="output_vpc_endpoint_network_interface_ipv6"></a> [vpc\_endpoint\_network\_interface\_ipv6](#output\_vpc\_endpoint\_network\_interface\_ipv6) | IPv6 addresses of the network interfaces for the S3 VPC endpoint |
| <a name="output_vpc_endpoint_security_group_arn"></a> [vpc\_endpoint\_security\_group\_arn](#output\_vpc\_endpoint\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_vpc_endpoint_security_group_id"></a> [vpc\_endpoint\_security\_group\_id](#output\_vpc\_endpoint\_security\_group\_id) | ID of the security group |
<!-- END_TF_DOCS -->
