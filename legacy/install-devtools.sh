#!/bin/bash -e

function usage() {
    echo "Usage: $0 [--mode=dev|prod]"
}

function parse_args() {
    argument="$1"

    while [[ $# -gt 0 ]]; do
        case $argument in
            --mode=*)
                MODE="${argument#*=}"

                if [[ ! $MODE =~ ^(dev|prod)$ ]]; then
                    echo "Invalid mode: $MODE"
                    exit 1
                fi

                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Invalid argument: $argument"
                usage
                exit 1
                ;;
        esac
    done
}

MODE="prod"
ANSIBLE_VERSION="ansible-core==2.12"
NVIM_CFG_URL='https://raw.githubusercontent.com/nicomiguelino/dotfiles/main/init.vim'
NVIM_CFG_DIR="${HOME}/.config/nvim"
GITHUB_REPO='https://github.com/nicomiguelino/devtools.git'

parse_args "$@"

if ! [ "$(which ansible)"  ]; then
    sudo apt update -y && \
    sudo apt-get install -y --no-install-recommends \
        git \
        python3 \
        python3-dev \
        python3-pip

    sudo pip install cryptography==38.0.2
    sudo pip install "$ANSIBLE_VERSION"
fi

if [[ "$MODE" == "dev" ]]; then
    ansible-playbook install-devtools.yml
elif [[ "$MODE" == "prod" ]]; then
    sudo -u ${USER} ansible localhost \
        -m git \
        -a "repo=$GITHUB_REPO dest=/home/${USER}/devtools version=main force=no"
    cd /home/${USER}/devtools
    ansible-playbook install-devtools.yml
fi

exec $(which zsh)
