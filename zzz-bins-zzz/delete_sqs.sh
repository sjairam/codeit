#!/bin/bash

# Variables
QUEUE_URL="https://sqs.us-east-1.amazonaws.com/847760228496/librarycloud-prod-dead-letter"
MAX_MESSAGES=10        # maximum number of messages to retrieve
WAIT_TIME=5            # seconds to wait to receive the message
AWS_REGION="us-east-1" # your SQS queue region

# Get messages from the queue
receive_messages() {
  echo $QUEUE_URL
  echo $AWS_REGION
  aws sqs receive-message \
    --queue-url "$QUEUE_URL" \
    --max-number-of-messages $MAX_MESSAGES \
    --wait-time-seconds $WAIT_TIME \
    --region "$AWS_REGION" \
    --query 'Messages[*].ReceiptHandle' \
    --output text
}

# Delete messages from the queue
delete_message() {
  RECEIPT_HANDLE="$1"
  aws sqs delete-message \
    --queue-url "$QUEUE_URL" \
    --receipt-handle "$RECEIPT_HANDLE" \
    --region "$AWS_REGION"
}

while true; do
  RECEIPT_HANDLES=$(receive_messages)

  if [ -z "$RECEIPT_HANDLES" ]; then
    echo "No messages to delete. Exiting..."
    break
  fi

  for RECEIPT_HANDLE in $RECEIPT_HANDLES
  do
    echo "Deleting message with Receipt Handle: $RECEIPT_HANDLE"
    delete_message "$RECEIPT_HANDLE"
  done
done
