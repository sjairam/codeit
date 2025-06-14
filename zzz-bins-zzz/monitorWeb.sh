#!/bin/bash

# List of websites to monitor
WEBSITES=(
  "https://kubernetes.io/releases/"
  "https://github.com/derailed/popeye"
  "https://istio.io/latest/docs/setup/platform-setup/"
)

# Directory to store the last known state of websites
STATE_DIR="/Users/jairams/Documents/GitHub/PERS/codeit/state"
mkdir -p "$STATE_DIR"

# Directory to store logs
LOG_DIR="/Users/jairams/Documents/GitHub/PERS/codeit/logs"
mkdir -p "$LOG_DIR"

# Iterate over each website
for WEBSITE in "${WEBSITES[@]}"; do
  # Generate a safe filename from the website URL
  SAFE_NAME=$(echo "$WEBSITE" | sed 's/[:\/]/_/g')
  
  # Paths to the state files
  LAST_STATE="$STATE_DIR/$SAFE_NAME.last"
  CURRENT_STATE="$STATE_DIR/$SAFE_NAME.current"
  
  # Fetch the current state of the website
  curl -s "$WEBSITE" -o "$CURRENT_STATE"
  
  # Check if the last state file exists
  if [ -f "$LAST_STATE" ]; then
    # Compare the current state with the last state
    if ! diff "$LAST_STATE" "$CURRENT_STATE" > /dev/null; then
      # If they differ, log the change
      echo "Website $WEBSITE has changed." | tee -a "$LOG_DIR/changes.log"
      # Optionally, you can add a timestamp
      echo "Change detected at $(date)" | tee -a "$LOG_DIR/changes.log"
    fi
  fi
  
  # Update the last state
  mv "$CURRENT_STATE" "$LAST_STATE"
done
