#!/usr/bin/env bash
set -euo pipefail

: "${BASE_DIR:?BASE_DIR env var must be set before loading config_dotfiles.sh}"
: "${DOTS_DIR:=$BASE_DIR/config/home}"
: "${ZSH_DIR:=$BASE_DIR/config/shell/zsh_custom}"
: "${ZSH_CUSTOM_DIR:=$HOME/zsh_custom}"
: "${GIT_DIR:=$BASE_DIR/config/git}"
: "${BREW_DIR:=$BASE_DIR/config/brew}"

# -----------------------------
# Helper utilities
# -----------------------------

dotfiles_backup_item() {
    local path="$1"
    local backup_dir="$2"

    [[ -n "${path:-}" && -n "${backup_dir:-}" ]] || return 0
    if [[ ! -e "$path" && ! -L "$path" ]]; then
        return 0
    fi

    mkdir -p "$backup_dir"

    if [[ ! -L "$path" ]]; then
        log_info "Backing up $path -> $backup_dir"
        cp -a "$path" "$backup_dir"/
    else
        log_info "Skipping backup for symlink $path"
    fi

    rm -rf "$path"
    log_info "Removed existing path: $path"
}

dotfiles_create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        log_warn "Source not found, skipping symlink: $source"
        return 1
    fi

    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
    log_info "Linked $target -> $source"
}

