#!/bin/bash

# Usage information
usage() {
  echo "Usage: $0 <qubex-config-file> [output-values-file]"
  echo "Example: $0 qubex-config.yaml kompass-compute-values.yaml"
  exit 1
}

# Check parameters
if [ $# -lt 1 ]; then
  echo "Error: Missing required parameter."
  usage
fi

# Define input and output files
QUBEX_CONFIG="$1"
VALUES_FILE="${2:-kompass-compute-values.yaml}"  # Default to kompass-compute-values.yaml if not provided

# Check if input file exists
if [ ! -f "${QUBEX_CONFIG}" ]; then
  echo "Error: Config file '${QUBEX_CONFIG}' not found!"
  exit 1
fi

# Print information
echo "Reading configuration from: ${QUBEX_CONFIG}"
echo "Writing values to: ${VALUES_FILE}"

# Check for yq
if ! command -v yq &> /dev/null; then
  echo "Error: yq is not installed but required for this script."
  echo "Please install yq: https://github.com/mikefarah/yq#install"
  echo "For example, on macOS: brew install yq"
  exit 1
fi

# Create the initial values.yaml template
echo "Creating initial values file template at ${VALUES_FILE}..."
rm -f "${VALUES_FILE}" 2>/dev/null
touch "${VALUES_FILE}"

echo "Extracting values from ${QUBEX_CONFIG}..."

# Process AWS configuration
echo "Processing AWS configuration..."
yq -i '.qubexConfig.infraConfig.aws.additionalTags = load("'"${QUBEX_CONFIG}"'").data.infraConfig.aws.additionalTags' "${VALUES_FILE}"
yq -i '.qubexConfig.infraConfig.aws.containerRuntime = load("'"${QUBEX_CONFIG}"'").data.infraConfig.aws.containerRuntime' "${VALUES_FILE}"
yq -i '.qubexConfig.infraConfig.aws.enableM7FlexInstances = load("'"${QUBEX_CONFIG}"'").data.infraConfig.aws.enableM7FlexInstances' "${VALUES_FILE}"
yq -i '.qubexConfig.infraConfig.aws.enableNonTrunkingInstances = load("'"${QUBEX_CONFIG}"'").data.infraConfig.aws.enableNonTrunkingInstances' "${VALUES_FILE}"
yq -i '.qubexConfig.infraConfig.baseDiskSize = load("'"${QUBEX_CONFIG}"'").data.infraConfig.baseDiskSize' "${VALUES_FILE}"

# Process general configuration
echo "Processing general configuration..."
yq -i '.qubexConfig.instanceTypesCount = load("'"${QUBEX_CONFIG}"'").data.instanceTypesCount' "${VALUES_FILE}"
yq -i '.qubexConfig.instanceTypeMaxCPU = load("'"${QUBEX_CONFIG}"'").data.instanceTypeMaxCPU' "${VALUES_FILE}"
yq -i '.qubexConfig.snapshooterInterval = load("'"${QUBEX_CONFIG}"'").data.snapshooterInterval' "${VALUES_FILE}"
yq -i '.qubexConfig.zestyConfig.uploadInterval = load("'"${QUBEX_CONFIG}"'").data.zestyConfig.uploadInterval' "${VALUES_FILE}"

# Process draining configuration
echo "Processing draining configuration..."
yq -i '.qubexConfig.drainingConfig.scaleInProtectionDuration = load("'"${QUBEX_CONFIG}"'").data.drainingConfig.scaleInProtectionDuration' "${VALUES_FILE}"
yq -i '.qubexConfig.drainingConfig.drainGracePeriod = load("'"${QUBEX_CONFIG}"'").data.drainingConfig.drainGracePeriod' "${VALUES_FILE}"
yq -i '.qubexConfig.drainingConfig.replacementPodRetryInterval = load("'"${QUBEX_CONFIG}"'").data.drainingConfig.replacementPodRetryInterval' "${VALUES_FILE}"

# Process disturbance configuration
echo "Processing disturbance configuration..."
yq -i '.qubexConfig.disturbanceConfig.cooldownPeriod = load("'"${QUBEX_CONFIG}"'").data.disturbanceConfig.cooldownPeriod' "${VALUES_FILE}"

# Process cache configuration
echo "Processing cache configuration..."
yq -i '.qubexConfig.cacheConfig.diskSize = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.diskSize' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.diskFillAmount = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.diskFillAmount' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.additionalImages = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.additionalImages // []' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.revisionMinCreationInterval = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.revisionMinCreationInterval' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.workloadsPerRevisionCreation = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.workloadsPerRevisionCreation' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.concurrentImagePullPerRevisionCreation = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.concurrentImagePullPerRevisionCreation' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.concurrentLayerPullPerRevisionCreation = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.concurrentLayerPullPerRevisionCreation' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.revisionCreationTimeout = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.revisionCreationTimeout' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.workloadExpirationTime = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.workloadExpirationTime' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.workloadsExpirationCount = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.workloadsExpirationCount' "${VALUES_FILE}"
yq -i '.qubexConfig.cacheConfig.shardsToMergeCount = load("'"${QUBEX_CONFIG}"'").data.qCacheConfig.shardsToMergeCount' "${VALUES_FILE}"

# Process Spot.io configuration
echo "Processing Spot.io configuration..."
yq -i '.qubexConfig.spotOceanConfig.enable = load("'"${QUBEX_CONFIG}"'").data.enableSpotOcean' "${VALUES_FILE}"
yq -i '.qubexConfig.spotOceanConfig.spotOceanID = load("'"${QUBEX_CONFIG}"'").data.spotOceanID // ""' "${VALUES_FILE}"
yq -i '.qubexConfig.spotOceanConfig.spotOceanSecretName = load("'"${QUBEX_CONFIG}"'").data.spotOceanSecretName' "${VALUES_FILE}"
yq -i '.qubexConfig.spotOceanConfig.spotOceanSecretNamespace = load("'"${QUBEX_CONFIG}"'").data.spotOceanSecretNamespace' "${VALUES_FILE}"
yq -i '.qubexConfig.spotOceanConfig.spotOceanSecretTokenKey = load("'"${QUBEX_CONFIG}"'").data.spotOceanSecretTokenKey' "${VALUES_FILE}"
yq -i '.qubexConfig.spotOceanConfig.spotOceanSecretAccountKey = load("'"${QUBEX_CONFIG}"'").data.spotOceanSecretAccountKey' "${VALUES_FILE}"


echo "Successfully extracted values from ${QUBEX_CONFIG} and updated ${VALUES_FILE}"
