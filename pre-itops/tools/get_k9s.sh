#!/bin/bash
# v0.1 - initial
# v0.2 - change colours 

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Function to print coloured output
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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root is not recommended. Continuing anyway..."
fi

# Check if running on RedHat-based system
if [ ! -f /etc/redhat-release ]; then
    print_error "This script is intended for RedHat-based systems only."
    exit 1
fi

print_status "Detecting system architecture..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

print_success "Architecture detected: $ARCH"

# Get latest k9s version
print_status "Fetching latest k9s version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    print_error "Failed to fetch latest version"
    exit 1
fi

print_success "Latest version: $LATEST_VERSION"

# Define installation directory
INSTALL_DIR="/usr/local/bin"
K9S_BINARY="$INSTALL_DIR/k9s"

# Check if k9s is already installed
if command -v k9s &> /dev/null; then
    CURRENT_VERSION=$(k9s version -s | grep Version | awk '{print $2}')
    print_warning "k9s is already installed (version: $CURRENT_VERSION)"
    read -p "Do you want to update to $LATEST_VERSION? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled."
        exit 0
    fi
fi

# Download and install k9s
print_status "Downloading k9s $LATEST_VERSION..."
DOWNLOAD_URL="https://github.com/derailed/k9s/releases/download/$LATEST_VERSION/k9s_Linux_$ARCH.tar.gz"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if ! curl -sSL "$DOWNLOAD_URL" -o k9s.tar.gz; then
    print_error "Failed to download k9s"
    rm -rf "$TEMP_DIR"
    exit 1
fi

print_success "Download completed"

# Extract and install
print_status "Extracting and installing..."
if ! tar -xzf k9s.tar.gz; then
    print_error "Failed to extract archive"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Move binary to installation directory
if ! sudo mv k9s "$K9S_BINARY"; then
    print_error "Failed to move binary to $INSTALL_DIR"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Set executable permissions
sudo chmod +x "$K9S_BINARY"

# Clean up
rm -rf "$TEMP_DIR"

# Verify installation
if command -v k9s &> /dev/null; then
    INSTALLED_VERSION=$(k9s version -s | grep Version | awk '{print $2}')
    print_success "k9s $INSTALLED_VERSION installed successfully!"
    print_status "Location: $K9S_BINARY"
else
    print_error "Installation completed but k9s command not found"
    exit 1
fi

# Check if /usr/local/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_warning "$INSTALL_DIR is not in your PATH. Add it to your shell profile:"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
fi

print_success "Installation completed! You can now run 'k9s' to start using it."
