#!/bin/bash

# Helm List Script
# Outputs formatted results of helm list -A with summary statistics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print header
print_header() {
    echo -e "${BLUE}# Helm Releases - All Namespaces${NC}"
    echo -e "${BLUE}# Generated: $(date)${NC}"
    echo
}

# Function to print table header
print_table_header() {
    echo "| NAME | NAMESPACE | REVISION | STATUS | CHART | APP VERSION | UPDATED |"
    echo "|------|-----------|----------|--------|-------|-------------|---------|"
}

# Function to print summary
print_summary() {
    echo
    echo -e "${GREEN}## Summary${NC}"
    echo -e "- **Total Releases**: $total_releases"
    echo -e "- **Namespaces**: $unique_namespaces"
    echo -e "- **All Status**: deployed"
    echo
}

# Function to print namespace breakdown
print_namespace_breakdown() {
    echo -e "${GREEN}## Namespace Breakdown${NC}"
    
    # Count releases per namespace
    declare -A namespace_counts
    while IFS=$'\t' read -r name namespace revision status chart app_version updated; do
        if [[ -n "$namespace" && "$namespace" != "NAMESPACE" ]]; then
            ((namespace_counts["$namespace"]++))
        fi
    done < <(helm list -A --output table | tail -n +2)
    
    # Sort namespaces by count (descending)
    for namespace in "${!namespace_counts[@]}"; do
        echo "$namespace:${namespace_counts[$namespace]}"
    done | sort -t: -k2 -nr | while IFS=: read -r namespace count; do
        echo -e "- **$namespace**: $count release$([ $count -ne 1 ] && echo "s")"
    done
    
    echo
}

# Function to print individual namespace details
print_namespace_details() {
    echo -e "${GREEN}## Namespace Details${NC}"
    
    # Get unique namespaces
    namespaces=$(helm list -A --output table | tail -n +2 | cut -f2 | sort -u)
    
    for namespace in $namespaces; do
        if [[ -n "$namespace" ]]; then
            echo -e "${YELLOW}### $namespace${NC}"
            helm list -n "$namespace" --output table | tail -n +2 | while IFS=$'\t' read -r name ns revision status chart app_version updated; do
                if [[ -n "$name" ]]; then
                    echo -e "  - $name ($chart v$app_version) - $status"
                fi
            done
            echo
        fi
    done
}

# Main execution
main() {
    print_header
    
    # Get helm list output and save to temporary file
    temp_file=$(mktemp)
    helm list -A --output table > "$temp_file"
    
    # Print the table
    print_table_header
    tail -n +2 "$temp_file"
    
    # Calculate statistics
    total_releases=$(tail -n +2 "$temp_file" | wc -l)
    unique_namespaces=$(tail -n +2 "$temp_file" | cut -f2 | sort -u | wc -l)
    
    print_summary
    print_namespace_breakdown
    
    # Optional: Print detailed breakdown by namespace
    if [[ "${1:-}" == "--detailed" ]]; then
        print_namespace_details
    fi
    
    # Cleanup
    rm -f "$temp_file"
}

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: helm command not found. Please install Helm first.${NC}" >&2
    exit 1
fi

# Check if we have access to a Kubernetes cluster
if ! helm list -A --output table &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster or no releases found.${NC}" >&2
    echo -e "${YELLOW}Make sure you have:${NC}" >&2
    echo -e "  1. Valid kubeconfig" >&2
    echo -e "  2. Access to the cluster" >&2
    echo -e "  3. Helm releases deployed" >&2
    exit 1
fi

# Run the script
main "$@" 