#!/bin/bash

# Shows the diff between omarchy's default nvim config and my dotfiles nvim config.

set -e

OMARCHY_NVIM="/etc/skel/.config/nvim"
if [ ! -d "$OMARCHY_NVIM" ]; then
  OMARCHY_NVIM="/usr/share/omarchy-nvim/config"
fi

DOTFILES_NVIM="$HOME/dotfiles/nvim/.config/nvim"

if [ ! -d "$OMARCHY_NVIM" ]; then
  echo "Omarchy default nvim config not found"
  exit 1
fi

if [ ! -d "$DOTFILES_NVIM" ]; then
  echo "Dotfiles nvim config not found at $DOTFILES_NVIM"
  exit 1
fi

git diff --no-index "$OMARCHY_NVIM" "$DOTFILES_NVIM" || true
