#!/bin/sh

echo "*** Adding this Lua project to PATH ***"

second_upper_dir=$(dirname "$(dirname "$(pwd)")")

alias_def="alias flowerpot=\"lua $second_upper_dir/flowerpot.lua\""

# echo  >> ~/.bashrc
sed -i "/^alias /a $alias_def" ~/.bashrc

chmod +x "$second_upper_dir/flowerpot.lua"
source ~/.bashrc



# Add flowerpot to PATH

echo "*** Adding flowerpot to PATH ***"

alias_def="alias flowerpot=\'lua $script_dir/flowerpot.lua\'"
global_bashrc=/etc/bash

if grep -q "$alias_def"; then
    echo "Alias already registered"
else
    echo "$alias_def" >> "$global_bashrc"
    echo "Alias $alias_def has been added to $global_bashrc."
fi