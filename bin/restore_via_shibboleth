#!/bin/bash

clear

echo " --> Starting Shibboleth restore ! "

# Function to prompt the user for confirmation
prompt_continue() {
    echo " SJ broke an environment the last time "
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

kubectl apply -f authconfigs.management.cattle.io\#v3/shibboleth.json

kubectl apply -f users.management.cattle.io\#v3/.

kubectl apply -f userattributes.management.cattle.io\#v3/.

kubectl apply -f secrets.\#v1/cattle-global-data/shibbolethconfig-spkey.json

echo " <-- Restore complete ! "