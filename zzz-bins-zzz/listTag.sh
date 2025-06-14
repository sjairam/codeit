#!/bin/bash

# Define the tag key and value to filter by
TAG_KEY="environment"
TAG_VALUE="Development"
MAX_RESULTS=10

# Function to list secrets with specific tags and handle pagination
list_secrets_paginated() {
    local next_token=""
    local result

    while true; do
        if [ -z "$next_token" ]; then
            result=$(aws secretsmanager list-secrets --filters Key=tag-key,Values=$TAG_KEY Key=tag-value,Values=$TAG_VALUE --max-results $MAX_RESULTS)
        else
            result=$(aws secretsmanager list-secrets --filters Key=tag-key,Values=$TAG_KEY Key=tag-value,Values=$TAG_VALUE --max-results $MAX_RESULTS --next-token $next_token)
        fi

        echo "$result" | jq '.SecretList[] | .Name'

        next_token=$(echo "$result" | jq -r '.NextToken')
        if [ "$next_token" == "null" ]; then
            break
        fi
    done
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install it and configure your credentials."
    exit 1
fi

# List secrets with the specified tag
echo "Secrets with tag $TAG_KEY=$TAG_VALUE:"
list_secrets_paginated
