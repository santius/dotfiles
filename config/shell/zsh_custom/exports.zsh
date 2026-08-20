# Dotfiles exports: fast, defensive, and organised

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

_export_if_unset() {
    local key="$1" value="$2"
    [[ -z "${(P)key:-}" ]] && export "$key=$value"
}

# Ensure secrets load first (keeps overrides intact).
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

# Neutralize inherited globals that commonly break app runtimes.
for _leaky_var in NODE_ENV NODE_TLS_REJECT_UNAUTHORIZED SSL_CERT_DIR MAKEFLAGS ARCHFLAGS LC_ALL; do
    [[ -n "${(P)_leaky_var:-}" ]] && unset "$_leaky_var"
done
unset _leaky_var

# --------------------------------------------------------------------------
# Directories & Paths
# --------------------------------------------------------------------------

typeset -gx ZSH="${ZSH:-$HOME/.oh-my-zsh}"
typeset -gx ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/zsh_custom}"
typeset -gx DOWNLOADS="$HOME/Downloads"
typeset -gx DESKTOP="$HOME/Desktop"
typeset -gx DOCUMENTS="$HOME/Documents"
typeset -gx PICTURES="$HOME/Pictures"
typeset -gx MOVIES="$HOME/Movies"
typeset -gx MUSIC="$HOME/Music"
typeset -gx PUBLIC="$HOME/Public"
typeset -gx DEV="${DEV:-$HOME/dev}"

_export_if_unset XDG_CONFIG_HOME "$HOME/.config"
_export_if_unset XDG_CACHE_HOME "$HOME/.cache"
_export_if_unset XDG_DATA_HOME "$HOME/.local/share"
_export_if_unset XDG_STATE_HOME "$HOME/.local/state"

# --------------------------------------------------------------------------
# Locale & Terminal
# --------------------------------------------------------------------------

_export_if_unset LANG 'en_US.UTF-8'
_export_if_unset PYTHONIOENCODING 'UTF-8'

_export_if_unset EDITOR 'nvim'
_export_if_unset VISUAL 'code -w'
_export_if_unset PAGER 'less'
_export_if_unset MANPAGER 'less -X'
_export_if_unset LESS '-F -g -i -M -R -S -w -X -z-4'
_export_if_unset LESSHISTFILE '-'
_export_if_unset CLICOLOR '1'

_export_if_unset LSCOLORS 'ExFxBxDxCxegedabagacad'
_export_if_unset LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Coloured man pages.
_export_if_unset LESS_TERMCAP_mb $'\E[1;31m'
_export_if_unset LESS_TERMCAP_md $'\E[1;36m'
_export_if_unset LESS_TERMCAP_me $'\E[0m'
_export_if_unset LESS_TERMCAP_so $'\E[01;44;33m'
_export_if_unset LESS_TERMCAP_se $'\E[0m'
_export_if_unset LESS_TERMCAP_us $'\E[1;32m'
_export_if_unset LESS_TERMCAP_ue $'\E[0m'

# --------------------------------------------------------------------------
# Security & Signing
# --------------------------------------------------------------------------

_export_if_unset GNUPGHOME "$HOME/.gnupg"
if [[ -t 0 ]]; then
    _export_if_unset GPG_TTY "$(tty)"
fi

# --------------------------------------------------------------------------
# Mobile tools Android and iOS
# --------------------------------------------------------------------------

_export_if_unset ANDROID_HOME "$HOME/Library/Android/sdk"

# --------------------------------------------------------------------------
# Development runtimes
# --------------------------------------------------------------------------

### Node.js
# Avoid exporting NODE_ENV globally; set it per-project when starting apps.
# Example: NODE_ENV=development npm run dev
_export_if_unset NVM_DIR "$HOME/.nvm"

load-nvm() {
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" --no-use
}
node() { load-nvm; command node "$@"; }
npm()  { load-nvm; command npm  "$@"; }
npx()  { load-nvm; command npx  "$@"; }

### Python
_export_if_unset PYENV_ROOT "$HOME/.pyenv"
_export_if_unset PYTHONDONTWRITEBYTECODE '1'
_export_if_unset PIPENV_VENV_IN_PROJECT '1'

### Java (cache expensive java_home)
if [[ -z "${JAVA_HOME:-}" && -x /usr/libexec/java_home ]]; then
    typeset _java_cache="${XDG_CACHE_HOME:-$HOME/.cache}/java_home"
    if [[ -f "$_java_cache" ]]; then
        export JAVA_HOME="$(<"$_java_cache")"
    else
        typeset _java_home
        _java_home="$(/usr/libexec/java_home 2>/dev/null)"
        if [[ -n "$_java_home" ]]; then
            export JAVA_HOME="$_java_home"
            mkdir -p "${_java_cache:h}"
            printf '%s\n' "$JAVA_HOME" >"$_java_cache"
        fi
    fi
    unset _java_cache _java_home
elif [[ -n "${JAVA_HOME:-}" ]]; then
    export JAVA_HOME
fi

### Golang (export only when Go present)
if command -v go >/dev/null 2>&1; then
    _export_if_unset GOPATH "$HOME/go"
    _export_if_unset GOBIN "$GOPATH/bin"
fi

### Docker
_export_if_unset DOCKER_BUILDKIT '1'
_export_if_unset COMPOSE_DOCKER_CLI_BUILD '1'

# --------------------------------------------------------------------------
# Tooling defaults
# --------------------------------------------------------------------------

# Use fd instead of fzf
if command -v fd >/dev/null 2>&1; then
    _export_if_unset FZF_DEFAULT_COMMAND 'fd --hidden --strip-cwd-prefix --exclude .git'
    _export_if_unset FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    _export_if_unset FZF_ALT_C_COMMAND 'fd --type=d --hidden --strip-cwd-prefix --exclude .git'
fi
_export_if_unset FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --info=inline'

if [[ -f "$HOME/.ripgreprc" ]]; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
else
    unset RIPGREP_CONFIG_PATH
fi


# --------------------------------------------------------------------------
# Package managers
# --------------------------------------------------------------------------

_export_if_unset HOMEBREW_NO_ANALYTICS '1'
_export_if_unset HOMEBREW_NO_AUTO_UPDATE '1'
_export_if_unset HOMEBREW_AUTO_UPDATE_SECS '86400'
_export_if_unset HOMEBREW_NO_ENV_HINTS '1'
_export_if_unset HOMEBREW_NO_INSECURE_REDIRECT '1'
_export_if_unset HOMEBREW_NO_INSTALL_CLEANUP '1'
_export_if_unset HOMEBREW_DISPLAY_INSTALL_TIMES '1'
_export_if_unset HOMEBREW_NO_EMOJI '1'
_export_if_unset HOMEBREW_FORCE_BREWED_CURL '1'
_export_if_unset HOMEBREW_COLOR '1'
_export_if_unset HOMEBREW_BAT '1'
_export_if_unset HOMEBREW_CASK_OPTS '--appdir=/Applications --fontdir=/Library/Fonts'
_export_if_unset HOMEBREW_EDITOR 'cursor'
[[ -n "${GITHUB_TOKEN:-}" ]] && export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_TOKEN"

_export_if_unset ASDF_CONFIG_FILE "$XDG_CONFIG_HOME/asdf/asdfrc"
_export_if_unset ASDF_DATA_DIR "$HOME/.asdf"

# --------------------------------------------------------------------------
# Security & networking defaults
# --------------------------------------------------------------------------

_export_if_unset CURL_SSL_VERIFY 'true'
