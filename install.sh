#!/bin/bash

# Exit on error
set -e

BASE_DIR="$HOME/dev/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"
ZSH_CUSTOM_DIR="$HOME/zsh_custom"
GIT_IGNORE_FILE="$BASE_DIR/git/gitignore"

FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
)

FILES_TO_INSTALL=(
    ".zshrc"
    ".vimrc"
    ".gitconfig"
    "zsh_custom/aliases.zsh"
    "zsh_custom/exports.zsh"
)

# Create directories if they don't exist
mkdir -p "$BACKUP_DIR" "$ZSH_CUSTOM_DIR"

# Backup existing files
for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$file" ]; then
        echo "Backing up $file to $BACKUP_DIR"
        mv "$file" "$BACKUP_DIR"
    else
        echo "Warning: $file does not exist, skipping backup."
    fi
done

# Install dotfiles by creating symlinks
for file in "${FILES_TO_INSTALL[@]}"; do
    target="$HOME/$file"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Removing existing $target"
        rm -rf "$target"
    fi

    if [ ! -L "$target" ]; then
        echo "Creating symlink for $file in $HOME"
        ln -s "$BASE_DIR/$file" "$target"
    fi
done

# Move custom Zsh configuration files to the appropriate directory
for custom_file in "aliases.zsh" "exports.zsh"; do
    if [ -e "$HOME/$custom_file" ]; then
        mv "$HOME/$custom_file" "$ZSH_CUSTOM_DIR/$custom_file"
        echo "Moved $custom_file to $ZSH_CUSTOM_DIR"
    else
        echo "Warning: $HOME/$custom_file does not exist, skipping move."
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
source "$BASE_DIR/set-defaults.sh"

echo "Backup and installation completed successfully."
