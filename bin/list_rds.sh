#!/bin/bash

# Check if AWS CLI is installed
AWS=$(command -v aws)
if [ ! -x "${AWS}" ]; then
    echo "ERROR: The aws binary does not exist or is not executable."
    echo "Please install AWS CLI and make sure it is in your PATH."
    exit 1
fi

checkMySQL (){
    rds_instances=$(aws rds describe-db-instances \
        --query "DBInstances[?Engine=='mysql'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
        --output table)
}

checkPostgres (){
    rds_instances=$(aws rds describe-db-instances \
        --query "DBInstances[?Engine=='postgres'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
        --output table)
}

while getopts ':as:h' opt; do
    case "$opt" in
        postgres)
            echo "Listing all postgres"
            checkPostgres
            ;;
        mysql)
            echo "Listing all mysql"
            checkMySQL            
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

# Check if any PostgreSQL RDS instances are found
# if [ -z "$rds_instances" ]; then
#     echo "No MySQL RDS instances found."
# else
#     echo "MySQL RDS Instances:"
#     echo "$rds_instances"
# fi