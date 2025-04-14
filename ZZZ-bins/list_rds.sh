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

checkOracle (){
    rds_instances=$(aws rds describe-db-instances \
        --query "DBInstances[?Engine=='oracle-ee'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
        --output table)
}


checkPostgres (){
    rds_instances=$(aws rds describe-db-instances \
        --query "DBInstances[?Engine=='postgres'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus,MultiAZ]" \
        --output table)
}


if [ $1 == "postgres"];
    checkPostgres
fi

if [ $1 == "mysql"];
    checkMySQL
fi

if [ $1 == "mysql"];
    checkOracle
fi
