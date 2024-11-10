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

function main() {
    install_prerequisites && clear

    display_banner "Install Raspberry Pi Development Tools"

    display_section "Install Oh My Bash"
}

main
