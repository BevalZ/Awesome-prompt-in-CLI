#!/usr/bin/env bash

# Cross-platform CLI tool for adding academic prompts
# Compatible with Linux, macOS, and Windows (Git Bash/WSL)

set -euo pipefail

# Colors for better UX (cross-platform compatible)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory (parent of scripts folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/Prompts/EN"
PROFILE_FILE="$SCRIPT_DIR/Profiles/user_profile.conf"

# Load cross-platform common library
SCRIPT_LIB="$SCRIPT_DIR/scripts/lib/common.sh"
if [[ -f "$SCRIPT_LIB" ]]; then
    source "$SCRIPT_LIB"
fi

# Load language strings
source "$SCRIPT_DIR/Profiles/language_strings.sh" 2>/dev/null || true

# Function to read profile value
read_profile_value() {
    local key="$1"
    local default_value="$2"
    
    if [[ -f "$PROFILE_FILE" ]]; then
        local value=$(grep "^$key=" "$PROFILE_FILE" | cut -d'=' -f2 | cut -d'#' -f1 | tr -d ' ')
        if [[ -n "$value" ]]; then
            echo "$value"
        else
            echo "$default_value"
        fi
    else
        echo "$default_value"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    local os=$(detect_os)
    local missing_deps=()
    local warnings=()
    
    print_color "$BLUE" "🔍 Checking system dependencies..."
    
    # Check bash version
    if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
        missing_deps+=("bash-4.0+")
    fi
    
    # Check required commands
    local required_commands=("find" "sed" "grep" "basename" "tr")
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done
    
    # OS-specific checks
    case "$os" in
        "Windows")
            if ! command_exists "bash"; then
                missing_deps+=("bash (Git Bash or WSL)")
            fi
            if [[ "$TERM" == "dumb" ]] || [[ -z "${TERM:-}" ]]; then
                warnings+=("Terminal may not support colors properly")
            fi
            ;;
        "macOS")
            # Check if using old bash
            if [[ ${BASH_VERSION%%.*} -eq 3 ]]; then
                warnings+=("Consider upgrading to Bash 4+ via Homebrew: brew install bash")
            fi
            ;;
        "Linux")
            # Most distributions have required tools by default
            ;;
        "Unknown")
            warnings+=("Unsupported operating system detected: $os")
            ;;
    esac
    
    # Report results
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_color "$RED" "❌ Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        show_installation_help "$os" "${missing_deps[@]}"
        exit 1
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        print_color "$YELLOW" "⚠️  Warnings:"
        for warning in "${warnings[@]}"; do
            echo "  - $warning"
        done
        echo ""
    fi
    
    print_color "$GREEN" "✅ All dependencies satisfied!"
    echo ""
}

# Function to show installation help
show_installation_help() {
    local os="$1"
    shift
    local deps=("$@")
    
    print_color "$BLUE" "📦 Installation help for $os:"
    
    case "$os" in
        "Linux")
            echo "Ubuntu/Debian:"
            echo "  sudo apt-get update && sudo apt-get install bash findutils sed grep coreutils"
            echo ""
            echo "CentOS/RHEL/Fedora:"
            echo "  sudo yum install bash findutils sed grep coreutils"
            echo "  # or: sudo dnf install bash findutils sed grep coreutils"
            ;;
        "macOS")
            echo "Using Homebrew (recommended):"
            echo "  brew install bash findutils gnu-sed grep coreutils"
            echo ""
            echo "Using MacPorts:"
            echo "  sudo port install bash findutils gsed grep coreutils"
            ;;
        "Windows")
            echo "Option 1 - Git Bash (recommended):"
            echo "  Download and install Git for Windows from https://git-scm.com/"
            echo "  This includes bash and all required UNIX tools"
            echo ""
            echo "Option 2 - Windows Subsystem for Linux (WSL):"
            echo "  Enable WSL and install a Linux distribution"
            echo "  wsl --install"
            echo ""
            echo "Option 3 - Cygwin:"
            echo "  Download from https://www.cygwin.com/"
            echo "  Select bash, findutils, sed, grep packages during installation"
            ;;
        *)
            echo "Please install the following tools using your system's package manager:"
            for dep in "${deps[@]}"; do
                echo "  - $dep"
            done
            ;;
    esac
    echo ""
}

