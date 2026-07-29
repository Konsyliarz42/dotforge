#!/bin/bash

get_or_null() {
    local key="$1"
    local file="$2"
    local result_name="$3"
    local -n result="$result_name"

    if [[ "$key" == *"[]" ]]; then
        result=()
        mapfile -t result < <(yq -r "$key" "$file")
    else
        result="$(yq -r "$key // \"\"" "$file")"
    fi
}

get_config() {
    local key="$1"
    local result_name="$2"
    local -n result="$result_name"

    if [[ "$key" == *"[]" ]]; then
        result=()
        if [[ -n "$CONFIG_FILE" ]]; then
            get_or_null "$key" "$CONFIG_FILE" "$result_name"
        fi
        if ((${#result[@]} == 0)); then
            get_or_null "$key" "$DEFAULT_CONFIG_FILE" "$result_name"
        fi
    else
        result=""
        if [[ -n "$CONFIG_FILE" ]]; then
            get_or_null "$key" "$CONFIG_FILE" "$result_name"
        fi
        if [[ -z "$result" ]]; then
            get_or_null "$key" "$DEFAULT_CONFIG_FILE" "$result_name"
        fi
    fi
}

get_path() {
    local path="$1"
    local relative="${2:-/}"

    if [[ "$path" == /* ]]; then
        echo "$path"
    else
        echo "$relative/$path"
    fi
}
