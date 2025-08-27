/**
 * # Zesty Kompass Compute Module
 *
 * This module allows installing Kompass Compute in an EKS cluster.
 *
 * It creates IAM roles, policies, SQS queues, and related resources for the Kompass Compute controller.
 *
 * ## Table of Contents
 *
 * - [Prerequisites](#prerequisites)
 * - [Quick Start](#quick-start)
 * - [Installation instructions](#installation-instructions)
 * - [Deployed Resources](#deployed-resources)
 * - [Provider Configuration](#provider-configuration)
 * - [Deploying the helm chart directly](#deploying-the-helm-chart-directly)
 * - [Advanced Usage](#advanced-usage)
 * - [API Reference](#requirements)
 *
 * ## Prerequisites
 *
 * - Kubernetes 1.28+
 * - Helm 3.2.0+
 * - [Kompass](https://github.com/zesty-co/kompass) installed in the cluster
 * - EKS Pod Identity enabled in the cluster, otherwise go to the [IRSA section](#using-iam-roles-for-service-accounts-irsa)
 *
 * ## Quick Start
 *
 * There are three ways to install Kompass Compute with basic setup:
 *
 * 1. Using the [quick-start](./examples/quick-start/main.tf) example.
 * 2. Using the [instructions below](#installation-instructions).
 * 3. Deploying the cloud resources through this module and the Kubernetes resources through the [helm chart directly](#deploying-the-helm-chart-directly).
 *
 * ## Installation instructions
 *
 * The simplest way to install involves creating a Terraform configuration with the following components:
 *
 * 1. A provider section that helps with the following things:
 *    1. AWS provider - Get cluster information.
 *    2. Helm provider - Deploy the Kompass Compute Helm chart.
 * 2. Invocation of the kompass-compute module that installs all required AWS resources.
 * 3. Invocation of the helm_release resource to deploy the Kompass Compute Helm chart.
 *    - The output of the kompass-compute module includes a values.yaml that gives the kompass-compute helm chart knowledge about the location of the deployed cloud resources.\
 *      The configuration below performs the plumbing.
 *
 * Below is a sample configuration for the necessary providers that help perform the later steps.
 *
 * If your setup is different, you will need to adjust the configuration accordingly.
 *
 * ```hcl
 * provider "aws" {}
 *
 * data "aws_eks_cluster" "eks_cluster" {
 *   name = var.cluster_name
 * }
 *
 * provider "helm" {
 *   kubernetes = {
 *     host                   = data.aws_eks_cluster.eks_cluster.endpoint
 *     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
 *
 *     exec = {
 *       api_version = "client.authentication.k8s.io/v1beta1"
 *       command     = "aws"
 *       # This requires the awscli to be installed locally where Terraform is executed
 *       args = ["eks", "get-token", "--cluster-name", var.cluster_name]
 *     }
 *   }
 * }
 * ```
 *
 * > This configuration works for helm version 3, for version 2 see the [Provider Configuration](#provider-configuration) section.
 *
 * Below is a configuration that deploys the Kompass Compute module and the Kompass Compute Helm chart.
 *
 * ```hcl
 * locals {
 *   cluster_name = "cluster-name"
 *   vpc_id       = data.aws_eks_cluster.this.vpc_config[0].vpc_id
 *   vpc_cidr     = data.aws_vpc.this.cidr_block
 *   subnet_ids   = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
 * }
 *
 * data "aws_eks_cluster" "this" {
 *   name = local.cluster_name
 * }
 *
 * data "aws_vpc" "this" {
 *   id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
 * }
 *
 * # Creates the cloud resources for Kompass Compute.
 * module "kompass_compute" {
 *   source  = "zesty-co/compute/kompass"
 *   version = "~> 1.0.0"
 *
 *   cluster_name = local.cluster_name
 *   vpc_id       = local.vpc_id
 *   subnet_ids   = local.subnet_ids
 *
 *   vpc_endpoint_security_group_rules = {
 *     ingress_https = {
 *       description = "HTTPS from VPC"
 *       cidr_blocks = [local.vpc_cidr]
 *     }
 *   }
 * }
 *
 * # The CRDs are managed by a separate chart, according to the helm best practices.
 * resource "helm_release" "kompass_compute_crd" {
 *   repository = "https://zesty-co.github.io/kompass-compute"
 *   # If you want to specify the exact version of the chart:
 *   # version    = "0.1.7"
 *   chart     = "kompass-compute-crd"
 *   name      = "kompass-compute-crd"
 *   namespace = "zesty-system"
 * }
 *
 * resource "helm_release" "kompass_compute" {
 *   repository = "https://zesty-co.github.io/kompass-compute"
 *   chart      = "kompass-compute"
 *   # If you want to specify the exact version of the chart:
 *   # version    = "0.1.7"
 *   name       = "kompass-compute"
 *   namespace  = "zesty-system"
 *
 *   values = [
 *     # Provide the helm chart with knowledge about the deployed cloud resources.
 *     module.kompass_compute.helm_values_yaml,
 *   ]
 *
 *   depends_on = [
 *     # Prevents from removing IAM roles and policies while deleting the Helm release
 *     module.kompass_compute,
 *     helm_release.kompass_compute_crd,
 *   ]
 * }
 * ```
 *
 * ## Deployed Resources
 *
 * - Creates IAM roles for various components of the Kompass Compute controller:
 *   - Hiberscaler
 *   - Image Size Calculator
 *   - Snapshooter
 *   - Telemetry Manager
 *
 * - SQS queue for spot instance termination notifications
 * - CloudWatch event rules for spot instance interruptions
 * - S3 VPC endpoint for secure access to S3
 * - Security groups for VPC endpoints
 * - EKS Pod Identity or IRSA (IAM Roles for Service Accounts) resources configs.
 *
 * ## Provider Configuration
 *
 * For Helm provider version 3 and above:
 *
 * ```hcl
 * provider "aws" {}
 *
 * data "aws_eks_cluster" "eks_cluster" {
 *   name = var.cluster_name
 * }
 *
 * provider "helm" {
 *   kubernetes = {
 *     host                   = data.aws_eks_cluster.eks_cluster.endpoint
 *     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
 *
 *     exec = {
 *       api_version = "client.authentication.k8s.io/v1beta1"
 *       command     = "aws"
 *       # This requires the awscli to be installed locally where Terraform is executed
 *       args = ["eks", "get-token", "--cluster-name", var.cluster_name]
 *     }
 *   }
 * }
 * ```
 *
 * For Helm provider version 2:
 *
 * ```hcl
 * provider "aws" {}
 *
 * data "aws_eks_cluster" "eks_cluster" {
 *   name = var.cluster_name
 * }
 *
 * provider "helm" {
 *   kubernetes {
 *     host                   = data.aws_eks_cluster.eks_cluster.endpoint
 *     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
 *
 *     exec {
 *       api_version = "client.authentication.k8s.io/v1beta1"
 *       command     = "aws"
 *       # This requires the awscli to be installed locally where Terraform is executed
 *       args = ["eks", "get-token", "--cluster-name", var.cluster_name]
 *     }
 *   }
 * }
 * ```
 *
 * ## Deploying the helm chart directly
 *
 * You might want to install the helm chart directly through a GitOps tool, such as ArgoCD, or something else.
 *
 * The helm chart requires knowledge about cloud resources deployed by the kompass-compute module, such as SQS queues, S3 VPC endpoints, IAM roles, and ECR pull-through cache rules.
 *
 * The terraform module outputs a values.yaml file that can be used to pass values to the helm chart.
 *
 * First deploy the module with all the required resources.
 *
 * Afterwards, the values.yaml can be retrieved from the terraform module directory by running `terraform output -raw helm_values_yaml > values.yaml`
 *
 * Visit the [helm chart repo](https://github.com/zesty-co/kompass-compute), follow the instructions, and provide it with the values.yaml from the aforementioned command.
 *
 * # Advanced Usage
 *
 * - [Pulling container images through ECR pull through cache](#pulling-container-images-through-ecr-pull-through-cache)
 * - [Passing values to the Helm Chart](#passing-values-to-the-helm-chart)
 * - [Using IAM Roles for Service Accounts (IRSA)](#using-iam-roles-for-service-accounts-irsa)
 * - [Disable S3 VPC Interface Endpoint creation](#disable-s3-vpc-interface-endpoint-creation)
 * - [API Reference](#requirements)
 *
 * ## Pulling container images through ECR pull through cache
 *
 * Caching the images on all Hibernated nodes can increase network costs.
 *
 * To reduce network costs, it's recommended to configure an ECR Pull-Through Cache and configure the nodes to pull images through it, thus only downloading each image from the internet once.
 *
 * The ECR pull through rules can be created using the `ecr` module as follows:
 *
 * ```hcl
 * module "ecr" {
 *   source  = "zesty-co/compute/kompass//modules/ecr"
 *   version = "~> 1.0.0"
 *
 *   ecr_pull_through_rule_name_prefix = "<Cluster Name>-"
 *
 *   # By default the ecr module creates an ECR pull through cache rule for each of the supported registries.
 *   # If you want to disable the creation of the ECR pull through cache rule for a specific registry, set the `create` variable to `false`.
 *   # If you want to specify credentials for a specific registry to access private images or avoid rate limits, set the `secret_arn` variable to the ARN of the secret, or `secret_content` to the content of the secret.
 *
 *   # registries = {
 *   #   "dockerhub" = {
 *   #     create = false
 *   #     secret_arn = "<Dockerhub Secret ARN>"
 *          # If you want to create a secret out of credentials, instead of using an existing secret
 *          secret_content = jsonencode({
 *            username    = "your-username"
 *            accessToken = "your-access-token"
 *          })
 *   #   },
 *   #   "ghcr" = {
 *   #     secret_arn = "<GitHub Container Registry Secret ARN>"
 *   #     # secret_content = ... # If you want to create a secret out of credentials, instead of using an existing secret
 *   #   }
 *   # }
 * }
 * ```
 *
 * > Note: It is recommended to deploy `ecr` module only once per region.
 * ECR pull-through cache rules are regional resources, and creating them multiple times is not necessary and may lead to conflicts.
 *
 * To connect the helm chart to the provided ECR repository, you need to provide the values.yaml file to the helm chart as follows:
 *
 * ```hcl
 * resource "helm_release" "kompass_compute" {
 *   repository = "https://zesty-co.github.io/kompass-compute"
 *   chart      = "kompass-compute"
 *   name       = "kompass-compute"
 *   namespace  = "zesty-system"
 *
 *   values = [
 *     module.kompass_compute.helm_values_yaml,
 *     module.ecr.helm_values_yaml,
 *     # Add any additional values here, such as the values.yaml provided by the kompass-compute module
 *   ]
 * }
 * ```
 *
 * ## Passing values to the Helm Chart
 *
 * The `kompass_compute` module and the `ecr` module output a `helm_values_yaml` variable that can be used to pass values to the Helm chart.
 *
 * These `helm_values_yaml` variables inform the controllers of the location of the deployed cloud resources, such as SQS queues, S3 VPC endpoints, IAM roles, and ECR pull-through cache rules.
 * You can use it in your Helm chart as follows:
 *
 * ```hcl
 * resource "helm_release" "kompass_compute" {
 *   repository = "https://zesty-co.github.io/kompass-compute"
 *   chart      = "kompass-compute"
 *   name       = "kompass-compute"
 *   namespace  = "zesty-system"
 *
 *   values = [
 *     module.ecr.helm_values_yaml,
 *     module.kompass_compute.helm_values_yaml,
 *     # Add any additional values here
 *   ]
 * }
 * ```
 *
 * The `helm_values_yaml` can be also accessed using the `terraform_remote_state` data source if you want to access it from a separate terraform module.
 *
 * The `helm_values_yaml` from ECR module contains the ECR Pull-Through Cache Rules configuration,
 * and has the following structure:
 *
 * ```yaml
 * cachePullMappings:
 *   dockerhub:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-dockerhub"
 *   ghcr:
 *     - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-ghcr"
 * ```
 *
 * Name of the ECR repository will be in the format `zesty-{registry_name}` where `{registry_name}` is the key from the `registries` map (e.g., `zesty-dockerhub`, `zesty-ghcr`, etc.).
 * It can be overridden by setting the `ecr_pull_through_rule_name_prefix` variable in the module configuration,
 * or by using the `ecr_repository_prefix_override` field in the `registries` map for each registry.
 *
 * The `helm_values_yaml` from the Kompass Compute module contains the necessary configuration for the Kompass Compute controller.
 * It has the following structure:
 *
 * ```yaml
 * qubexConfig:
 *   infraConfig:
 *     aws:
 *       spotFailuresQueueUrl: "https://sqs.us-west-2.amazonaws.com/123456789012/ZestyKompassCompute-cluster-name"
 *       s3VpcEndpointID: "vpce-1234567890abcdef0"
 * ```
 *
 * ## Using IAM Roles for Service Accounts (IRSA)
 *
 * By default the module creates EKS Pod Identity roles for the Kompass Compute controller components.
 *
 * If you want to use IRSA (IAM Roles for Service Accounts) instead, set the `enable_irsa` variable to `true`
 * and provide the OIDC provider ARN using the `irsa_oidc_provider_arn` variable.
 *
 * Optionally, you can disable EKS Pod Identity by setting `enable_pod_identity` to `false`.
 *
 * ```hcl
 * module "kompass_compute" {
 *   source  = "zesty-co/compute/kompass"
 *   version = "~> 1.0.0"
 *
 *   cluster_name = "cluster-name"
 *
 *   enable_pod_identity    = false
 *   enable_irsa            = true
 *   irsa_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EXAMPLE1234567890"
 * }
 * ```
 *
 * ## Disable S3 VPC Interface Endpoint creation
 *
 * An S3 VPC Interface Endpoint is created by default to allow the Kompass Compute controller to access container images stored securely and cheaply.
 * Images are not downloaded from the public internet, but rather from the S3 VPC Interface Endpoint.
 *
 * If you have an S3 VPC Gateway Endpoint or any other reason to disable the creation of the S3 VPC Interface Endpoint,
 * set the `create_s3_vpc_endpoint` variable to `false`:
 *
 * ```hcl
 * module "kompass_compute" {
 *   source  = "zesty-co/compute/kompass"
 *   version = "~> 1.0.0"
 *
 *   cluster_name           = "cluster-name"
 *   create_s3_vpc_endpoint = false
 * }
 * ```
 */