# Function to check directory structure
check_directory_structure() {
    if [[ ! -d "$PROMPTS_DIR" ]]; then
        print_color "$RED" "❌ Directory structure error: $PROMPTS_DIR not found"
        print_color "$BLUE" "Expected directory structure:"
        echo "  $(basename "$SCRIPT_DIR")/"
        echo "  ├── Prompts/"
        echo "  │   └── EN/"
        echo "  │       ├── computer-science.md"
        echo "  │       ├── natural-sciences.md"
        echo "  │       └── ..."
        echo "  └── add_prompt.sh"
        exit 1
    fi
    
    # Check if we have write permissions
    if [[ ! -w "$PROMPTS_DIR" ]]; then
        print_color "$RED" "❌ Permission error: Cannot write to $PROMPTS_DIR"
        print_color "$BLUE" "Fix with: chmod -R u+w \"$PROMPTS_DIR\""
        exit 1
    fi
}

# Function to check if text is primarily English
check_english() {
    local text="$1"
    # Simple heuristic: check for common English words and patterns
    local english_words=("the" "and" "is" "are" "was" "were" "have" "has" "will" "would" "can" "could" "should" "may" "might" "more" "then" "than" "test" "nothing" "something" "this" "that" "with" "from" "they" "been" "their" "said" "each" "which" "what" "where" "when" "how" "why" "who")
    local word_count=0
    local english_count=0
    
    # Convert to lowercase and count words
    for word in $text; do
        word_lower=$(echo "$word" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z]//g')
        if [[ -n "$word_lower" ]]; then
            ((word_count++))
            
            for eng_word in "${english_words[@]}"; do
                if [[ "$word_lower" == "$eng_word" ]]; then
                    ((english_count++))
                    break
                fi
            done
        fi
    done
    
    # If we have at least 2 words and 15% are common English words, consider it English
    if [[ $word_count -ge 2 ]] && [[ $english_count -gt 0 ]] && [[ $((english_count * 100 / word_count)) -ge 15 ]]; then
        return 0  # English
    else
        return 1  # Not English
    fi
}

# Function to get available categories
get_categories() {
    if [[ ! -d "$PROMPTS_DIR" ]]; then
        print_color "$RED" "Error: Prompts/EN directory not found at: $PROMPTS_DIR"
        exit 1
    fi
    
    find "$PROMPTS_DIR" -name "*.md" -type f | sort
}

# Function to parse research areas from a category file
# Function to parse research areas from a category file
get_research_areas() {
    local file="$1"
    sed -n '/## Research Areas/,/^## /p' "$file" | grep '^- ' | sed 's/^- //'
}

# Function to parse prompt categories from a category file
get_prompt_categories() {
    local file="$1"
    sed -n '/## Prompt Categories/,/^## /p' "$file" | grep '^- ' | sed 's/^- //'
}

# Function to get next prompt number (deprecated - no longer numbering prompts)
# Keeping function for backward compatibility but not using numbering
get_next_number() {
    local file="$1"
    # No longer numbering prompts, return empty
    echo ""
}

