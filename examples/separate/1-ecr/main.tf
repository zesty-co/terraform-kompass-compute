/**
 * # ECR per region
 *
 * This example demonstrates how to set up ECR pull-through cache rules for Docker Hub and GitHub Container Registry
 * in a separate Terraform module. This module should be deployed once per region to manage ECR repositories.
 * Clusters can then reference these repositories to pull images from Docker Hub and GitHub Container Registry.
 *
 * ## Prerequisites
 *
 * - Docker and GitHub Container Registry credentials stored in AWS Secrets Manager
 *
 * ## Configuration
 *
 * The example uses the following variables:
 *
 * - `dockerhub_secret_arn`: The ARN of the AWS Secrets Manager secret for Docker Hub credentials.
 * - `ghcr_secret_arn`: The ARN of the AWS Secrets Manager secret for GitHub Container Registry credentials.
 *
 * ## Image registry secrets
 *
 * The example uses existing AWS Secrets Manager secrets for Docker Hub and GitHub Container Registry credentials.
 * These secrets are used to authenticate with the respective registries when pulling images.
 * The secrets should be created in the format expected by the ECR pull-through cache rules.
 *
 * Check the [ECR module documentation](../../../modules/ecr/README.md) for more details on how to create these secrets.
 *
 * ## Helm values
 *
 * The ECR module outputs a `helm_values_yaml` variable that can be used to configure the Helm chart for Kompass Compute.
 * This variable contains the necessary ECR configuration for the Helm chart.
 *
 * Check the [ECR module documentation](../../../modules/ecr/README.md) for more details on how to use this variable.
 *
 */

# Creates ECR pull-through cache rules and manages authentication credentials in AWS Secrets Manager.
module "ecr" {
  source = "../../../modules/ecr"

  registries = {
    "dockerhub" = {
      secret_arn = var.dockerhub_secret_arn
    },
    "ghcr" = {
      secret_arn = var.ghcr_secret_arn
    }
  }
}
