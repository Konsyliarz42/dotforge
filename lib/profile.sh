#!/bin/bash

run_profile() {
    local file="$1"

    local name
    local modules

    name=$(get_or_null ".name" "$file")
    modules=$(get_or_null ".modules[]" "$file")

    echo_profile "$name"

    for module in "$modules[@]"; do
        run_module "$module"
    done
}
