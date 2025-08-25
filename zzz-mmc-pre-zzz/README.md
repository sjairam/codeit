# zzz-mmc-pre-zzz

A collection of Kubernetes and AWS utility scripts and tools for enhanced command-line productivity and infrastructure management.

## Overview

This directory contains various utility scripts and tools that enhance the Kubernetes and AWS command-line experience. These tools provide convenient shortcuts, prompt enhancements, and management capabilities for Kubernetes contexts, namespaces, and AWS WAF configurations.

## Directory Structure

```
zzz-mmc-pre-zzz/
├── README.md
├── kubectx.sh
├── profiles/
│   ├── kube_ps.sh
│   └── kubens.sh
├── aws-waf-cloudfrontV2/
│   ├── AWS-AWF-CLOUDFRONT.jpg
│   └── aws-waf-cloudfrontv2.html
└── tools/
    └── get_k9s.sh
```

## Contents

### Kubernetes Utilities

#### `profiles/kube_ps.sh` - Kubernetes Prompt Helper
A comprehensive bash/zsh prompt enhancement script that displays current Kubernetes context and namespace information in your shell prompt.

**Features:**
- Shows current Kubernetes context and namespace
- Configurable colors and symbols
- Support for both bash and zsh
- Automatic prompt updates
- Configurable display options

**Usage:**
```bash
# Source the script in your .bashrc or .zshrc
source /path/to/zzz-mmc-pre-zzz/profiles/kube_ps.sh

# Customize the prompt appearance
export KUBE_PS1_SYMBOL_ENABLE=true
export KUBE_PS1_NS_ENABLE=true
export KUBE_PS1_CONTEXT_ENABLE=true
```

#### `kubectx.sh` - Kubernetes Context Manager
A utility for managing and switching between kubectl contexts with an intuitive interface.

**Features:**
- List all available contexts
- Switch between contexts
- Rename contexts
- Delete contexts
- Previous context switching
- Colored output for current context

**Usage:**
```bash
# List all contexts
./kubectx.sh

# Switch to a specific context
./kubectx.sh <context-name>

# Switch to previous context
./kubectx.sh -

# Show current context
./kubectx.sh -c

# Rename a context
./kubectx.sh <new-name>=<old-name>

# Delete a context
./kubectx.sh -d <context-name>
```

#### `profiles/kubens.sh` - Kubernetes Namespace Manager
A utility for switching between Kubernetes namespaces within the current context.

**Features:**
- List namespaces in current context
- Switch between namespaces
- Previous namespace switching
- Current namespace display
- Persistent namespace memory per context

**Usage:**
```bash
# List all namespaces in current context
./profiles/kubens.sh

# Switch to a specific namespace
./profiles/kubens.sh <namespace-name>

# Switch to previous namespace
./profiles/kubens.sh -

# Show current namespace
./profiles/kubens.sh -c
```

#### `tools/get_k9s.sh` - K9s Installation Helper
A utility script for installing and managing K9s, a terminal-based Kubernetes UI.

**Features:**
- Automated K9s installation
- Version management
- Platform detection (Linux, macOS, Windows)
- Dependency checking
- Installation verification

**Usage:**
```bash
# Install K9s
./tools/get_k9s.sh

# Install specific version
./tools/get_k9s.sh --version v0.27.3

# Check current installation
./tools/get_k9s.sh --check

# Update K9s
./tools/get_k9s.sh --update
```

### AWS Utilities

#### `aws-waf-cloudfrontV2/aws-waf-cloudfrontv2.html` - AWS WAF & CloudFront Configuration Guide
An interactive HTML presentation/documentation for AWS WAF and CloudFront configuration best practices.

**Features:**
- Slide-based presentation format
- Comprehensive coverage of WAF and CloudFront setup
- Interactive navigation
- Professional styling and layout
- Best practices and configuration examples

**Usage:**
```bash
# Open in browser
open aws-waf-cloudfrontV2/aws-waf-cloudfrontv2.html
# or
xdg-open aws-waf-cloudfrontV2/aws-waf-cloudfrontv2.html
```

## Installation & Setup

### Prerequisites
- `kubectl` installed and configured
- Bash or Zsh shell
- Access to Kubernetes clusters
- AWS CLI (for AWS-related operations)

### Setup Instructions