locals {
  create_hiberscaler_iam_role           = var.create && var.create_hiberscaler_iam_role
  create_snapshooter_iam_role           = var.create && var.create_snapshooter_iam_role
  create_telemetry_manager_iam_role     = var.create && var.create_telemetry_manager_iam_role
  create_image_size_calculator_iam_role = var.create && var.create_image_size_calculator_iam_role

  # Tags used for all resources
  tags = {
    Zesty = "true"
  }
}

################################################################################
# Kompass Compute IAM Roles
################################################################################

module "iam_hiberscaler" {
  source = "./modules/iam"

  create                            = local.create_hiberscaler_iam_role
  cluster_name                      = var.cluster_name
  iam_role_name                     = var.iam_hiberscaler_role_name
  iam_role_use_name_prefix          = var.iam_hiberscaler_role_use_name_prefix
  iam_role_path                     = var.iam_hiberscaler_role_path
  iam_role_description              = var.iam_hiberscaler_role_description
  iam_role_max_session_duration     = var.iam_hiberscaler_role_max_session_duration
  iam_role_permissions_boundary_arn = var.iam_hiberscaler_role_permissions_boundary_arn
  iam_role_tags                     = var.iam_hiberscaler_role_tags
  iam_policy_name                   = var.iam_hiberscaler_policy_name
  iam_policy_use_name_prefix        = var.iam_hiberscaler_policy_use_name_prefix
  iam_policy_path                   = var.iam_hiberscaler_policy_path
  iam_policy_description            = var.iam_hiberscaler_policy_description
  iam_policy_statements             = var.iam_hiberscaler_policy_statements
  iam_use_hiberscaler_policy        = true
  iam_role_policies                 = var.iam_hiberscaler_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_hiberscaler_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.hiberscaler_service_account_name

