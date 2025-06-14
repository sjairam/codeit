#!/bin/bash

# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi


echo " param 1 " $1

aws secretsmanager delete-secret --secret-id $1 --force-delete-without-recovery --region us-east-1
