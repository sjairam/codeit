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

## check-vs

Bash script that detects Istio VirtualServices across Kubernetes namespaces and curls their hosts to verify connectivity.

### Requirements

- kubectl installed and in PATH
- curl installed and in PATH
- kubectl context configured (connected to the target cluster)
- Istio VirtualService CRD present

### Usage

```bash
./bin/check-vs [-v] [-d] [-a] [-h]
```

### Options

- `-v` — Verbose output (shows additional script details)
- `-d` — Dry run (show what would be done without executing curls)
- `-a` — Include system namespaces (default: skip)
- `-h` — Show help message

### What it does

- Scans all namespaces for VirtualServices (skips `kube-system`, `kube-public`, `kube-node-lease`, `default`, `istio-system`, `istio-operator`, and namespaces starting with `kube-` or `istio-` by default)
- Extracts hosts from each VirtualService and tests them with `curl`
- Uses `curl -v` for detailed connection output; tries HTTP first, then HTTPS if HTTP fails
- Prints HTTP status code (success: 2xx/3xx), connection failures, and a summary with total VirtualServices and hosts tested
- Reports start time, end time, and elapsed duration

---

## delete-pods

Bash script that deletes all pods scheduled on a specific Kubernetes node.

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)

### Usage

```bash
./bin/delete-pods NODE_NAME [--fast]
```

### Arguments

- `NODE_NAME` — Kubernetes node name to match (required)
- `--fast` — Use aggressive deletion: zero grace period, force, and don't wait (optional)

### What it does

- Finds all pods scheduled on the specified node using `kubectl get pods --all-namespaces --field-selector "spec.nodeName=${NODE_NAME}"`
- Deletes each pod in its namespace
- With `--fast`, uses `--grace-period=0 --force --wait=false` for immediate deletion
- Reports the number of pods found and any deletion errors
- Exits with status 1 if any deletions fail

### Examples

```bash
./bin/delete-pods node-01
./bin/delete-pods node-02 --fast
```

---

## find-pods-node

Bash script that lists all pods running on a given Kubernetes node across all namespaces.

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)

### Usage

```bash
./bin/find-pods-node <node-name>
```

### Arguments

- `<node-name>` — Name of the Kubernetes node to list pods for (required)

### Options

- `-h`, `--help` — Show help message

### What it does

- Lists all pods on the given node via `kubectl get pods --all-namespaces -o wide --field-selector "spec.nodeName=<node-name>"`
- Prints a summary table with script name, start time, end time, and pod count (excluding header row)

### Examples

```bash
./bin/find-pods-node ip-10-0-1-42.us-east-2.compute.internal
./bin/find-pods-node my-worker-node-01
```

---

## cert-list

Bash script that lists AWS ACM (Certificate Manager) certificates in the current region, with optional filtering and detailed output.

### Requirements

- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/cert-list [-r region] [-d] [-e] [-h]
```

### Options

- `-r`, `--region` — AWS region (default: from AWS config or environment)
- `-d`, `--detailed` — Show detailed information for each certificate (IssuedAt, NotBefore, NotAfter, KeyAlgorithm, SubjectAlternativeNames, InUseBy)
- `-e`, `--expired` — Show only expired certificates
- `-h`, `--help` — Show help message

### What it does

- Lists certificates with statuses: ISSUED, EXPIRED, INACTIVE, PENDING_VALIDATION
- Default output is a table of Domain Name, Status, and Type, plus total certificate count
- With `-d`, prints per-certificate details from `describe-certificate`
- With `-e`, filters to expired certificates only (uses ACM `--certificate-statuses EXPIRED`)

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

## export-GW-secrets

Bash script that exports Istio gateway certificate secrets from a Kubernetes cluster for backup or inspection (for Istio clients).

### Requirements

- kubectl installed and in PATH
- kubens installed and in PATH (for namespace switching)
- kubectl context configured (connected to the target cluster)
- Istio installed with gateway certificates in `istio-system` namespace

### Usage

```bash
./bin/export-GW-secrets
```

### What it does

- Creates a dated directory `gateway-YYYY-MM-DD` in the current working directory
- Switches to the `istio-system` namespace using kubens
- Exports the following certificate secrets as YAML files:
  - `apiprivate-cert.yaml`
  - `private-cert.yaml`
  - `public-cert.yaml`
  - `server-cert.yaml`
- Decodes the base64-encoded values from `server-cert` and prints them in readable format

---

## find-alb

Bash script that finds which Application Load Balancer (ALB) and target group an EC2 instance is registered to.

### Requirements

- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/find-alb <instance-id>
```

