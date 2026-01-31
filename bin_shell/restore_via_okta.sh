#!/bin/bash
# Initial version - SJ
# Add pre-reqs
# Check OKAT spkey

clear

KUBECTL=$(command -v kubectl)

#### KUBECTL
#### Check to make sure the kubectl is available
if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: Unable to locate the KUBECTL binary."
    echo "FIX: Please modify the \${KUBECTL} variables in the program header."
    exit 1
fi

echo " --> Starting OKTA restore ! "
sleep 5

# Function to prompt the user for confirmation
prompt_continue() {
    echo " A devOps resource broke an environment the last time "
    read -p " Are you sure you want to continue? (y/n): " response
    case "$response" in
        [Yy]* ) echo "Continuing...";;
        [Nn]* ) echo "Exiting."; exit 0;;
        * ) echo "Please answer y or n." && prompt_continue;;
    esac
}

# Call the prompt function
prompt_continue

# Continue with the rest of the script

echo " --> Commencing restore ! "

kubectl apply -f authconfigs.management.cattle.io\#v3/okta.json

kubectl apply -f users.management.cattle.io\#v3/.

kubectl apply -f userattributes.management.cattle.io\#v3/.

#This is missing Key for OKTA
kubectl apply -f secrets.#v1/cattle-global-data/oktaconfig-spkey.json

echo " <-- Restore complete ! "
