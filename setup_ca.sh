#!/bin/bash

install_programs() {
    CURRENT_USER=$1
    echo "User which started the script: $CURRENT_USER"
    echo "Current user privilege is: $(whoami)"

    snap install --classic code
    apt update
    apt install -y git wget curl docker.io docker-compose-v2 docker-buildx mono-complete python3 python3-pip
    usermod -aG docker $CURRENT_USER
    chmod 666 /var/run/docker.sock
}

sudo bash -c "$(declare -f install_programs); install_programs $USER"

code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-python.python
code --install-extension PKief.material-icon-theme