### Arguments

- `<instance-id>` — EC2 instance ID to look up (required)

### What it does

- Lists all Application Load Balancers in the current region
- For each ALB, checks target groups and their registered targets
- If the instance is registered to a target group, prints the load balancer name and target group name
- Exits with a message if the instance is not associated with any ALB

---

## list-alb

Bash script that lists Application Load Balancers (ALBs) in the current AWS region, with optional profile and region.

### Requirements

- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/list-alb [-p profile] [-r region] [-h]
```

### Options

- `-p` — AWS CLI profile to use (optional)
- `-r` — AWS region to use (optional)
- `-h` — Show help message

### What it does

- Fetches Application Load Balancers via `aws elbv2 describe-load-balancers` (Type `application` only)
- Outputs a table of ALB Name and ARN, plus total ALB count
- Prints a message if no ALBs are found
- Uses colored output (yellow for status, green for results, red for errors)

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

## list-postgres-rds

Bash script that lists all RDS instances with PostgreSQL as the database engine.

### Requirements

- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`)

### Usage

```bash
./bin/list-postgres-rds
```

Output is a table with DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus, and MultiAZ. Prints "No PostgreSQL RDS instances found." if none exist.

---

## list_rds

Go program that lists AWS RDS instances filtered by database engine. Source lives in `go/list_rds.go`; the compiled binary is `bin/list_rds`.

### Requirements

- Go installed and in PATH (to build or run from source)
- AWS CLI installed and in PATH
- AWS credentials configured (`aws configure`) with RDS read permissions

### Building

From the repo root:

```bash
go build -o bin/list_rds go/list_rds.go
```

### Usage

```bash
./bin/list_rds <database-engine>
# or run from source:
go run go/list_rds.go <database-engine>
```

### Arguments

- `<database-engine>` — Engine type to list (required). Valid: `mysql`, `postgres`, `oracle-ee`

### Options

- `-h`, `--help` — Show usage and help

### Examples

```bash
./bin/list_rds postgres
./bin/list_rds mysql
./bin/list_rds oracle-ee
go run go/list_rds.go postgres
```

### Output

Table with DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus, AllocatedStorage, and MultiAZ. Prints a message if no instances of that engine are found (with hints about permissions, region, or config).

### go/ folder

- **list_rds.go** — Source for the list_rds RDS lister. Single-file Go program; build with `go build -o bin/list_rds go/list_rds.go` from the repo root.

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

## get-ns-secrets

Bash script that lists Kubernetes namespaces (excluding system namespaces by default) and optionally saves all secrets from each namespace to a YAML file.

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)

### Usage

```bash
./bin/get-ns-secrets [options]
```

### Options

- `-h`, `--help` — Show help
- `--format <lines|csv|array>` — Output format (default: lines)
- `--array-name <NAME>` — When `--format array`, name the generated array (default: NAMESPACES)
- `--no-exclude-system` — Do not exclude common system namespaces
- `--exclude <ns1,ns2,...>` — Comma- or space-separated additional namespaces to exclude
- `--kubectl <path>` — Path to kubectl binary (default: kubectl from PATH)
- `--save-secrets [dir]` — Save all secrets to YAML file: `<kubecontext>_<timestamp>.yaml` (default dir: `.`)

### What it does

- Fetches namespaces via `kubectl get namespaces`
- By default excludes system namespaces (e.g. `kube-system`, `kube-public`, `default`, `istio-system`, `cert-manager`, and Rancher `cattle-*` / `fleet-*` namespaces)
- Excludes namespaces whose names start with `u-` or `p-`
- Outputs namespaces as one per line (lines), comma-separated (csv), or a bash array (array)
- With `--save-secrets`, iterates over the filtered namespaces, runs `kubectl get secrets -n <ns> -o yaml` for each, and writes to an auto-generated file `<kubecontext>_<timestamp>.yaml` in the specified directory (or current dir if omitted). The file includes a header with kubectx and timestamp, then `---` and `# Namespace: <ns>` before each namespace's secrets.
- Prints timing (start, end, elapsed) to stderr

### Examples

```bash
./bin/get-ns-secrets
./bin/get-ns-secrets --format csv
./bin/get-ns-secrets --format array --array-name MYNS
./bin/get-ns-secrets --save-secrets
./bin/get-ns-secrets --save-secrets /path/to/output-dir
./bin/get-ns-secrets --no-exclude-system --exclude my-ns,other-ns
```

