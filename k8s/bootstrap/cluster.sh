#!/usr/bin/env bash

info() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") [INFO]:    $1" | tee -a "$LOG_FILE"
}

err() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") [ERROR]:    $1" | tee -a "$LOG_FILE" 1>&2
}

fail() {
    [ -n "$2" ] && err=$2 || err=1
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") [ERROR]:    $1" | tee -a "$LOG_FILE" 1>&2
    exit $err
}

# REPO_ROOT=$(git rev-parse --show-toplevel)

if [[ -z "$resource_groups" ]]; then
    fail "Resource group cannot be null!"
fi
