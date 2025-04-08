function execute_scripts() {
    local scripts_dir="$DOTFILES/scripts"
    log_section "Executing scripts from $scripts_dir"

    if [ -d "$scripts_dir" ]; then
        for script in "$scripts_dir"/*.sh; do
            if [ -f "$script" ]; then
                log_info "Making script executable: $(basename "$script")"
                chmod +x "$script"

                log_info "Executing script: $(basename "$script")"
                bash "$script"
            fi
        done
    else
        log_warn "Scripts directory not found: $scripts_dir"
    fi
}

function config_dotfiles() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_root="$HOME/.dotfiles_backups"
    local backup_dir="$backup_root/backup_$timestamp"

    # Create backup directories
    mkdir -p "$backup_dir" "$ZSH_CUSTOM_DIR"

    # Function to safely backup a file
    backup_file() {
        local file="$1"
        local backup_path="$2"
        if [ -e "$file" ]; then
            if [ ! -L "$file" ]; then  # Don't backup symlinks
                log_info "Backing up $file to $backup_path"
                cp -a "$file" "$backup_path/"
            fi
            # Remove the original file or symlink after backup
            rm "$file"
            log_info "Removed existing file/symlink: $file"
        fi
    }

    # Function to safely create symlink
    create_symlink() {
        local source="$1"
        local target="$2"
        if [ -f "$source" ]; then
            log_info "Creating symlink: $target -> $source"
            ln -sf "$source" "$target"
        else
            log_warn "Source file not found: $source"
        fi
    }

    # Backup existing files
    log_section "Backing up existing files"
    for file in "${FILES_TO_BACKUP[@]}"; do
        backup_file "$file" "$backup_dir"
    done

    # Create symlinks for dotfiles
    log_section "Creating dotfile symlinks"
    for file in "$DOTS_DIR"/* "$DOTS_DIR"/.*; do
        case "$(basename "$file")" in
            .|..|.git|.DS_Store|dots) continue ;;
            *) create_symlink "$file" "$HOME/$(basename "$file")" ;;
        esac
    done

    # Create symlinks for zsh custom files
    log_section "Creating Zsh custom symlinks"
    for file in "$ZSH_DIR"/* "$ZSH_DIR"/.*; do
        case "$(basename "$file")" in
            .|..) continue ;;
            *) create_symlink "$file" "$ZSH_CUSTOM_DIR/$(basename "$file")" ;;
        esac
    done

    # Setup Git configuration
    log_section "Setting up Git configuration"

    # Setup gitconfig
    log_info "Setting up gitconfig..."
    backup_file "$HOME/.gitconfig" "$backup_dir"
    if [ -f "$DOTS_DIR/.gitconfig" ]; then
        create_symlink "$DOTS_DIR/.gitconfig" "$HOME/.gitconfig"
    else
        log_warn "gitconfig not found at $DOTS_DIR/.gitconfig"
    fi

    # Setup gitignore_global
    log_info "Setting up gitignore_global..."
    backup_file "$HOME/.gitignore_global" "$backup_dir"
    if [ -f "$DOTS_DIR/.gitignore_global" ]; then
        create_symlink "$DOTS_DIR/.gitignore_global" "$HOME/.gitignore_global"
    else
        log_warn "gitignore_global not found at $DOTS_DIR/.gitignore_global"
    fi

    # Setup git commit message template
    log_info "Setting up git commit message template..."
    mkdir -p "$HOME/.config/git"
    backup_file "$HOME/.config/git/message" "$backup_dir"
    if [ -f "$GIT_DIR/message" ]; then
        create_symlink "$GIT_DIR/message" "$HOME/.config/git/message"
    else
        log_warn "Git message template not found at $GIT_DIR/message"
    fi

    # Verify the symlinks were created
    log_info "Verifying git configuration..."
    [ -L "$HOME/.gitconfig" ] && log_success "gitconfig symlink created" || log_error "gitconfig symlink missing"
    [ -L "$HOME/.gitignore_global" ] && log_success "gitignore_global symlink created" || log_error "gitignore_global symlink missing"

    # Cleanup old backups (keep last 5)
    log_section "Cleaning up old backups"
    ls -1dt "$backup_root"/backup_* 2>/dev/null | tail -n +6 | xargs -r rm -rf

    setup_config_dirs
    setup_ssh
    setup_bin_directory
    execute_scripts

    log_success "Dotfiles configuration completed successfully"
}

# Keep this one as it's the newer neovim setup
function config_nvim(){
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    mkdir -p ~/.config/nvim
    ln -s $DOTS_DIR/init.vim ~/.config/nvim/init.vim
}

function install_node(){
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
}

function setup_ssh() {
    log_section "Setting up SSH configuration"

    # Create SSH directory with correct permissions
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Backup existing SSH config
    backup_file "$HOME/.ssh/config" "$backup_dir"

    # Create symlink for SSH config
    if [ -f "$DOTS_DIR/.ssh/config" ]; then
        create_symlink "$DOTS_DIR/.ssh/config" "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
        log_success "SSH config symlink created"
    else
        log_warn "SSH config not found at $DOTS_DIR/.ssh/config"
    fi
}

function setup_config_dirs() {
    log_section "Setting up .config directory structure"

    # Create base .config directory
    mkdir -p "$HOME/.config"

    # Array of config directories to create and sync
    local config_dirs=(
        "git"
        "nvim"
        "starship"
        "kitty"
        "bat"
        "htop"
    )

    # Create directories and symlinks
    for dir in "${config_dirs[@]}"; do
        if [ -d "$DOTS_DIR/.config/$dir" ]; then
            # Backup existing config
            if [ -d "$HOME/.config/$dir" ]; then
                backup_file "$HOME/.config/$dir" "$backup_dir"
            fi

            # Create symlink for entire directory
            log_info "Setting up $dir configuration..."
            ln -sf "$DOTS_DIR/.config/$dir" "$HOME/.config/$dir"
            log_success "$dir configuration linked"
        fi
    done

    # Handle individual config files
    local config_files=(
        "starship.toml"
        "bat/config"
        "git/message"
    )

    for file in "${config_files[@]}"; do
        local dir=$(dirname "$file")
        mkdir -p "$HOME/.config/$dir"

        if [ -f "$DOTS_DIR/.config/$file" ]; then
            backup_file "$HOME/.config/$file" "$backup_dir"
            create_symlink "$DOTS_DIR/.config/$file" "$HOME/.config/$file"
        fi
    done
}

function setup_bin_directory() {
    log_section "Setting up bin directory"

    # Create bin directory if it doesn't exist
    mkdir -p "$HOME/bin"

    # Copy all files from dotfiles bin directory to home bin
    if [ -d "$DOTFILES/bin" ]; then
        log_info "Copying bin files..."
        for file in "$DOTFILES/bin"/*; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file")
                cp -f "$file" "$HOME/bin/$filename"
                chmod +x "$HOME/bin/$filename"
                log_success "Installed: $filename"
            fi
        done
    else
        log_warn "Bin directory not found at $DOTFILES/bin"
    fi
}