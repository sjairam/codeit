#!/bin/bash

# Check if clusters.txt exists
if [[ ! -f clusters.txt ]]; then
  echo "clusters.txt not found in the current directory."
  exit 1
fi

# Clear the report file
report_file="certManagerreport.txt"
> "$report_file"

# Function to handle each cluster
handle_cluster() {
  local clusterName="$1"
  {
    echo "clustername: $clusterName" >> "$report_file"

    # Switch context
    kubectl config use-context "$clusterName" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      echo "Failed to switch to cluster $clusterName. Skipping..." >> "$report_file"
      echo -e "\n*******************************************************\n" >> "$report_file"
      return
    fi

    echo "" >> "$report_file"

    # Get cert-manager pods
    kubectl get pods -n cert-manager >> "$report_file" 2>&1

    echo "" >> "$report_file"

    # Get container images
    kubectl get pods -n cert-manager -o=jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' >> "$report_file" 2>&1

    echo "" >> "$report_file"

    # Apply test cert resources
    kubectl apply -f cert-manager-test-resources.yaml >/dev/null 2>&1

    # Wait a bit to allow cert-manager to process
    sleep 10

    # Check if cert was issued
    if kubectl describe certificate -n cert-manager-test 2>/dev/null | grep -q "The certificate has been successfully issued"; then
      echo -e "\nCERT MANAGER ON $clusterName IS WORKING WELL" >> "$report_file"
    else
      echo -e "\nCERT MANAGER ON $clusterName IS NOT WORKING PROPERLY" >> "$report_file"
    fi

    # Cleanup test resources
    kubectl delete -f cert-manager-test-resources.yaml >/dev/null 2>&1

    # Divider
    echo -e "\n*******************************************************\n" >> "$report_file"
  } &
  pid=$!

  # Timeout: 60 seconds per cluster
  SECONDS=0
  while kill -0 $pid 2>/dev/null; do
    if [[ $SECONDS -ge 60 ]]; then
      echo "Timeout reached for $clusterName. Skipping to next cluster..." >> "$report_file"
      kill -9 $pid 2>/dev/null
      echo -e "\n*******************************************************\n" >> "$report_file"
      break
    fi
    sleep 1
  done
}

# Loop through clusters
while IFS= read -r clusterName || [[ -n "$clusterName" ]]; do
  [[ -z "$clusterName" ]] && continue
  handle_cluster "$clusterName"
  sleep 3
done < clusters.txt

echo "Done. Results saved in $report_file"
