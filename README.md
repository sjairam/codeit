# CodeIt - DevOps & Infrastructure Toolkit

A comprehensive collection of DevOps tools, scripts, and utilities for managing cloud infrastructure, Kubernetes clusters, AWS resources, and development workflows.

## 🚀 Overview

This repository contains a curated set of tools and scripts for:
- **Cloud Infrastructure Management** (AWS, Kubernetes, Istio)
- **Development & Operations Automation**
- **Security & Compliance Tools**
- **Monitoring & Health Checks**
- **Database & Message Queue Management**

## 📁 Project Structure

### 🔧 Core Tools & Scripts

#### `/bin/` - Main Scripts Directory
- **AWS Management**: `aws-list`, `list_alb`, `list_rds`, `list_secrets`
- **Kubernetes Tools**: `kubectl-get-pod`, `helm-list.sh`, `restart-deployments.sh`
- **System Health**: `check_system_health`, `sslCheck.sh`, `solr-check.sh`
- **Database Tools**: `connect_db`, `connect_postgres`, `export_db`
- **Security**: `gen_passwd`, `find_replace_secrets`
- **GitHub Management**: `github-COM`, `github-INFRA`, `github-PERSONAL`, `github-TOOLS`

#### `/bin_shell/` - Shell Scripts
- Backup and system management scripts
- Infrastructure deployment utilities
- Security and compliance tools

#### `/go/` - Go Applications
- **AWS Tools**: `check_aws.go`, `check_rds.go`, `list_alb.go`, `list_rds.go`
- **Security**: `gen_passwd.go`, `list_secretsGO.go`
- **Infrastructure**: `list_ec2_instances.go`

#### `/python/` - Python Scripts
- **AWS Integration**: `aws-login.py`
- **Algorithm Challenges**: Various mathematical problem solutions
- **Utility Scripts**: File processing and automation tools

### 🏗️ Infrastructure & Configuration

#### `/kafka/` - Apache Kafka Setup
- Kafka cluster configuration
- Strimzi operator deployment
- Prometheus monitoring setup

#### `/istio/` - Service Mesh Configuration
- Istio gateway configurations
- Service mesh lab examples
- Ambient and sidecar deployment patterns

#### `/kube/` - Kubernetes Configurations
- Cluster configuration files
- Environment-specific configs (dev, qa, prod)

#### `/terraform/` - Infrastructure as Code
- Terraform configurations for various resources
- Kafka infrastructure setup

#### `/deployment/` - Kubernetes Deployments
- Sample deployment manifests
- Nginx and hello-world examples

### 🔒 Security & Compliance

#### `/sast/` - Static Application Security Testing
- SAST configurations for multiple languages:
  - Java, Node.js, Python, Ruby
  - Orca and Wiz security tools
- Suppression rules and policies

#### `/wiz/` - Wiz Security Platform
- Wiz CLI configurations
- Infrastructure as Code security scanning

### 📊 Monitoring & Testing

#### `/testkube/` - TestKube Configuration
- Kubernetes-native testing framework setup
- Harvard-specific test configurations

#### `/k6s/` - Performance Testing
- K6 load testing configurations

#### `/rpchecker/` - Site Connectivity Checker
- Python-based website availability monitoring
- Synchronous and asynchronous checking capabilities

### 🗄️ Data & Storage

#### `/oracle/` - Oracle Database Tools
- Database size checking scripts
- Oracle-specific utilities

#### `/solr/` - Apache Solr
- Solr backup and management scripts
- Search infrastructure tools

#### `/runmqsc/` - IBM MQ Scripts
- Message queue management scripts
- Queue depth monitoring
- System queue operations

#### `/pv_pvc_sc/` - Kubernetes Storage
- Persistent Volume configurations
- Storage Class definitions
- PVC templates

### 📝 Documentation & Notes

#### `/docs/` - Documentation
- Project documentation
- Setup guides and tutorials

#### `/notes/` - Project Notes
- Infrastructure documentation
- Decommissioning plans
- System architecture notes

#### `/history/` - Historical Records
- Project history and changes
- Migration documentation

## 🛠️ Setup & Installation

### Prerequisites

This project uses various tools and technologies. Install them using the provided `brewfile.txt`:

```bash
# Install Homebrew packages
brew bundle --file=brewfile.txt
```

### Key Dependencies

- **AWS CLI** - Cloud infrastructure management
- **kubectl** - Kubernetes cluster management
- **Helm** - Kubernetes package manager
- **Istio** - Service mesh
- **Terraform** - Infrastructure as Code
- **Python 3.11+** - Scripting and automation
- **Go** - High-performance tools
- **Node.js** - JavaScript utilities

### Environment Setup

1. **AWS Configuration**:
   ```bash
   aws configure
   ```

2. **Kubernetes Context**:
   ```bash
   kubectl config use-context <your-cluster>
   ```

3. **Python Environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

## 🚀 Quick Start

### Basic Usage Examples

1. **List AWS Resources**:
   ```bash
   ./bin/aws-list
   ./bin/list_alb
   ./bin/list_rds
   ```

2. **Kubernetes Operations**:
   ```bash
   ./bin/kubectl-get-pod
   ./bin/helm-list.sh
   ```

3. **System Health Check**:
   ```bash
   ./bin/check_system_health
   ./bin/sslCheck.sh
   ```

4. **Site Connectivity Check**:
   ```bash
   cd rpchecker
   python -m rpchecker -u example.com
   ```

## 🔧 Development

### Adding New Tools

1. **Shell Scripts**: Add to `/bin/` or `/bin_shell/`
2. **Go Applications**: Add to `/go/` with proper Go modules
3. **Python Scripts**: Add to `/python/` with requirements
4. **Infrastructure**: Add to appropriate subdirectory

### Code Standards

- Follow shell script best practices for `/bin/` scripts
- Use Go modules for Go applications
- Include proper error handling and logging
- Add documentation for complex tools

## 📋 Current Projects

### Active Development
- Infrastructure cleanup and optimization
- Security compliance automation
- Monitoring and alerting improvements
- Performance testing framework

### Planned Work
See `Future-Work.txt` for detailed roadmap including:
- ALB cleanup across environments
- Certificate management improvements
- Route53 cleanup
- S3 bucket optimization
- Secret management enhancements

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your tools/scripts with proper documentation
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is for internal use and contains various tools and configurations for DevOps and infrastructure management.

## 🔗 Related Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Istio Documentation](https://istio.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)

---

**Note**: This repository contains production infrastructure tools. Always test changes in development environments before applying to production systems.
