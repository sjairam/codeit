#!/bin/bash
# Initial version - 01 - SJ
# Check AWS - 02 - SJ

# Check if AWS CLI is installed
AWS=$(command -v aws)
if [ ! -x "${AWS}" ]; then
    echo "ERROR: The aws binary does not exist or is not executable."
    echo "Please install AWS CLI and make sure it is in your PATH."
    exit 1
fi

# Fetch all RDS instances with PostgreSQL as the database engine
rds_instances=$(aws rds describe-db-instances \
    --query "DBInstances[?Engine=='postgres'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
    --output table)

# Check if any PostgreSQL RDS instances are found
if [ -z "$rds_instances" ]; then
    echo "No PostgreSQL RDS instances found."
else
    echo "PostgreSQL RDS Instances:"
    echo "$rds_instances"
fi