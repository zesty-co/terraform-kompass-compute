<!-- BEGIN_TF_DOCS -->
# Quick Start
This example shows how to install Kompass Compute with the most basic setup.
It deploys 3 components:
1. The Kompass Compute module, which creates the cloud resources for Kompass Compute.
2. The Kompass Compute Helm chart.
3. The CRDs of the Kompass Compute Helm chart, through a separate chart, according to the helm best practices.

Before applying the module, ensure that the providers target the correct EKS cluster, and AWS account.

You need to ensure the following:
1. The AWS provider is configured to target the correct AWS account.\
By default the module will use the accounted configured in your local aws cli.\
It can be overriden by modifying the `aws` provider configuration inside [providers.tf](./providers.tf).
2. The name of the EKS cluster is provided in the `cluster_name` variable through a tfvars or env var.\
See [variables.tf](./variables.tf) for more details.
3. You have the helm binary installed and available in your PATH and the helm provider is configured correctly.

The module works in the following order:
1. Scrapes the EKS cluster for information.
2. Creates the cloud resources for Kompass Compute.
3. Deploys the CRDs of the Kompass Compute Helm chart, through a separate chart, according to the helm best practices.
4. Deploys the Kompass Compute Helm chart, providing it with knowledge about the deployed cloud resources.

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
| <a name="module_kompass_compute"></a> [kompass\_compute](#module\_kompass\_compute) | zesty-co/compute/kompass | ~> 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.kompass_compute](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kompass_compute_crd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_values_yaml"></a> [helm\_values\_yaml](#output\_helm\_values\_yaml) | Merged helm\_values\_yaml outputs from the kompass\_compute and ecr submodules |
<!-- END_TF_DOCS -->