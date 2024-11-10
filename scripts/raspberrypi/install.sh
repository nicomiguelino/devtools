#!/bin/bash

set -euo pipefail

function install_prerequisites() {
    if [ -f /usr/bin/gum ]; then
        return
    fi

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | \
        sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list

    sudo apt -y update && sudo apt -y install gum
}


function display_banner() {
    local TITLE="${1:-Banner Title}"
    local COLOR="212"

    gum style \
        --foreground "${COLOR}" \
        --border-foreground "${COLOR}" \
        --border "thick" \
        --align center \
        --width 95 \
        --margin "1 1" \
        --padding "2 6" \
        "${TITLE}"
}

function display_section() {
    local TITLE="${1:-Section Title}"
    local COLOR="#00FFFF"

    gum style \
        --foreground "${COLOR}" \
        --border-foreground "${COLOR}" \
        --border "thick" \
        --align center \
        --width 95 \
        --margin "1 1" \
        --padding "1 4" \
        "${TITLE}"
}

function install_apt_packages() {
    local APT_PACKAGES=(
        "curl"
        "git"
        "python3"
        "python3-dev"
        "python3-pip"
        "python3-venv"
        "ripgrep"
    )

    sudo apt update -y
    sudo apt install -y "${APT_PACKAGES[@]}"
}

function install_oh_my_bash() {
    local INSTALL_URL="$GITHUB_RAW_BASE/ohmybash/oh-my-bash/master/tools/install.sh"

    if [ -d $HOME/.oh-my-bash ]; then
        gum style "Oh My Bash is already installed." \
            --foreground "212" | \
            gum format
    else
        bash -c "$(curl -fsSL $INSTALL_URL)" --unattended
    fi
}

function get_raspberry_pi_version() {
    local PI_MODEL=$(cat /proc/device-tree/model)

    # if $PI_MODEL has "Raspberry Pi 4" in it, then set $PI_VERSION to 'pi4'
    if [[ $PI_MODEL == *"Raspberry Pi 4"* ]]; then
        PI_VERSION="pi4"
    elif [[ $PI_MODEL == *"Raspberry Pi 3"* ]]; then
        PI_VERSION="pi3"
    else
        gum style "Unsupported Raspberry Pi model: $PI_MODEL" \
            --foreground "196" | \
            gum format
        exit 1
    fi

    echo $PI_VERSION
}

function install_nodejs() {
    local VERSION="v20.17.0"
    local DIST_URL="https://nodejs.org/dist"
    local NODE_HOME="$HOME/node-$VERSION-linux-x64"
    local ARCHIVE="node-${VERSION}-linux-x64.tar.xz"
    local DOWNLOAD_URL="${DIST_URL}/${VERSION}/${ARCHIVE}"
    local ARCHIVE_PATH="/tmp/$ARCHIVE"
}

function main() {
    install_prerequisites && clear

    display_banner "Install Raspberry Pi Development Tools"

    display_section "Install Oh My Bash"

    RASPBERRY_PI_VERSION=$(get_raspberry_pi_version)
    echo "Raspberry Pi version: $RASPBERRY_PI_VERSION"
}

main
