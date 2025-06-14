#!/bin/bash

# Check if AWS CLI is installed
AWS=$(command -v aws)
if [ ! -x "${AWS}" ]; then
    echo "ERROR: The aws binary does not exist or is not executable."
    echo "Please install AWS CLI and make sure it is in your PATH."
    exit 1
fi

checkRDSInstances () {
    local engine="$1"
    aws rds describe-db-instances \
        --query "DBInstances[?Engine=='${engine}'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
        --output table
}

usage()
{
   echo " "
   echo " You need to pass in 1 parameter.  Either 'mysql', 'postgres' or 'oracle' "
   echo ""
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

case $1 in
    "postgres")
        checkRDSInstances "postgres"
        ;;
    "mysql")
        checkRDSInstances "mysql"
        ;;
    "oracle")
        # Change oracel to oracle-ee
        checkRDSInstances "oracle-ee"
        ;;
    *)
        usage
        exit 1
        ;;
esac