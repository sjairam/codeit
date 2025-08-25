# CodeIt - DevOps & Infrastructure Toolkit

A comprehensive collection of DevOps tools, scripts, and utilities for managing cloud infrastructure, Kubernetes clusters, AWS resources, and development workflows.

## 🚀 Overview

This repository contains a curated set of tools and scripts for:
- **Cloud Infrastructure Management** (AWS, Kubernetes, Istio)
- **Development & Operations Automation**
- **Security & Compliance Tools**
- **Monitoring & Health Checks**
- **Database & Message Queue Management**
- **Performance Testing & Load Balancing**

## 📁 Project Structure

### 🔧 Core Tools & Scripts

#### `/bin/` - Main Scripts Directory
- **AWS Management**: `aws-list`, `list_alb`, `list_rds`, `list_secrets`
- **Kubernetes Tools**: `kubectl-get-pod`, `helm-list.sh`, `restart-deployments.sh`
- **System Health**: `check_system_health`, `sslCheck.sh`, `solr-check.sh`
- **Database Tools**: `connect_db`, `connect_postgres`, `export_db`
- **Security**: `gen_passwd`, `find_replace_secrets`
- **GitHub Management**: `github-COM`, `github-INFRA`, `github-PERSONAL`, `github-TOOLS`
- **Message Queues**: `connect_broker`, `readMessagesOffQueue.sh`
- **Archival**: `archive/` - GitHub repo and message queue archival tools

#### `/bin_shell/` - Shell Scripts
- Backup and system management scripts
- Infrastructure deployment utilities
- Security and compliance tools
- Rolling restart deployments
- Certificate management

#### `/go/` - Go Applications
- **AWS Tools**: `check_aws.go`, `check_rds.go`, `list_alb.go`, `list_rds.go`
- **Security**: `gen_passwd.go`, `list_secretsGO.go`
- **Infrastructure**: `list_ec2_instances.go`

#### `/python/` - Python Scripts
- **AWS Integration**: `aws-login.py`
- **Algorithm Challenges**: Various mathematical problem solutions
- **Utility Scripts**: File processing and automation tools

#### `/shells/` - Shell Configuration
- **Shell Aliases**: `.aliases` - Custom shell aliases for common operations
- **Shell Profiles**: `.bashrc`, `.zshrc` - Shell configuration files
- **Environment Setup**: Shell environment customization

### 🏗️ Infrastructure & Configuration

#### `/kafka/` - Apache Kafka Setup
- Kafka cluster configuration
- Strimzi operator deployment
- Prometheus monitoring setup
- Installation scripts and documentation

#### `/istio/` - Service Mesh Configuration
- Istio gateway configurations
- Service mesh lab examples
- Ambient and sidecar deployment patterns
- Gateway and route configurations

#### `/kube/` - Kubernetes Configurations
- Cluster configuration files
- Environment-specific configs (dev, qa, prod, sandbox)
- Context management tools

#### `/terraform/` - Infrastructure as Code
- Terraform configurations for various resources
- Kafka infrastructure setup
- Main infrastructure definitions

#### `/deployment/` - Kubernetes Deployments
- Sample deployment manifests
- Nginx and hello-world examples
- Production-ready deployment templates

#### `/rollouts/` - Kubernetes Rollouts
- **Argo Rollouts**: `curiosity-rollouts.yaml` - Progressive delivery configurations
- Canary and blue-green deployment strategies

#### `/pv_pvc_sc/` - Kubernetes Storage
- Persistent Volume configurations
- Storage Class definitions
- PVC templates for various environments

### 🔒 Security & Compliance

#### `/sast/` - Static Application Security Testing
- SAST configurations for multiple languages:
  - Java, Node.js, Python, Ruby
  - Orca and Wiz security tools
- Suppression rules and policies
- Security scanning configurations

#### `/wiz/` - Wiz Security Platform
- Wiz CLI configurations
- Infrastructure as Code security scanning
- Security policy definitions

### 📊 Monitoring & Testing

#### `/testkube/` - TestKube Configuration
- Kubernetes-native testing framework setup
- Harvard-specific test configurations
- Test execution and monitoring

#### `/rpchecker/` - Site Connectivity Checker
- Python-based website availability monitoring
- Synchronous and asynchronous checking capabilities
- URL health monitoring tools

#### `/state/` - State Management
- **Popeye Reports**: Kubernetes cluster health reports
- **Documentation Cache**: Cached documentation for offline access
- **System State**: Current system state snapshots

### 🗄️ Data & Storage

#### `/oracle/` - Oracle Database Tools
- Database size checking scripts
- Oracle-specific utilities
- DDL scripts for database operations

#### `/solr/` - Apache Solr
- Solr backup and management scripts
- Search infrastructure tools
- Index management utilities

