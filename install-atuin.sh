#!/bin/bash

# magical shell history

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
atuin login
atuin sync
