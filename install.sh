#!/bin/bash

# Exit on error
# set -e

BASE_DIR="$HOME/dev/dotfiles"
DOTS_DIR="$HOME/dev/dotfiles/dots"
BACKUP_DIR="$HOME/.dotfiles_backup"
ZSH_CUSTOM_DIR="$HOME/zsh_custom"
GIT_IGNORE_FILE="$BASE_DIR/git/gitignore"

FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$GIT_IGNORE_FILE"
)

# Create directories if they don't exist
mkdir -p "$BACKUP_DIR" "$ZSH_CUSTOM_DIR"

# Backup existing files
for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$file" ]; then
        echo "Backing up $file to $BACKUP_DIR"
        mv -n "$file" "$BACKUP_DIR"
    fi
done

for file in "$DOTS_DIR"/* "$DOTS_DIR"/.*; do
  if [ "$file" == "$DOTS_DIR/." ] || [ "$file" == "$DOTS_DIR/.." ] || [ "$file" == "$DOTS_DIR/dots" ]; then
    continue
  fi
  if [ -f "$file" ]; then
    ln -s $file $HOME
  fi
done

# Set up gitignore file
if [ -e "$HOME/.config/git/gitignore" ]; then
    rm "$HOME/.config/git/gitignore"
    echo "Removed existing gitignore."
fi
ln -s "$GIT_IGNORE_FILE" "$HOME/.config/git/gitignore"
echo "Created symlink for gitignore."

# Install Homebrew if it's not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Set default preferences
# source "$BASE_DIR/set-defaults.sh"