#### `/runmqsc/` - IBM MQ Scripts
- Message queue management scripts
- Queue depth monitoring
- System queue operations
- Environment-specific configurations (COM, OST)

### 📝 Documentation & Notes

#### `/docs/` - Documentation
- Project documentation
- Setup guides and tutorials
- Configuration documentation

#### `/notes/` - Project Notes
- Infrastructure documentation
- Decommissioning plans
- System architecture notes
- Rebuild procedures

#### `/history/` - Historical Records
- Project history and changes
- Migration documentation
- Personal and organizational history

#### `/props/` - Properties & Configuration
- **Nmap Configuration**: `nmapEmail.props`, `nmapList.txt` - Network scanning tools
- **Tool Lists**: `toolList.txt` - Inventory of available tools

### 🔄 Legacy & Archive

#### `/zzz-bins-zzz/` - Legacy Binaries
- Historical scripts and tools
- Deprecated utilities
- Migration candidates

#### `/zzz-mmc-pre-zzz/` - Pre-MMC Tools
- **AWS WAF/CloudFront**: Security and CDN configurations
- **Profiles**: `kubectx.sh`, `kubens.sh`, `kube_ps.sh` - Kubernetes context management
- **Tools**: Legacy tool configurations

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
- **Argo Rollouts** - Progressive delivery
- **TestKube** - Kubernetes-native testing

### Environment Setup

1. **AWS Configuration**:
   ```bash
   aws configure
   ```

2. **Kubernetes Context**:
   ```bash
   kubectl config use-context <your-cluster>
   # Use kubectx for context management
   ./zzz-mmc-pre-zzz/profiles/kubectx.sh
   ```

3. **Python Environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

4. **Shell Configuration**:
   ```bash
   # Source shell aliases
   source ./shells/.aliases
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

5. **Message Queue Operations**:
   ```bash
   ./bin/connect_broker
   ./bin/readMessagesOffQueue.sh
   ```

## 🔧 Development

### Adding New Tools

1. **Shell Scripts**: Add to `/bin/` or `/bin_shell/`
2. **Go Applications**: Add to `/go/` with proper Go modules
3. **Python Scripts**: Add to `/python/` with requirements
4. **Infrastructure**: Add to appropriate subdirectory
5. **Configuration**: Add to `/props/` for tool configurations

### Code Standards

- Follow shell script best practices for `/bin/` scripts
- Use Go modules for Go applications
- Include proper error handling and logging
- Add documentation for complex tools
- Use consistent naming conventions

## 📋 Current Projects & Status

### Active Development (August 2025)
- Infrastructure cleanup and optimization
- Security compliance automation
- Monitoring and alerting improvements
- Performance testing framework
- Progressive delivery with Argo Rollouts

### Infrastructure Cleanup Projects
Based on `Future-Work.txt`, current priorities include:

#### ALB Cleanup
- **Dev Environment**: Cleanup of internal ALBs for acorn, aspace, drs, FTS, ids, iiif, listview, policy-admin
- **QA Environment**: Cleanup of internal ALBs for aspace, curiosity, FTS, ids, jobmon, listview, drs-message-queue, nrsadmin, mps, talkwithhollis
- **Prod Environment**: Cleanup of beta-curiosity and hgl-prod ALBs

#### Amazon MQ Cleanup
- Remove old brokers: JSTOR_QA_Rabbit, MPS_QA_Rabbit
- Complete amalgamation cleanup

#### Certificate Management
- Clean up old certificates: beta.curiosity.lib.harvard.edu, deployment.prod.lib.harvard.edu

#### Route53 Cleanup
- Remove old DNS records: beta-hgl.hz.lib.harvard.edu

#### S3 Bucket Optimization
- Remove unused buckets: lts-rancher-backup-dev

#### Secret Management
- Clean up old secrets in sandbox1 environment

### Planned Work
- ArgoCD deployment for multi-cluster management
- Enhanced monitoring and alerting
- Security compliance automation
- Performance optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your tools/scripts with proper documentation
4. Test thoroughly
5. Submit a pull request

### Development Guidelines
- Follow existing code patterns and conventions
- Include proper error handling and logging
- Add documentation for new tools
- Test in development environments first
- Update this README for significant changes

## 📄 License

This project is for internal use and contains various tools and configurations for DevOps and infrastructure management.

## 🔗 Related Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Istio Documentation](https://istio.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Argo Rollouts Documentation](https://argoproj.github.io/argo-rollouts/)
- [TestKube Documentation](https://kubeshop.github.io/testkube/)

---

**Note**: This repository contains production infrastructure tools. Always test changes in development environments before applying to production systems. Current cleanup projects are documented in `Future-Work.txt`.

**Last Updated**: August 2025
