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

path=""

while [[ $# -gt 0 ]]; do
    case "$1" in
    -c | --config)
        CONFIG_FILE="$2"
        shift 2
        ;;

    -*)
        echo_error "Unknown argument: $1"
        exit 1
        ;;

    *)
        if [[ -n "$path" ]]; then
            echo_error "Only one path per run"
            exit 1
        fi
        path="$1"
        shift
        ;;
    esac
done

if [[ -z "$path" ]]; then
    echo "Usage: $0 [-c CONFIG] <path>"
    exit 1
fi

if [[ ! -e "$path" ]]; then
    echo_error "Profile not found"
    exit 1
fi

check_not_root
echo_hello

run_sudo
run_profile "$path"

exit $EXIT_CODE
