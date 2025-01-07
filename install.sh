#!/bin/bash

# Exit immediately if a command exits with a non-zero status, and show errors
set -euo pipefail

script_path="$(realpath "$0")"
script_dir="$(dirname $script_path)"

# Variables
PROGRAM_NAME="flowerpot"
INSTALL_DIR="/opt/$PROGRAM_NAME"
PROGRAM_REPO="https://github.com/crannbog/flowerpot/archive/refs/heads/stable.zip"
LUA_REPO="https://www.github.com/lua/lua.git"
LUA_INSTALL_DIR="$INSTALL_DIR/core/runtime"
BASHRC_FILE="/etc/bash.bashrc"
PROGRAM_ALIAS="ff"

# Function to display messages
function log {
    echo "     [INFO] $1"
}

# Ensure the script is run with sudo
function ensure_sudo {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root or with sudo. Re-running with sudo..."
        exec sudo bash $script_path
    fi
}

# Prepare system by updating package lists and installing required packages
function prepare_system {
    log "Updating package lists and installing prerequisites..."
    apt-get update -y
    apt-get install -y build-essential speedtest-cli unzip
}

# Download and extract program repository
function download_and_extract_program {
    log "Downloading program archive from $PROGRAM_REPO..."
    wget --no-cache $PROGRAM_REPO -O "/tmp/$PROGRAM_NAME.zip"

    log "Extracting program archive to $INSTALL_DIR..."
    unzip -q -o "/tmp/$PROGRAM_NAME.zip" -d "/tmp/$PROGRAM_NAME"
    log "Removing old contents from $INSTALL_DIR..."
    sudo rm -rf "$INSTALL_DIR" # Remove old program files if they exist
    log "Recreating Dir $INSTALL_DIR..."
    sudo mkdir -p $INSTALL_DIR
    mv "/tmp/$PROGRAM_NAME/$PROGRAM_NAME-stable/"* "$INSTALL_DIR/"
    rm -rf "/tmp/$PROGRAM_NAME" "/tmp/$PROGRAM_NAME.zip"
    sudo chown -R root:users $INSTALL_DIR
    sudo chmod -R 775 $INSTALL_DIR 
    sudo chmod g+s $INSTALL_DIR 
}

# Function to get the latest Lua version number
get_latest_lua_version() {
    curl -s https://www.lua.org/ftp/ | grep -oP 'lua-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1
}

# Check if Lua is installed
function check_lua_installed {
    local latest_version=$(get_latest_lua_version)
    
    if command -v lua &>/dev/null; then
        log "Lua is already installed and available in PATH."
        return 0
    else
        log "Lua is not installed. Proceeding with Lua installation..."
        return 1
    fi
}

# Install Lua from source
function install_lua {
    local latest_version=$(get_latest_lua_version)
    local lua_tarball="lua-$latest_version.tar.gz"
    local lua_url="https://www.lua.org/ftp/$lua_tarball"

    log "Downloading Lua $latest_version..."
    mkdir -p /tmp/lua
    cd /tmp/lua
    curl -R -O $lua_url
    tar -zxf $lua_tarball

    cd "lua-$latest_version" || exit

    log "Building and installing Lua..."
    make linux
    make INSTALL_TOP="$LUA_INSTALL_DIR" install

    log "Creating symlink for Lua binaries..."
    ln -sf "$LUA_INSTALL_DIR/bin/lua" /usr/local/bin/lua
    ln -sf "$LUA_INSTALL_DIR/bin/luac" /usr/local/bin/luac

    log "Lua installation completed successfully."
}

# Add program alias to bashrc
function add_program_alias {
    if ! grep -q "alias $PROGRAM_ALIAS=" "$BASHRC_FILE"; then
        log "Adding program alias to $BASHRC_FILE..."
        echo "alias $PROGRAM_ALIAS='lua $INSTALL_DIR/flowerpot.lua'" >>"$BASHRC_FILE"
        echo "alias $PROGRAM_NAME='lua $INSTALL_DIR/flowerpot.lua'" >>"$BASHRC_FILE"
        log "Alias added successfully. Please reload your shell or run 'source $BASHRC_FILE' to apply changes."
    else
        log "Program alias already exists in $BASHRC_FILE."
    fi
}

# Main execution
ensure_sudo
prepare_system
download_and_extract_program

if ! check_lua_installed; then
    install_lua
fi

check_lua_installed # Verify Lua installation again after installing

add_program_alias

log "Installation completed successfully!"

exit