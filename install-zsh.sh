#!/bin/bash

# Install Zsh
if ! command -v zsh &>/dev/null; then
  sudo pacman -S --noconfirm --needed zsh
fi
