#!/bin/sh

# Variables
QUEUE_NAME="librarycloud-dev-upload-marc"
REGION="us-east-1"  # You can change the region to your preferred region

# Create SQS Queue
echo "Creating SQS queue..."
aws sqs create-queue --queue-name $QUEUE_NAME --region $REGION

# List SQS Queues
echo "Listing all SQS queues..."
aws sqs list-queues --region $REGION

# Get Queue URL
QUEUE_URL=$(aws sqs get-queue-url --queue-name $QUEUE_NAME --region $REGION --query 'QueueUrl' --output text)

if [ -z "$QUEUE_URL" ]; then
    echo "Failed to get Queue URL. Exiting."
    exit 1
fi

echo "Queue URL: $QUEUE_URL"

# Send Message to SQS Queue
echo "Sending message to SQS queue..."
MESSAGE_BODY="This is a test message"
aws sqs send-message --queue-url $QUEUE_URL --message-body "$MESSAGE_BODY" --region $REGION

# Receive Message from SQS Queue
echo "Receiving message from SQS queue..."
RECEIVE_OUTPUT=$(aws sqs receive-message --queue-url $QUEUE_URL --region $REGION --max-number-of-messages 1 --query 'Messages[0].Body' --output text)

if [ -z "$RECEIVE_OUTPUT" ]; then
    echo "No messages received."
else
    echo "Received message: $RECEIVE_OUTPUT"
fi

# Cleanup/Delete SQS Queue - disabled SJ
#echo "Deleting SQS queue..."
#aws sqs delete-queue --queue-url $QUEUE_URL --region $REGION

echo "Test completed."