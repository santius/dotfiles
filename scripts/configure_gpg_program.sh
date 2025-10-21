#!/usr/bin/env bash
# configure_gpg_program.sh
# Find an available gpg binary and configure git to use it (git config --global gpg.program)
# Usage:
#   ./configure_gpg_program.sh         # dry-run - prints what would be configured
#   ./configure_gpg_program.sh --apply # actually sets git config --global gpg.program
#   ./configure_gpg_program.sh --yes   # same as --apply

echo "Installing gpg program..."

set -euo pipefail

APPLY=false
for arg in "$@"; do
  case "$arg" in
    --apply|--yes) APPLY=true; shift ;;
    -h|--help)
      sed -n '1,120p' "$0"
      exit 0
      ;;
  esac
done

candidates=("$(command -v gpg 2>/dev/null || true)" "$(command -v gpg2 2>/dev/null || true)" "/opt/homebrew/bin/gpg" "/usr/local/bin/gpg")
# unique & non-empty
unique=()
for p in "${candidates[@]}"; do
  if [ -n "$p" ] && [ ! "${unique[*]}" = *"$p"* ]; then
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
  echo "No gpg binary found on PATH or common locations. Please install gnupg (e.g. 'brew install gnupg')." >&2
  exit 2
fi

current=$(git config --global --get gpg.program || true)

echo "Found gpg: $selected"
if [ -n "$current" ]; then
  echo "Git currently has gpg.program='$current'"
else
  echo "Git currently has no gpg.program set"
fi

if [ "$current" = "$selected" ]; then
  echo "gpg.program already set to the found binary. Nothing to do."
  exit 0
fi

if [ "$APPLY" = true ]; then
  git config --global gpg.program "$selected"
  echo "Set git global gpg.program to: $selected"
else
  echo "Dry-run: would run: git config --global gpg.program \"$selected\""
  echo "Rerun with --apply or --yes to make the change." 
fi
