#!/bin/bash

set -e

BASHRC="$HOME/.bashrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES="$SCRIPT_DIR/bashrc-overrides.sh"
SOURCE_LINE="source $OVERRIDES"

if [ ! -f "$BASHRC" ]; then
  echo ".bashrc not found at $BASHRC"
  exit 1
fi

if [ ! -f "$OVERRIDES" ]; then
  echo "Overrides file not found at $OVERRIDES"
  exit 1
fi

if grep -Fxq "$SOURCE_LINE" "$BASHRC"; then
  echo "Source line already exists in $BASHRC"
else
  echo "Adding source line to $BASHRC"
  echo "" >> "$BASHRC"
  echo "$SOURCE_LINE" >> "$BASHRC"
  echo "Source line added successfully"
fi

echo "Bashrc overrides setup complete!"
