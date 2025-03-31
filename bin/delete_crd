#!/bin/bash

clear

AWS=$(command -v aws)
KUBECTL=$(command -v kubectl)

check_binaries() {
  if [ ! -f "${AWS}" ]; then
    echo "ERROR: The aws binary does not exist."
    echo "FIX: Please modify the \${AWS} variable in the program header."
    exit 1
  fi

  if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: The kubectl binary does not exist."
    echo "FIX: Please modify the \${KUBECTL} variable in the program header."
    exit 1
  fi
}


# List all CRD names into an array
crd_list=$(kubectl get crds --no-headers -o custom-columns=":metadata.name")

# Define a pattern to match CRDs you want to delete
pattern=$1  # Change this to your specific pattern

# Loop through the list of CRDs
for crd in ${crd_list}; do
  # Check if the CRD name matches the pattern
  if [[ "$crd" == *"$pattern"* ]]; then
    echo "Deleting CRD: $crd"
    # Delete the CRD
    kubectl delete crd "$crd"
  fi
done