  sqs_queue_name = local.queue_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "iam_image_size_calculator" {
  source = "./modules/iam"

  create                               = local.create_image_size_calculator_iam_role
  cluster_name                         = var.cluster_name
  iam_role_name                        = var.iam_image_size_calculator_role_name
  iam_role_use_name_prefix             = var.iam_image_size_calculator_role_use_name_prefix
  iam_role_path                        = var.iam_image_size_calculator_role_path
  iam_role_description                 = var.iam_image_size_calculator_role_description
  iam_role_max_session_duration        = var.iam_image_size_calculator_role_max_session_duration
  iam_role_permissions_boundary_arn    = var.iam_image_size_calculator_role_permissions_boundary_arn
  iam_role_tags                        = var.iam_image_size_calculator_role_tags
  iam_policy_name                      = var.iam_image_size_calculator_policy_name
  iam_policy_use_name_prefix           = var.iam_image_size_calculator_policy_use_name_prefix
  iam_policy_path                      = var.iam_image_size_calculator_policy_path
  iam_policy_description               = var.iam_image_size_calculator_policy_description
  iam_policy_statements                = var.iam_image_size_calculator_policy_statements
  iam_use_image_size_calculator_policy = true
  iam_role_policies                    = var.iam_image_size_calculator_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_image_size_calculator_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.image_size_calculator_service_account_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "iam_snapshooter" {
  source = "./modules/iam"

  create                            = local.create_snapshooter_iam_role
  cluster_name                      = var.cluster_name
  iam_role_name                     = var.iam_snapshooter_role_name
  iam_role_use_name_prefix          = var.iam_snapshooter_role_use_name_prefix
  iam_role_path                     = var.iam_snapshooter_role_path
  iam_role_description              = var.iam_snapshooter_role_description
  iam_role_max_session_duration     = var.iam_snapshooter_role_max_session_duration
  iam_role_permissions_boundary_arn = var.iam_snapshooter_role_permissions_boundary_arn
  iam_role_tags                     = var.iam_snapshooter_role_tags
  iam_policy_name                   = var.iam_snapshooter_policy_name
  iam_policy_use_name_prefix        = var.iam_snapshooter_policy_use_name_prefix
  iam_policy_path                   = var.iam_snapshooter_policy_path
  iam_policy_description            = var.iam_snapshooter_policy_description
  iam_policy_statements             = var.iam_snapshooter_policy_statements
  iam_use_snapshooter_policy        = true
  iam_role_policies                 = var.iam_snapshooter_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_snapshooter_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.snapshooter_service_account_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "iam_telemetry_manager" {
  source = "./modules/iam"

  create                            = local.create_telemetry_manager_iam_role
  cluster_name                      = var.cluster_name
  iam_role_name                     = var.iam_telemetry_manager_role_name
  iam_role_use_name_prefix          = var.iam_telemetry_manager_role_use_name_prefix
  iam_role_path                     = var.iam_telemetry_manager_role_path
  iam_role_description              = var.iam_telemetry_manager_role_description
  iam_role_max_session_duration     = var.iam_telemetry_manager_role_max_session_duration
  iam_role_permissions_boundary_arn = var.iam_telemetry_manager_role_permissions_boundary_arn
  iam_role_tags                     = var.iam_telemetry_manager_role_tags
  iam_policy_name                   = var.iam_telemetry_manager_policy_name
  iam_policy_use_name_prefix        = var.iam_telemetry_manager_policy_use_name_prefix
  iam_policy_path                   = var.iam_telemetry_manager_policy_path
  iam_policy_description            = var.iam_telemetry_manager_policy_description
  iam_policy_statements             = var.iam_telemetry_manager_policy_statements
  iam_use_telemetry_manager_policy  = true
  iam_role_policies                 = var.iam_telemetry_manager_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_telemetry_manager_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.telemetry_manager_service_account_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

################################################################################
# Node Termination Queue
################################################################################

locals {
  enable_spot_termination = var.create && var.enable_spot_termination

  queue_name = coalesce(var.queue_name, "ZestyKompassCompute-${var.cluster_name}")
}

resource "aws_sqs_queue" "this" {
  count = local.enable_spot_termination ? 1 : 0

  name                              = local.queue_name
  message_retention_seconds         = 300
  sqs_managed_sse_enabled           = var.queue_managed_sse_enabled ? var.queue_managed_sse_enabled : null
  kms_master_key_id                 = var.queue_kms_master_key_id
  kms_data_key_reuse_period_seconds = var.queue_kms_data_key_reuse_period_seconds

  tags = merge(
    local.tags,
    var.tags,
  )
}

data "aws_iam_policy_document" "queue" {
  count = local.enable_spot_termination ? 1 : 0

  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this[0].arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
  statement {
    sid    = "DenyHTTP"
    effect = "Deny"
    actions = [
      "sqs:*"
    ]
    resources = [aws_sqs_queue.this[0].arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  count = local.enable_spot_termination ? 1 : 0

  queue_url = aws_sqs_queue.this[0].url
  policy    = data.aws_iam_policy_document.queue[0].json
}

################################################################################
# Node Termination Event Rules
################################################################################

locals {
  events = {
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Kompass Compute interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.events : k => v if local.enable_spot_termination }

  name_prefix   = "${var.rule_name_prefix}${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(
    local.tags,
    var.tags,
  )
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.events : k => v if local.enable_spot_termination }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "ZestyKompassComputeInterruptionQueueTarget"
  arn       = aws_sqs_queue.this[0].arn
}

################################################################################
# S3 VPC Endpoint
################################################################################

locals {
  create_s3_vpc_endpoint = var.create && var.create_s3_vpc_endpoint
  security_group_ids     = local.create_s3_vpc_endpoint_security_group ? concat(var.vpc_endpoint_security_group_ids, [aws_security_group.this[0].id]) : var.vpc_endpoint_security_group_ids
}

data "aws_vpc_endpoint_service" "this" {
  count = local.create_s3_vpc_endpoint ? 1 : 0

  service      = "s3"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "this" {
  count = local.create_s3_vpc_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.this[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = local.security_group_ids
  subnet_ids          = var.subnet_ids
  policy              = var.vpc_endpoint_policy
  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  ip_address_type     = var.vpc_endpoint_ip_address_type

  dynamic "dns_options" {
    for_each = var.vpc_endpoint_dns_options.dns_record_ip_type != null || var.vpc_endpoint_dns_options.private_dns_only_for_inbound_resolver_endpoint != null ? [var.vpc_endpoint_dns_options] : []
    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  tags = merge(
    local.tags,
    var.tags,
    {
      "Name" = "zesty-kompass-compute-s3-${var.cluster_name}"
    },
    var.vpc_endpoint_tags,
  )

  timeouts {
    create = try(var.vpc_endpoint_timeouts.create, "10m")
    update = try(var.vpc_endpoint_timeouts.update, "10m")
    delete = try(var.vpc_endpoint_timeouts.delete, "10m")
  }
}

################################################################################
# Security Group
################################################################################

locals {
  create_s3_vpc_endpoint_security_group = var.create && var.create_s3_vpc_endpoint && var.create_s3_vpc_endpoint_security_group
}

resource "aws_security_group" "this" {
  count = local.create_s3_vpc_endpoint_security_group ? 1 : 0

  name        = var.vpc_endpoint_security_group_use_name_prefix ? null : var.vpc_endpoint_security_group_name
  name_prefix = var.vpc_endpoint_security_group_use_name_prefix ? "${var.vpc_endpoint_security_group_name}-" : null
  description = var.vpc_endpoint_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.tags,
    {
      "Name" = var.vpc_endpoint_security_group_name
    },
    var.vpc_endpoint_security_group_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.vpc_endpoint_security_group_rules : k => v if local.create_s3_vpc_endpoint_security_group }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = try(each.value.protocol, "tcp")
  from_port         = try(each.value.from_port, 443)
  to_port           = try(each.value.to_port, 443)
  type              = try(each.value.type, "ingress")

  # Optional
  description              = try(each.value.description, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}
