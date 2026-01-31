# codeit

Utility scripts for AWS and development workflows.

## aws_list

Lists all running EC2 instances with InstanceID, Name, State, and Private IP.

**Requirements:**
- [AWS CLI](https://aws.amazon.com/cli/) installed and in PATH
- Valid AWS credentials (e.g. `aws configure`)

**Usage:**
```bash
bin/aws_list [-r region]
```

**Options:**
- `-r, --region`  AWS region (default: from AWS config or environment)
- `-h, --help`    Show help message

**Example:**
```bash
bin/aws_list -r us-east-1
```
