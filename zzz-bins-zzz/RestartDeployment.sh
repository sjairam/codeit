#!/bin/bash
# Need to be in NS

# Check if the number of arguments is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <deployment-name>"
    exit 1
fi

# Assign the first argument to the DEPLOYMENT_NAME variable
DEPLOYMENT_NAME=$1

# Restart the specified deployment
kubectl rollout restart deployment "$DEPLOYMENT_NAME"

sleep 2

kubectl get pods -w