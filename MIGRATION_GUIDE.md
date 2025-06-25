# Migrating from qubexctl to Helm-based Kompass Compute Installation

This guide helps users migrate from the legacy `qubexctl`-based installation of Kompass Compute to the new Helm-based installation method. This migration ensures you can take advantage of the latest features and improvements while preserving your existing configuration and workload protections.

## Prerequisites

Before beginning the migration, ensure you have:

- Access to your Kubernetes cluster with sufficient permissions
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured to communicate with your cluster
- [Helm](https://helm.sh/docs/intro/install/) (version 3.2.0+) installed
- The existing `qubexctl` binary used for the previous installation
- [Terraform](https://www.terraform.io/downloads) (version 1.0.0+) installed
- AWS CLI configured with appropriate credentials

## Terraform Dependencies for Cloud Resources

The new Helm-based installation requires specific cloud infrastructure resources that are managed through Terraform. Unlike the previous `qubexctl` installation which handled these automatically, you'll need to:

1. Create AWS IAM roles and policies for Kompass Compute components
2. Set up SQS queues for node lifecycle management
3. Configure ECR repositories (optional pull-through cache)
4. Set up appropriate VPC endpoints for private clusters

The Terraform modules provided with Kompass Compute will create these resources with minimal configuration. Refer to the [Getting Started Guide](./GETTING_STARTED.md) for detailed Terraform configuration options.

## Step 1: Backup Existing Configuration

Before making any changes, back up your existing configuration to ensure a smooth transition and recovery if needed.

### 1.1: Backup QubexConfig

The QubexConfig contains your global configuration settings. Back it up with:

```bash
kubectl get qubexconfig qubex-config -n zesty-kompass-compute -o yaml > qubex-config.yaml
```

### 1.2: Backup QScalers

QScalers define how your cluster autoscaling behaves. Back them up with:

```bash
kubectl get qscaler -A -o yaml > qscalers.yaml
```

### 1.3: Backup WorkloadDescriptors

WorkloadDescriptors define which workloads are protected and how. Back them up with:

```bash
kubectl get workloaddescriptor -A -o yaml > workload-descriptors.yaml
```

## Step 2: Uninstall Legacy Kompass Compute

Uninstall the existing Kompass Compute installation using the `qubexctl` binary:

```bash
./qubexctl qscaler uninstall aws
```

This command will:
- Remove all Kompass Compute components from your cluster
- Clean up associated resources

## Step 3: Extract Configuration Values for Helm Installation

To preserve your existing configuration when migrating to the Helm-based installation, you need to extract relevant values from your backed-up QubexConfig and create a values.yaml file for Helm.

### 3.1: Extract Configuration Using the Script

We've provided a script in the repository that automatically extracts values from your backed-up QubexConfig and creates a properly formatted values.yaml file for the Helm chart. The script is located at [./scripts/extract_config.sh](./scripts/extract_config.sh).

The script handles mapping values from the old configuration structure to the new Helm chart values structure, ensuring compatibility while preserving your settings.

### 3.2: Using the Extraction Script

To use the extraction script:

1. **Install Dependencies**: The script requires [yq](https://github.com/mikefarah/yq) v4+ for parsing YAML files. If you don't have it installed, you can install it following the instructions on the [yq GitHub page](https://github.com/mikefarah/yq#install).

    ```bash
    # For macOS users
    brew install yq
    
    # For Linux users
    wget https://github.com/mikefarah/yq/releases/download/v4.34.2/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq
    # Or using apt for Debian/Ubuntu
    apt-get update && apt-get install -y yq
    ```

2. Run the script by passing the path to your backed-up QubexConfig:

    ```bash
    ./extract_config.sh qubex-config.yaml kompass-compute-values.yaml
    ```

    The script accepts two parameters:
    1. The path to your backed-up QubexConfig file (required)
    2. The output values.yaml file path (optional, defaults to `kompass-compute-values.yaml`)

### 3.3: Review and Adjust the values.yaml File

After the script has generated your values.yaml file, review it to ensure all settings have been properly transferred:

## Step 4: Install New Kompass Compute Using Helm

Follow the instructions in the [Getting Started Guide](./GETTING_STARTED.md) to install Kompass Compute using Terraform and Helm. The guide covers:

1. Creating required cloud infrastructure using Terraform
2. Installing Kompass Compute using Helm charts
3. Configuration options for different deployment scenarios

## Step 5: Restore Workload Protections

After successfully installing Kompass Compute with Helm, you'll need to restore your WorkloadProtections from the backup created in step 1.3.

```bash
kubectl apply -f workload-descriptors.yaml
```

This will recreate all your WorkloadDescriptor resources with their original settings, ensuring that your critical workloads maintain the same level of protection as before the migration.

## Step 6: Adjust QScalers Based on Backup

To ensure your QScalers maintain any custom adjustments you've made to them, you can use the following script to extract overrides from your backed-up QScalers and apply them to the newly created ones.

### 6.1: Get the QScaler Adjustment Script

We've provided a script in the repository that automatically extracts overrides from your backed-up QScalers and applies them to the QScalers in your cluster. The script is located at [./scripts/adjust_qscalers.sh](./scripts/adjust_qscalers.sh)

The script handles extracting any custom overrides from your backed-up QScalers and applying them to the corresponding QScalers in your current cluster, ensuring your custom adjustments are preserved.

### 6.2: Run the QScaler Adjustment Script

1. **Install Dependencies**: The script requires [yq](https://github.com/mikefarah/yq) v4+ for parsing YAML files and converting between YAML and JSON formats. If you don't have it installed, you can install it following the instructions on the [yq GitHub page](https://github.com/mikefarah/yq#install).

    ```bash
    # For macOS users
    brew install yq
    
    # For Linux users
    wget https://github.com/mikefarah/yq/releases/download/v4.34.2/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq
    # Or using apt for Debian/Ubuntu
    apt-get update && apt-get install -y yq
    ```

2. Run the script with your backed-up QScalers file:

    ```bash
    ./adjust_qscalers.sh qscalers.yaml
    ```

    The script will:
    1. Extract overrides from your backed-up QScalers
    2. Look for QScalers in your cluster with the same name as in the backup
    3. Apply the overrides to maintain custom settings

### 6.3: Verify QScaler Configuration

After running the script, verify that your QScalers have the correct configuration:

```bash
kubectl get qscalers -A -o yaml
```

Review the output to ensure that all overrides have been properly applied.
