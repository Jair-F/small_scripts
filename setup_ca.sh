#!/bin/bash

# Prevent script from failing completely due to minor utility checks
set -u

increase_swap() {
    SWAP_FILE="/swp.img"
    echo "=== Configuring 8GB Swap File ==="
    
    if [ -f "$SWAP_FILE" ] && swapon --show | grep -q "$SWAP_FILE"; then
        swapoff "$SWAP_FILE"
    fi

    if command -v fallocate &> /dev/null; then
        fallocate -l 8G $SWAP_FILE
    else
        dd if=/dev/zero of=$SWAP_FILE bs=1M count=8192
    fi

    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    swapon --show
    free -h
}

install_programs() {
    CURRENT_USER=$1
    echo "User which started the script: $CURRENT_USER"
    echo "Current user privilege is: $(whoami)"

    snap install --classic code
    apt update
    apt install -y git wget curl docker.io docker-compose-v2 docker-buildx mono-complete python3 python3-pip jq gparted
    sudo -u "$CURRENT_USER" bash -c 'wget -qO- https://astral.sh/uv/install.sh | sh'
    usermod -aG docker $CURRENT_USER
    chmod 666 /var/run/docker.sock
}

add_remove_dock_apps() {
    echo "Current Gnome Apps: $(gsettings get org.gnome.shell favorite-apps)"

    gsettings set org.gnome.shell favorite-apps "[
        'firefox_firefox.desktop',
        'org.gnome.Nautilus.desktop',
        'org.gnome.Terminal.desktop',
        'org.gnome.Settings.desktop',
        'code_code.desktop',
        'org.gnome.SystemMonitor.desktop',
        'gparted.desktop',
        'org.gnome.TextEditor.desktop'
    ]"

    echo "Updated Gnome Apps: $(gsettings get org.gnome.shell favorite-apps)"
}

vscode_default_settings() {
    local TARGET_HOME=$1
    local SETTINGS_DIR="$TARGET_HOME/.config/Code/User"
    local SETTINGS_FILE="$SETTINGS_DIR/settings.json"
    
    mkdir -p "$SETTINGS_DIR"

    if [ ! -s "$SETTINGS_FILE" ]; then
        echo "{}" > "$SETTINGS_FILE"
    fi

    local TMP_FILE
    TMP_FILE=$(mktemp)

    jq ' . + {
        "telemetry.telemetryLevel": "error",
        "editor.detectIndentation": false,
        "git.openRepositoryInParentFolders": "always",
        "workbench.iconTheme": "material-icon-theme",
        "files.eol": "\n",
        "files.autoSave": "onFocusChange",
        "workbench.colorTheme": "Default Dark Modern",
        "security.workspace.trust.untrustedFiles": "open",
        "explorer.confirmDragAndDrop": false
    }' "$SETTINGS_FILE" > "$TMP_FILE"

    mv "$TMP_FILE" "$SETTINGS_FILE"
    echo "VS Code settings updated successfully."
}

run_as_root() {
    CURRENT_USER=$1
    install_programs $CURRENT_USER
    increase_swap
}

if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script directly as root. Run it as a standard user."
  exit 1
fi

SAVED_USER="$USER"
SAVED_HOME="$HOME"

sudo bash -c "$(declare -f run_as_root; declare -f install_programs; declare -f increase_swap); run_as_root $SAVED_USER"

echo "=== Installing VS Code Extensions ==="
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-python.python
code --install-extension PKief.material-icon-theme

add_remove_dock_apps
vscode_default_settings "$SAVED_HOME"

echo "=== Setup complete! ==="
