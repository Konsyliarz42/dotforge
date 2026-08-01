validate_profile() {
    local file="$1"

    local name
    local modules

    get_or_null ".name" "$file" name
    get_or_null ".modules[]" "$file" modules

    if [[ -z "$name" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file")" "Missing property: name"
    fi

    if [[ -z "$modules" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file")" "Profile must have at least 1 module"
    fi

    for module in "${modules[@]}"; do
        validate_module "$module"
    done
}

validate_module() {
    local file="$1"

    local name
    local strict
    local steps
    local step_index
    local steps_count

    get_or_null ".name" "$file" name
    get_or_null ".strict" "$file" strict
    get_or_null ".steps[]" "$file" steps
    get_or_null ".steps | length" "$file" steps_count

    if [[ -z "$name" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file")" "Missing property: name"
    fi

    if [[ -z "$strict" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file")" "Missing property: strict"
    else
        case "$strict" in
        true) ;;
        false) ;;
        *)
            EXIT_CODE=1
            echo_error_validate "$(realpath "$file")" "Strict must be a boolean"
            ;;
        esac
    fi

    if [[ -z "$steps" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file")" "Module must have at least 1 step"
    else
        for ((step_index = 0; step_index < steps_count; step_index++)); do
            local type

            get_or_null ".steps[$step_index].type" "$file" type

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

    get_or_null ".steps[$step_index].url" "$file" url
    get_or_null ".steps[$step_index].target" "$file" target

    if [[ -z "$url" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: url"
    fi

    if [[ -z "$target" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: target"
    fi
}

validate_step_command() {
    local step_index="$1"
    local file="$2"

    local cmd
    local optional

    get_or_null ".steps[$step_index].cmd" "$file" cmd
    get_or_null ".steps[$step_index].optional" "$file" optional

    if [[ -z "$cmd" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: cmd"
    fi

    if [[ ! -z "$optional" ]]; then
        case "$optional" in
        true) ;;
        false) ;;
        *)
            EXIT_CODE=1
            echo_error_validate "$(realpath "$file")" "optional must be a boolean"
            ;;
        esac
    fi
}

validate_step_copy() {
    local step_index="$1"
    local file="$2"

    local source
    local target

    get_or_null ".steps[$step_index].source" "$file" source
    get_or_null ".steps[$step_index].target" "$file" target

    if [[ -z "$source" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: source"
    fi

    if [[ -z "$target" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: target"
    fi
}

validate_step_install() {
    local step_index="$1"
    local file="$2"

    local manager
    local manager_config
    local packages

    get_or_null ".steps[$step_index].manager" "$file" manager
    get_or_null ".steps[$step_index].packages" "$file" packages

    if [[ -z "$manager" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: manager"
    else
        get_config ".install.manager.$manager" manager_config
        if [[ -z "$manager_config" ]]; then
            EXIT_CODE=1
            echo_error_validate "$(realpath "$file") - [$step_index]" "Unknown manager: $manager"
        fi
    fi

    if [[ -z "$packages" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: packages"
    fi
}

validate_step_link() {
    local step_index="$1"
    local file="$2"

    local source
    local target

    get_or_null ".steps[$step_index].source" "$file" source
    get_or_null ".steps[$step_index].target" "$file" target

    if [[ -z "$source" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: source"
    fi

    if [[ -z "$target" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: target"
    fi
}

validate_step_service() {
    local step_index="$1"
    local file="$2"

    local action
    local name
    local scope

    get_or_null ".steps[$step_index].action" "$file" action
    get_or_null ".steps[$step_index].name" "$file" name
    get_or_null ".steps[$step_index].scope" "$file" scope

    if [[ -z "$action" ]]; then
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: action"
    else
        case "$action" in
        disable) ;;
        enable) ;;
        restart) ;;
        start) ;;
        stop) ;;
        *)
            EXIT_CODE=1
            echo_error_validate "$(realpath "$file") - [$step_index]" "Unknown action"
            ;;
        esac
    fi

    if [[ -z "$name" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: name"
    fi

    if [[ -z "$scope" ]]; then
        EXIT_CODE=1
        echo_error_validate "$(realpath "$file") - [$step_index]" "Missing property: scope"
    else
        case "$scope" in
        user) ;;
        system) ;;
        *)
            EXIT_CODE=1
            echo_error_validate "$(realpath "$file") - [$step_index]" "Unknown scope"
            ;;
        esac
    fi
}
