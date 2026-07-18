#!/usr/bin/env bash

set -euo pipefail

readonly DOTFILES_RAW_BASE="https://raw.githubusercontent.com/nicomiguelino/dotfiles/main"
readonly NVIM_VERSION="v0.11.7"
readonly NVIM_HOME="$HOME/apps/nvim/$NVIM_VERSION"

log() {
    printf '\n==> %s\n' "$1"
}

require_ubuntu_version() {
    if [[ ! -r /etc/os-release ]]; then
        printf 'Unable to determine the operating system.\n' >&2
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "26.04" ]]; then
        printf 'This installer requires Ubuntu 26.04.\n' >&2
        exit 1
    fi

    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        printf 'This installer requires an x86_64 Ubuntu system.\n' >&2
        exit 1
    fi
}

install_prerequisites() {
    log "Install bootstrap packages"
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        git \
        gnupg \
        sudo \
        unzip \
        wget \
        zsh
}

install_oh_my_zsh() {
    log "Install Oh My Zsh and set zsh as the default shell"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    sudo usermod --shell "$(command -v zsh)" "$USER"
}

install_apt_packages() {
    log "Install general development packages"
    sudo apt-get install -y \
        build-essential \
        fzf \
        gh \
        htop \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        ripgrep \
        tmux \
        tree \
        xclip
}

install_nodejs() {
    log "Install Node.js 24 via NodeSource"
    curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

install_bun() {
    log "Install the latest stable Bun"
    curl -fsSL https://bun.sh/install | bash
}

install_neovim() {
    log "Install Neovim $NVIM_VERSION"
    local archive="nvim-linux-x86_64.tar.gz"
    local archive_path="/tmp/$archive"
    local download_url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$archive"

    if [[ ! -x "$NVIM_HOME/bin/nvim" ]]; then
        mkdir -p "$HOME/apps/nvim"
        curl -fsSL "$download_url" -o "$archive_path"
        rm -rf "$NVIM_HOME"
        mkdir -p "$NVIM_HOME"
        tar -xzf "$archive_path" --strip-components=1 -C "$NVIM_HOME"
        rm -f "$archive_path"
    fi
}

install_nvim_config() {
    log "Install the Neovim configuration"
    if [[ ! -d "$HOME/.config/nvim/.git" ]]; then
        mkdir -p "$HOME/.config"
        git clone https://github.com/nicomiguelino/nvim.git "$HOME/.config/nvim"
    fi
}

install_tmux_config() {
    log "Install tmux configuration and plugin manager"
    curl -fsSL "$DOTFILES_RAW_BASE/.tmux.conf" -o "$HOME/.tmux.conf"
    if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

add_path_once() {
    local path_line="$1"
    local file="$2"

    touch "$file"
    if ! grep -Fqx "$path_line" "$file"; then
        printf '\n%s\n' "$path_line" >> "$file"
    fi
}

configure_path() {
    log "Configure user paths"
    add_path_once 'export PATH="$HOME/apps/nvim/v0.11.7/bin:$HOME/.bun/bin:$PATH"' "$HOME/.zshrc"
    add_path_once 'export PATH="$HOME/apps/nvim/v0.11.7/bin:$HOME/.bun/bin:$PATH"' "$HOME/.bashrc"
}

main() {
    require_ubuntu_version
    install_prerequisites
    install_oh_my_zsh
    install_apt_packages
    install_nodejs
    install_bun
    install_neovim
    install_nvim_config
    install_tmux_config
    configure_path

    log "Installation complete"
    printf 'Restart your shell to use zsh, Node.js, Bun, Neovim, and tmux.\n'
}

main "$@"
