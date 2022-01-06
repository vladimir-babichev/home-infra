#!/usr/bin/env bash

root_dir=$(git rev-parse --show-toplevel)
: "${ROOT_DIR=$root_dir}"
export ROOT_DIR=$ROOT_DIR

info() {
    echo -e "$1"
}

err() {
    echo -e "$1"
}

fail() {
    [ -n "$2" ] && err_code=$2 || err_code=1
    echo -e "$1"
    exit $err_code
}
