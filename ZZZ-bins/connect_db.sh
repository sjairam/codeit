#!/bin/bash
# Initial version - neeed to check for pre-reqs

clear

SQLPLUS=$(command -v sqlplus)

if [ ! -f "${SQLPLUS}" ]; then
    echo "ERROR: The sqlplus binary does not exist."
    echo "FIX: Please modify the \${SQLPLUS} variable in the program header."
    exit 1
fi

# Function to prompt for user input
prompt_input() {
    local var_name="$1"
    local prompt_message="$2"
    local result

    read -p "$prompt_message: " result
    echo "$result"
}

# Prompt the user for inputs
PASSWORD=$(prompt_input "PASSWORD" " Please enter the database password")
HOSTNAME=$(prompt_input "HOSTNAME" " Please enter the hostname")
PORT=$(prompt_input "PORT" " Please enter the port number")
DB_NAME=$(prompt_input "DB_NAME" " Please enter the database SID")

# Run the sqlplus command with the provided credentials
sqlplus "dbadmin/${PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=${HOSTNAME})(Port=${PORT}))(CONNECT_DATA=(SID=${DB_NAME})))"