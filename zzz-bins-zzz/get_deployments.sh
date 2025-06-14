#!/bin/bash

# Check if a namespace is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

# Set the namespace
NAMESPACE=$1

# Get the deployments in the specified namespace
echo "Fetching deployments in namespace: $NAMESPACE"
kubectl get deployments -n $NAMESPACE

# Exit successfully
exit 0