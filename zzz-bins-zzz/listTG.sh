#!/bin/bash

# Set the region to your preferred AWS region
REGION="us-east-1"

# List all target groups in the specified region
echo "Listing all target groups in region $REGION..."

TARGET_GROUPS=$(aws elbv2 describe-target-groups --region $REGION --query 'TargetGroups[*].{Name:TargetGroupName, ARN:TargetGroupArn}' --output table)

if [ -z "$TARGET_GROUPS" ]; then
    echo "No target groups found."
else
    echo "$TARGET_GROUPS"
fi
