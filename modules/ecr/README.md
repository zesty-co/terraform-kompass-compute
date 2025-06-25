<!-- BEGIN_TF_DOCS -->
# Zesty Kompass Compute AWS ECR Pull-Through Cache Module

This Terraform module creates and manages AWS ECR Pull-Through Cache Rules and their associated secrets in AWS Secrets Manager.

## Features

- Creates ECR Pull-Through Cache Rules for various registries
- Manages authentication credentials in AWS Secrets Manager

## Usage

```hcl
module "ecr_pull_through_cache" {
  source = "git@github.com:zesty-co/terraform-kompass-compute.git//modules/ecr"

  # Basic configuration with default public registries
  # By default, creates rules for dockerhub, ghcr, kubernetes-registry, etc.

  # It is required to provide `dockerhub` and `ghcr` secrets if you want to use them.
  # You can provide secret ARN or secret content in format: "{\"username\":\"USERNAME\",\"accessToken\":\"TOKEN\"}"
  registries = {
    dockerhub = {
      secret_content = jsonencode({
        username    = "your-username"
        accessToken = "your-access-token"
      })
    }
    ghcr = {
      secret_arn = "aws:secretsmanager:REGION:123456789012:secret:ecr-pullthroughcache/ghcr"
    }
  }
}
```

## ECR Secrets

This module can use existing secrets or create new ones in AWS Secrets Manager for the ECR Pull-Through Cache Rules.
You can specify the secrets using either `secret_arn` or `secret_content`.

Format of the `secret_content` or secret in AWS Secrets Manager should be a JSON string containing the `username` and `accessToken` fields:

```json
  {
    "username": "your-username",
    "accessToken": "your-access-token"
  }
```

## Disable ECR Pull-Through Cache Rule Creation

To disable the creation of the ECR Pull-Through Cache Rule, set the `create` variable to `false`:

```hcl
registries = {
  dockerhub = {
    create = false
  }
}
```

## Passing values to Helm Chart

The module outputs a `helm_values_yaml` variable that can be used to pass values to the Helm chart.
This variable contains the necessary configuration for the ECR Pull-Through Cache Rules.
You can use it in your Helm chart as follows:

```hcl
resource "helm_release" "kompass_compute" {
  repository = "https://zesty-co.github.io/kompass-compute"
  chart      = "kompass-compute"
  name       = "kompass-compute"
  namespace  = "zesty-system"

  values = [
    module.ecr.helm_values_yaml,
  ]
}
```

The `helm_values_yaml` can be also accessed using the `terraform_remote_state` data source
or generated directly in the module like this:

```hcl
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
locals {
  ecr_helm_values_yaml = jsonencode({
    cachePullMappings = {
      dockerhub: [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-dockerhub""
      }],
      ghcr: [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-ghcr"
      }],
      ecr: [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-ecr"
      }],
      k8s: [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-k8s"
      }],
      quay: [{
        proxyAddress = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/zesty-quay"
      }],
    }
  })
}
```

The generated YAML can look like this:

```yaml
cachePullMappings:
  dockerhub:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-dockerhub"
  ghcr:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-ghcr"
  ecr:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-ecr"
  k8s:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-k8s"
  quay:
    - proxyAddress: "123456789012.dkr.ecr.us-west-2.amazonaws.com/zesty-quay"
```

Name of the ECR repository will be in the format `zesty-{registry_name}` where `{registry_name}` is the key from the `registries` map (e.g., `zesty-dockerhub`, `zesty-ghcr`, etc.).
It can be overridden by setting the `ecr_pull_through_rule_name_prefix` variable in the module configuration,
or by using the `ecr_repository_prefix_override` field in the `registries` map for each registry.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
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
| [aws_ecr_pull_through_cache_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_ecr_pull_through_rule_name_prefix"></a> [ecr\_pull\_through\_rule\_name\_prefix](#input\_ecr\_pull\_through\_rule\_name\_prefix) | Prefix for the ECR Pull Through Cache Rule name (e.g., 'myorg-'). The registry key will be appended (e.g., 'myorg-dockerhub'). | `string` | `"zesty-"` | no |
| <a name="input_registries"></a> [registries](#input\_registries) | A map of configurations for ECR pull-through cache rules and their associated secrets. The map key (e.g., 'dockerhub', 'ghcr') is used in naming resources and outputs. | <pre>map(object({<br/>    # Whether to create the pull-through rule for this registry.<br/>    create = optional(bool, true)<br/><br/>    # The URL of the upstream registry (e.g., "registry-1.docker.io", "ghcr.io").<br/>    upstream_registry_url = optional(string, null)<br/><br/>    # Optional: Override for the ECR repository prefix. If null, uses var.ecr_pull_through_rule_name_prefix + key.<br/>    ecr_repository_prefix_override = optional(string, null)<br/><br/>    # Secret configuration:<br/>    # - If 'secret_arn' is provided, it will be used.<br/>    # - If 'secret_content' is provided (and 'secret_arn' is not), a new secret will be created.<br/>    # - If neither is provided, the rule will be created without credentials (for public registries).<br/>    secret_arn     = optional(string, null)<br/>    secret_content = optional(string, null)<br/><br/>    # Optional: Override for the secret name prefix. If null, uses var.secret_name_prefix + key + "-".<br/>    secret_name_prefix_override = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_secret_name_prefix"></a> [secret\_name\_prefix](#input\_secret\_name\_prefix) | Prefix for the Secret name (e.g., 'ecr-pullthroughcache/myorg-'). The registry key will be appended (e.g., 'ecr-pullthroughcache/myorg-dockerhub-'). | `string` | `"ecr-pullthroughcache/zesty-"` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | Recovery window in days for the secret | `number` | `30` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_pull_through_cache_rule_ids"></a> [ecr\_pull\_through\_cache\_rule\_ids](#output\_ecr\_pull\_through\_cache\_rule\_ids) | Map of created ECR pull through cache rule IDs |
| <a name="output_ecr_pull_through_cache_rule_prefixes"></a> [ecr\_pull\_through\_cache\_rule\_prefixes](#output\_ecr\_pull\_through\_cache\_rule\_prefixes) | Map of ECR pull through cache rule prefixes |
| <a name="output_ecr_pull_through_cache_rules"></a> [ecr\_pull\_through\_cache\_rules](#output\_ecr\_pull\_through\_cache\_rules) | Map of created ECR pull through cache rules |
| <a name="output_helm_values"></a> [helm\_values](#output\_helm\_values) | Map of Helm chart values for ECR pull through cache |
| <a name="output_helm_values_yaml"></a> [helm\_values\_yaml](#output\_helm\_values\_yaml) | YAML encoded Helm chart values for ECR pull through cache |
| <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns) | Map of created ECR pull through cache secret ARNs |
| <a name="output_secret_version_arns"></a> [secret\_version\_arns](#output\_secret\_version\_arns) | Map of created ECR pull through cache secret version ARNs |
| <a name="output_secret_version_ids"></a> [secret\_version\_ids](#output\_secret\_version\_ids) | Map of created ECR pull through cache secret version IDs |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Map of created ECR pull through cache secrets |
<!-- END_TF_DOCS -->