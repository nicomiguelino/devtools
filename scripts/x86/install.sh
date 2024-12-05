#!/bin/bash

set -euo pipefail

GITHUB_RAW_BASE="https://raw.githubusercontent.com"

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
            --foreground "212" | \
            gum format
        export PATH=$NVIM_HOME/bin:$PATH
    else
        wget -O $ARCHIVE_PATH $DOWNLOAD_URL
        tar -xzf $ARCHIVE_PATH -C $HOME
    fi

    if [[ "$PATH" =~ "$NVIM_HOME" ]]; then
        gum style "Neovim is already in the \$PATH" \
            --foreground "212" | \
            gum format
    else
        echo "export PATH=$NVIM_HOME/bin:\$PATH" >> $HOME/.bashrc
    fi

    rm -f $ARCHIVE_PATH
}

function configure_neovim() {
    if [ -d ~/.config/nvim ]; then
        gum style "Neovim is already configured." \
            --foreground "212" | \
            gum format
        return
    fi

    git clone https://github.com/nicomiguelino/nvim.git ~/.config/nvim
}

function install_nodejs() {
    local VERSION="v20.17.0"
    local DIST_URL="https://nodejs.org/dist"
    local NODE_HOME="$HOME/node-$VERSION-linux-x64"
    local ARCHIVE="node-${VERSION}-linux-x64.tar.xz"
    local DOWNLOAD_URL="${DIST_URL}/${VERSION}/${ARCHIVE}"
    local ARCHIVE_PATH="/tmp/$ARCHIVE"

    if [ -d $NODE_HOME ] && [ -x $NODE_HOME/bin/node ]; then
        gum style "Node.js is already installed." \
            --foreground "212" | \
            gum format
        export PATH=$NODE_HOME/bin:$PATH
    else
        wget -O $ARCHIVE_PATH $DOWNLOAD_URL
        tar -xf $ARCHIVE_PATH -C $HOME
    fi

    if [[ "$PATH" =~ "$NODE_HOME" ]]; then
        gum style "Node.js is already in the \$PATH" \
            --foreground "212" | \
            gum format
    else
        echo "export PATH=$NODE_HOME/bin:\$PATH" >> $HOME/.bashrc
    fi

    rm -f $ARCHIVE_PATH
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

function install_oh_my_tmux() {
    local OMT_REPO_URL="https://github.com/gpakosz/.tmux.git"

    if [ -d $HOME/.tmux ]; then
        gum style "Oh My Tmux is already installed." \
            --foreground "212" | \
            gum format
        return
    fi

    cd
    git clone $OMT_REPO_URL
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
}

function configure_oh_my_tmux() {
    local REPOSITORY="nicomiguelino/devtools"
    local CONFIG_FILE=".tmux.conf.local"
    local DOWNLOAD_URL="$GITHUB_RAW_BASE/$REPOSITORY/main/common/$CONFIG_FILE"

    wget -O $HOME/$CONFIG_FILE $DOWNLOAD_URL
}

function install_docker() {
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker:
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # Add the current user to the docker group:
    sudo usermod -aG docker $USER
}

function install_github_cli() {
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
}

function main() {
    install_prerequisites && clear
    source $HOME/.bashrc

    display_banner "Install x86 Development Tools"

    display_section "Install Packages via APT"
    install_apt_packages

    display_section "Install Oh My Bash"
    install_oh_my_bash

    display_section "Install Neovim"
    install_neovim

    display_section "Configure Neovim"
    configure_neovim

    display_section "Install Node.js"
    install_nodejs

    display_section "Install Oh My Tmux"
    install_oh_my_tmux

    display_section "Configure Oh My Tmux"
    configure_oh_my_tmux

    display_section "Install Docker"
    install_docker

    display_section "Install GitHub CLI"
    install_github_cli

    display_section "Installation Complete"
    gum style "Please restart your shell to apply changes." \
        --foreground "212" | \
        gum format

    echo
}

main
