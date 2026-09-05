#!/bin/bash

# Install all packages in order
# TODO: If the package has been installed already, skip and provide a list of all skipped at the end to the user
./install-ghostty.sh
./install-yazi.sh
./install-git-delta.sh
./install-imagemagick.sh
./install-tectonic.sh
./install-tree-sitter-cli.sh
./install-bluetui.sh
./install-atuin.sh
# Extremely fast Python package installer and resolver, written in Rust
./install-uv.sh
# tmux
# zathura
# Install python dev tools
uv tool install --upgrade pynvim
uv tool install --upgrade ruff
uv tool install --upgrade pytest
# An extremely fast Python linter and code formatter, written in Rust.
./install-ruff.sh

./install-burpsuite.sh
./install-ueberzugpp.sh
npm install -g neovim
npm install -g @biomejs/biome
sudo pacman -S tabiew
sudo pacman -S serpl
yay -S otree
yay -S anki
yay -S superproductivity-bin
# Install ruby
# tree
# nmap
# xh
# ffuf
# gobuster
# ngrok

# .config
# ghostty
# yazi
# delta
# nvim
# fzf
# starship
# nushell
# .stowrc
# setup.sh

./install-stow.sh
./install-dotfiles.sh
./install-hyprland-overrides.sh

