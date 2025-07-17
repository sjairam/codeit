#!/bin/bash

# Usage: ./find_replace_secrets.sh [find|replace|find-external|find-secretstore] [directory]
#   find         - Display all occurrences of 'v1beta' in .yaml/.yml files
#   replace      - Replace all 'v1beta' with 'v1' in those files (in-place)
#   find-external- Display all occurrences of 'v1beta' in files that also contain 'ExternalSecret'
#   find-secretstore - Display all occurrences of 'v1beta' in files that contain 'SecretStore'
# Default mode is 'find'. Default directory is current directory if not specified.

MODE="${1:-find}"
DIR="${2:-.}"

if [[ "$MODE" == "find" ]]; then
  echo "Searching for 'v1beta' in $DIR..."
  find "$DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \) -exec grep --color=always -Hn 'v1beta' {} +
elif [[ "$MODE" == "replace" ]]; then
  echo "Replacing 'v1beta' with 'v1' in $DIR..."
  find "$DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \) -exec sed -i '' 's/v1beta/v1/g' {} +
elif [[ "$MODE" == "find-external" ]]; then
  echo "Searching for 'v1beta' in ExternalSecret resources in $DIR..."
  while IFS= read -r file; do
    if grep -q 'ExternalSecret' "$file"; then
      grep --color=always -Hn 'v1beta' "$file"
    fi
  done < <(find "$DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \))
elif [[ "$MODE" == "find-secretstore" ]]; then
  echo "Searching for 'v1beta' in files containing 'SecretStore' in $DIR..."
  while IFS= read -r file; do
    if grep -q 'SecretStore' "$file"; then
      grep --color=always -Hn 'v1beta' "$file"
    fi
  done < <(find "$DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \))
else
  echo "Unknown mode: $MODE"
  echo "Usage: $0 [find|replace|find-external|find-secretstore] [directory]"
  exit 1
fi
