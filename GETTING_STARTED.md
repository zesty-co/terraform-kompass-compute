# Getting Started with Kompass Compute

This guide will help you deploy Kompass Compute on your Kubernetes cluster, including the necessary cloud infrastructure resources. Kompass Compute maintains a pool of hibernated nodes that can be quickly resumed to protect your workloads against spikes in resource demands or spot instance terminations.

## Prerequisites

Before you begin, make sure you have the following:

- A Kubernetes cluster (version 1.19+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured to communicate with your cluster
- [Helm](https://helm.sh/docs/intro/install/) (version 3.2.0+) installed
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (version 1.0.0+) installed
- AWS CLI configured with appropriate credentials
- Kompass Insight Agent installed in your cluster

## Step 1: Create Cloud Resources with Terraform

Kompass Compute requires specific cloud resources for operation. These are divided into two categories:

- **Regional resources**: Resources shared across all clusters in a region (ECR repositories, etc.)
- **Cluster-specific resources**: Resources specific to a single cluster (SQS queues, IAM roles, etc.)

You can deploy these resources using the provided Terraform modules.

### Option 1: All-in-One Deployment

For simplicity, you can deploy all required resources at once using the Terraform modules directly:

```hcl
# main.tf

# Provider configuration for AWS and Kubernetes
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
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

# Creates ECR pull-through cache rules for Docker Hub, GitHub Container Registry, etc.
module "ecr" {
  source = "github.com/zesty-co/terraform-kompass-compute//modules/ecr"

  ecr_pull_through_rule_name_prefix = "${var.cluster_name}-"

  registries = {
    "dockerhub" = {
      secret_arn = var.dockerhub_secret_arn
    },
    "ghcr" = {
      secret_arn = var.ghcr_secret_arn
    }
  }
}

# Creates IAM roles and policies, SQS queues, and other resources for Kompass Compute
module "kompass_compute" {
  source = "github.com/zesty-co/terraform-kompass-compute"

  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids

  vpc_endpoint_security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [var.vpc_endpoints_ingress_cidr_block]
    }
  }
}

# Extract Helm values from Terraform outputs
output "ecr_helm_values" {
  description = "Helm values for ECR pull-through cache configuration"
  value       = module.ecr.helm_values_yaml
}

output "kompass_compute_helm_values" {
  description = "Helm values for Kompass Compute configuration"
  value       = module.kompass_compute.helm_values_yaml
}
```

```hcl
# variables.tf

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where S3 VPC endpoints will be created"
  type        = list(string)
}

variable "vpc_endpoints_ingress_cidr_block" {
  description = "CIDR block for ingress traffic to the VPC endpoints"
  type        = string
}

variable "dockerhub_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for Docker Hub credentials"
  type        = string
}

variable "ghcr_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for GitHub Container Registry credentials"
  type        = string
}

variable "helm_values_yaml" {
  description = "Additional Helm values to customize the deployment"
  type        = string
  default     = ""
}
```

To use this module:

```bash
# Initialize Terraform
terraform init

# Create a tfvars file with your configuration
cat > terraform.tfvars <<EOF
cluster_name                     = "my-cluster"
vpc_id                           = "vpc-12345678"
subnet_ids                       = ["subnet-12345678", "subnet-23456789"]
vpc_endpoints_ingress_cidr_block = "10.0.0.0/16"
dockerhub_secret_arn             = "arn:aws:secretsmanager:us-east-1:123456789012:secret:ecr-pullthroughcache/dockerhub-secret"
ghcr_secret_arn                  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:ecr-pullthroughcache/ghcr-secret"

helm_values_yaml = <<EOT
# Custom Helm values here
EOT
EOF

# Review the plan
terraform plan -out=tfplan

# Apply the plan
terraform apply tfplan

# Save outputs for later use with Helm
terraform output -json > kompass-compute-outputs.json
```

> **Note:** The all-in-one deployment option is not recommended for production environments. It is better to deploy regional resources separately to enable better resource sharing, security, and management across multiple clusters. Use the separate regional and cluster resource deployment approach described below for improved scalability and maintainability.

### Option 2: Separate Regional and Cluster Resources

For production environments, you should separate regional and cluster-specific resources:

#### Step 1a: Deploy Regional Resources (ECR)

```hcl
# ecr-regional/main.tf

provider "aws" {}

# Creates ECR pull-through cache rules for Docker Hub, GitHub Container Registry, etc.
module "ecr" {
  source = "github.com/zesty-co/terraform-kompass-compute//modules/ecr"

  registries = {
    "dockerhub" = {
      secret_arn = var.dockerhub_secret_arn
    },
    "ghcr" = {
      secret_arn = var.ghcr_secret_arn
    }
  }
}

output "helm_values_yaml" {
  value = module.ecr.helm_values_yaml
}
```

```hcl
# ecr-regional/variables.tf

variable "dockerhub_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for Docker Hub credentials"
  type        = string
}

variable "ghcr_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for GitHub Container Registry credentials"
  type        = string
}
```

To use this module:

```bash
cd ecr-regional

# Initialize Terraform
terraform init

# Create a tfvars file with your configuration
cat > terraform.tfvars <<EOF
dockerhub_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:ecr-pullthroughcache/dockerhub-secret"
ghcr_secret_arn      = "arn:aws:secretsmanager:us-east-1:123456789012:secret:ecr-pullthroughcache/ghcr-secret"
EOF

# Review the plan
terraform plan -out=tfplan

# Apply the plan
terraform apply tfplan
```

#### Step 1b: Deploy Cluster-Specific Resources

```hcl
# kompass-cluster/main.tf

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
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

# Creates IAM roles and policies, SQS queues, and other resources for Kompass Compute
module "kompass_compute" {
  source = "path/to/modules/kompass-compute"

  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids

  vpc_endpoint_security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [var.vpc_endpoints_ingress_cidr_block]
    }
  }
}

# Note: Instead of using a helm_release resource in Terraform, we'll use the Helm command directly
# with values from Terraform outputs

output "helm_values_yaml" {
  value = module.kompass_compute.helm_values_yaml
}
```

To use this module:

```bash
cd kompass-cluster

# Initialize Terraform
terraform init

# Create a tfvars file with your configuration
cat > terraform.tfvars <<EOF
cluster_name                     = "my-cluster"
vpc_id                           = "vpc-12345678"
subnet_ids                       = ["subnet-12345678", "subnet-23456789"]
vpc_endpoints_ingress_cidr_block = "10.0.0.0/16"
EOF

# Review the plan
terraform plan -out=tfplan

# Apply the plan
terraform apply tfplan
```

## Step 2: Install Kompass Compute Helm Chart

Kompass Compute can be deployed in two ways:

1. Single Helm chart `kompass-compute`: Contains both the core components and CRDs
2. Separate charts approach (useful for CRD management)

### Option 1: Single Chart Deployment

You can deploy Kompass Compute using a single Helm chart, which will install the project including all CRDs:

```bash
# Add the Kompass Helm repository (if not already added)
helm repo add kompass-compute https://your-helm-repo-url
helm repo update

# Install the Kompass Compute chart with CRDs
helm install kompass-compute kompass-compute/kompass-compute \
  --namespace zesty-system \
  --create-namespace
```

> **Note:** When using the single chart approach, CRDs will need to be updated manually after the initial installation when upgrading to newer versions.

### Option 2: Separate CRD Chart (For CRD Management)

If you need to manage CRDs separately (e.g., for upgrading CRDs independently), you can use the `kompass-compute-crd` chart:

```bash
# Install or upgrade just the CRDs
helm install kompass-compute-crd kompass-compute/kompass-compute-crd \
  --namespace zesty-system \
  --create-namespace
```

### Step 2a: Prepare Helm Values from Terraform Outputs

Create a `values.yaml` file for the Helm chart using the Terraform outputs:

```bash
# Create temporary value files from terraform outputs
# Get ECR values from the regional module
(cd ecr-regional && terraform output -raw helm_values_yaml) > /tmp/ecr-values.yaml

# Get values from the cluster-specific module
(cd kompass-cluster && terraform output -raw helm_values_yaml) > /tmp/kompass-values.yaml
```

### Step 2b: Install Kompass Compute

Now install the Kompass Compute chart with the values from Terraform:

```bash
helm install kompass-compute kompass/kompass-compute \
  --namespace zesty-system \
  --values /tmp/ecr-values.yaml \
  --values /tmp/kompass-values.yaml \
  --values kompass-compute-values.yaml
```

## Step 3: Verify the Installation

Verify that all Kompass Compute components are running:

```bash
# Check pod status
kubectl get pods -n zesty-system

# Verify the controllers are running
kubectl get deployment -n zesty-system
```

### Checking the Custom Resources

```bash
# List available QScalers
kubectl get qscalers -A

# List WorkloadDescriptors (used for workload protection)
kubectl get workloaddescriptors -A
```

## Step 4: Protecting Your First Workload

To protect a workload with Kompass Compute, create a `WorkloadDescriptor` that references your workload:

```yaml
apiVersion: kompass.zesty.co/v1alpha1
kind: WorkloadDescriptor
metadata:
  name: my-deployment-protection
  namespace: my-app
spec:
  workloadReference:
    apiVersion: apps/v1
    kind: Deployment
    name: my-deployment
  protection:
    resources:
      cpu: "2"
      memory: "4Gi"
    spot:
      active: true
    spike:
      active: true
      strategy: default
      threshold: "50%"
```

Apply this resource to your cluster:

```bash
kubectl apply -f workload-descriptor.yaml
```

## Troubleshooting

If you encounter issues during installation or operation:

1. Verify all pods are running:
   ```bash
   kubectl get pods -n zesty-system
   ```

2. Check the logs of the relevant components:
   ```bash
   kubectl logs -n zesty-system deployment/kompass-compute-hiberscaler
   kubectl logs -n zesty-system deployment/kompass-compute-cache
   ```

3. Verify the QubexConfig is correctly configured:
   ```bash
   kubectl get qubexconfig -n zesty-system -o yaml
   ```

4. Check for events related to WorkloadDescriptors:
   ```bash
   kubectl describe workloaddescriptor my-deployment-protection -n my-app
   ```

## Uninstalling Kompass Compute

To uninstall Kompass Compute:

```bash
# Uninstall the Kompass Compute chart
helm uninstall kompass-compute -n zesty-system

# If you installed the CRD chart separately, uninstall it as well
helm uninstall kompass-compute-crd -n zesty-system
```

> **Note:** If you deployed using the single chart approach, the CRDs will remain in the cluster even after uninstallation. You can manually delete them if needed with `kubectl delete crd <crd-name>`.
