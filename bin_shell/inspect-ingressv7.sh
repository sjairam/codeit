#!/bin/bash
# v0.1 initial
# v0.2 Check with H if they have scripts
# v0.3 add cluster name.. as number of clusters
# v0.4 add pre-reqs for needed software
# v0.5 add colours for better visual output
# v0.6 add colours for curl response & icons
# v0.7 change to inspect

# Colour definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Colour

# Bold colours
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'

#######################################
## Location of system binaries
#######################################

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

#######################################
## Send Mail Function
#######################################

send_mail() {
  local log_file="$1"
  local cluster_name="$2"
  local recipient="${3:-$USER@localhost}"
  local subject="Ingress Inspection Results - ${cluster_name} - $(date '+%Y-%m-%d %H:%M:%S')"
  
  # Check if mail command is available
  if ! command -v mail &> /dev/null; then
    echo -e "${BOLD_YELLOW}Warning: 'mail' command not found. Email functionality disabled.${NC}"
    echo -e "${YELLOW}To enable email, install mailutils or postfix package.${NC}"
    return 1
  fi
  
  # Check if log file exists and is readable
  if [ ! -f "$log_file" ] || [ ! -r "$log_file" ]; then
    echo -e "${BOLD_RED}Error: Log file '$log_file' not found or not readable.${NC}"
    return 1
  fi
  
  # Create email body with summary
  local email_body=""
  email_body+="Ingress Inspection Results for Kubernetes Cluster: ${cluster_name}\n"
  email_body+="Generated on: $(date '+%Y-%m-%d %H:%M:%S')\n"
  email_body+="Log file: ${log_file}\n\n"
  email_body+="Summary:\n"
  email_body+="$(grep -c "✓" "$log_file" 2>/dev/null || echo "0") successful responses (HTTP 200)\n"
  email_body+="$(grep -c "→" "$log_file" 2>/dev/null || echo "0") redirects (HTTP 3xx)\n"
  email_body+="$(grep -c "⚠" "$log_file" 2>/dev/null || echo "0") authentication issues (HTTP 4xx)\n"
  email_body+="$(grep -c "✗" "$log_file" 2>/dev/null || echo "0") errors (HTTP 5xx/connection failed)\n"
  email_body+="$(grep -c "?" "$log_file" 2>/dev/null || echo "0") not found (HTTP 404)\n\n"
  email_body+="Full log attached.\n"
  
  # Send email with attachment
  echo -e "$email_body" | mail -s "$subject" -a "$log_file" "$recipient"
  
  if [ $? -eq 0 ]; then
    echo -e "${BOLD_GREEN}✓ Email sent successfully to ${CYAN}$recipient${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Email sent successfully to $recipient" >> "$log_file"
  else
    echo -e "${BOLD_RED}✗ Failed to send email to ${CYAN}$recipient${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to send email to $recipient" >> "$log_file"
    return 1
  fi
}

#Add cluster name
echo -e "${CYAN}Getting cluster information...${NC}"
cluster_name=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
resultLog="Istio Mesh-${cluster_name}_$1_$2.log"

# Add timestamp header to the log file
echo "$(date '+%Y-%m-%d %H:%M:%S') - ========================================" >> "$resultLog"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting Ingress inspection for cluster: ${cluster_name}" >> "$resultLog"
echo "$(date '+%Y-%m-%d %H:%M:%S') - ========================================" >> "$resultLog"

echo -e "${BOLD_BLUE}Getting Ingress Config${NC}"

for host in $(kubectl get ingress --all-namespaces -o jsonpath='{..host}' | tr ' ' '\n' | sort -u); do
  url="https://$host"
  [[ "$host" == *mgt* ]] && url="https://$host:9443"

  echo -e "${YELLOW}Inspecting ${CYAN}$url${YELLOW}...${NC}" | tee -a "$resultLog"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Inspecting $url" >> "$resultLog"
  code=$(curl -k -s --max-time 10 -o /dev/null -w "%{http_code}" "$url")

  # Colour code the HTTP response based on status
  if [[ "$code" == "200" ]]; then
    echo -e "${BOLD_GREEN}✓ $host responded with HTTP ${GREEN}$code${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ✓ $host responded with HTTP $code" >> "$resultLog"
  elif [[ "$code" == "301" ]] || [[ "$code" == "302" ]] || [[ "$code" == "307" ]] || [[ "$code" == "308" ]]; then
    echo -e "${BOLD_BLUE}→ $host responded with HTTP ${BLUE}$code${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - → $host responded with HTTP $code" >> "$resultLog"
  elif [[ "$code" == "401" ]] || [[ "$code" == "403" ]]; then
    echo -e "${BOLD_YELLOW}⚠ $host responded with HTTP ${YELLOW}$code${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ⚠ $host responded with HTTP $code" >> "$resultLog"
  elif [[ "$code" == "404" ]]; then
    echo -e "${BOLD_PURPLE}? $host responded with HTTP ${PURPLE}$code${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ? $host responded with HTTP $code" >> "$resultLog"
  elif [[ "$code" == "500" ]] || [[ "$code" == "502" ]] || [[ "$code" == "503" ]] || [[ "$code" == "504" ]]; then
    echo -e "${BOLD_RED}✗ $host responded with HTTP ${RED}$code${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ✗ $host responded with HTTP $code" >> "$resultLog"
  elif [[ "$code" == "000" ]]; then
    echo -e "${BOLD_RED}✗ $host ${RED}connection failed${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ✗ $host connection failed" >> "$resultLog"
  else
    echo -e "${WHITE}• $host responded with HTTP ${WHITE}$code${NC}" | tee -a "$resultLog"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - • $host responded with HTTP $code" >> "$resultLog"
  fi
done

# Add completion timestamp to the log file
echo "$(date '+%Y-%m-%d %H:%M:%S') - ========================================" >> "$resultLog"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Ingress inspection completed" >> "$resultLog"
echo "$(date '+%Y-%m-%d %H:%M:%S') - ========================================" >> "$resultLog"

echo -e "${BOLD_GREEN}Ta da ! ${CYAN}$resultLog${NC}"

# Send email with results (optional)
if [ "${4:-}" = "--send-email" ]; then
  recipient="${5:-$USER@localhost}"
  echo -e "${CYAN}Sending email with results to ${YELLOW}$recipient${NC}..."
  send_mail "$resultLog" "$cluster_name" "$recipient"
elif [ "${4:-}" = "--help" ] || [ "${4:-}" = "-h" ]; then
  echo -e "${CYAN}Usage: $0 [namespace] [service] [--send-email] [recipient_email]${NC}"
  echo -e "${CYAN}  --send-email: Send results via email${NC}"
  echo -e "${CYAN}  recipient_email: Email address to send results to (default: $USER@localhost)${NC}"
  echo -e "${CYAN}  --help or -h: Show this help message${NC}"
fi
