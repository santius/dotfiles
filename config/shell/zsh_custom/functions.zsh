# zsh utility functions — fast, composable helpers

autoload -Uz colors && colors

# ---------------------------------------------------------------------------
# Guard helpers
# ---------------------------------------------------------------------------

function_exists() { typeset -f "$1" >/dev/null 2>&1 }

ensure_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$cmd" >&2
        return 1
    fi
}

# ---------------------------------------------------------------------------
# History helpers
# ---------------------------------------------------------------------------

unalias h 2>/dev/null

h() {
    local entry_limit="" date_filter="" search_term="" opt

    while [[ $# -gt 0 ]]; do
        opt="$1"
        case "$opt" in
            -h|--help)
                cat <<'EOF'
Usage: h [options] [pattern]
Options:
  -n NUM     Show last NUM entries
  -d DATE    Filter by date (YYYY-MM-DD)
  -t         Show entries from today
  -h, --help Show this help
Examples:
  h                 Show all history with timestamps
  h -n 20           Show last 20 commands
  h -d 2025-03-21   Show commands executed on 21 Mar 2025
  h git             Search history for "git"
EOF
                return
                ;;
            -n)
                shift
                [[ $# -gt 0 ]] || { echo "Missing number for -n" >&2; return 1; }
                entry_limit="-$1"
                ;;
            -d)
                shift
                [[ $# -gt 0 ]] || { echo "Missing date for -d" >&2; return 1; }
                date_filter=$(date -j -f %Y-%m-%d "$1" +%Y-%m-%d 2>/dev/null) || {
                    echo "Invalid date format. Use YYYY-MM-DD" >&2
                    return 1
                }
                ;;
            -t)
                date_filter=$(date +%Y-%m-%d)
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "Unknown option: $opt" >&2
                return 1
                ;;
            *)
                search_term="$opt"
                ;;
        esac
        shift
    done

    local cmd="fc -l -t '%Y-%m-%d %H:%M'"
    [[ -n $entry_limit ]] && cmd+=" $entry_limit"
    [[ -z $entry_limit ]] && cmd+=' 1'

    ensure_command fc || return 1

    eval "$cmd" | while read -r num timestamp rest; do
        if [[ -n $date_filter && $timestamp != $date_filter* ]]; then
            continue
        fi
        if [[ -z $search_term ]]; then
            printf '%s%s%s  %s%s%s  %s%s%s\n' \
                "$fg[green]" "$num" "$reset_color" \
                "$fg[blue]" "$timestamp" "$reset_color" \
                "$fg[yellow]" "$rest" "$reset_color"
        else
            printf '%s\n' "$num $timestamp $rest"
        fi
    done | {
        if [[ -n $search_term ]]; then
            command grep --color=always -i -- "$search_term"
        else
            cat
        fi
    }
}

# ---------------------------------------------------------------------------
# Git shortcuts
# ---------------------------------------------------------------------------

groot() {
    ensure_command git || return 1
    git rev-parse --show-toplevel 2>/dev/null || {
        echo "Not inside a git repository" >&2
        return 1
    }
}

gopen() {
    local repo
    repo="$(groot 2>/dev/null)" || return 1
    open "$repo"
}

gclean-worktree() {
    ensure_command git || return 1
    git clean -fdx && git reset --hard
}

# ---------------------------------------------------------------------------
# Navigation helpers
# ---------------------------------------------------------------------------

cdf() {
    ensure_command fzf || return 1
    local dir
    dir=$(find . -type d -maxdepth 5 2>/dev/null | fzf --height 40% --reverse)
    [[ -n $dir ]] && cd "$dir"
}

cdfav() {
    local favorites=("$HOME/dev" "$HOME/Desktop" "$HOME")
    ensure_command fzf || return 1
    local dir
    dir=$(printf '%s\n' "${favorites[@]}" | fzf --height 20% --reverse)
    [[ -n $dir ]] && cd "$dir"
}

# ---------------------------------------------------------------------------
# Misc utilities
# ---------------------------------------------------------------------------

take_screenshot() {
    local dest="${1:-$HOME/Desktop}" name timestamp
    ensure_command screencapture || return 1
    mkdir -p "$dest"
    timestamp=$(date +%Y%m%d-%H%M%S)
    name="$dest/Screenshot-$timestamp.png"
    screencapture -i "$name" && echo "Saved to $name"
}

json() {
    ensure_command jq || return 1
    jq --monochrome-output --color-output "$@"
}

weather() {
    ensure_command curl || return 1
    curl -fsSL "https://wttr.in/${1:-auto}?format=3"
}

pathprepend() {
    local dir="$1"
    [[ -d $dir ]] && PATH="$dir:$PATH"
}

mktempdir() {
    mktemp -d "${TMPDIR:-/tmp}/tmp.XXXXXXXX"
}