---

## get-ns-clustersecretstore

Bash script that lists Kubernetes namespaces (excluding system namespaces by default) and optionally exports ClusterSecretStore resources from External Secrets Operator to YAML.

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)

### Usage

```bash
./bin/get-ns-clustersecretstore [options]
```

### Options

- `-h`, `--help` — Show help
- `--format <lines|csv|array>` — Output format (default: lines)
- `--array-name <NAME>` — When `--format array`, name the generated array (default: NAMESPACES)
- `--no-exclude-system` — Do not exclude common system namespaces
- `--exclude <ns1,ns2,...>` — Comma- or space-separated additional namespaces to exclude
- `--kubectl <path>` — Path to kubectl binary (default: kubectl from PATH)
- `--save-clustersecretstore [dir]` — Export ClusterSecretStore resources to YAML file: `<kubecontext>_clustersecretstore_<timestamp>.yaml` (default dir: `.`)
- `--all-contexts` — Cycle through all contexts from kubeconfig (use with `--save-clustersecretstore`)
- `--contexts <ctx1,ctx2,...>` — Cycle through specified contexts only (use with `--save-clustersecretstore`)

### What it does

- Fetches namespaces via `kubectl get namespaces` (same exclusion logic as get-ns-secrets)
- By default excludes system namespaces (e.g. `kube-system`, `kube-public`, `default`, `istio-system`, `cert-manager`, Rancher `cattle-*` / `fleet-*`)
- Excludes namespaces whose names start with `u-` or `p-`
- Outputs namespaces as one per line (lines), comma-separated (csv), or a bash array (array)
- With `--save-clustersecretstore`, exports cluster-scoped ClusterSecretStore resources via `kubectl get clustersecretstore -o yaml` to `<kubecontext>_clustersecretstore_<timestamp>.yaml` (requires External Secrets Operator)
- With `--all-contexts` or `--contexts`, switches context, exports ClusterSecretStore for each, then restores the original context
- Prints timing (start, end, elapsed) to stderr

### Examples

```bash
./bin/get-ns-clustersecretstore
./bin/get-ns-clustersecretstore --format csv
./bin/get-ns-clustersecretstore --save-clustersecretstore
./bin/get-ns-clustersecretstore --save-clustersecretstore /path/to/output-dir
./bin/get-ns-clustersecretstore --save-clustersecretstore --all-contexts
./bin/get-ns-clustersecretstore --save-clustersecretstore --contexts ctx1,ctx2,ctx3
```

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


## update_cert_manager

Bash script that safely upgrades cert-manager in a Kubernetes cluster, supporting both Helm and YAML manifest upgrade methods with backup and rollback.

### Requirements

- kubectl installed and in PATH
- kubectl context configured (connected to the target cluster)
- Helm installed and in PATH (for `--method helm`)
- curl installed and in PATH (for `--method yaml` dry-run)

### Usage

```bash
./bin_shell/update_cert_manager.sh [options]
```

### Options

- `-v`, `--version VERSION` — Cert-manager version to upgrade to (default: `v1.13.3`)
- `-n`, `--namespace NAMESPACE` — Namespace where cert-manager is installed (default: `cert-manager`)
- `-m`, `--method METHOD` — Upgrade method: `helm` or `yaml` (default: `helm`)
- `-b`, `--backup-dir DIR` — Backup directory (default: `./cert-manager-backup-<timestamp>`)
- `--dry-run` — Perform a dry run without making any changes
- `-f`, `--force` — Skip confirmation prompt and proceed with upgrade
- `-h`, `--help` — Show help message

### What it does

- Checks prerequisites (cluster connectivity, namespace existence, and cert-manager presence)
- Detects current cert-manager version (when possible)
- Creates a backup of cert-manager resources, CRDs, secrets, and configmaps
- Upgrades cert-manager via Helm (`jetstack/cert-manager`) or applies the official YAML manifest for the chosen version
- Verifies the upgrade by waiting for pods to be ready, checking CRDs, and inspecting issuers/clusterissuers
- On errors, attempts rollback from the backup; on success (non-dry-run), cleans up the backup directory

### Examples

```bash
./bin_shell/update_cert_manager.sh -v v1.13.3 -m helm
./bin_shell/update_cert_manager.sh -v v1.13.3 -m yaml --dry-run
./bin_shell/update_cert_manager.sh -f -v v1.13.3
```

