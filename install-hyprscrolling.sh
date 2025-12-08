#!/bin/bash

set -e

# URL of the plugin repo
REPO_URL="https://github.com/hyprwm/hyprland-plugins"
REPO_NAME="hyprland-plugins"

# Install hyprpm dependencies
echo "Installing hyprpm dependencies"
sudo pacman -S --noconfirm --needed cpio cmake git meson gcc

echo "Updating hyprpm"
hyprpm update

# Check if the repo is already listed
if hyprpm list | grep -q "Repository $REPO_NAME"; then
    echo "Repository '$REPO_NAME' is already installed."
else
    echo "Adding repository '$REPO_NAME'..."
    hyprpm add "$REPO_URL"
fi

echo "Enabling hyprscrolling"
hyprpm enable hyprscrolling
hyprpm list

echo "Reloading hyprpm"
hyprpm reload
hyprctl plugin list

