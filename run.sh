#!/bin/bash
# set -euo pipefail

EXIT_CODE=0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

CONFIG_FILE=""
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/default_config.yaml"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/echo.sh"
source "$SCRIPT_DIR/lib/sudo.sh"
source "$SCRIPT_DIR/lib/module.sh"

check_not_root
run_sudo
run_module "$1"
exit $EXIT_CODE
