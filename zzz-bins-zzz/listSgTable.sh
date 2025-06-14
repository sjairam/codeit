#!/bin/bash


# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install jq to use this script."
    exit 1
fi

# Check if security group ID is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <security-group-id>"
    exit 1
fi

# Displays help options. 
Help()
{
   # Display Help
   echo "Displays IN PLAIN TEXT the SG rules per Security Group"
   echo
   echo "Syntax: ./listSgTable.sh [-h|-s <<security-group-id>> | -a]"
   echo "options:"
   echo "-h                      Print this message."
   echo "-s <<security-group>>   Prints rules for the SG."
   echo "-a                      Prints all SGs."
   echo
}

# Function to list security group rules
list_security_group_rules() {
    local sg_id=$1

    echo "Fetching rules for security group: $sg_id"
    aws ec2 describe-security-groups --group-ids "$sg_id" --query "SecurityGroups[*].{GroupName:GroupName,GroupId:GroupId,Inbound:IpPermissions,Outbound:IpPermissionsEgress}" | jq -r '
        .[] |
        ["GroupName", .GroupName, "", "", ""],
        ["GroupId", .GroupId, "", "", ""],
        ["Inbound Rules:", "", "", ""],
        ["Protocol", "Port Range", "Source", "Description"],
        (if .Inbound | length == 0 then [["-", "-", "-", "-"]] else (.Inbound[] | [
            .IpProtocol,
            (.FromPort | tostring) + "-" + (.ToPort | tostring),
            (.IpRanges | map(.CidrIp) | join(", ")),
            (.IpRanges | map(.Description // "-") | join(", "))
        ]) end),
        ["Outbound Rules:", "", "", ""],
        ["Protocol", "Port Range", "Destination", "Description"],
        (if .Outbound | length == 0 then [["-", "-", "-", "-"]] else (.Outbound[] | [
            .IpProtocol,
            (.FromPort | tostring) + "-" + (.ToPort | tostring),
            (.IpRanges | map(.CidrIp) | join(", ")),
            (.IpRanges | map(.Description // "-") | join(", "))
        ]) end)
    ' | column -t -s $'\t'
}

# Get all security group IDs
sg_ids=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --output text)

# Get and parse options
while getopts ':as:h' opt; do
  case "$opt" in
    a)
    echo "Listing all SGs:"
    sg_ids=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --output text)
    for sg_id in $sg_ids; do
        list_security_group_rules "$sg_id"
        echo
    done
    ;;
    s)
      SECURITY_GROUP_ID=$1
      list_security_group_rules "$sg_id"
      ;;
    h)
      Help
      exit 0
      ;;
  esac
done




