#!/bin/bash

# ⚡️ Blazing fast terminal file manager written in Rust, based on async I/O.
sudo pacman -S --noconfirm --needed yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick ueberzugpp

# Install flavors (themes)
ya pkg add yazi-rs/flavors:catppuccin-mocha
ya pkg add BennyOe/tokyo-night

# Install smart-enter.yazi plugin
ya pkg add yazi-rs/plugins:smart-enter

# Install duckdb.yazi plugin
curl https://install.duckdb.org | sh
ya pkg add wylie102/duckdb

# Install toggle-pane.yazi (Toggle the show, hide, and maximize states for different panes: parent, current, and preview.)
ya pkg add yazi-rs/plugins:toggle-pane

# A mount manager for Yazi, providing disk mount, unmount, and eject functionality.
ya pkg add yazi-rs/plugins:mount
