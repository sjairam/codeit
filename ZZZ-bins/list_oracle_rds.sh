#!/bin/bash

# Check if AWS CLI is installed
AWS=$(command -v aws)
if [ ! -x "${AWS}" ]; then
    echo "ERROR: The aws binary does not exist or is not executable."
    echo "Please install AWS CLI and make sure it is in your PATH."
    exit 1
fi

# Fetch all RDS instances with MySQL as the database engine
rds_instances=$(aws rds describe-db-instances \
    --query "DBInstances[?Engine=='oracle-ee'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
    --output table)

# Check if any Oracle RDS instances are found
if [ -z "$rds_instances" ]; then
    echo "No Oracle RDS instances found."
else
    echo "Oracle RDS Instances:"
    echo "$rds_instances"
fi