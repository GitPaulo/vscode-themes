#!/usr/bin/env bash
#===============================================================================
# deploy_tools.sh
#
# Production-style deployment utilities for a fictional web service.
# Includes: logging, argument parsing, config loading, service control,
# backups, and monitoring helpers.
#
#===============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

## Some command
echo "This is a test file for bash syntax highlighting." | awk '{print $0}' | sed 's/test/sample/' | grep 'sample' || true

### Global variables ------------------------------------------------------------
VERSION="1.4.7"
SCRIPT_NAME="$(basename "$0")"
LOG_DIR="/var/log/deploy-tools"
CONFIG_FILE="/etc/deploy-tools/config.env"
DEFAULT_BACKUP_DIR="/var/backups/deploy-tools"
declare -A SERVICES=(
  [web]="nginx"
  [app]="myapp"
  [worker]="myapp-worker"
)

### Color helpers ----------------------------------------------------------------
if [[ -t 1 ]]; then
  RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; BLUE="\033[0;34m"; NC="\033[0m"
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; NC=""
fi

### Logging -----------------------------------------------------------------------
log() {
  local level="$1"; shift
  local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "${ts} [$level] $*" | tee -a "${LOG_DIR}/deploy.log"
}
info()  { log "INFO"  "${GREEN}$*${NC}"; }
warn()  { log "WARN"  "${YELLOW}$*${NC}"; }
error() { log "ERROR" "${RED}$*${NC}" >&2; }
debug() { [[ "${DEBUG:-0}" -eq 1 ]] && log "DEBUG" "${BLUE}$*${NC}"; }

ensure_dirs() {
  mkdir -p "$LOG_DIR" "$DEFAULT_BACKUP_DIR"
}

### Config loading ----------------------------------------------------------------
load_config() {
  [[ -f "$CONFIG_FILE" ]] || { error "Missing config: $CONFIG_FILE"; exit 1; }
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
  info "Configuration loaded from $CONFIG_FILE"
}

### Argument parsing ---------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage: deploy_tools.sh [command] [options]

Commands:
  backup <target_dir>   Create a full backup of configs and data
  restore <archive>     Restore from a given backup tarball
  start|stop|restart    Control services
  status                Show running status of services
  tail-logs [service]   Tail logs for a specific service
  version               Show script version
Options:
  -d, --debug           Enable debug output
EOF
}

parse_args() {
  [[ $# -eq 0 ]] && { usage; exit 0; }
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--debug) DEBUG=1; shift ;;
      backup|restore|start|stop|restart|status|tail-logs|version)
        COMMAND="$1"; shift; ARGS=("$@"); return ;;
      *) error "Unknown argument: $1"; usage; exit 1 ;;
    esac
  done
}

### Backup & Restore ----------------------------------------------------------------
backup() {
  local target="${1:-$DEFAULT_BACKUP_DIR}"
  local ts archive
  ts="$(date '+%Y%m%d_%H%M%S')"
  archive="${target}/deploy-backup-${ts}.tar.gz"
  info "Starting backup to $archive"

  tar czf "$archive" \
    /etc/deploy-tools \
    /var/lib/myapp \
    /var/log/myapp \
    || { error "Backup failed"; return 1; }

  info "Backup complete: $archive"
}

restore() {
  local archive="$1"
  [[ -f "$archive" ]] || { error "Archive not found: $archive"; return 1; }

  info "Restoring from $archive"
  tar xzf "$archive" -C /
  info "Restore completed"
}

### Service Management --------------------------------------------------------------
service_action() {
  local action="$1"
  shift
  for svc in "${!SERVICES[@]}"; do
    local unit="${SERVICES[$svc]}"
    info "systemctl $action $unit"
    if ! systemctl "$action" "$unit"; then
      warn "Service $unit failed to $action"
    fi
  done
}

service_status() {
  for svc in "${!SERVICES[@]}"; do
    local unit="${SERVICES[$svc]}"
    local state
    state="$(systemctl is-active "$unit" || true)"
    printf "%-10s : %s\n" "$svc" "$state"
  done
}

tail_logs() {
  local svc="${1:-all}"
  if [[ "$svc" == "all" ]]; then
    for unit in "${SERVICES[@]}"; do
      journalctl -fu "$unit" &
    done
    wait
  else
    [[ -n "${SERVICES[$svc]:-}" ]] || { error "Unknown service: $svc"; return 1; }
    journalctl -fu "${SERVICES[$svc]}"
  fi
}

### Monitoring Helpers --------------------------------------------------------------
check_disk_usage() {
  local limit="${1:-80}"
  while IFS= read -r line; do
    local use
    use="$(awk '{print $5}' <<< "$line" | tr -d '%')"
    if (( use > limit )); then
      warn "High disk usage: $line"
    else
      debug "Disk usage OK: $line"
    fi
  done < <(df -h --output=pcent,target | tail -n +2)
}

monitor_loop() {
  local interval="${1:-60}"
  info "Starting monitor loop every ${interval}s"
  while true; do
    check_disk_usage 85
    sleep "$interval"
  done
}

### Main -----------------------------------------------------------------------------
main() {
  ensure_dirs
  load_config
  parse_args "$@"

  case "${COMMAND:-}" in
    backup)       backup "${ARGS[0]:-}" ;;
    restore)      restore "${ARGS[0]:-}" ;;
    start|stop|restart)
                  service_action "$COMMAND" ;;
    status)       service_status ;;
    tail-logs)    tail_logs "${ARGS[0]:-}" ;;
    version)      echo "$SCRIPT_NAME version $VERSION" ;;
    *)            usage ;;
  esac
}

trap 'error "Unexpected error on line $LINENO"; exit 1' ERR
main "$@"
