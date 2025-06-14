# Assuming you already have the secret.yml file from the previous step
grep "^[ ]*[a-zA-Z0-9]" secret.yml | \
while read line; do
    # Split the key and value
    KEY=$(echo "$line" | awk '{print $1}')
    VALUE=$(echo "$line" | awk '{print $2}')

    # Decode the value
    DECODED_VALUE=$(echo "$VALUE" | base64 --decode)

    # Print key and decoded value as YAML
    echo "  $KEY: $DECODED_VALUE"
done
