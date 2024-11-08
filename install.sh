#!/bin/bash

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
)

FILES_TO_INSTALL_ZSH=(
    "aliases.zsh"
)

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory at $BACKUP_DIR"
    mkdir "$BACKUP_DIR"
else
    echo "Backup directory already exists at $BACKUP_DIR"
fi

if [ ! -d "$ZSH_CUSTOM_DIR" ]; then
    echo "Creating ZSH custom directory at $ZSH_CUSTOM_DIR"
    mkdir "$ZSH_CUSTOM_DIR"
else
    echo "ZSH custom directory already exists at $ZSH_CUSTOM_DIR"
fi

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$file" ]; then
        echo "Moving $file to $BACKUP_DIR"
        mv "$file" "$BACKUP_DIR"
    else
        echo "Warning: $file does not exist, skipping."
    fi
done

for file in "${FILES_TO_INSTALL[@]}"; do
    if [ -e "$file" ]; then
        rm "$HOME"/"$file" 
        echo "Creating symlink for $file in $HOME"
        ln -s "$BASE_DIR"/"$file" "$HOME"
    else
        echo "Warning: $file does not exist, skipping."
    fi
done


for file in "zsh_custom"/"${FILES_TO_INSTALL_ZSH[@]}"; do
    if [ -e "$file" ]; then
        rm "$HOME"/"$file" 
        echo "Creating symlink for $file in $ZSH_CUSTOM_DIR"
        ln -s "$BASE_DIR"/zsh_custom/"$file" "$ZSH_CUSTOM_DIR"
    else
        echo "Warning: $file does not exist, skipping."
    fi
done

rm "$HOME"/.config/git/gitignore
ln -s "$GIT_IGNORE_FILE" "$HOME/.config/git/gitignore"

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

source "$BASE_DIR"/set-defaults.sh

echo "Backup completed."