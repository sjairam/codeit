#!/bin/bash
# 01 - first version
# 02 - Add EXCLUDED

set -e

# List of namespaces to exclude from the restart
EXCLUDED_NAMESPACES=("cattle-fleet-clusters-system" "cattle-fleet-local-system" "cattle-fleet-system" "cattle-global-data" "cattle-global-nt" "cattle-monitoring-system" "cattle-provisioning-capi-system" "cattle-resources-system" "cattle-system" "fleet-default" "kube-node-lease" "kube-public" "kube-system")

# Convert the array to a string separated by spaces to use in conditional checks
EXCLUDED_PATTERN=$(printf "|%s" "${EXCLUDED_NAMESPACES[@]}")
EXCLUDED_PATTERN=${EXCLUDED_PATTERN:1} # Remove the leading '|'

# Loop through all namespaces
for namespace in $(kubectl get namespaces --no-headers -o custom-columns=":metadata.name"); do
    # Check if the namespace is in the excluded list
    if [[ $namespace =~ ^($EXCLUDED_PATTERN)$ ]]; then
      echo " --> Skipping namespace: $namespace"
      continue
    fi

    echo " --> Processing namespace: $namespace"
    # Loop through all daemon-sets in the current NS (namespace)
    for daemon-set in $(kubectl get daemon-sets -n "$namespace" --no-headers -o custom-columns=":metadata.name"); do
      echo " --> Restarting daemon-set: $daemon-set in namespace: $namespace"

      # Patch the daemon-set to set a new annotation, which will trigger a rolling update
      kubectl patch daemon-set "$daemon-set" -n "$namespace" \
        -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"kubectl.kubernetes.io/restartedAt\":\"$(date +%Y-%m-%dT%H:%M:%S%Z)\"}}}}}"

    done
done

echo " --> All daemon-sets restarted."