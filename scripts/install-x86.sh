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
    APT_PACKAGES=(
        "curl"
        "git"
        "python3"
        "python3-dev"
        "python3-pip"
        "python3-venv"
        "ripgrep"
        "fzf"
        "tree"
        "htop"
    )

    sudo apt update -y
    sudo apt-get install -y "${APT_PACKAGES[@]}"
}

function install_neovim() {
    local RELEASES_URL="https://github.com/neovim/neovim/releases"
    local ARCHIVE="nvim-linux64.tar.gz"
    local DOWNLOAD_URL="$RELEASES_URL/download/v0.10.1/$ARCHIVE"
    local NVIM_HOME="$HOME/nvim-linux64"
    local ARCHIVE_PATH="/tmp/$ARCHIVE"

    if [ -d $NVIM_HOME ] && [ -x $NVIM_HOME/bin/nvim ]; then
        gum style "Neovim is already installed." \
            --foreground "#FF00FF" | \
            gum format
        export PATH=$NVIM_HOME/bin:$PATH
    else
        wget -O $ARCHIVE_PATH $DOWNLOAD_URL
        tar -xzf $ARCHIVE_PATH -C $HOME
    fi

    if [[ "$PATH" =~ "$NVIM_HOME" ]]; then
        gum style "Neovim is already in the \$PATH" \
            --foreground "#FF00FF" | \
            gum format
    else
        echo "export PATH=$NVIM_HOME/bin:\$PATH" >> $HOME/.bashrc
    fi

    rm -f $ARCHIVE_PATH
}

function refresh_bashrc() {
    source $HOME/.bashrc
}

function main() {
    install_prerequisites && clear
    source $HOME/.bashrc

    display_banner "Install x86 Development Tools"

    display_section "Install Packages via APT"
    install_apt_packages

    display_section "Install Neovim"
    install_neovim

    echo
}

main
