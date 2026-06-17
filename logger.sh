#!/usr/bin/env bash

# Compatibility shim. Shared logging helpers live in scripts/shared/logger.sh.
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "$DOTFILES_ROOT/scripts/shared/logger.sh"
