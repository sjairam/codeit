#!/bin/bash

# Function to check node statuses and output them in a table format
function check_nodes() {
  echo "Checking Kubernetes Nodes..."
  
  # Header for the table
  printf "%-30s %-15s %-15s %-15s %-15s %-20s %-20s\n" "Node" "Overall Status" "Ready" "MemoryPressure" "DiskPressure" "CPU Usage" "Memory Usage"
  echo "-----------------------------------------------------------------------------------------------------------"

  # Get all nodes
  nodes=$(kubectl get nodes --no-headers | awk '{print $1}')

  for node in $nodes; do
    # Get the overall status of the node
    node_status=$(kubectl get node $node --no-headers | awk '{print $2}')

    # Get node conditions
    ready_status=$(kubectl describe node $node | grep "Ready" | awk '{print $2}')
    memory_pressure=$(kubectl describe node $node | grep "MemoryPressure" | awk '{print $2}')
    disk_pressure=$(kubectl describe node $node | grep "DiskPressure" | awk '{print $2}')
    
    # Get CPU and Memory usage (assuming metrics-server is installed)
    cpu_usage=""
    memory_usage=""
    if kubectl top node $node --no-headers &>/dev/null; then
      cpu_usage=$(kubectl top node $node --no-headers | awk '{print $2}')
      memory_usage=$(kubectl top node $node --no-headers | awk '{print $3}')
    else
      cpu_usage="N/A"
      memory_usage="N/A"
    fi

    # Print the data in a tabular format
    printf "%-30s %-15s %-15s %-15s %-15s %-20s %-20s\n" "$node" "$node_status" "$ready_status" "$memory_pressure" "$disk_pressure" "$cpu_usage" "$memory_usage"
  done
  echo ""
}

# Run the check every 60 seconds
while true; do
  check_nodes
  sleep 600
done
