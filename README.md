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

## cleanup_purgeable

Bash script that frees purgeable space on macOS by clearing caches, temp files, and triggering APFS reclaim.

### Requirements

- macOS (uses `~/Library/Caches`, `/Library/Caches`, `/tmp`; APFS cleanup step)
- sudo (for system caches and APFS fill/free step)

### Usage

```bash
./bin/cleanup_purgeable
```

Shell-only version:

```bash
./bin_shell/cleanup_purgeable.sh
```

### What it does

- **User caches** — Removes `~/Library/Caches/*`
- **System caches** — Removes `/Library/Caches/*` (requires sudo)
- **Temp files** — Removes `/tmp/*`
- **Xcode DerivedData** — Removes `~/Library/Developer/Xcode/DerivedData/*` if present
- **APFS reclaim** — Creates ~1GB in `/private/tmp/cleanup`, then deletes it to encourage APFS to free purgeable space

When finished, the script suggests running `df -h` to check available space.

---

## list-oracle-rds

Bash script that lists all RDS instances with Oracle as the database engine (oracle-ee).

### Requirements

- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/list-oracle-rds
```

Output is a table with DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus, and MultiAZ. Prints "No Oracle RDS instances found." if none exist.

---

## list-secrets

Bash script that displays in plain text the key-value pairs for secrets in AWS Secrets Manager.

### Requirements

- AWS CLI installed and in PATH
- jq installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/list-secrets [-h|-s env/stack-secrets|-a]
```

### Options

- `-h` — Print help message
- `-s env/stack-secrets` — Print secrets for that stack only (also runs a whitespace check on the secret values)
- `-a` — Print all secrets in Secrets Manager (not advised)

When using `-s`, the script shows the secret name, key-value pairs (via jq), and reports whether leading or trailing whitespace was found in the secret value.

---

## get-kubectl

Bash script that downloads and installs kubectl for a specified Kubernetes version.

### Requirements

- `curl` in PATH
- Linux or macOS (darwin)
- amd64 or arm64 architecture
- sudo (if `/usr/local/bin` is not writable)

### Usage

```bash
./bin_shell/get-kubectl.sh [version]
```

### Arguments

- `[version]` — Kubernetes version to install (optional). If omitted, installs the latest stable.
  - Examples: `v1.28.0`, `1.28.0`, or `latest`
  - `v` prefix is added automatically if missing

### Examples

```bash
./bin_shell/get-kubectl.sh              # Install latest stable version
./bin_shell/get-kubectl.sh latest       # Install latest stable version
./bin_shell/get-kubectl.sh v1.28.0      # Install version 1.28.0
./bin_shell/get-kubectl.sh 1.28.0       # Same as above (v prefix added)
```

kubectl is installed to `/usr/local/bin`. The script verifies the binary after installation.

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

---

## restore_via_oidc

Bash script that restores OIDC (Keycloak) authentication configuration to a Rancher/Kubernetes cluster (authconfigs, users, user attributes, and the Keycloak OIDC client secret).

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)
- Rancher/Cattle management resources present (authconfigs, users, userattributes)

### Usage

```bash
./bin_shell/restore_via_oidc.sh
```

The script prompts for confirmation before applying any resources. It then applies:

- `authconfigs.management.cattle.io/v3/keycloakoidc.json`
- `users.management.cattle.io/v3/`
- `userattributes.management.cattle.io/v3/`
- `secrets/v1/cattle-global-data/keycloakoidcconfig-clientsecret.json`

---

## restore_via_okta

Bash script that restores Okta authentication configuration to a Rancher/Kubernetes cluster (authconfigs, users, user attributes, and the Okta SP key secret).

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)
- Rancher/Cattle management resources present (authconfigs, users, userattributes)

### Usage

```bash
./bin_shell/restore_via_okta.sh
```

The script prompts for confirmation before applying any resources. It then applies:

- `authconfigs.management.cattle.io/v3/okta.json`
- `users.management.cattle.io/v3/`
- `userattributes.management.cattle.io/v3/`
- `secrets/v1/cattle-global-data/oktaconfig-spkey.json`

---

## restore_via_shibboleth

Bash script that restores Shibboleth authentication configuration to a Rancher/Kubernetes cluster (authconfigs, users, user attributes, and the Shibboleth secret).

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)
- Rancher/Cattle management resources present (authconfigs, users, userattributes)

### Usage

```bash
./bin_shell/restore_via_shibboleth.sh
```

The script prompts for confirmation before applying any resources. It then applies:

- `authconfigs.management.cattle.io/v3/shibboleth.json`
- `users.management.cattle.io/v3/`
- `userattributes.management.cattle.io/v3/`
- `secrets/v1/cattle-global-data/shibbolethconfig-spkey.json`

---


