#!/bin/sh

# Set AWS region, update this to your specific region
REGION="us-east-1"

# List all RDS instances
echo "Listing all RDS DB instances..."
DB_INSTANCES=$(aws rds describe-db-instances --region $REGION --query 'DBInstances[*].{DBInstanceIdentifier:DBInstanceIdentifier}' --output text)

if [ -z "$DB_INSTANCES" ]; then
    echo "No RDS DB instances found."
    exit 1
fi

# Loop over each DB instance and retrieve connection information
for DB_INSTANCE_IDENTIFIER in $DB_INSTANCES; do
    echo "Gathering connection details for RDS DB instance: $DB_INSTANCE_IDENTIFIER"

    # Fetch endpoint details
    ENDPOINT=$(aws rds describe-db-instances --region $REGION --db-instance-identifier $DB_INSTANCE_IDENTIFIER --query 'DBInstances[0].Endpoint.Address' --output text)
    PORT=$(aws rds describe-db-instances --region $REGION --db-instance-identifier $DB_INSTANCE_IDENTIFIER --query 'DBInstances[0].Endpoint.Port' --output text)
    DB_ENGINE=$(aws rds describe-db-instances --region $REGION --db-instance-identifier $DB_INSTANCE_IDENTIFIER --query 'DBInstances[0].Engine' --output text)
    
    if [ -z "$ENDPOINT" ] || [ -z "$PORT" ] || [ -z "$DB_ENGINE" ]; then
        echo "Failed to retrieve endpoint, port, or engine details for DB instance: $DB_INSTANCE_IDENTIFIER"
        continue
    fi

    echo "DB Instance Identifier: $DB_INSTANCE_IDENTIFIER"
    echo "Engine: $DB_ENGINE"
    echo "Endpoint: $ENDPOINT"
    echo "Port: $PORT"

    # For demonstration purposes, use netcat (nc) to check the TCP connection to RDS endpoint
    echo "Checking connection to $ENDPOINT on port $PORT..."
    nc_result=$(nc -zv $ENDPOINT $PORT 2>&1)
    if echo "$nc_result" | grep -q 'succeeded'; then
        echo "Connection to $DB_INSTANCE_IDENTIFIER ($ENDPOINT:$PORT) succeeded."
    else
        echo "Connection to $DB_INSTANCE_IDENTIFIER ($ENDPOINT:$PORT) failed."
    fi

    echo "-----------------------------"
done

echo "RDS connection check completed."