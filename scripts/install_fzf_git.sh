#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [[ -f "$SCRIPT_DIR/shared/logger.sh" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/shared/logger.sh"
fi

repo_url="https://github.com/junegunn/fzf-git.sh.git"
dev_dir="${DEV:-$HOME/dev}"
target_dir="$dev_dir/fzf-git.sh"

mkdir -p "$dev_dir"

if [[ -d "$target_dir/.git" ]]; then
    log_info "fzf-git.sh already exists at $target_dir; skipping clone"
elif [[ -e "$target_dir" ]]; then
    log_warn "Skipping fzf-git.sh clone because path already exists: $target_dir"
else
    log_info "Cloning fzf-git.sh into $target_dir"
    git clone "$repo_url" "$target_dir"
fi
