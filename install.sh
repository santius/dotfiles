#!/bin/bash

source logger.sh

BASE_DIR="$HOME/dev/dotfiles"
DOTS_DIR="$BASE_DIR/dots"
ZSH_DIR="$BASE_DIR/zsh_custom"
BACKUP_DIR="$HOME/.dotfiles_backup"
ZSH_CUSTOM_DIR="$HOME/zsh_custom"
GIT_IGNORE_FILE="$BASE_DIR/git/gitignore"

FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/Brewfile"
    "$GIT_IGNORE_FILE"
)

rm -rf $BACKUP_DIR
mkdir -p "$BACKUP_DIR" "$ZSH_CUSTOM_DIR"

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$file" ]; then
        log_info "Backing up $file to $BACKUP_DIR"
        mv -n "$file" "$BACKUP_DIR"
    fi
done

read -p "Do you want to install Homebrew? (yes/no): " install_homebrew
read -p "Do you want to install Dotfiles? (yes/no): " install_dotfiles
read -p "Do you want to config MacOS defaults? (yes/no): " install_macos_defaults

function config_dotfiles(){
  for file in "$DOTS_DIR"/* "$DOTS_DIR"/.*; do
    if [ "$file" == "$DOTS_DIR/." ] || [ "$file" == "$DOTS_DIR/.." ] || [ "$file" == "$DOTS_DIR/dots" ]; then
      continue
    fi
    if [ -f "$file" ]; then
      log_info "File is $file"
      ln -s $file $HOME
    fi
  done
  for file in "$ZSH_DIR"/* "$ZSH_DIR"/.*; do
    if [ "$file" == "$ZSH_DIR/." ] || [ "$file" == "$ZSH_DIR/.." ] ; then
      continue
    fi
    if [ -f "$file" ]; then
      log_info "File is $file"
      ln -s $file $ZSH_CUSTOM_DIR
    fi
  done
  if [ -e "$HOME/.config/git/gitignore" ]; then
    rm "$HOME/.config/git/gitignore"
    log_info "Removed existing gitignore."
  fi
  ln -s "$GIT_IGNORE_FILE" "$HOME/.config/git/gitignore"
  log_info "Created symlink for gitignore."
}

function config_homebrew(){
  if ! command -v brew &> /dev/null; then
      log_info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
      log_info "Homebrew is already installed."
  fi
  echo "Base dir is $BASE_DIR/Brewfile"
  ln -s $HOME/Brewfile $BASE_DIR/Brewfile
  brew bundle --file=$HOME/Brewfile
}

function config_macos_defaults(){
  source "$BASE_DIR/set-defaults.sh" $1
}

if [[ "$install_homebrew" == "yes" ]]; then
    config_homebrew
fi

if [[ "$install_dotfiles" == "yes" ]]; then
    config_dotfiles
fi

if [[ "$install_macos_defaults" == "yes" ]]; then
    read -p "Enter desired hostname: " hostname
    config_macos_defaults $hostname
fi