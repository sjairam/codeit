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

REGION=$1

# Displays help options. 
Help()
{
   # Display Help
   echo "Displays IN PLAIN TEXT the Key-Value pairs for secrets in Secrets Manager"
   echo
   echo "Syntax: ./listSgRule.sh [-h|-s region/security-groups | -a]"
   echo "options:"
   echo "-h                         Print this message."
   echo "-s resgion/stack-secrets   Prints just secrets for that stack."
   echo "-a                         Prints all SG in AWS (not advised)."
   echo
}

# Function to print rule details
print_rule_details() {
    local direction=$1
    local rules=$2
    
    echo "$direction Rules:"
    echo "$rules" | jq -r '.[] | 
        "  Rule Name: \(.Description // "N/A")\n  From Port: \(.FromPort // "All")\n  To Port: \(.ToPort // "All")\n  Protocol: \(.IpProtocol // "All")\n  CIDR: \(.IpRanges[].CidrIp // "N/A")\n"'
    echo
}

# Function to list all secrets
list_all_SGs() {
aws ec2 describe-security-groups --region $REGION | jq -r '.SecurityGroups[] | 
    "Security Group: \(.GroupName)\nGroup ID: \(.GroupId)\nDescription: \(.Description)\n" + 
    "Inbound Rules:\n" + 
    (.IpPermissions | @json) + 
    "\nOutbound Rules:\n" + 
    (.IpPermissionsEgress | @json) + 
    "\n-------------------\n"' | 
while IFS= read -r line
do
    if [[ $line == "Inbound Rules:" ]]; then
        read -r inbound_rules
        print_rule_details "Inbound" "$inbound_rules"
    elif [[ $line == "Outbound Rules:" ]]; then
        read -r outbound_rules
        print_rule_details "Outbound" "$outbound_rules"
    else
        echo "$line"
    fi
done
}

# Get and parse options
while getopts ':as:h' opt; do
  case "$opt" in
    a)
    echo "Listing all secrets:"
    all_sgs=$(list_all_SGc)
    for sg in $all_sgs; do
        describe_secret "$secret"
    done
      ;;
    s)
      arg="$OPTARG"
      describe_secret ${OPTARG}
      find_whitespaces ${OPTARG}
      ;;
    h)
      Help
      exit 0
      ;;
  esac
done
shift "$(($OPTIND -1))"