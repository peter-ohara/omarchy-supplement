#!/bin/bash

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/peter-ohara/dotfiles.git"
REPO_NAME="dotfiles"

is_stow_installed() {
  pacman -Qi "stow" &>/dev/null
}

if ! is_stow_installed; then
  echo "Install stow first"
  exit 1
fi

cd ~

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
  echo "Repository '$REPO_NAME' already exists. Skipping clone"
else
  git clone "$REPO_URL"
fi

# IMPORTANT: Do not add trailing slash to directories.
# With a trailing slash on a symlink, rm follows into the target 
# and deletes the contents of the dotfiles folder
# do      "$HOME/.config/yazi"
# don't   "$HOME/.config/yazi/"
declare -A CONFIGS=(
  [ghostty]="$HOME/.config/ghostty/config"
  [nvim]="$HOME/.config/nvim $HOME/.local/share/nvim $HOME/.cache/nvim"
  [starship]="$HOME/.config/starship.toml"
  [yazi]="$HOME/.config/yazi"
)

# Check if the clone was successful
if [ $? -eq 0 ]; then
  cd "$REPO_NAME" || exit 1
  for pkg in "${!CONFIGS[@]}"; do
    echo "removing old config for $pkg"
    for path in ${CONFIGS[$pkg]}; do
      rm -rf "$path"
    done
    stow -R "$pkg"
  done
else
  echo "Failed to clone the repository."
  exit 1
fi
