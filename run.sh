#!/bin/bash

EXIT_CODE=0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

CONFIG_FILE=""
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/default_config.yaml"

source "$SCRIPT_DIR/lib/echo.sh"
source "$SCRIPT_DIR/lib/module.sh"
source "$SCRIPT_DIR/lib/profile.sh"
source "$SCRIPT_DIR/lib/sudo.sh"
source "$SCRIPT_DIR/lib/utils.sh"

if [[ $# -lt 1 ]]; then
    echo_error "No path to the profile was specified"
    exit 1
fi

check_not_root
echo_hello

if [[ ! -e "$1" ]]; then
    echo_error "Profile not found"
    exit 1
fi

run_sudo
run_profile "$1"

exit $EXIT_CODE
