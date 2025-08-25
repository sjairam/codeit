#!/bin/bash

# Simple Apigee Environment CSV Export
# Get access token
AUTH="Authorization: Bearer $(gcloud auth print-access-token)"

# CSV Header
echo "Project,Environment,IP"

# List of environments to test
environments=(
    # MMCX Melbourne
    "mmcx-melbourne-ext-prod/prod-1"
    "mmcx-melbourne-ext-prod/trusted-broker-noweb-ext"
    "mmcx-melbourne-ext-non-prod/non-prod-1"
    "mmcx-melbourne-ext-non-prod/non-prod-stage-1"
    "mmcx-melbourne-ext-non-prod/trusted-broker-noweb-ext"
    "mmcx-melbourne-int-prod/prod-1"
    "mmcx-melbourne-int-prod/trusted-broker-int"
    "mmcx-melbourne-int-non-prod/non-prod-1"
    "mmcx-melbourne-int-non-prod/non-prod-dev-1"
    "mmcx-melbourne-int-non-prod/non-prod-stage-1"
    "mmcx-melbourne-int-non-prod/non-prod-test-1"
    "mmcx-melbourne-int-non-prod/trusted-broker-int"
    
    # MMCX Dallas
    "mmcx-dallas-ext-prod/prod-1"
    "mmcx-dallas-ext-prod/trusted-broker-noweb-ext"
    "mmcx-dallas-ext-non-prod/non-prod-1"
    "mmcx-dallas-ext-non-prod/non-prod-dev-1"
    "mmcx-dallas-ext-non-prod/non-prod-stage-1"
    "mmcx-dallas-ext-non-prod/non-prod-test-1"
    "mmcx-dallas-ext-non-prod/non-prod-uat-1"
    "mmcx-dallas-ext-non-prod/trusted-broker-noweb-ext"
    "mmcx-dallas-int-prod/prod-1"
    "mmcx-dallas-int-prod/prod-prd-1"
    "mmcx-dallas-int-prod/trusted-broker-int"
    "mmcx-dallas-int-non-prod/non-prod-1"
    "mmcx-dallas-int-non-prod/non-prod-dev-1"
    "mmcx-dallas-int-non-prod/non-prod-stage-1"
    "mmcx-dallas-int-non-prod/non-prod-test-1"
    "mmcx-dallas-int-non-prod/non-prod-uat-1"
    "mmcx-dallas-int-non-prod/trusted-broker-int"
    
    # MercerX Melbourne
    "mercerx-melbourne-ext-prod/prod-1"
    "mercerx-melbourne-ext-non-prod/non-prod-1"
    "mercerx-melbourne-ext-non-prod/non-prod-uat-1"
    "mercerx-melbourne-int-non-prod/non-prod-1"
    
    # MercerX Dallas
    "mercerx-dallas-int-prod/prod-1"
    
    # MercerX Bedford
    "mercerx-bedford-int-non-prod/non-prod-dev-1"
    
    # MarshX Melbourne
    "marshx-melbourne-ext-prod/prod-1"
    "marshx-melbourne-ext-prod/prod-noweb-1"
    "marshx-melbourne-ext-non-prod/non-prod-1"
    "marshx-melbourne-ext-non-prod/non-prod-dev-1"
    "marshx-melbourne-ext-non-prod/non-prod-noweb-uat-1"
    "marshx-melbourne-ext-non-prod/non-prod-stage-1"
    "marshx-melbourne-ext-non-prod/non-prod-uat-1"
    "marshx-melbourne-int-non-prod/non-prod-dev-1"
    "marshx-melbourne-int-non-prod/non-prod-stage-1"
    "marshx-melbourne-int-non-prod/non-prod-test-1"
    
    # MarshX Bedford
    "marshx-bedford-ext-prod/prod-1"
    "marshx-bedford-ext-prod/prod-noweb-1"
    "marshx-bedford-ext-non-prod/non-prod-1"
    "marshx-bedford-ext-non-prod/non-prod-dev-1"
    "marshx-bedford-ext-non-prod/non-prod-noweb-uat-1"
    "marshx-bedford-ext-non-prod/non-prod-stage-1"
    "marshx-bedford-ext-non-prod/non-prod-uat-1"
    "marshx-bedford-int-prod/prod-1"
    "marshx-bedford-int-non-prod/non-prod-1"
    "marshx-bedford-int-non-prod/non-prod-dev-1"
    "marshx-bedford-int-non-prod/non-prod-uat-1"
    
    # MarshX Dallas
    "marshx-dallas-ext-prod/prod-1"
    "marshx-dallas-ext-prod/prod-noweb-1"
    "marshx-dallas-ext-non-prod/non-prod-1"
    "marshx-dallas-ext-non-prod/non-prod-dev-1"
    "marshx-dallas-ext-non-prod/non-prod-noweb-uat-1"
    "marshx-dallas-ext-non-prod/non-prod-stage-1"
    "marshx-dallas-ext-non-prod/non-prod-uat-1"
    "marshx-dallas-int-prod/prod-1"
    "marshx-dallas-int-non-prod/non-prod-1"
    "marshx-dallas-int-non-prod/non-prod-dev-1"
    "marshx-dallas-int-non-prod/non-prod-stage-1"
    "marshx-dallas-int-non-prod/non-prod-test-1"
    "marshx-dallas-int-non-prod/non-prod-uat-1"
    
    # MMCX Bedford
    "mmcx-bedford-ext-prod/prod-1"
    "mmcx-bedford-ext-prod/trusted-broker-noweb-ext"
    "mmcx-bedford-ext-non-prod/non-prod-1"
    "mmcx-bedford-ext-non-prod/non-prod-dev-1"
    "mmcx-bedford-ext-non-prod/non-prod-stage-1"
    "mmcx-bedford-ext-non-prod/trusted-broker-noweb-ext"
    "mmcx-bedford-int-prod/prod-1"
    "mmcx-bedford-int-prod/trusted-broker-int"
    "mmcx-bedford-int-non-prod/non-prod-1"
    "mmcx-bedford-int-non-prod/non-prod-dev-1"
    "mmcx-bedford-int-non-prod/non-prod-stage-1"
    "mmcx-bedford-int-non-prod/non-prod-uat-1"
    "mmcx-bedford-int-non-prod/trusted-broker-int"
)

# Test each environment
for env in "${environments[@]}"; do
    org=$(echo $env | cut -d'/' -f1)
    environment=$(echo $env | cut -d'/' -f2)
    
    response=$(curl -s -H "$AUTH" -H "content-type: application/json" \
        "https://apigee.googleapis.com/v1/organizations/$org/environments/$environment")
    
    if echo "$response" | grep -q '"name"'; then
        forward_proxy=$(echo "$response" | jq -r '.forwardProxyUri // "N/A"')
        # Extract IP from forwardProxyUri (format: http://IP:PORT)
        ip=$(echo "$forward_proxy" | sed 's|http://||' | cut -d':' -f1)
        echo "$org,$environment,$ip"
    else
        echo "$org,$environment,N/A"
    fi
done