1. **Clone or copy the scripts to your desired location**
2. **Make scripts executable:**
   ```bash
   chmod +x kubectx.sh profiles/*.sh tools/*.sh
   ```

3. **Add to your shell configuration:**
   ```bash
   # For bash (.bashrc)
   source /path/to/zzz-mmc-pre-zzz/profiles/kube_ps.sh
   
   # For zsh (.zshrc)
   source /path/to/zzz-mmc-pre-zzz/profiles/kube_ps.sh
   ```

4. **Optional: Add scripts to your PATH:**
   ```bash
   export PATH="$PATH:/path/to/zzz-mmc-pre-zzz:/path/to/zzz-mmc-pre-zzz/profiles:/path/to/zzz-mmc-pre-zzz/tools"
   ```

## Configuration

### Environment Variables

The scripts support various environment variables for customization:

- `KUBE_PS1_SYMBOL_ENABLE`: Enable/disable Kubernetes symbol in prompt
- `KUBE_PS1_NS_ENABLE`: Enable/disable namespace display in prompt
- `KUBE_PS1_CONTEXT_ENABLE`: Enable/disable context display in prompt
- `KUBE_PS1_SYMBOL_COLOR`: Customize symbol color
- `KUBECTX_CURRENT_FGCOLOR`: Customize current context foreground color
- `KUBECTX_CURRENT_BGCOLOR`: Customize current context background color

### Example Configuration

```bash
# Add to your shell configuration file
export KUBE_PS1_SYMBOL_ENABLE=true
export KUBE_PS1_NS_ENABLE=true
export KUBE_PS1_CONTEXT_ENABLE=true
export KUBE_PS1_SYMBOL_COLOR=cyan
export KUBECTX_CURRENT_FGCOLOR=$(tput setaf 3)
export KUBECTX_CURRENT_BGCOLOR=$(tput setab 0)
```

## Usage Examples

### Basic Kubernetes Operations

```bash
# Check current context and namespace
kubectl config current-context
kubectl config view --minify --output 'jsonpath={..namespace}'

# Switch context and namespace
./kubectx.sh production
./profiles/kubens.sh monitoring

# Quick context/namespace switching
./kubectx.sh -  # Previous context
./profiles/kubens.sh -   # Previous namespace
```

### Enhanced Shell Prompt

After setting up `profiles/kube_ps.sh`, your prompt will display:
```
user@host (context:namespace) $
```

### K9s Management

```bash
# Install K9s for better Kubernetes management
./tools/get_k9s.sh

# Launch K9s
k9s

# Use K9s with specific context
k9s --context production
```

## Troubleshooting

### Common Issues

1. **Scripts not executable:**
   ```bash
   chmod +x kubectx.sh profiles/*.sh tools/*.sh
   ```

2. **Prompt not updating:**
   - Ensure the script is sourced in your shell configuration
   - Check that `kubectl` is accessible
   - Verify your shell supports the required features

3. **Permission denied errors:**
   - Check file permissions
   - Ensure proper ownership
   - Verify execution rights

4. **K9s installation issues:**
   - Check internet connectivity
   - Verify platform compatibility
   - Ensure sufficient disk space

### Debug Mode

Enable debug mode for troubleshooting:
```bash
export DEBUG=1
source profiles/kube_ps.sh
```

## Contributing

These scripts are maintained as part of the personal toolkit. For improvements or bug fixes:

1. Test changes thoroughly
2. Maintain backward compatibility
3. Update documentation as needed
4. Follow existing code style

## License

- **profiles/kube_ps.sh**: Apache License 2.0 (Copyright 2025 Jon Mosco)
- **kubectx.sh**: Apache License 2.0 (Copyright 2017 Google Inc.)
- **profiles/kubens.sh**: Apache License 2.0 (Copyright 2017 Google Inc.)
- **tools/get_k9s.sh**: Custom script
- **aws-waf-cloudfrontV2/aws-waf-cloudfrontv2.html**: Custom documentation

## Related Tools

These scripts complement other Kubernetes and AWS tools:
- `kubectl` - Kubernetes command-line tool
- `k9s` - Terminal-based Kubernetes UI
- `lens` - Kubernetes IDE
- AWS CLI and related tools

## Support

For issues or questions:
- Check the troubleshooting section
- Review script help output (`./script.sh --help`)
- Verify your environment meets prerequisites
- Test with minimal configuration first
