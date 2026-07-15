#!/bin/bash

echo_module() {
    local text="Processing module: $1"
    local decorator="== "

    local format
    format="\n"
    format+="\033[0;34m%s\033[0m"
    format+="%s"
    format+="\n"

    printf "$format" "$decorator" "$text"
}

echo_step() {
    local text="$*"
    local decorator=":: "

    local format
    format="\033[0;36m%s\033[0m"
    format+="%s"
    format+="\n"

    printf "$format" "$decorator" "$text"
}

echo_ok() {
    local text="OK"

    local format
    format="\033[1A"
    format+="\033[%dG"
    format+="\033[0;32m%s\033[0m"
    format+="\n"

    local col
    col=$((80 - ${#text} + 1))

    printf "$format" "$col" "$text"
}

echo_nok() {
    local text="NOK"

    local format
    format="\033[1A"
    format+="\033[%dG"
    format+="\033[0;31m%s\033[0m"
    format+="\n"

    local col
    col=$((80 - ${#text} + 1))

    printf "$format" "$col" "$text"
}

echo_log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S.%4N") $1" >>"$2"
}

echo_error() {
    local text="$1"

    local format
    format="\033[0;31mError:\033[0m"
    format+=" %s"
    format+="\n"

    printf "$format" "$text"
}
