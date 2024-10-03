#!/bin/sh

echo "*** Adding this Lua project to PATH ***"

second_upper_dir=$(dirname "$(dirname "$(pwd)")")

alias_def="alias flowerpot=\"lua $second_upper_dir/flowerpot.lua\""

# echo  >> ~/.bashrc
sed -i "/^alias /a $alias_def" ~/.bashrc

chmod +x "$second_upper_dir/flowerpot.lua"
source ~/.bashrc