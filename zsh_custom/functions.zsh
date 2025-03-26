# Unalias h if it exists
unalias h 2>/dev/null

# Colorized history function with timestamps and additional features
h() {
    # Help message
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: h [options] [search-term]"
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo "  -n NUMBER     Show last N entries"
        echo "  -d DATE       Show entries for specific date (YYYY-MM-DD)"
        echo "  -t           Show entries from today only"
        echo "Examples:"
        echo "  h            Show all history with timestamps"
        echo "  h git        Search for 'git' in history"
        echo "  h -n 10      Show last 10 entries"
        echo "  h -d 2024-02-23  Show entries from specific date"
        echo "  h -t         Show today's entries"
        return
    fi

    local entries=""
    local filter=""
    local date_filter=""

    # Parse options
    while [[ "$1" == -* ]]; do
        case "$1" in
            -n)
                shift
                entries="-$1"
                shift
                ;;
            -d)
                shift
                date_filter=$(date -j -f "%Y-%m-%d" "$1" "+%Y-%m-%d" 2>/dev/null)
                if [ $? -ne 0 ]; then
                    echo "Invalid date format. Use YYYY-MM-DD"
                    return 1
                fi
                shift
                ;;
            -t)
                date_filter=$(date "+%Y-%m-%d")
                shift
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done

    # Base command with timestamp format
    local cmd="fc -l -t '%Y-%m-%d %H:%M'"

    # Add entries limit if specified
    [[ -n "$entries" ]] && cmd="$cmd $entries"

    # Add starting point if not limited
    [[ -z "$entries" ]] && cmd="$cmd 1"

    # Execute command and process output
    if [ -z "$1" ]; then
        eval "$cmd" | while read -r num timestamp rest; do
            # Filter by date if specified
            if [[ -n "$date_filter" && ! "$timestamp" =~ ^$date_filter ]]; then
                continue
            fi
            print -P "%F{green}${num}%f  %F{blue}${timestamp}%f  %F{yellow}${rest}%f"
        done
    else
        eval "$cmd" | while read -r num timestamp rest; do
            # Filter by date if specified
            if [[ -n "$date_filter" && ! "$timestamp" =~ ^$date_filter ]]; then
                continue
            fi
            print -P "%F{green}${num}%f  %F{blue}${timestamp}%f  %F{yellow}${rest}%f"
        done | grep --color=always -i "$1"
    fi
}