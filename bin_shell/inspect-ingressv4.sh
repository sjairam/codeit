#!/bin/bash
# v0.1 initial
# v0.2 Check with H if they have scripts
# v0.3 add cluster name.. as number of clusters
# v0.4 add pre-reqs for needed software

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Bold colors
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'

GREP=$(command -v grep)
KUBECTL=$(command -v kubectl)
SED=$(command -v sed)
TEE=$(command -v tee)

# Check if 'grep' command is available
if [ ! -f "${GREP}"] &> /dev/null; then
  echo -e "${BOLD_RED}'grep' command not found. Please install it to run this script.${NC}"
  exit 1
fi

# Check if 'kubectl' command is available
if ! command -v kubectl &> /dev/null; then
  echo -e "${BOLD_RED}'kubectl' command not found. Please install it and configure access to your Kubernetes cluster.${NC}"
  exit 1
fi

# Check if 'sed' command is available
if ! command -v sed &> /dev/null; then
  echo -e "${BOLD_RED}'sed' command not found. Please install it to run this script.${NC}"
  exit 1
fi

# Check if 'tee' command is available
if ! command -v tee &> /dev/null; then
  echo -e "${BOLD_RED}'tee' command not found. Please install it to run this script.${NC}"
  exit 1
fi

#Add cluster name
echo -e "${CYAN}Getting cluster information...${NC}"
cluster_name=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
resultLog="Istio Mesh-${cluster_name}_$1_$2.log"

echo -e "${BOLD_BLUE}Getting Ingress Config${NC}"

kubectl get ingress -A -o jsonpath='{range .items[*]}{.spec.rules[*].host}{"\n"}{end}' | sort -u | \
while read -r host; do
  if echo "$host" | grep -q "mgt"; then
    url="https://$host:9443"
  else
    url="https://$host"
  fi

  echo -e "${YELLOW}Testing ${CYAN}$url${YELLOW}...${NC}" | tee -a "$resultLog"
  code=$(curl -k -s --max-time 10  -o /dev/null -w "%{http_code}" "$url")
  
  # Color code the HTTP response based on status
  if [[ "$code" -ge 200 && "$code" -lt 300 ]]; then
    echo -e "${BOLD_GREEN}$host responded with HTTP $code${NC}" | tee -a "$resultLog"
  elif [[ "$code" -ge 300 && "$code" -lt 400 ]]; then
    echo -e "${BOLD_YELLOW}$host responded with HTTP $code${NC}" | tee -a "$resultLog"
  elif [[ "$code" -ge 400 && "$code" -lt 500 ]]; then
    echo -e "${BOLD_RED}$host responded with HTTP $code${NC}" | tee -a "$resultLog"
  elif [[ "$code" -ge 500 ]]; then
    echo -e "${BOLD_RED}$host responded with HTTP $code${NC}" | tee -a "$resultLog"
  else
    echo -e "${PURPLE}$host responded with HTTP $code${NC}" | tee -a "$resultLog"
  fi
done

echo -e "${BOLD_GREEN}Ta da ! ${CYAN}$resultLog${NC}"