dotfiles_cleanup_old_backups() {
    local backup_root="$1"
    local keep="${2:-5}"

    [[ -d "$backup_root" ]] || return 0

    mapfile -t backups < <(ls -1dt "$backup_root"/backup_* 2>/dev/null || true)
    if (( ${#backups[@]} > keep )); then
        for old in "${backups[@]:keep}"; do
            rm -rf "$old"
            log_info "Removed old backup: $old"
        done
    fi
}

dotfiles_run_script() {
    local script="$1"
    local name
    name="$(basename "$script")"

    log_info "Running: $name"
    if bash "$script"; then
        log_success "Completed: $name"
        return 0
    else
        log_warn "Script failed: $name"
        return 1
    fi
}

# -----------------------------
# Main entry points
# -----------------------------

execute_scripts() {
    local scripts_dir="$BASE_DIR/scripts"
    log_section "EXECUTING SCRIPTS FROM $scripts_dir"

    if [[ ! -d "$scripts_dir" ]]; then
        log_warn "Scripts directory not found: $scripts_dir"
        return 0
    fi

    local script failures=0
    for script in "$scripts_dir"/*.sh; do
        [[ -f "$script" ]] || continue

        local script_name
        script_name="$(basename "$script")"
        case "$script_name" in
            install_vim_plugins.sh|install_vim_themes.sh)
                log_info "Skipping legacy Vim helper: $script_name (Neovim handles plugins now)"
                continue
                ;;
        esac

        chmod +x "$script"
        if ! dotfiles_run_script "$script"; then
            ((failures++))
        fi
    done

    if ((failures > 0)); then
        log_warn "$failures script(s) exited with errors"
    fi
}

config_dotfiles() {
    local install_fonts=false
    while (($# > 0)); do
        case "$1" in
            --fonts) install_fonts=true ;;
            --no-fonts) install_fonts=false ;;
            *)
                log_warn "Unknown option for config_dotfiles: $1"
                ;;
        esac
        shift
    done

    local timestamp backup_root backup_dir
    timestamp="$(date +"%Y%m%d_%H%M%S")"
    backup_root="$HOME/.dotfiles_backups"
    backup_dir="$backup_root/backup_$timestamp"

    mkdir -p "$backup_dir" "$ZSH_CUSTOM_DIR" "$HOME/.local/state/zsh"

    log_section "PERFORMING BACKUP"
    if [[ ${FILES_TO_BACKUP+x} ]]; then
        local item
        for item in "${FILES_TO_BACKUP[@]}"; do
            dotfiles_backup_item "$item" "$backup_dir"
        done
    else
        log_warn "FILES_TO_BACKUP not defined; skipping default backup list"
    fi

    log_section "CREATING DOTFILES SYMLINKS"
    if [[ -d "$DOTS_DIR" ]]; then
        local entry name
        for entry in "$DOTS_DIR"/.*; do
            [[ -e "$entry" || -L "$entry" ]] || continue
            name="$(basename "$entry")"
            case "$name" in
                .|..|.git|.DS_Store) continue ;;
            esac
            dotfiles_create_symlink "$entry" "$HOME/$name"
        done
    else
        log_warn "Dots directory not found: $DOTS_DIR"
    fi

    log_section "CREATING ZSH SYMLINKS"
    if [[ -d "$ZSH_DIR" ]]; then
        local zsh_entry zsh_name
        for zsh_entry in "$ZSH_DIR"/* "$ZSH_DIR"/.*; do
            [[ -e "$zsh_entry" || -L "$zsh_entry" ]] || continue
            zsh_name="$(basename "$zsh_entry")"
            case "$zsh_name" in
                .|..) continue ;;
            esac
            dotfiles_create_symlink "$zsh_entry" "$ZSH_CUSTOM_DIR/$zsh_name"
        done
    else
        log_warn "Zsh custom directory not found: $ZSH_DIR"
    fi

    log_section "GIT"
    dotfiles_backup_item "$HOME/.gitconfig" "$backup_dir"
    if [[ -f "$DOTS_DIR/.gitconfig" ]]; then
        dotfiles_create_symlink "$DOTS_DIR/.gitconfig" "$HOME/.gitconfig"
    else
        log_warn "gitconfig not found at $DOTS_DIR/.gitconfig"
    fi

    dotfiles_backup_item "$HOME/.gitignore_global" "$backup_dir"
    if [[ -f "$DOTS_DIR/.gitignore_global" ]]; then
        dotfiles_create_symlink "$DOTS_DIR/.gitignore_global" "$HOME/.gitignore_global"
    else
        log_warn "gitignore_global not found at $DOTS_DIR/.gitignore_global"
    fi

    mkdir -p "$HOME/.config/git"
    dotfiles_backup_item "$HOME/.config/git/message" "$backup_dir"
    if [[ -f "$GIT_DIR/message" ]]; then
        dotfiles_create_symlink "$GIT_DIR/message" "$HOME/.config/git/message"
    else
        log_warn "Git message template not found at $GIT_DIR/message"
    fi

    mkdir -p "$HOME/.gnupg"
    if ! grep -qF "pinentry-program /opt/homebrew/bin/pinentry-mac" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
        echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
    fi

    dotfiles_cleanup_old_backups "$backup_root"

    setup_config_dirs "$backup_dir"
    setup_ssh "$backup_dir"
    setup_bin_directory

    if [[ -f "$BREW_DIR/Brewfile" ]]; then
        log_section "BREWFILE"
        dotfiles_backup_item "$HOME/Brewfile" "$backup_dir"
        dotfiles_create_symlink "$BREW_DIR/Brewfile" "$HOME/Brewfile"
    fi

    execute_scripts
    config_nvim

    if $install_fonts; then
        config_fonts || log_warn "Font installation encountered problems"
    fi

    config_themes

    log_success "Dotfiles configuration completed successfully"
}

config_nvim() {
    log_section "NEOVIM"

    if ! command -v nvim >/dev/null 2>&1; then
        log_warn "Neovim not installed, skipping Neovim configuration"
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        log_warn "curl not available; unable to bootstrap vim-plug"
        return 1
    fi

    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    local nvim_plug_file="$nvim_data_dir/site/autoload/plug.vim"

    if [[ -d "$nvim_config_dir" || -L "$nvim_config_dir" ]]; then
        local backup_target="$nvim_config_dir.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing Neovim configuration to $backup_target"
        mv "$nvim_config_dir" "$backup_target"
    fi

    mkdir -p "$nvim_config_dir" "$nvim_data_dir/plugged" "$nvim_data_dir/site/autoload"

    if [[ ! -f "$nvim_plug_file" ]]; then
        log_info "Installing vim-plug"
        curl -fLo "$nvim_plug_file" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    if [[ -f "$DOTS_DIR/.config/nvim/init.vim" ]]; then
        dotfiles_create_symlink "$DOTS_DIR/.config/nvim/init.vim" "$nvim_config_dir/init.vim"
    else
        log_error "init.vim not found in dotfiles"
        return 1
    fi

    log_info "Installing Neovim plugins"
    local old_git_dir="${GIT_DIR-}"
    unset GIT_DIR
    if nvim --headless +"PlugInstall --sync" +qa; then
        log_success "Neovim plugins installed"
    else
        log_warn "Neovim plugin installation encountered an error; open Neovim and run :PlugInstall manually for details"
    fi
    if [[ -n "${old_git_dir:-}" ]]; then
        export GIT_DIR="$old_git_dir"
    else
        unset GIT_DIR
    fi
}

config_themes() {
    log_section "THEMES"

    local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d "$theme_dir/.git" ]]; then
        log_info "Updating Powerlevel10k theme"
        git -C "$theme_dir" pull --ff-only >/dev/null || log_warn "Unable to update Powerlevel10k theme"
    else
        log_info "Cloning Powerlevel10k theme"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
    fi
}

config_fonts() {
    log_section "FONTS"

    local source_dir="$BASE_DIR/assets/fonts"
    local target_dir="/Library/Fonts"

    if [[ ! -d "$source_dir" ]]; then
        log_warn "Fonts directory not found at $source_dir, skipping font installation"
        return 0
    fi

    local copier_command=()
    if command -v rsync >/dev/null 2>&1; then
        copier_command=(rsync -a)
    else
        copier_command=(cp -a)
    fi

    local runner=()
    if [[ ! -w "$target_dir" ]]; then
        if command -v sudo >/dev/null 2>&1; then
            runner=(sudo)
        else
            log_error "Cannot write to $target_dir and sudo is unavailable"
            return 1
        fi
    fi

    log_info "Copying fonts from $source_dir to $target_dir"
    if "${runner[@]}" "${copier_command[@]}" "$source_dir/." "$target_dir/"; then
        log_success "Fonts installed to $target_dir"
    else
        log_error "Failed to copy fonts to $target_dir"
        return 1
    fi
}

install_node() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
}

setup_ssh() {
    local backup_dir="$1"
    log_section "SSH"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    mkdir -p "$HOME/.ssh/sockets"
    chmod 700 "$HOME/.ssh/sockets"

    dotfiles_backup_item "$HOME/.ssh/config" "$backup_dir"

    if [[ -f "$DOTS_DIR/.ssh/config" ]]; then
        dotfiles_create_symlink "$DOTS_DIR/.ssh/config" "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
    else
        log_warn "SSH config not found at $DOTS_DIR/.ssh/config"
    fi
}

setup_config_dirs() {
    local backup_dir="$1"
    log_section ".config CONFIGURATION"

    mkdir -p "$HOME/.config"

    local config_dirs=(
        git
        nvim
        starship
        kitty
        bat
        htop
    )

    local dir
    for dir in "${config_dirs[@]}"; do
        if [[ -d "$DOTS_DIR/.config/$dir" ]]; then
            dotfiles_backup_item "$HOME/.config/$dir" "$backup_dir"
            dotfiles_create_symlink "$DOTS_DIR/.config/$dir" "$HOME/.config/$dir"
        fi
    done

    local config_files=(
        starship.toml
        bat/config
    )

    local file
    for file in "${config_files[@]}"; do
        if [[ -f "$DOTS_DIR/.config/$file" ]]; then
            dotfiles_backup_item "$HOME/.config/$file" "$backup_dir"
            dotfiles_create_symlink "$DOTS_DIR/.config/$file" "$HOME/.config/$file"
        fi
    done
}

setup_bin_directory() {
    log_section "BIN DIRECTORY"

    mkdir -p "$HOME/bin"

    if [[ ! -d "$BASE_DIR/bin" ]]; then
        log_warn "Bin directory not found at $BASE_DIR/bin"
        return 0
    fi

    if command -v rsync >/dev/null 2>&1; then
        rsync -a "$BASE_DIR/bin/" "$HOME/bin/"
    else
        cp -a "$BASE_DIR/bin/." "$HOME/bin/"
    fi

    log_success "Updated $HOME/bin from $BASE_DIR/bin"
}
