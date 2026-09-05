#!/bin/bash

set -e

TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_CONFIG="$SCRIPT_DIR/tmux-overrides.conf"
SOURCE_LINE="source-file $OVERRIDES_CONFIG"
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

# Check if tmux config exists
if [ ! -f "$TMUX_CONFIG" ]; then
  echo "Tmux config not found at $TMUX_CONFIG"
  echo "Please install tmux first"
  exit 1
fi

# Check if overrides config exists
if [ ! -f "$OVERRIDES_CONFIG" ]; then
  echo "Overrides config not found at $OVERRIDES_CONFIG"
  exit 1
fi

# Check if source line already exists in tmux.conf
if grep -Fxq "$SOURCE_LINE" "$TMUX_CONFIG"; then
  echo "Source line already exists in $TMUX_CONFIG"
else
  echo "Adding source line to $TMUX_CONFIG"
  echo "" >> "$TMUX_CONFIG"
  echo "$SOURCE_LINE" >> "$TMUX_CONFIG"
  echo "Source line added successfully"
fi

# TPM (tmux plugin manager) lives under ~/.config/tmux/plugins and is wiped by
# `omarchy reinstall`, so re-clone it if missing
if [ -d "$TPM_DIR" ]; then
  echo "TPM already installed at $TPM_DIR"
else
  echo "Cloning TPM to $TPM_DIR"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "Tmux overrides setup complete!"
echo "Open tmux and press prefix + I to install/update plugins via TPM."
