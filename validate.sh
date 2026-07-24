#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE=""
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/default_config.yaml"

source "$SCRIPT_DIR/lib/echo.sh"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/validation.sh"

profile=false
path=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--profile)
            profile=true
            shift
            ;;

        -*)
            echo_error "Unknown argument"
            exit 1
            ;;

        *)
            if [[ -n "$path" ]]; then
                echo_error ""
                exit 1
            fi

            path="$1"
            shift
            ;;
    esac
done

if [[ -z "$path" ]]; then
    echo_error "Path is required"
    exit 1
fi

if [[ "$profile" == true ]]; then
    validate_profile "$path"
else
    validate_module "$path"
fi

