#!/bin/bash

# Cert-Manager Upgrade Script
# This script safely upgrades cert-manager in Kubernetes clusters
# Supports both Helm and YAML manifest upgrade methods
# v0.1 - initial 
# v0.2 - Harvard request
# 0.3 - Add usage and help 

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CERT_MANAGER_VERSION="v1.19.0"
NAMESPACE="cert-manager"
BACKUP_DIR="./cert-manager-backup-$(date +%Y%m%d-%H%M%S)"
UPGRADE_METHOD="helm"
DRY_RUN=false
FORCE=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -v, --version VERSION     Cert-manager version to upgrade to (default: $CERT_MANAGER_VERSION)
    -n, --namespace NAMESPACE Namespace where cert-manager is installed (default: $NAMESPACE)
    -m, --method METHOD       Upgrade method: helm or yaml (default: $UPGRADE_METHOD)
    -b, --backup-dir DIR      Backup directory (default: $BACKUP_DIR)
    --dry-run                 Perform a dry run without making changes
    -f, --force               Force upgrade without confirmation
    -h, --help                Show this help message

Examples:
    $0 -v v1.18.3 -m helm
    $0 -v v1.18.3 -m yaml --dry-run
    $0 -f -v v1.18.3

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    # Check if cert-manager namespace exists
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        print_error "Namespace '$NAMESPACE' does not exist. Cert-manager may not be installed."
        exit 1
    fi
    
    # Check if cert-manager is installed
    if ! kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=cert-manager &> /dev/null; then
        print_warning "Cert-manager pods not found in namespace '$NAMESPACE'"
    fi
    
    print_success "Prerequisites check passed"
}

