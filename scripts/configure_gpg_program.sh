#!/usr/bin/env bash
# configure_gpg_program.sh
# Find an available gpg binary and configure git to use it (git config --global gpg.program)
# Usage:
#   ./configure_gpg_program.sh         # dry-run - prints what would be configured
#   ./configure_gpg_program.sh --apply # actually sets git config --global gpg.program
#   ./configure_gpg_program.sh --yes   # same as --apply

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

# Source dependencies
# shellcheck disable=SC1091
source "$BASE_DIR/scripts/lib/logger.sh"

APPLY=false
for arg in "$@"; do
  case "$arg" in
    --apply|--yes) APPLY=true ;;
    -h|--help)
      sed -n '1,120p' "$0"
      exit 0
      ;;
    *)
      log_error "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

log_section "GPG"

if ! command -v git >/dev/null 2>&1; then
  log_error "git is required to configure gpg.program"
  exit 1
fi

candidates=("$(command -v gpg 2>/dev/null || true)" "$(command -v gpg2 2>/dev/null || true)" "/opt/homebrew/bin/gpg" "/usr/local/bin/gpg")
# unique & non-empty
unique=()
for p in "${candidates[@]}"; do
  [[ -n "$p" ]] || continue

  found=false
  for existing in "${unique[@]}"; do
    if [[ "$existing" == "$p" ]]; then
      found=true
      break
    fi
  done

  if [[ "$found" == false ]]; then
      unique+=("$p")
  fi
done

selected=""
for p in "${unique[@]}"; do
  if [ -x "$p" ]; then
    selected="$p"
    break
  fi
done

if [ -z "$selected" ]; then
  log_info "No gpg binary found on PATH or common locations. Please install gnupg (e.g. 'brew install gnupg')." >&2
  exit 2
fi

current=$(git config --global --get gpg.program || true)

log_info "Found gpg: $selected"
if [ -n "$current" ]; then
  log_info "Git currently has gpg.program='$current'"
else
  log_info "Git currently has no gpg.program set"
fi

if [ "$current" = "$selected" ]; then
  log_warn "gpg.program already set to the found binary. Nothing to do."
  exit 0
fi

if [ "$APPLY" = true ]; then
  git config --global gpg.program "$selected"
  log_info "Set git global gpg.program to: $selected"
else
  log_info "Dry-run: would run: git config --global gpg.program \"$selected\""
  log_info "Rerun with --apply or --yes to make the change." 
fi
