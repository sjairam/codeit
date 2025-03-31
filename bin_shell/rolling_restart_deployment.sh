#!/bin/bash
# Need to be in NS

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

#Check binaries
check_binaries

# Assign the first argument to the DEPLOYMENT_NAME variable
DEPLOYMENT_NAME=$1

# Restart the specified deployment
kubectl rollout restart deployment "$DEPLOYMENT_NAME"

sleep 2

kubectl get pods -w