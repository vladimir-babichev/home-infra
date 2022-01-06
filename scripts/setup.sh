#!/usr/bin/env bash

# Source common functions
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/common.sh"
OS="unknown"

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="OSX"
        info "🔎  MacOS X (\xef\x94\xb4) detected "
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        [ -f "/etc/os-release" ] && . /etc/os-release
        if [ "$ID" == "ubuntu" ]; then
            OS="Ubuntu"
            info "🔎  Ubuntu (\xef\x8c\x9b) detected"
        fi
    fi
}

check_dependencies_osx() {
    if ! which brew >/dev/null 2>&1; then
        fail "💀  Homebrew is missing. Follow instructions @ https://brew.sh/ to install"
    fi
}

install_packages_osx() {
    local packages=(
        kubectl
        make
        pre-commit
        shellcheck
    )
    for package in "${packages[@]}"; do
        if ! which "$package" >/dev/null 2>&1; then
            info "   $package is missing. Installing..."
            brew install "$package"
        fi
    done
}

install_packages_ubuntu() {
    local pip_packages=(
        pre-commit
    )
    for package in "${pip_packages[@]}"; do
        if ! which "$package" >/dev/null 2>&1; then
            info "   $package is missing. Installing..."
            pip install "$package"
        fi
    done

    local apt_packages=(
        shellcheck
        kubectl
    )
    for package in "${apt_packages[@]}"; do
        if ! which "$package" >/dev/null 2>&1; then
            info "   $package is missing. Installing..."
            apt install -y  "$package"
        fi
    done
}

main() {
    detect_os
    [ "$OS" = "unknown" ] && fail "💀  Unsupported OS"

    check_dependencies_${OS,,}
    install_packages_${OS,,}

    # Enable pre-commit
    pre-commit install --install-hooks
    info "🙌  All done"
}

main
