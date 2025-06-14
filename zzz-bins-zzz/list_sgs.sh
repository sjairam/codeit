#!/bin/bash

clear 

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if a region is provided as an argument
if [ $# -eq 0 ]
then
    echo "Please provide an AWS region as an argument."
    echo "Usage: $0 <aws-region>"
    exit 1
fi

# Displays help options. 
Help()
{
   # Display Help
   echo "Displays IN PLAIN TEXT the Security Groups (SG) in AWS "
   echo
   echo "Syntax: ./listSG.sh [-h|-s <<region>> ] |"
   echo "options:"
   echo "-h                Print this message."
   echo "-s <<region>>     Prints just SG for the region"
   echo
}

REGION=$1

# List all security groups and their descriptions
list_all_SG() {
    aws ec2 describe-security-groups \
        --region $REGION \
        --query 'SecurityGroups[].[GroupId,GroupName,Description]' \
        --output table
}

aws ec2 describe-security-groups \
    --region $REGION \
    --query 'SecurityGroups[].[GroupId,GroupName,Description]' \
    --output table

# # Get and parse options
# while getopts ':as:h' opt; do
#   case "$opt" in
#     s)
#       list_all_SG () 
#       ;
#     h)
#       Help
#       exit 0
#       ;;
#   esac
# done
# shift "$(($OPTIND -1))"