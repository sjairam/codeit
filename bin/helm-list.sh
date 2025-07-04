#!/bin/bash
# Initial version: SJ 001 - Find the software deployed in cluster
# 0.2 - Change the output to a detailed table

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

# Function to format helm output as a proper table
format_helm_table() {
    local temp_file="$1"
    
    # Print table header
    echo "| NAME | NAMESPACE | REVISION | STATUS | CHART | APP VERSION | UPDATED |"
    echo "|------|-----------|----------|--------|-------|-------------|---------|"
    
    # Process each line and format as markdown table
    tail -n +2 "$temp_file" | while IFS=$'\t' read -r name namespace revision status chart app_version updated; do
        if [[ -n "$name" ]]; then
            # Escape any pipes in the data to prevent table formatting issues
            name=$(echo "$name" | sed 's/|/\\|/g')
            namespace=$(echo "$namespace" | sed 's/|/\\|/g')
            chart=$(echo "$chart" | sed 's/|/\\|/g')
            app_version=$(echo "$app_version" | sed 's/|/\\|/g')
            updated=$(echo "$updated" | sed 's/|/\\|/g')
            
            echo "| $name | $namespace | $revision | $status | $chart | $app_version | $updated |"
        fi
    done
}

# Function to print summary
print_summary() {
    local total_releases="$1"
    local unique_namespaces="$2"
    
    echo
    echo -e "${GREEN}## Summary${NC}"
    echo -e "- **Total Releases**: $total_releases"
    echo -e "- **Namespaces**: $unique_namespaces"
    echo
}



# Function to print individual namespace details
print_namespace_details() {
    local temp_file="$1"
    
    echo -e "${GREEN}## Namespace Details${NC}"
    
    # Get unique namespaces
    namespaces=$(tail -n +2 "$temp_file" | cut -f2 | sort -u)
    
    for namespace in $namespaces; do
        if [[ -n "$namespace" ]]; then
            echo -e "${YELLOW}### $namespace${NC}"
            
            # Get releases for this namespace
            tail -n +2 "$temp_file" | while IFS=$'\t' read -r name ns revision status chart app_version updated; do
                if [[ "$ns" == "$namespace" && -n "$name" ]]; then
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
    
    # Check if we have any releases
    if [[ $(tail -n +2 "$temp_file" | wc -l) -eq 0 ]]; then
        echo -e "${YELLOW}No Helm releases found in any namespace.${NC}"
        rm -f "$temp_file"
        return 0
    fi
    
    # Print the formatted table
    format_helm_table "$temp_file"
    
    # Calculate statistics
    total_releases=$(tail -n +2 "$temp_file" | wc -l)
    unique_namespaces=$(tail -n +2 "$temp_file" | cut -f2 | sort -u | wc -l)
    
    print_summary "$total_releases" "$unique_namespaces"
    
    # Optional: Print detailed breakdown by namespace
    if [[ "${1:-}" == "--detailed" ]]; then
        print_namespace_details "$temp_file"
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

