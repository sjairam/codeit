#!/bin/bash

clear

echo " --> Starting OIDC restore ! "
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

kubectl apply -f authconfigs.management.cattle.io\#v3/keycloakoidc.json

kubectl apply -f users.management.cattle.io\#v3/.

kubectl apply -f userattributes.management.cattle.io\#v3/.

#This is missing Key for OIDC
kubectl apply -f secrets.#v1/cattle-global-data/keycloakoidcconfig-clientsecret.json

echo " <-- Restore complete ! "