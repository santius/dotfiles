function execute_scripts() {
    local scripts_dir="$DOTFILES/scripts"
    log_section "EXECUTING SCRIPTS FROM $scripts_dir"
    
    if [ -d "$scripts_dir" ]; then
        for script in "$scripts_dir"/*.sh; do
            if [ -f "$script" ]; then
                log_info "Making script executable: $(basename "$script")"
                chmod +x "$script"
                
                log_info "Running: $(basename "$script")"
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
        # Allow creating symlinks for files or directories
        if [ -e "$source" ]; then
            log_info "Creating symlink: $target -> $source"
            ln -sf "$source" "$target"
        else
            log_warn "Source file not found: $source"
        fi
    }
    
    # Backup existing files
    log_section "PERFORMING BACKUP"
    for file in "${FILES_TO_BACKUP[@]}"; do
        backup_file "$file" "$backup_dir"
    done
    
    # Create symlinks for dotfiles
    log_section "CREATING DOTFILES SYMLINKS"
    if [ -d "$DOTS_DIR" ]; then
        for file in "$DOTS_DIR"/.*; do
            case "$(basename "$file")" in
                .|..|.git|.DS_Store|dots) continue ;;
                *) create_symlink "$file" "$HOME/$(basename "$file")" ;;
            esac
        done
    else
        log_warn "Dots directory not found: $DOTS_DIR"
    fi
    
    # Create symlinks for zsh custom files
    log_section "CREATING ZSH SYMLINKS"
    for file in "$ZSH_DIR"/* "$ZSH_DIR"/.*; do
        case "$(basename "$file")" in
            .|..) continue ;;
            *) create_symlink "$file" "$ZSH_CUSTOM_DIR/$(basename "$file")" ;;
        esac
    done
    
    # Setup Git configuration
    log_section "GIT"
    
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
    
    # Setup gpg-agent configuration
    log_info "Setting up gpg-agent configuration..."
    mkdir -p ~/.gnupg
    grep -qF "pinentry-program /opt/homebrew/bin/pinentry-mac" ~/.gnupg/gpg-agent.conf 2>/dev/null || \
    echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
    
    # Verify the symlinks were created
    log_info "Verifying git configuration..."
    [ -L "$HOME/.gitconfig" ] && log_success "gitconfig symlink created" || log_error "gitconfig symlink missing"
    [ -L "$HOME/.gitignore_global" ] && log_success "gitignore_global symlink created" || log_error "gitignore_global symlink missing"
    

    ls -1dt "$backup_root"/backup_* 2>/dev/null | tail -n +6 | xargs -r rm -rf
    
    setup_config_dirs
    setup_ssh
    setup_bin_directory
    execute_scripts
    config_nvim
    
    log_success "Dotfiles configuration completed successfully"
}

# Keep this one as it's the newer neovim setup
function config_nvim() {
    log_section "NEOVIM"
    
    # Define directories
    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    local nvim_plug_file="$nvim_data_dir/site/autoload/plug.vim"
    
    # Backup existing configuration if it exists
    if [ -d "$nvim_config_dir" ]; then
        log_info "Backing up existing Neovim configuration"
        mv "$nvim_config_dir" "$nvim_config_dir.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create necessary directories
    log_info "Creating Neovim directories"
    mkdir -p "$nvim_config_dir"
    mkdir -p "$nvim_data_dir/plugged"
    mkdir -p "$nvim_data_dir/site/autoload"
    
    # Install vim-plug if not already installed
    if [ ! -f "$nvim_plug_file" ]; then
        log_info "Installing vim-plug"
        curl -fLo "$nvim_plug_file" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    # Create symlink for init.vim
    if [ -f "$DOTS_DIR/.config/nvim/init.vim" ]; then
        log_info "Creating symlink for init.vim"
        ln -sf "$DOTS_DIR/.config/nvim/init.vim" "$nvim_config_dir/init.vim"
    else
        log_error "init.vim not found in dotfiles"
        return 1
    fi
    
    # Install plugins
    log_info "Installing Neovim plugins"
    nvim --headless +PlugInstall +qall
    
    log_success "Neovim configuration completed"
}

function install_node(){
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
}

function setup_ssh() {
    log_section "SSH"
    
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
    log_section ".config CONFIGURATION"
    
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
    log_section "BIN DIRECTORY"
    
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
