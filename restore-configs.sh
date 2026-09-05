#!/bin/bash

# Reapplies my personal config on top of a fresh `omarchy reinstall`.
# Only touches configs/dotfiles -- does not install packages.
# Safe to re-run at any time.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Hyprland overrides"
"$SCRIPT_DIR/install-hyprland-overrides.sh"

echo "==> Dotfiles"
"$SCRIPT_DIR/install-dotfiles.sh"

echo "==> Bashrc overrides"
"$SCRIPT_DIR/install-bashrc-overrides.sh"

echo "==> Tmux overrides"
"$SCRIPT_DIR/install-tmux-overrides.sh"

echo "All configs restored."
echo
echo "==> Nvim"
echo "Dotfiles nvim config was stowed above, but omarchy's bundled nvim config"
echo "may have changed since you last merged it. To check for upstream changes:"
echo "  1. Run: $SCRIPT_DIR/diff-nvim.sh"
echo "  2. For each differing file, merge with:"
echo "       nvim -d <omarchy-file> <dotfiles-file>"
echo "     using ]c/[c to jump hunks and :diffget/:diffput to pull changes across"
echo "  3. Add any omarchy-only files you want to keep into"
echo "     ~/dotfiles/nvim/.config/nvim, then stow will pick them up"
