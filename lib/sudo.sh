#!/bin/bash

SUDO_PID=""

check_not_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        echo "ERROR: Do not run this script with sudo/as root."
        exit 1
    fi
}

run_sudo() {
    local interval
    interval=$(get_config ".sudo_interval")

    sudo -v

    while true; do
        sudo -n true
        sleep "$interval"
        kill -0 "$$" || exit
    done 2>/dev/null &
    SUDO_PID=$!
}

cleanup() {
    if [[ -n "$SUDO_PID" ]]; then
        kill "$SUDO_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT
