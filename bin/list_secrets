#!/bin/bash
# 01 - initial - jairams
# 02 - Add AWS CLI check
# 03 - Add jq check
# 04 - Improved parameter handling and script validation

AWS=$(command -v aws)
JQ=$(command -v jq)

# Function to display help options
Help() {
    echo "Displays IN PLAIN TEXT the Key-Value pairs for secrets in Secrets Manager"
    echo
    echo "Syntax: ./list_secrets.sh [-h|-s env/stack-secrets| -a]"
    echo "options:"
    echo "-h                     Print this message."
    echo "-s env/stack-secrets   Prints just secrets for that stack."
    echo "-a                     Prints all secrets in Secrets Manager (not advised)."
    echo
}

# Function to check the availability of required binaries
check_binaries() {
    # Check AWS CLI
    if [ -z "${AWS}" ]; then
        echo "ERROR: The aws binary does not exist."
        echo "FIX: Please ensure AWS CLI is installed and in your PATH."
        exit 1
    fi

    # Check jq
    if [ -z "${JQ}" ]; then
        echo "ERROR: The jq binary does not exist."
        echo "FIX: Please ensure jq is installed and in your PATH."
        exit 1
    fi
}

# Function to list all secrets
list_all_secrets() {
    aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text
}

# Function to describe a secret and get key-value pairs
describe_secret() {
    local secret_name="$1"
    if [ -z "$secret_name" ]; then
        echo "ERROR: Secret name not provided."
        exit 1
    fi
    secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_name" --query 'SecretString' --output text)
    echo "Secret Name: $secret_name"
    echo "Key-Value Pairs:"
    echo "$secret_value" | jq
}

# Function to find whitespaces in secret values
find_whitespaces() {
    local secret_name="$1"
    if [ -z "$secret_name" ]; then
        echo "ERROR: Secret name not provided."
        exit 1
    fi
    string=$(aws secretsmanager get-secret-value --secret-id "$secret_name" | jq --raw-output '.SecretString')
    if [[ "$string" =~ \ |\' ]]; then
        echo "Secret '$secret_name': WHITESPACEs FOUND - check the output for leading or trailing spaces."
    else
        echo "Secret '$secret_name': No whitespace found"
    fi
}

# Add parameter 1 check
if [ "$#" -lt 1 ]; then
    echo "Error: Missing required parameter."
    Help
fi

# Ensure required binaries are present
check_binaries

# Parse and handle command-line options
while getopts ':as:h' opt; do
    case "$opt" in
        a)
            echo "Listing all secrets:"
            all_secrets=$(list_all_secrets)
            for secret in $all_secrets; do
                describe_secret "$secret"
            done
            ;;
        s)
            arg="$OPTARG"
            describe_secret "$arg"
            find_whitespaces "$arg"
            ;;
        h)
            Help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            Help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            Help
            exit 1
            ;;
    esac
done
shift "$(($OPTIND -1))"