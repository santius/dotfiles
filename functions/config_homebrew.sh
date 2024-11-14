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