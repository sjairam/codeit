#!/bin/bash

# Check if the load balancer name is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <load-balancer-name>"
  exit 1
fi

# Set the load balancer name
LOAD_BALANCER_NAME=$1

# Delete the Load Balancer
echo "Attempting to delete Load Balancer: $LOAD_BALANCER_NAME"

# Check if it's a classic load balancer
aws elb describe-load-balancers --load-balancer-names $LOAD_BALANCER_NAME > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Detected as a Classic Load Balancer. Deleting..."
  aws elb delete-load-balancer --load-balancer-name $LOAD_BALANCER_NAME
  if [ $? -eq 0 ]; then
    echo "Classic Load Balancer '$LOAD_BALANCER_NAME' deleted successfully."
  else
    echo "Failed to delete Classic Load Balancer '$LOAD_BALANCER_NAME'."
  fi
  exit 0
fi

# Check if it's an application or network load balancer
LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --names $LOAD_BALANCER_NAME --query "LoadBalancers[0].LoadBalancerArn" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "Detected as an Application or Network Load Balancer. Deleting..."
  aws elbv2 delete-load-balancer --load-balancer-arn $LOAD_BALANCER_ARN
  if [ $? -eq 0 ]; then
    echo "Application or Network Load Balancer '$LOAD_BALANCER_NAME' deleted successfully."
  else
    echo "Failed to delete Application or Network Load Balancer '$LOAD_BALANCER_NAME'."
  fi
  exit 0
fi

# If no load balancer is found
echo "Load Balancer '$LOAD_BALANCER_NAME' not found."
exit 1
