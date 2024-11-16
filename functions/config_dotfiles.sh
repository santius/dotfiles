function config_dotfiles(){
  timestamp=$(date +"%Y%m%d_%H%M%S")
  mv $BACKUP_DIR ~/dotfiles_backup_$timestamp
  mv $ZSH_CUSTOM_DIR "$ZSH_CUSTOM_DIR_$timestamp"
  mkdir -p "$BACKUP_DIR" "$ZSH_CUSTOM_DIR"

  for file in "${FILES_TO_BACKUP[@]}"; do
      if [ -e "$file" ]; then
          log_info "Backing up $file to $BACKUP_DIR"
          mv -n "$file" "$BACKUP_DIR"
      fi
  done

  for file in "$DOTS_DIR"/* "$DOTS_DIR"/.*; do
    if [ "$file" == "$DOTS_DIR/." ] || [ "$file" == "$DOTS_DIR/.." ] || [ "$file" == "$DOTS_DIR/dots" ]; then
      continue
    fi
    if [ -f "$file" ]; then
      log_info "Created $file in $HOME"
      ln -sf $file $HOME
    fi
  done
  for file in "$ZSH_DIR"/* "$ZSH_DIR"/.*; do
    if [ "$file" == "$ZSH_DIR/." ] || [ "$file" == "$ZSH_DIR/.." ] ; then
      continue
    fi
    if [ -f "$file" ]; then
      log_info "File is $file"
      ln -sf $file $ZSH_CUSTOM_DIR
    fi
  done
  if [ -e "$HOME/.config/git/gitignore" ]; then
    rm "$HOME/.config/git/gitignore"
    log_info "Removed existing gitignore."
  fi
  ln -sf "$GIT_IGNORE_FILE" "$HOME/.config/git/gitignore"
  log_info "Created symlink for gitignore."
}

function config_vim(){
    mkdir -p ~/.vim/colors ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    ln -sf  $VIM_DIR/colors/solarized.vim ~/.vim/bundle/solarized.vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

}