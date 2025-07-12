#!/bin/bash
# Script to delete all TestKube CRDs from the cluster
# Usage: ./delete_testkube.sh [--force] [--dry-run]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_NAME=$(basename "$0")
DRY_RUN=false
FORCE=false
VERBOSE=false

# TestKube CRD patterns to match
CRD_PATTERNS=(
  ".*\.tests\.testkube\.io$"
  ".*\.testworkflows\.testkube\.io$"
  ".*\.executor\.testkube\.io$"
)

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Help function
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Delete all TestKube CRDs from the Kubernetes cluster using regex patterns.

OPTIONS:
    --dry-run     Show what would be deleted without actually deleting
    --force       Skip confirmation prompt
    --verbose     Enable verbose output
    -h, --help    Show this help message

EXAMPLES:
    $SCRIPT_NAME                    # Delete with confirmation
    $SCRIPT_NAME --dry-run          # Show what would be deleted
    $SCRIPT_NAME --force            # Delete without confirmation
    $SCRIPT_NAME --verbose --force  # Verbose deletion without confirmation

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Get current context
get_current_context() {
    local context
    context=$(kubectl config current-context 2>/dev/null || echo "unknown")
    log_info "Current Kubernetes context: $context"
}

# Find CRDs matching patterns
find_matching_crds() {
    local matching_crds=()
    
    # Get all CRDs and filter by patterns
    while IFS= read -r crd; do
        if [[ -n "$crd" ]]; then
            for pattern in "${CRD_PATTERNS[@]}"; do
                if [[ "$crd" =~ $pattern ]]; then
                    matching_crds+=("$crd")
                    break
                fi
            done
        fi
    done < <(kubectl get crd --no-headers -o custom-columns=":metadata.name" 2>/dev/null || true)
    
    echo "${matching_crds[@]}"
}

# Check if CRDs exist
check_crds_exist() {
    log_info "Checking for existing TestKube CRDs using regex patterns..."
    
    local matching_crds
    readarray -t matching_crds < <(find_matching_crds)
    
    if [[ ${#matching_crds[@]} -eq 0 ]]; then
        log_warning "No TestKube CRDs found in the cluster"
        return 1
    else
        log_info "Found ${#matching_crds[@]} TestKube CRDs:"
        for crd in "${matching_crds[@]}"; do
            echo "  - $crd"
        done
        return 0
    fi
}

# Confirm deletion
confirm_deletion() {
    if [[ "$FORCE" == true ]]; then
        log_warning "Force flag specified, skipping confirmation"
        return 0
    fi
    
    echo
    log_warning "This will delete ALL TestKube CRDs from the cluster!"
    log_warning "This action cannot be undone and may affect running TestKube resources."
    echo
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled by user"
        exit 0
    fi
}

# Delete CRDs
delete_crds() {
    local deleted_count=0
    local failed_count=0
    
    log_info "Starting CRD deletion..."
    
    local matching_crds
    readarray -t matching_crds < <(find_matching_crds)
    
    for crd in "${matching_crds[@]}"; do
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY-RUN] Would delete CRD: $crd"
            continue
        fi
        
        if [[ "$VERBOSE" == true ]]; then
            log_info "Deleting CRD: $crd"
        fi
        
        if kubectl delete crd "$crd" --ignore-not-found &> /dev/null; then
            log_success "Deleted CRD: $crd"
            ((deleted_count++))
        else
            log_error "Failed to delete CRD: $crd"
            ((failed_count++))
        fi
    done
    
    # Summary
    echo
    if [[ "$DRY_RUN" == true ]]; then
        log_info "Dry run completed. No actual changes were made."
    else
        if [[ $deleted_count -gt 0 ]]; then
            log_success "Successfully deleted $deleted_count CRD(s)"
        fi
        if [[ $failed_count -gt 0 ]]; then
            log_error "Failed to delete $failed_count CRD(s)"
        fi
        if [[ $deleted_count -eq 0 && $failed_count -eq 0 ]]; then
            log_info "No CRDs were found to delete"
        fi
    fi
}

# Main function
main() {
    log_info "Starting TestKube CRD cleanup script"
    
    parse_args "$@"
    check_prerequisites
    get_current_context
    
    if ! check_crds_exist; then
        log_info "No TestKube CRDs to delete"
        exit 0
    fi
    
    confirm_deletion
    delete_crds
    
    log_success "TestKube CRD cleanup completed"
}

# Run main function with all arguments
main "$@" 