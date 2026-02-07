#!/usr/bin/env bash
# Opens a file:line reference in an existing Neovim instance.
# Called by tmux-fingers: echo "src/foo.rs:42" | xargs -I {} open-in-nvim.sh {}
set -euo pipefail

input="$1"
SOCKET="${XDG_RUNTIME_DIR:-/tmp}/nvim-server.sock"

# Parse file:line:col
file="${input%%:*}"
rest="${input#*:}"
line="${rest%%:*}"

# Resolve relative paths against active tmux pane CWD
if [[ "$file" != /* ]]; then
    file="$(tmux display-message -p '#{pane_current_path}')/${file}"
fi

# Escape characters special to Neovim's command line
file="${file// /\\ }"
file="${file//#/\\#}"
file="${file//%/\\%}"

# Send to Neovim: exit any mode, open file, jump to line
nvim --server "$SOCKET" --remote-send \
    "<C-\\><C-N>:drop ${file}<CR>:${line}<CR>"
