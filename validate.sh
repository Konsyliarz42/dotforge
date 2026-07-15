#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE=""
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/default_config.yaml"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/echo.sh"

validate_module() {
    local file="$1"

    local name
    local strict
    local steps
    local step_index
    local steps_count

    name=$(get_or_null ".name" "$file")
    strict=$(get_or_null ".strict" "$file")
    steps=$(get_or_null ".steps[]" "$file")
    steps_count=$(get_or_null ".steps | length" "$file")

    if [[ -z "$name" ]]; then
        echo_error "$file: Missing property: name"
    fi

    if [[ -z "$strict" ]]; then
        echo_error "$file: Missing property: strict"
    else
        case "$strict" in
        true) ;;
        false) ;;
        *) echo_error "$file: Strict must be a boolean" ;;
        esac
    fi

    if [[ -z "$steps" ]]; then
        echo_error "$file: Module must have at least 1 step"
    else
        for ((step_index = 0; step_index < steps_count; step_index++)); do
            local type

            type=$(get_or_null ".steps[$step_index].type" "$file")

            case "$type" in
            clone) validate_step_clone $step_index "$file" ;;
            command) validate_step_command $step_index "$file" ;;
            copy) validate_step_copy $step_index "$file" ;;
            install) validate_step_install $step_index "$file" ;;
            link) validate_step_link $step_index "$file" ;;
            module) validate_step_module $step_index "$file" ;;
            service) validate_step_service $step_index "$file" ;;
            *) echo_error "$file - $step_index: Unknown type" ;;
            esac
        done
    fi

}

validate_step_clone() {
    local step_index="$1"
    local file="$2"

    local url
    local target

    url=$(get_or_null ".steps[$step_index].url" "$file")
    target=$(get_or_null ".steps[$step_index].target" "$file")

    if [[ -z "$url" ]]; then
        echo_error "$file - $step_index: Missing property: url"
    fi

    if [[ -z "$target" ]]; then
        echo_error "$file - $step_index: Missing property: target"
    fi
}

validate_step_command() {
    local step_index="$1"
    local file="$2"

    local cmd

    cmd=$(get_or_null ".steps[$step_index].cmd" "$file")

    if [[ -z "$cmd" ]]; then
        echo_error "$file - $step_index: Missing property: cmd"
    fi
}

validate_step_copy() {
    local step_index="$1"
    local file="$2"

    local source
    local target

    source=$(get_or_null ".steps[$step_index].source" "$file")
    target=$(get_or_null ".steps[$step_index].target" "$file")

    if [[ -z "$source" ]]; then
        echo_error "$file - $step_index: Missing property: source"
    fi

    if [[ -z "$target" ]]; then
        echo_error "$file - $step_index: Missing property: target"
    fi
}

validate_step_install() {
    local step_index="$1"
    local file="$2"

    local manager
    local manager_config
    local packages

    manager=$(get_or_null ".steps[$step_index].manager" "$file")
    manager_config=$(get_config ".package.manager.$manager")
    packages=$(get_or_null ".steps[$step_index].packages" "$file")

    if [[ -z "$manager" ]]; then
        echo_error "$file - $step_index: Missing property: manager"
    fi

    if [[ -z "$packages" ]]; then
        echo_error "$file - $step_index: Missing property: packages"
    fi

    if [[ -z "$manager_config" ]]; then
        echo_error "$file - $step_index: Unknown manager"
    fi

}

validate_step_link() {
    local step_index="$1"
    local file="$2"

    local source
    local target

    source=$(get_or_null ".steps[$step_index].source" "$file")
    target=$(get_or_null ".steps[$step_index].target" "$file")

    if [[ -z "$source" ]]; then
        echo_error "$file - $step_index: Missing property: source"
    fi

    if [[ -z "$target" ]]; then
        echo_error "$file - $step_index: Missing property: target"
    fi
}

validate_step_module() {
    return 0
}

validate_step_service() {
    local step_index="$1"
    local file="$2"

    local action
    local name
    local scope

    action=$(get_or_null ".steps[$step_index].action" "$file")
    name=$(get_or_null ".steps[$step_index].name" "$file")
    scope=$(get_or_null ".steps[$step_index].scope" "$file")

    if [[ -z "$action" ]]; then
        echo_error "$file - $step_index: Missing property: action"
    else
        case "$action" in
        disable) ;;
        enable) ;;
        restart) ;;
        start) ;;
        stop) ;;
        *) echo_error "$file - $step_index: Unknown action" ;;
        esac
    fi

    if [[ -z "$name" ]]; then
        echo_error "$file - $step_index: Missing property: name"
    fi

    if [[ -z "$scope" ]]; then
        echo_error "$file - $step_index: Missing property: scope"
    else
        case "$scope" in
        user) ;;
        system) ;;
        *) echo_error "$file - $step_index: Unknown scope" ;;
        esac
    fi
}

validate_module "$1"
