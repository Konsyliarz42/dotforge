#!/bin/bash

run_module() {
    local file="$1"

    local log_directory
    local log_file
    local name
    local step_index
    local steps_count
    local strict

    get_or_null ".name" "$file" name
    get_or_null ".steps | length" "$file" steps_count
    get_or_null ".strict" "$file" strict

    log_directory="$SCRIPT_DIR/logs/$name"
    log_file="$log_directory/$TIMESTAMP.log"

    if [ ! -f "$log_file" ]; then
        mkdir -p "$log_directory"
        touch "$log_file"
    fi

    echo_log "Executing module: $name($file)" "$log_file"
    if [ $strict == "true" ]; then
        echo_log "- Strict mode is enabled" "$log_file"
    fi

    echo_module "$name"

    for ((step_index = 0; step_index < steps_count; step_index++)); do
        local type

        get_or_null ".steps[$step_index].type" "$file" type

        case "$type" in
        clone) git_clone $step_index "$file" "$log_file" ;;
        command) run_command $step_index "$file" "$log_file" ;;
        copy) copy $step_index "$file" "$log_file" ;;
        install) install_packages $step_index "$file" "$log_file" ;;
        link) create_symlink $step_index "$file" "$log_file" ;;
        service) manage_service $step_index "$file" "$log_file" ;;
        esac

        if [ $? -eq 0 ]; then
            echo_ok
        else
            echo_nok
            EXIT_CODE=1
            if [ $strict == "true" ]; then
                echo_log "Step failed, stop executing the module" "$log_file"
                return 1
            fi
        fi
    done
}

git_clone() {
    local step_index="$1"
    local file="$2"
    local log_file="$3"

    echo_log "Executing step: $step_index(clone)" "$log_file"

    local description
    local target
    local url

    get_or_null ".steps[$step_index].description" "$file" description
    get_or_null ".steps[$step_index].target" "$file" target
    get_or_null ".steps[$step_index].url" "$file" url

    echo_step "${description:-"Cloning repository"}"

    echo_log "> git clone $url $target" "$log_file"
    git clone "$url" "$target" >>"$log_file"
}

run_command() {
    local step_index="$1"
    local file="$2"
    local log_file="$3"

    echo_log "Executing step: $step_index(command)" "$log_file"

    local cmd
    local description

    get_or_null ".steps[$step_index].description" "$file" description
    get_or_null ".steps[$step_index].cmd" "$file" cmd

    echo_step "${description:-"Executing command"}"

    echo_log "> eval $cmd" "$log_file"
    eval "$cmd" >>"$log_file"
}

copy() {
    local step_index="$1"
    local file="$2"
    local log_file="$3"

    echo_log "Executing step: $step_index(copy)" "$log_file"

    local backup
    local backup_suffix
    local description
    local source
    local target

    get_config ".backup.enabled" backup
    get_config ".backup.suffix" backup_suffix

    get_or_null ".steps[$step_index].description" "$file" description
    get_or_null ".steps[$step_index].source" "$file" source
    get_or_null ".steps[$step_index].target" "$file" target

    echo_step "${description:-"Copying source to target"}"

    if [[ -e "$target" && "$backup" == "true" ]]; then
        echo_log "> mv $target ${target}${backup_suffix}" "$log_file"
        mv "$target" "${target}${backup_suffix}" >>"$log_file"
    fi

    echo_log "> mkdir -p $(dirname "$target")" "$log_file"
    mkdir -p "$(dirname "$target")" >>"$log_file"
    echo_log "> cp -r $source $target" "$log_file"
    cp -r "$source" "$target" >>"$log_file"
}

install_packages() {
    local step_index="$1"
    local file="$2"
    local log_file="$3"

    echo_log "Executing step: $step_index(install)" "$log_file"

    local cmd
    local description
    local manager
    local packages

    get_or_null ".steps[$step_index].description" "$file" description
    get_or_null ".steps[$step_index].manager" "$file" manager
    get_or_null ".steps[$step_index].packages[]" "$file" packages

    get_config ".package.manager.$manager" cmd

    echo_step "${description:-"Installing packages"}"

    echo_log "> eval $cmd ${packages[*]}" "$log_file"
    eval "$cmd" "${packages[@]}" >>"$log_file"
}

create_symlink() {
    local step_index="$1"
    local file="$2"
    local log_file="$3"

    echo_log "Executing step: $step_index(link)" "$log_file"

    local backup
    local backup_suffix
    local description
    local source
    local target

    get_config ".backup.enabled" backup
    get_config ".backup.suffix" backup_suffix

    get_or_null ".steps[$step_index].description" "$file" description
    get_or_null ".steps[$step_index].source" "$file" source
    get_or_null ".steps[$step_index].target" "$file" target

    echo_step "${description:-"Linking source to target"}"

    if [[ -e "$target" && "$backup" == "true" ]]; then
        echo_log "> mv $target ${target}${backup_suffix}" "$log_file"
        mv "$target" "${target}${backup_suffix}" >>"$log_file"
    fi

    echo_log "> mkdir -p $(dirname "$target")" "$log_file"
    mkdir -p "$(dirname "$target")" >>"$log_file"
    echo_log "> ln -sf $(realpath "$source") $target" "$log_file"
    ln -sf "$(realpath "$source")" "$target" >>"$log_file"
}

manage_service() {
    local step_index="$1"
    local file="$2"
    local log_file="$3"

    echo_log "Executing step: $step_index(service)" "$log_file"

    local description
    local action
    local cmd
    local name
    local scope

    get_or_null ".steps[$step_index].description" "$file" description
    get_or_null ".steps[$step_index].action" "$file" action
    get_or_null ".steps[$step_index].name" "$file" name
    get_or_null ".steps[$step_index].scope" "$file" scope

    echo_step "${description:-"Managing service"}"

    case "$scope" in
    system) cmd="sudo systemctl" ;;
    user) cmd="systemctl --user" ;;
    esac

    echo_log "> eval $cmd $action $name" "$log_file"
    eval "$cmd" "$action" "$name" >>"$log_file"
}
