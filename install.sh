#!/bin/sh

# ======== ======== ======== ======== #
# 
# Script: install.sh
# Targets: install lua and other necessary tools
# Author: cmmdmx
# 
# PROVIDED BY CRANNBOG OPENSOURCE
#
# ======== ======== ======== ======== #

# Function to get the latest Lua version number
get_latest_lua_version() {
    curl -s https://www.lua.org/ftp/ | grep -oP 'lua-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1
}

# Determine script directory and target installation directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="$script_dir/core/runtime"

# Function to download and install Lua into a specified directory
install_lua() {
    local version=$1
    local lua_tarball="lua-$version.tar.gz"
    local lua_url="https://www.lua.org/ftp/$lua_tarball"
    local install_dir=$2

    echo "Downloading Lua $version..."
    curl -R -O $lua_url

    echo "Extracting Lua $version..."
    tar -zxf $lua_tarball

    cd "lua-$version" || exit

    echo "Building Lua $version..."
    make linux test

    echo "Installing Lua $version into $install_dir..."
    make INSTALL_TOP="$install_dir" install

    echo "Lua $version has been installed into $install_dir!"
    ln -sf ~/flowerpot/core/runtime/bin/lua /usr/bin/lua
        
    # Clean up extracted files
    cd "$script_dir"
    rm -rf "lua-$latest_version"
    rm "lua-$latest_version.tar.gz"
}

# Prerequisites

apt-get update
apt-get install build-essential -y

# Main script
latest_version=$(get_latest_lua_version)

if [ -z "$latest_version" ]; then
    echo "Failed to determine the latest Lua version."
    exit 1
fi

echo "Latest Lua version is $latest_version"

# Create the target directory if it doesn't exist
mkdir -p "$install_dir"  # Ensures the ./core/runtime directory is created

if command -v lua &> /dev/null; then
    # Lua is installed, now check its version
    INSTALLED_VERSION=$(lua -v 2>&1 | awk '{print $2}')
    
    if [ "$INSTALLED_VERSION" != "$latest_version" ]; then
        echo "Lua is installed but not the latest version. Installing version $latest_version."
        install_lua "$latest_version" "$install_dir"
    else
        echo "Lua is already installed and is the latest version ($INSTALLED_VERSION)."
    fi
else
    echo "Lua is not installed. Installing version $latest_version."
    install_lua "$latest_version" "$install_dir"
fi

# Add flowerpot to PATH

echo "*** Adding flowerpot to PATH ***"

alias_def="alias flowerpot=\'lua $script_dir/flowerpot.lua\'"
# Temporary variable to hold the output
output=""
found_alias=false

# Read the .bashrc file line by line
while IFS= read -r line; do
    output+="$line"$'\n'  # Append the current line to output

    echo $line

    # Check if the line starts with "alias"
    if [[ "$line" == alias* && "$found_alias" == false ]]; then
        echo "INSERTING NEW ALIAS at line $line"
        output+="$alias_def"$'\n'  # Insert the new alias after the first found alias
        found_alias=true  # Set the flag to true to avoid inserting again
    fi
done < ~/.bashrc

# If no alias was found, append the new alias at the end
if [[ "$found_alias" == false ]]; then
    echo "INSERTING NEW ALIAS 2"
    output+="$alias_def"$'\n'
fi

# Write all lines back to .bashrc
echo -e "$output" > ~/.bashrc