#!/bin/bash

# Usage information
usage() {
  echo "Usage: $0 <qscalers-backup-file>"
  echo "Example: $0 qscalers.yaml"
  exit 1
}

# Check parameters
if [ $# -lt 1 ]; then
  echo "Error: Missing required parameter."
  usage
fi

QSCALERS_FILE="$1"

# Check if input file exists
if [ ! -f "${QSCALERS_FILE}" ]; then
  echo "Error: QScalers backup file '${QSCALERS_FILE}' not found!"
  exit 1
fi

# Check for yq
if ! command -v yq &> /dev/null; then
  echo "Error: yq is not installed but required for this script."
  echo "Please install yq: https://github.com/mikefarah/yq#install"
  echo "For example, on macOS: brew install yq"
  exit 1
fi

echo "Extracting QScaler overrides from ${QSCALERS_FILE}..."

# Process each QScaler in the backup file
qscaler_count=$(yq '.items | length' "${QSCALERS_FILE}")

for ((i=0; i<qscaler_count; i++)); do
  name=$(yq ".items[$i].metadata.name" "${QSCALERS_FILE}")

  # Check if this QScaler has any overrides
  has_overrides=$(yq ".items[$i].spec.overrides | length > 0" "${QSCALERS_FILE}")

  if [ "${has_overrides}" == "true" ]; then
    echo "Found overrides for QScaler: ${name}"

    # Extract overrides and convert from YAML to JSON
    overrides_json=$(yq -o=json ".items[$i].spec.overrides" "${QSCALERS_FILE}")
    echo "Overrides (JSON): ${overrides_json}"

    # Check if the QScaler exists in the current cluster
    exists=$(kubectl get qscaler "${name}" --ignore-not-found)

    if [ -n "$exists" ]; then
      echo "Found QScaler in cluster: ${name}"

      # Create the patch JSON string
      patch="{\"spec\":{\"overrides\":${overrides_json}}}"
      echo "Patch JSON: ${patch}"

      # Apply the patch directly
      echo "Applying overrides to QScaler ${name}..."
      kubectl patch qscaler "${name}" --type=merge --patch "${patch}"
    else
      echo "QScaler not found in cluster: ${name}"
    fi
  fi
done

echo "QScaler adjustment complete."
