#!/bin/bash

FOLDER="$1"

# Check if a parameter was given
if [ -z "$FOLDER" ]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

echo "🔎 Searching for the biggest files in: $1"
echo "--------------------------------------------"

find "$1" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 20