# Function to detect current cert-manager version
detect_current_version() {
    print_status "Detecting current cert-manager version..."
    
    # Try to get version from deployment
    CURRENT_VERSION=$(kubectl get deployment -n $NAMESPACE cert-manager -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
    
    if [ "$CURRENT_VERSION" != "unknown" ]; then
        print_status "Current cert-manager version: $CURRENT_VERSION"
    else
        print_warning "Could not detect current cert-manager version"
    fi
}

# Function to create backup
create_backup() {
    print_status "Creating backup of current cert-manager configuration..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup all cert-manager resources
    kubectl get all -n $NAMESPACE -o yaml > "$BACKUP_DIR/cert-manager-resources.yaml"
    
    # Backup CRDs
    kubectl get crd -o yaml | grep -E "(cert-manager|certificates|certificaterequests|clusterissuers|issuers)" > "$BACKUP_DIR/cert-manager-crds.yaml" || true
    
    # Backup secrets and configmaps
    kubectl get secrets -n $NAMESPACE -o yaml > "$BACKUP_DIR/cert-manager-secrets.yaml"
    kubectl get configmaps -n $NAMESPACE -o yaml > "$BACKUP_DIR/cert-manager-configmaps.yaml"
    
    print_success "Backup created in: $BACKUP_DIR"
}

# Function to upgrade using Helm
upgrade_with_helm() {
    print_status "Upgrading cert-manager using Helm..."
    
    # Check if Helm is available
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed or not in PATH"
        exit 1
    fi
    
    # Add cert-manager repo if not exists
    if ! helm repo list | grep -q jetstack; then
        print_status "Adding cert-manager Helm repository..."
        helm repo add jetstack https://charts.jetstack.io
        helm repo update
    fi
    
    # Check if cert-manager is installed via Helm
    if ! helm list -n $NAMESPACE | grep -q cert-manager; then
        print_warning "Cert-manager does not appear to be installed via Helm"
        print_status "Attempting to install cert-manager via Helm..."
        
        if [ "$DRY_RUN" = true ]; then
            helm install cert-manager jetstack/cert-manager \
                --namespace $NAMESPACE \
                --create-namespace \
                --version $CERT_MANAGER_VERSION \
                --set installCRDs=true \
                --dry-run
        else
            helm install cert-manager jetstack/cert-manager \
                --namespace $NAMESPACE \
                --create-namespace \
                --version $CERT_MANAGER_VERSION \
                --set installCRDs=true
        fi
    else
        print_status "Upgrading existing cert-manager installation..."
        
        if [ "$DRY_RUN" = true ]; then
            helm upgrade cert-manager jetstack/cert-manager \
                --namespace $NAMESPACE \
                --version $CERT_MANAGER_VERSION \
                --dry-run
        else
            helm upgrade cert-manager jetstack/cert-manager \
                --namespace $NAMESPACE \
                --version $CERT_MANAGER_VERSION
        fi
    fi
}

# Function to upgrade using YAML manifests
upgrade_with_yaml() {
    print_status "Upgrading cert-manager using YAML manifests..."
    
    # Download cert-manager manifests
    MANIFEST_URL="https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.yaml"
    
    print_status "Downloading cert-manager manifests from: $MANIFEST_URL"
    
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run - would apply manifests from: $MANIFEST_URL"
        curl -sL "$MANIFEST_URL" | kubectl apply --dry-run=client -f -
    else
        kubectl apply -f "$MANIFEST_URL"
    fi
}

# Function to verify upgrade
verify_upgrade() {
    print_status "Verifying cert-manager upgrade..."
    
    # Wait for cert-manager pods to be ready
    print_status "Waiting for cert-manager pods to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n $NAMESPACE --timeout=300s
    
    # Check pod status
    print_status "Cert-manager pod status:"
    kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=cert-manager
    
    # Verify CRDs are installed
    print_status "Verifying CRDs..."
    kubectl get crd | grep cert-manager
    
    # Test cert-manager functionality
    print_status "Testing cert-manager functionality..."
    kubectl get clusterissuer 2>/dev/null || print_warning "No ClusterIssuers found"
    kubectl get issuer -n $NAMESPACE 2>/dev/null || print_warning "No Issuers found in $NAMESPACE"
    
    print_success "Cert-manager upgrade verification completed"
}

# Function to rollback
rollback() {
    print_error "Rolling back cert-manager..."
    
    if [ -d "$BACKUP_DIR" ]; then
        print_status "Restoring from backup: $BACKUP_DIR"
        kubectl apply -f "$BACKUP_DIR/cert-manager-resources.yaml"
        kubectl apply -f "$BACKUP_DIR/cert-manager-crds.yaml"
    else
        print_error "Backup directory not found. Manual rollback required."
    fi
}

# Function to cleanup
cleanup() {
    if [ "$DRY_RUN" = false ] && [ -d "$BACKUP_DIR" ]; then
        print_status "Cleaning up backup directory..."
        rm -rf "$BACKUP_DIR"
    fi
}

# Main execution
main() {
    # Allow --help without requiring kubectl
    for arg in "$@"; do
        if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
            show_usage
            exit 0
        fi
    done

    # Check kubectl is available before any other operations
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                CERT_MANAGER_VERSION="$2"
                shift 2
                ;;
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -m|--method)
                UPGRADE_METHOD="$2"
                shift 2
                ;;
            -b|--backup-dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate upgrade method
    if [[ "$UPGRADE_METHOD" != "helm" && "$UPGRADE_METHOD" != "yaml" ]]; then
        print_error "Invalid upgrade method: $UPGRADE_METHOD. Use 'helm' or 'yaml'"
        exit 1
    fi
    
    print_status "Cert-manager upgrade script started"
    print_status "Target version: $CERT_MANAGER_VERSION"
    print_status "Namespace: $NAMESPACE"
    print_status "Upgrade method: $UPGRADE_METHOD"
    print_status "Dry run: $DRY_RUN"
    
    # Confirmation prompt
    if [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
        echo
        read -p "Do you want to proceed with the cert-manager upgrade? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Upgrade cancelled by user"
            exit 0
        fi
    fi
    
    # Set up error handling
    trap 'print_error "An error occurred. Rolling back..."; rollback; cleanup; exit 1' ERR
    trap 'cleanup' EXIT
    
    # Execute upgrade steps
    check_prerequisites
    detect_current_version
    create_backup
    
    case $UPGRADE_METHOD in
        "helm")
            upgrade_with_helm
            ;;
        "yaml")
            upgrade_with_yaml
            ;;
    esac
    
    if [ "$DRY_RUN" = false ]; then
        verify_upgrade
        print_success "Cert-manager upgrade completed successfully!"
    else
        print_success "Dry run completed successfully!"
    fi
}

# Run main function with all arguments
main "$@"
