#!/bin/bash

source logger.sh
source "functions/config_dotfiles.sh"
source "functions/config_homebrew.sh"
source "functions/config_mac_defaults.sh"

BASE_DIR="$HOME/dev/dotfiles"
DOTS_DIR="$BASE_DIR/dots"
ZSH_DIR="$BASE_DIR/zsh_custom"
BACKUP_DIR="$HOME/.dotfiles_backup"
ZSH_CUSTOM_DIR="$HOME/zsh_custom"
GIT_IGNORE_FILE="$BASE_DIR/git/gitignore"
VIM_DIR="$BASE_DIR/vim"

FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/Brewfile"
    "$GIT_IGNORE_FILE"
)

read -p "Do you want to install Dotfiles? (yes/no): " install_dotfiles
read -p "Do you want to install Homebrew? (yes/no): " install_homebrew
read -p "Do you want to config MacOS defaults? (yes/no): " install_macos_defaults

if [[ "$install_dotfiles" == "yes" ]]; then
    config_dotfiles
    config_vim
fi

if [[ "$install_homebrew" == "yes" ]]; then
    config_homebrew
fi

if [[ "$install_macos_defaults" == "yes" ]]; then
    read -p "Enter desired hostname: " hostname
    config_macos_defaults $hostname
fi