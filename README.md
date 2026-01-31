# codeit

Personal scripts and utilities.

## aws_list

Bash script that lists all running EC2 instances with InstanceID, Name, State, and Private IP.

### Requirements

- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/aws_list [-r region]
```

### Options

- `-r`, `--region` — AWS region (default: from AWS config or environment)
- `-h`, `--help` — Show help message

---

## backup

Bash script that creates monthly backups of Documents, Pictures, Movies, and Desktop to a USB drive.

### Requirements

- USB drive mounted at `/Volumes/Data2024/`
- macOS (uses `~/Documents`, `~/Pictures`, `~/Movies`, `~/Desktop`)

### Usage

```bash
./bin/backup
```

### What it backs up

Creates a timestamped folder `Documents-{Month}-20{Year}` (e.g. `Documents-Jan-2025`) containing:

- **00-kube-shells-00/** — Config files: `~/.kube`, `~/.ssh`, `~/.aliases`, `~/.bashrc`, `~/.zshrc`, git configs, `~/.aws`, KeePass (`Passwords.kdb*`)
- **Documents/** — `~/Documents` folders (00-docs, 00-personal, 00-USEFUL, PROD, QA, DEV, etc.)
- **Pictures/** — `~/Pictures` folders
- **Movies/** — `~/Movies` folders
- **Desktop/** — `~/Desktop` contents
- **ZZZ-SOFTWARE/** — Rebuild apps from `ZZZ-SOFTWAREZ`

The script creates the folder structure on first run; subsequent runs reuse existing folders. Elapsed time is printed at the end.

---

## biggest_files

Bash script that finds and lists the largest files in a given directory.

### Usage

```bash
./bin/biggest_files <folder> [num_files]
```

### Arguments

- `<folder>` — Directory to search (required)
- `[num_files]` — Number of files to show (optional, default: 20)

### Examples

```bash
./bin/biggest_files ~/Downloads 10
./bin/biggest_files /tmp
```

Output shows file size and path, sorted largest first.

---

## rrd

Bash script that restarts a Kubernetes deployment and watches the pods rollout.

### Requirements

- AWS CLI installed and in PATH
- kubectl installed and in PATH
- kubectl context configured (kubectl must be connected to the target cluster)
- Need to be in the correct namespace (NS)

### Usage

```bash
./bin/rrd <deployment-name>
```

### Arguments

- `<deployment-name>` — Name of the deployment to restart (required)

After restarting, the script watches pods with `kubectl get pods -owide -w`.

---

## rrs

Bash script that restarts a Kubernetes StatefulSet and watches the pods rollout.

### Requirements

- AWS CLI installed and in PATH
- kubectl installed and in PATH
- kubectl context configured (kubectl must be connected to the target cluster)
- Need to be in the correct namespace (NS)

### Usage

```bash
./bin/rrs <sts-name>
```

### Arguments

- `<sts-name>` — Name of the StatefulSet to restart (required)

After restarting, the script watches pods with `kubectl get pods -owide -w`.
