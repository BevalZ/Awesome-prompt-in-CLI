#!/usr/bin/env bash

# Common cross-platform utility functions
# Shared by all scripts in the Awesome Academic Prompts toolkit

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*|MINGW*|MSYS*) echo "Windows";;
        *)          echo "Unknown";;
    esac
}

# Check if path conversion is needed
# Only convert on Windows when NOT in Git Bash/MSYS environment
should_convert_paths() {
    local os=$(detect_os)
    [[ "$os" == "Windows" ]] && [[ -z "${MSYSTEM:-}" ]]
}

# Convert Unix path to Windows path
# Priority: cygpath > wslpath > pure Bash
to_windows_path() {
    local path="$1"
    
    # Temporarily disable strict error handling
    set +e
    
    local result=""
    
    if command -v cygpath >/dev/null 2>&1; then
        result=$(cygpath -w "$path" 2>/dev/null)
    elif command -v wslpath >/dev/null 2>&1; then
        result=$(wslpath -w "$path" 2>/dev/null)
    else
        # Pure Bash fallback: /d/path -> D:\path
        if [[ "$path" =~ ^/([a-zA-Z])/ ]]; then
            local drive="${BASH_REMATCH[1]}"
            local drive_upper="${drive^^}"
            local rest="${path#/[a-zA-Z]/}"
            # Replace forward slashes with backslashes
            rest="${rest//\//\\}"
            result="${drive_upper}:\\${rest}"
        else
            # Not a standard Unix path, return as-is
            result="$path"
        fi
    fi
    
    # Re-enable error handling
    set -e
    
    # Fallback to original path if conversion failed
    if [[ -z "$result" ]]; then
        echo "$path"
    else
        echo "$result"
    fi
}

# Convert paths in text string (word-by-word)
# Handles quoted paths, skips URLs
convert_paths_in_text() {
    local text="$1"
    
    # Only convert if needed
    if ! should_convert_paths; then
        echo "$text"
        return
    fi
    
    # Regex pattern: quoted strings or path-like patterns
    # Matches: "/path", '/path', /path/file, ./relative, ../parent
    local regex='("[^"]*[/][^"]*"|'"'"'[^'"'"']*[/][^'"'"']*'"'"'|/[a-zA-Z0-9_/. -]+|\.\.?/[a-zA-Z0-9_/. -]+)'
    
    local result="$text"
    local processed=""
    
    while [[ "$result" =~ $regex ]]; do
        local matched="${BASH_REMATCH[0]}"
        local before="${result%%"$matched"*}"
        
        # Extract path (remove quotes if present)
        local path="$matched"
        local has_quotes=false
        
        if [[ "$path" =~ ^[\"\'](.*)[\"\']\$ ]]; then
            path="${BASH_REMATCH[1]}"
            has_quotes=true
        fi
        
        # Skip URLs
        if [[ "$path" =~ :// ]]; then
            processed="${processed}${before}${matched}"
            result="${result#*"$matched"}"
            continue
        fi
        
        # Convert path
        local converted=$(to_windows_path "$path")
        
        # Reconstruct with quotes if needed
        if [[ "$has_quotes" == true ]]; then
            converted="\"${converted}\""
        fi
        
        processed="${processed}${before}${converted}"
        result="${result#*"$matched"}"
    done
    
    echo "${processed}${result}"
}

# Enhanced print_color with automatic path conversion
print_color() {
    local color=$1
    local message=$2
    local NC='\033[0m'
    
    # Convert paths in message if needed
    if should_convert_paths; then
        message=$(convert_paths_in_text "$message")
    fi
    
    # Check color preference from profile
    local show_colors="${SHOW_COLORS:-true}"
    
    if [[ "$show_colors" == "true" ]]; then
        echo -e "${color}${message}${NC}"
    else
        echo "$message"
    fi
}

# Export functions for use in other scripts
export -f detect_os
export -f should_convert_paths
export -f to_windows_path
export -f convert_paths_in_text
export -f print_color

# Backward compatibility: read_profile_value for scripts
# Many scripts use this function to read user preferences
read_profile_value() {
    local key="$1"
    local default_value="$2"
    local profile_file="${PROFILE_FILE:-${SCRIPT_DIR:-$(pwd)}/Profiles/user_profile.conf}"
    
    if [[ -f "$profile_file" ]]; then
        local value=$(grep "^$key=" "$profile_file" 2>/dev/null | cut -d'=' -f2 | cut -d'#' -f1 | tr -d ' ')
        if [[ -n "$value" ]]; then
            echo "$value"
        else
            echo "$default_value"
        fi
    else
        echo "$default_value"
    fi
}

# Export read_profile_value for use in other scripts
export -f read_profile_value



# Safe read function that works in both interactive and non-interactive environments
# Handles stdin redirection gracefully
safe_read() {
    if [[ -t 0 ]]; then
        # stdin is a terminal, read normally
        read "$@"
    elif { true >/dev/tty; } 2>/dev/null; then
        # /dev/tty is writable (truly available), use it
        read "$@" </dev/tty
    else
        # No TTY available, read from stdin
        read "$@"
    fi
}

# Export safe_read for use in other scripts
export -f safe_read