# Function to validate input
validate_input() {
    local input="$1"
    local min_length="${2:-1}"
    
    if [[ ${#input} -lt $min_length ]]; then
        return 1
    fi
    return 0
}

# Function to select from list
select_from_list() {
    local title="$1"
    shift
    local options=("$@")
    
    # Display menu to stderr to avoid capturing it
    echo "" >&2
    print_color "$BLUE" "$title" >&2
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}" >&2
    done
    echo "" >&2
    
    while true; do
        printf "Select (1-${#options[@]}): " >&2
        read -r choice </dev/tty
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return 0
        else
            print_color "$RED" "Invalid choice. Please select 1-${#options[@]}" >&2
        fi
    done
}

# Function to get multiline input
get_multiline_input() {
    local prompt="$1"
    local end_marker="${2:-END}"
    
    print_color "$BLUE" "$prompt"
    print_color "$YELLOW" "(Type '$end_marker' on a new line when finished)"
    
    local input=""
    local line=""
    
    while IFS= read -r line </dev/tty; do
        if [[ "$line" == "$end_marker" ]]; then
            break
        fi
        if [[ -n "$input" ]]; then
            input="$input"$'\n'"$line"
        else
            input="$line"
        fi
    done
    
    echo "$input"
}

# Main function
main() {
    print_color "$GREEN" "🚀 Academic Prompt Addition Tool"
    print_color "$BLUE" "Following PROMPT_FORMAT.md guidelines\n"
    
    # Check dependencies first
    check_dependencies
    check_directory_structure
    
    # Get available category files
    mapfile -t category_files < <(get_categories)
    
    if [[ ${#category_files[@]} -eq 0 ]]; then
        print_color "$RED" "No category files found in $PROMPTS_DIR"
        exit 1
    fi
    
    # Extract category names for display
    category_names=()
    for file in "${category_files[@]}"; do
        basename="$(basename "$file" .md)"
        category_names+=("$basename")
    done
    
    # Select category
    selected_category=$(select_from_list "📂 Select Category:" "${category_names[@]}")
    selected_file=""
    
    # Find the corresponding file
    for file in "${category_files[@]}"; do
        if [[ "$(basename "$file" .md)" == "$selected_category" ]]; then
            selected_file="$file"
            break
        fi
    done
    
    if [[ -z "$selected_file" ]]; then
        print_color "$RED" "Error: Could not find file for category '$selected_category'"
        exit 1
    fi
    
    print_color "$GREEN" "Selected: $selected_category"
    
    # Get research areas and prompt categories
    mapfile -t research_areas < <(get_research_areas "$selected_file")
    mapfile -t prompt_categories < <(get_prompt_categories "$selected_file")
    
    # Get prompt details
    echo ""
    echo -n "$(get_string "ENTER_PROMPT_TITLE" "$interface_lang"): "
    read -r title </dev/tty
    
    while ! validate_input "$title" 5; do
        print_color "$RED" "Title must be at least 5 characters long"
        echo -n "$(get_string "ENTER_PROMPT_TITLE" "$interface_lang"): "
        read -r title </dev/tty
    done
    
    # Select research area
    research_area=$(select_from_list "🔬 Select Research Area:" "${research_areas[@]}")
    
    # Select prompt category
    prompt_category=$(select_from_list "📋 Select Prompt Category:" "${prompt_categories[@]}")
    
    # Get description
    echo ""
    echo -n "$(get_string "ENTER_DESCRIPTION" "$interface_lang"): "
    read -r description </dev/tty
    
    while ! validate_input "$description" 10; do
        print_color "$RED" "Description must be at least 10 characters long"
        echo -n "$(get_string "ENTER_DESCRIPTION_SHORT" "$interface_lang"): "
        read -r description </dev/tty
    done
    
    # Check if description is in English
    if ! check_english "$description"; then
        print_color "$YELLOW" "⚠️  WARNING: Description doesn't appear to be in English."
        echo -n "$(get_string "CONTINUE_ANYWAY" "$interface_lang"): "
        read -r confirm </dev/tty
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_color "$RED" "Aborted."
            exit 1
        fi
    fi
    
    # Get prompt text
    echo ""
    prompt_text=$(get_multiline_input "✍️  Enter the prompt text:" "END")
    
    while ! validate_input "$prompt_text" 20; do
        print_color "$RED" "Prompt text must be at least 20 characters long"
        
        # Retry multiline input
        echo ""
        prompt_text=$(get_multiline_input "✍️  Enter the prompt text:" "END")
    done
    
    # Check if prompt is in English
    if ! check_english "$prompt_text"; then
        print_color "$YELLOW" "⚠️  WARNING: Prompt text doesn't appear to be in English."
        echo -n "$(get_string "CONTINUE_ANYWAY" "$interface_lang"): "
        read -r confirm </dev/tty
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_color "$RED" "Aborted."
            exit 1
        fi
    fi
    
    # Preview
    echo ""
    print_color "$BLUE" "📋 Preview:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "### $title"
    echo ""
    echo "**Tags:** \`$research_area\` | \`$prompt_category\`"
    echo ""
    echo "**Description:** $description"
    echo ""
    echo "**Prompt:**"
    echo '```'
    echo "$prompt_text"
    echo '```'
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Confirm
    echo ""
    echo -n "$(get_string "ADD_PROMPT_CONFIRM" "$interface_lang"): $selected_category$(get_string "ADD_PROMPT_CONFIRM_SUFFIX" "$interface_lang"): "
    read -r confirm </dev/tty
    
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        print_color "$RED" "Aborted."
        exit 1
    fi
    
    # Add to file
    {
        echo ""
        echo "### $title"
        echo ""
        echo "**Tags:** \`$research_area\` | \`$prompt_category\`"
        echo ""
        echo "**Description:** $description"
        echo ""
        echo "**Prompt:**"
        echo '```'
        echo "$prompt_text"
        echo '```'
    } >> "$selected_file"
    
    print_color "$GREEN" "✅ Prompt successfully added to $selected_category.md!"
    print_color "$BLUE" "📍 Location: $selected_file"
}

# Run main function
main "$@"