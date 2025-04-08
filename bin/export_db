#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -u <username> -p <password> -s <schema> -d <directory> -f <dumpfile> -l <logfile>"
    exit 1
}

# Parse command-line arguments
while getopts "u:p:s:d:f:l:" opt; do
    case $opt in
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) SCHEMA="$OPTARG" ;;
        d) DIRECTORY="$OPTARG" ;;
        f) DUMPFILE="$OPTARG" ;;
        l) LOGFILE="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all arguments have been provided
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$SCHEMA" ] || [ -z "$DIRECTORY" ] || [ -z "$DUMPFILE" ] || [ -z "$LOGFILE" ]; then
    echo "Error: Missing argument(s)"
    usage
fi

# Construct the expdp command
EXPDP_COMMAND="expdp ${USERNAME}/${PASSWORD} schemas=${SCHEMA} directory=${DIRECTORY} dumpfile=${DUMPFILE} logfile=${LOGFILE}"

# Execute the command
echo "Executing: $EXPDP_COMMAND"
eval $EXPDP_COMMAND

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Export completed successfully."
else
    echo "Export failed."
fi