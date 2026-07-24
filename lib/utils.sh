#!/bin/bash

get_or_null() {
    local key="$1"
    local file="$2"
    local -n result="$3"

    if [[ "$key" == *"[]" ]]; then
        mapfile -t result < <(yq -r "$key" "$file")
    else
        result=("$(yq -r "$key // \"\"" "$file")")
    fi
}

get_config() {
    local key="$1"
    local -n result="$2"

    if [[ -n "$CONFIG_FILE" ]]; then
        get_or_null "$key" "$CONFIG_FILE" result
    fi

    if [[ -z "$value" ]]; then
        get_or_null "$key" "$DEFAULT_CONFIG_FILE" result
    fi

}
