#!/bin/bash

# ble.sh -- Bash Line Editor.
# Gives bash syntax highlighting, autosuggestions, and a much better
# line editor. Atuin has built-in support for it.
#
# We install blesh-git, NOT the blesh package.
#   blesh      = tag 0.3.4, from 2023. It predates bash 5.3.
#   blesh-git  = the 0.4.0 devel branch, where all current work happens.
# Both AUR packages are maintained by akinomyoga, the ble.sh author.

set -euo pipefail

yay -S --needed blesh-git

# ---------------------------------------------------------------------------
# The two .bashrc lines are kept in the dotfiles repo, not written here.
# This script only checks that they are in place.
# ---------------------------------------------------------------------------

BASHRC="$HOME/.bashrc"
top='source /usr/share/blesh/ble.sh --attach=none'
bottom='ble-attach'

echo
if grep -qF "$top" "$BASHRC" && grep -qF "$bottom" "$BASHRC"; then
  echo "OK: $BASHRC already loads ble.sh."
else
  cat <<'MSG'
TODO: your .bashrc does not load ble.sh yet.

Add this NEAR THE TOP, just after the "not interactive" guard:

  [[ $- == *i* ]] && [[ -r /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh --attach=none

Add this as the VERY LAST LINE, after starship and atuin:

  [[ ! ${BLE_VERSION-} ]] || ble-attach

The order matters. --attach=none loads ble.sh but keeps it asleep.
ble-attach then wakes it after every other tool has set itself up.

In this setup the file lives at ~/dotfiles/bash/.bashrc.
Edit it there, then run: cd ~/dotfiles && stow -R bash
MSG
fi

echo
echo "Open a new terminal to use it. Press F12 to turn ble.sh off and on."
