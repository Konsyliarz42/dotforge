#!/bin/bash

get_or_null() {
    local key="$1"
    local file="$2"

    local value

    if [[ "$key" == *"[]" ]]; then
        mapfile -t value < <(yq -r "$key" "$file")
        echo "${value[@]}"
    else
        value=$(yq -r "$key // \"\"" "$file")
        echo "$value"
    fi
}

get_config() {
    local key="$1"

    local value=""

    if [[ -n "$CONFIG_FILE" ]]; then
        value=$(get_or_null "$key" "$CONFIG_FILE")
    fi

    if [[ -z "$value" ]]; then
        value=$(get_or_null "$key" "$DEFAULT_CONFIG_FILE")
    fi

    echo "$value"
}
