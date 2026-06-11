#!/usr/bin/env bash

# Simple Prompt Search Tool
# Search academic prompts by keywords across all categories

# Disabled strict error handling to prevent early exit on search results
# set -euo pipefail

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_FILE="$SCRIPT_DIR/README.md"
PROFILE_FILE="$SCRIPT_DIR/Profiles/user_profile.conf"

# Load cross-platform common library
SCRIPT_LIB="$SCRIPT_DIR/scripts/lib/common.sh"
if [[ -f "$SCRIPT_LIB" ]]; then
    source "$SCRIPT_LIB"
fi

# Function to get prompts directory based on interface language
get_prompts_directory() {
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    local lang_dir="$SCRIPT_DIR/Prompts/$interface_lang"
    
    # Check if the language directory exists, fallback to EN if not
    if [[ -d "$lang_dir" ]]; then
        echo "$lang_dir"
    else
        echo "$SCRIPT_DIR/Prompts/EN"
    fi
}

# Set prompts directory based on interface language
PROMPTS_DIR=$(get_prompts_directory)

# Function to refresh prompts directory (useful if language changes during runtime)
refresh_prompts_directory() {
    PROMPTS_DIR=$(get_prompts_directory)
}

# Load language strings
source "$SCRIPT_DIR/Profiles/language_strings.sh" 2>/dev/null || true

# Function to calculate display width accounting for emojis
# Emojis display as 2 characters but count as 1 in bash
get_display_width() {
    local text="$1"
    # Count emoji characters (simplified regex for common emojis)
    local emoji_count=$(echo "$text" | grep -o '[🎓⚙️🔍📊💾🌐📝🏷️📋📚🚪🔙]' | wc -l || true)
    local char_count=${#text}
    # Each emoji adds 1 extra character to display width
    echo $((char_count + emoji_count))
}

# Global variable for search results
SEARCH_RESULTS_COUNT=0
SEARCH_RESULTS_TITLES=()
SEARCH_RESULTS_FILES=()
SEARCH_RESULTS_LINES=()

# Function to clear search results
clear_search_results() {
    SEARCH_RESULTS_COUNT=0
    SEARCH_RESULTS_TITLES=()
    SEARCH_RESULTS_FILES=()
    SEARCH_RESULTS_LINES=()
}

# Function to add search results
add_search_results() {
    # Append the new results to global arrays
    SEARCH_RESULTS_TITLES+=("$1")
    SEARCH_RESULTS_FILES+=("$2")
    SEARCH_RESULTS_LINES+=("$3")
    
    # Update the count
    SEARCH_RESULTS_COUNT=${#SEARCH_RESULTS_TITLES[@]}
}

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

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    local show_colors=$(read_profile_value "SHOW_COLORS" "true")
    
    if [[ "$show_colors" == "true" ]]; then
        echo -e "${color}${message}${NC}"
    else
        echo "$message"
    fi
}

# Function to show usage
show_usage() {
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BLUE" "$(get_string "SEARCH_TOOL_TITLE" "$interface_lang")"
    echo ""
    echo "$(get_string "USAGE" "$interface_lang") $0 [OPTIONS] [KEYWORDS...]"
    echo ""
    echo "$(get_string "OPTIONS" "$interface_lang")"
    echo "  -h, --help              $(get_string "HELP_MESSAGE" "$interface_lang")"
    echo "  -i, --interactive       $(get_string "INTERACTIVE_MODE" "$interface_lang")"
    echo "  -l, --list-categories   $(get_string "LIST_CATEGORIES" "$interface_lang")"
    echo "  -b, --browse-categories $(get_string "BROWSE_CATEGORIES" "$interface_lang")"
    echo "  -c, --category CATEGORY $(get_string "SEARCH_CATEGORY" "$interface_lang")"
    echo ""
    echo "$(get_string "EXAMPLES" "$interface_lang")"
    echo "  $0 machine learning                    # Search for 'machine learning'"
    echo "  $0 -c computer-science neural          # Search 'neural' in computer science"
    echo "  $0 -i                                  # $(get_string "INTERACTIVE_MODE_DESC" "$interface_lang")"
    echo "  $0 -l                                  # $(get_string "LIST_ALL_CATEGORIES_DESC" "$interface_lang")"
    echo "  $0 -b                                  # $(get_string "BROWSE_CATEGORIES_DESC" "$interface_lang")"
    echo ""
}

# Function to list categories
list_categories() {
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BLUE" "$(get_string "AVAILABLE_CATEGORIES" "$interface_lang")"
    echo ""
    
    if [[ ! -d "$PROMPTS_DIR" ]]; then
        print_color "$RED" "$(get_string "ERROR_PROMPTS_DIR_NOT_FOUND" "$interface_lang") $PROMPTS_DIR"
        exit 1
    fi
    
    local count=1
    for file in "$PROMPTS_DIR"/*.md; do
        if [[ -f "$file" ]]; then
            local category=$(basename "$file" .md)
            local title=$(head -n 1 "$file" | sed 's/^# //')
            printf "%2d. %-25s %s\n" "$count" "$category" "($title)"
            ((count++))
        fi
    done
    echo ""
}

# Function to browse prompts in a specific category
browse_category_prompts() {
    local category_name="$1"
    local category_file="$PROMPTS_DIR/$category_name.md"
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    if [[ ! -f "$category_file" ]]; then
        print_color "$RED" "$(get_string "ERROR_CATEGORY_FILE_NOT_FOUND" "$interface_lang") $category_file"
        return 1
    fi
    
    # Clear screen and show header
    clear
    print_header
    print_color "$BOLD$CYAN" "📂 $(get_string "CATEGORY" "$interface_lang") $category_name"
    echo ""
    
    # Get all prompts in the category
    local prompts_data=$(grep -n "^### " "$category_file" 2>/dev/null || echo "")
    
    if [[ -z "$prompts_data" ]]; then
        print_color "$YELLOW" "$(get_string "NO_PROMPTS_FOUND_CATEGORY" "$interface_lang")"
        echo ""
        print_color "$BLUE" "0 $(get_string "PROMPTS_AVAILABLE" "$interface_lang")"
        echo ""
    else
        # Count total prompts
        local total_prompts=$(echo "$prompts_data" | wc -l | tr -d ' ')
        print_color "$GREEN" "$(get_string "FOUND_PROMPTS_IN" "$interface_lang") $category_name $(get_string "FOUND_PROMPTS_IN_SUFFIX" "$interface_lang") $total_prompts $(get_string "PROMPTS_SUFFIX" "$interface_lang")"
        echo ""
        
        # Process each prompt
        local prompt_count=1
        while IFS= read -r prompt_line; do
            if [[ -n "$prompt_line" ]]; then
                local line_num=$(echo "$prompt_line" | cut -d: -f1)
                local prompt_title=$(echo "$prompt_line" | cut -d: -f2-)
                
                # Extract prompt section
                local next_prompt_line=$((line_num + 100))
                local prompt_section=$(sed -n "${line_num},${next_prompt_line}p" "$category_file")
                
                # Display prompt information
                printf "%2d. %s\n" "$prompt_count" "$prompt_title"
                
                # Show tags if available
                local tags_line=$(echo "$prompt_section" | grep -m 1 "^\*\*Tags:\*\*" || echo "")
                if [[ -n "$tags_line" ]]; then
                    print_color "$YELLOW" "   🏷️  $tags_line"
                fi
                
                # Show description if available
                local desc_line=$(echo "$prompt_section" | grep -m 1 "^\*\*Description:\*\*" || echo "")
                if [[ -n "$desc_line" ]]; then
                    # Remove the **Description:** prefix and show the actual description
                    local description=$(echo "$desc_line" | sed 's/^\*\*Description:\*\* //')
                    print_color "$MAGENTA" "   📝 $description"
                fi
                
                echo ""
                ((prompt_count++))
            fi
        done <<< "$prompts_data"
    fi
    
    # Show navigation options
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$GREEN" "  1. $(get_string "VIEW_SPECIFIC_PROMPT" "$interface_lang")"
    print_color "$GREEN" "  2. $(get_string "BACK_TO_LIST_CATEGORIES" "$interface_lang")"
    print_color "$GREEN" "  3. $(get_string "BACK_TO_SEARCH_MENU_OPTION" "$interface_lang")"
    echo ""
    
    while true; do
        echo -n "$(get_string "SELECT_OPTION_1_3" "$interface_lang") "
        read -r browse_choice </dev/tty
        
        case $browse_choice in
            1)
                if [[ -n "$prompts_data" ]]; then
                    echo -n "$(get_string "ENTER_PROMPT_NUMBER" "$interface_lang") (1-$total_prompts): "
                    read -r prompt_selection </dev/tty
                    
                    if [[ "$prompt_selection" =~ ^[0-9]+$ ]] && [[ $prompt_selection -ge 1 ]] && [[ $prompt_selection -le $total_prompts ]]; then
                        # Find the selected prompt
                        local selected_line=$(echo "$prompts_data" | sed -n "${prompt_selection}p")
                        local line_num=$(echo "$selected_line" | cut -d: -f1)
                        
                        # Set up search results arrays for the copy language functionality
                        clear_search_results
                        local prompt_title=$(echo "$selected_line" | cut -d: -f2-)
                        add_search_results "$prompt_title" "$category_file" "$line_num"
                        
                        # Clear and show prompt details
                        clear
                        print_header
                        print_color "$BOLD$CYAN" "$(get_string "PROMPT_DETAILS" "$interface_lang")"
                        echo ""
                        
                        # Extract and display full prompt
                        local next_prompt_line=$((line_num + 100))
                        local full_prompt=$(sed -n "${line_num},${next_prompt_line}p" "$category_file")
                        
                        # Display the prompt
                        print_color "$CYAN" "$(echo \"$selected_line\" | cut -d: -f2-)"
                        echo ""
                        
                        # Show tags
                        local tags_line=$(echo "$full_prompt" | grep -m 1 "^\*\*Tags:\*\*" || echo "")
                        if [[ -n "$tags_line" ]]; then
                            print_color "$YELLOW" "$tags_line"
                            echo ""
                        fi
                        
                        # Show description
                        local desc_line=$(echo "$full_prompt" | grep -m 1 "^\*\*Description:\*\*" || echo "")
                        if [[ -n "$desc_line" ]]; then
                            echo "$desc_line"
                            echo ""
                        fi
                        
                        # Show prompt content
                        local prompt_content=$(echo "$full_prompt" | sed -n '/```/,/```/p' | sed '1d' | sed '$d')
                        if [[ -n "$prompt_content" ]]; then
                            print_color "$MAGENTA" "**Prompt:**"
                            echo ""
                            echo "$prompt_content"
                            echo ""
                        fi
                        
                        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        
                        # Show category-specific prompt action menu
                        show_category_prompt_action_menu "$prompt_content" "$category_name"
                        return
                    else
                        print_color "$RED" "$(get_string "INVALID_PROMPT_NUMBER" "$interface_lang")"
                    fi
                else
                    print_color "$YELLOW" "$(get_string "NO_PROMPTS_AVAILABLE_VIEW" "$interface_lang")"
                fi
                ;;
            2)
                # Back to list all categories
                return 0
                ;;
            3)
                # Back to search menu
                return 1
                ;;
            *)
                print_color "$RED" "$(get_string "INVALID_CHOICE_SELECT_1_3" "$interface_lang")"
                ;;
        esac
    done
}

# Function to show interactive category browser
show_category_browser() {
    while true; do
        clear
        print_header
        # Refresh prompts directory in case language changed
        refresh_prompts_directory
        
        local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
        print_color "$BOLD$CYAN" "$(get_string "AVAILABLE_CATEGORIES" "$interface_lang")"
        echo ""
        
        if [[ ! -d "$PROMPTS_DIR" ]]; then
            print_color "$RED" "$(get_string "ERROR_PROMPTS_DIR_NOT_FOUND" "$interface_lang") $PROMPTS_DIR"
            return 1
        fi
        
        # List categories with numbers
        local categories=()
        local count=1
        for file in "$PROMPTS_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                local category=$(basename "$file" .md)
                local title=$(head -n 1 "$file" | sed 's/^# //')
                categories+=("$category")
                printf "%2d. %-25s %s\n" "$count" "$category" "($title)"
                ((count++))
            fi
        done
        
        if [[ ${#categories[@]} -eq 0 ]]; then
            print_color "$YELLOW" "$(get_string "NO_CATEGORIES_FOUND" "$interface_lang")"
            return 1
        fi
        
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        print_color "$GREEN" "$(get_string "SELECT_CATEGORY_TO_BROWSE" "$interface_lang")"
        print_color "$GREEN" "  0. $(get_string "BACK_TO_SEARCH_MENU" "$interface_lang")"
        echo ""
        
        echo -n "$(get_string "ENTER_CATEGORY_NUMBER" "$interface_lang") (1-${#categories[@]}) $(get_string "OR_RETURN" "$interface_lang") "
        read -r category_choice </dev/tty
        
        case $category_choice in
            0)
                return 1
                ;;
            [1-9]|[1-9][0-9])
                if [[ $category_choice -ge 1 ]] && [[ $category_choice -le ${#categories[@]} ]]; then
                    local selected_category="${categories[$((category_choice-1))]}"
                    browse_category_prompts "$selected_category"
                    
                    # Check return value to determine next action
                    if [[ $? -eq 1 ]]; then
                        # User chose to go back to search menu
                        return 1
                    fi
                    # Otherwise, continue browsing categories
                else
                    print_color "$RED" "$(get_string "INVALID_CATEGORY_NUMBER" "$interface_lang")"
                    sleep 1
                fi
                ;;
            *)
                print_color "$RED" "$(get_string "INVALID_CHOICE_ENTER_NUMBER" "$interface_lang")"
                sleep 1
                ;;
        esac
    done
}

# Function to search in a file
search_in_file() {
    local file="$1"
    local search_terms=("${@:2}")
    local found_results=0
    
    # Check if file exists and is readable
    if [[ ! -f "$file" ]] || [[ ! -r "$file" ]]; then
        return 0
    fi
    
    # Search for prompts (lines starting with ###)
    local prompt_lines_raw=$(grep -n "^### " "$file" 2>/dev/null || true)
    
    if [[ -z "$prompt_lines_raw" ]]; then
        return 0
    fi
    
    # Check each prompt
    while IFS= read -r prompt_line; do
        local line_num=$(echo "$prompt_line" | cut -d: -f1)
        local prompt_title=$(echo "$prompt_line" | cut -d: -f2-)
        
        # Look ahead 100 lines for content (prompts can be longer and in code blocks)
        local next_prompt_line=$((line_num + 100))
        local prompt_section=$(sed -n "${line_num},${next_prompt_line}p" "$file")
        
        # Check if any search term matches in this section
        local matches=false
        for term in "${search_terms[@]}"; do
            if echo "$prompt_section" | grep -qi "$term"; then
                matches=true
                break
                fi
            done
        
        if [[ "$matches" == "true" ]]; then
            ((found_results++))
            
            # Add this result to global arrays
            add_search_results "$prompt_title" "$file" "$line_num"
        fi
    done <<< "$prompt_lines_raw"
}

# Function to display search results summary
display_search_summary() {
    local total_results=$1
    
    if [[ $total_results -eq 0 ]]; then
        print_color "$YELLOW" "No results found"
        return
    fi
    
    print_color "$GREEN" "Found $total_results result(s):"
                echo ""
    
    # Display detailed information for each result
    for i in "${!SEARCH_RESULTS_TITLES[@]}"; do
        local category=$(basename "${SEARCH_RESULTS_FILES[$i]}" .md)
        local title="${SEARCH_RESULTS_TITLES[$i]}"
        local file="${SEARCH_RESULTS_FILES[$i]}"
        local line_num="${SEARCH_RESULTS_LINES[$i]}"
        
        # Get additional details for this prompt
        local next_prompt_line=$((line_num + 100))
        local prompt_section=$(sed -n "${line_num},${next_prompt_line}p" "$file")
        
        # Display result number and title
        printf "%2d. %s\n" "$((i + 1))" "$title"
        print_color "$CYAN" "   📁 Category: $category"
        
        # Show tags if available
        local tags_line=$(echo "$prompt_section" | grep -m 1 "^\*\*Tags:\*\*" || echo "")
        if [[ -n "$tags_line" ]]; then
            print_color "$YELLOW" "   🏷️  $tags_line"
        fi
        
        # Show description if available
        local desc_line=$(echo "$prompt_section" | grep -m 1 "^\*\*Description:\*\*" || echo "")
        if [[ -n "$desc_line" ]]; then
            # Remove the **Description:** prefix and show the actual description
            local description=$(echo "$desc_line" | sed 's/^\*\*Description:\*\* //')
            print_color "$MAGENTA" "   📝 $description"
            fi
            
            echo ""
    done
    
    # Ask user to select one for details
    echo "----------------------------------------"
    print_color "$BLUE" "Enter a number (1-$total_results) to view full prompt, or press Enter to skip: "
    print_color "$CYAN" "Type 'm' to go back to search options menu"
    echo ""
}

# Function to show prompt details
show_prompt_details() {
    local selection=$1
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#SEARCH_RESULTS_TITLES[@]} ]]; then
        print_color "$RED" "Invalid selection. Please enter a number between 1 and ${#SEARCH_RESULTS_TITLES[@]}"
        return 0 # Indicate failure
    fi
    
    local index=$((selection - 1))
    local file="${SEARCH_RESULTS_FILES[$index]}"
    local line_num="${SEARCH_RESULTS_LINES[$index]}"
    local title="${SEARCH_RESULTS_TITLES[$index]}"
    
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "$BOLD$GREEN" "📋 Prompt Details:"
    echo ""
    
    # Display the full prompt details
    print_color "$CYAN" "$title"
    echo ""
    
    # Look ahead 100 lines for content
    local next_prompt_line=$((line_num + 100))
    local prompt_section=$(sed -n "${line_num},${next_prompt_line}p" "$file")
    
    # Show tags if available
    local tags_line=$(echo "$prompt_section" | grep -m 1 "^\*\*Tags:\*\*" || echo "")
    if [[ -n "$tags_line" ]]; then
        print_color "$YELLOW" "$tags_line"
        echo ""
    fi
    
    # Show description if available
    local desc_line=$(echo "$prompt_section" | grep -m 1 "^\*\*Description:\*\*" || echo "")
    if [[ -n "$desc_line" ]]; then
        echo "$desc_line"
        echo ""
    fi
    
    # Show the full prompt content
    local prompt_content=$(echo "$prompt_section" | sed -n '/```/,/```/p' | sed '1d' | sed '$d')
    if [[ -n "$prompt_content" ]]; then
        print_color "$MAGENTA" "**Prompt:**"
        echo ""
        echo "$prompt_content"
        echo ""
    fi
    
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Show action menu
    show_prompt_action_menu "$prompt_content"
    return 0 # Indicate success
}

# Function to show prompt action menu
show_prompt_action_menu() {
    local prompt_content="$1"
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    while true; do
        echo ""
        print_color "$BOLD$CYAN" "$(get_string "WHAT_TO_DO_WITH_PROMPT" "$interface_lang")"
        echo ""
        print_color "$GREEN" "  1. $(get_string "COPY_PROMPT_TO_CLIPBOARD" "$interface_lang")"
        print_color "$GREEN" "  2. $(get_string "COPY_SPECIFIC_LANGUAGE" "$interface_lang")"
        print_color "$GREEN" "  3. $(get_string "BACK_TO_SEARCH_RESULTS" "$interface_lang")"
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo -n "$(get_string "SELECT_OPTION_1_3_PROMPT" "$interface_lang") "
        read -r action_choice </dev/tty
        
        case $action_choice in
            1)
                copy_prompt_to_clipboard "$prompt_content"
                ;;
            2)
                copy_language_version "$prompt_content"
                ;;
            3)
                print_color "$BLUE" "$(get_string "RETURNING_TO_SEARCH_RESULTS" "$interface_lang")"
                return 0
                ;;
            *)
                print_color "$RED" "$(get_string "INVALID_CHOICE_SELECT_1_3" "$interface_lang")"
                ;;
        esac
    done
}

# Function to copy prompt to clipboard
copy_prompt_to_clipboard() {
    local prompt_content="$1"
    
    # Check for clipboard command
    local clipboard_cmd=""
    if command -v pbcopy >/dev/null 2>&1; then
        clipboard_cmd="pbcopy"  # macOS
    elif command -v xclip >/dev/null 2>&1; then
        clipboard_cmd="xclip -selection clipboard"  # Linux with xclip
    elif command -v xsel >/dev/null 2>&1; then
        clipboard_cmd="xsel --clipboard --input"  # Linux with xsel
    elif command -v clip.exe >/dev/null 2>&1; then
        clipboard_cmd="clip.exe"  # Windows with clip.exe
    fi
    
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    if [[ -z "$clipboard_cmd" ]]; then
        print_color "$RED" "$(get_string "CLIPBOARD_NOT_FOUND" "$interface_lang")"
        echo "  - $(get_string "MACOS_PBCOPY" "$interface_lang")"
        echo "  - $(get_string "LINUX_XCLIP" "$interface_lang")"
        echo "  - $(get_string "WINDOWS_CLIP" "$interface_lang")"
        echo ""
        print_color "$YELLOW" "$(get_string "PROMPT_CONTENT_COPY_MANUALLY" "$interface_lang")"
        echo "----------------------------------------"
        echo "$prompt_content"
        echo "----------------------------------------"
        return
    fi
    
    # Copy to clipboard
    echo "$prompt_content" | eval "$clipboard_cmd"
    if [[ $? -eq 0 ]]; then
        print_color "$GREEN" "$(get_string "PROMPT_COPIED_SUCCESS" "$interface_lang")"
    else
        print_color "$RED" "$(get_string "FAILED_COPY_CLIPBOARD" "$interface_lang")"
        echo ""
        print_color "$YELLOW" "$(get_string "PROMPT_CONTENT_COPY_MANUALLY" "$interface_lang")"
        echo "----------------------------------------"
        echo "$prompt_content"
        echo "----------------------------------------"
    fi
}

# Function to show category-specific prompt action menu
show_category_prompt_action_menu() {
    local prompt_content="$1"
    local category_name="$2"
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    while true; do
        echo ""
        print_color "$BOLD$CYAN" "$(get_string "WHAT_TO_DO_WITH_PROMPT" "$interface_lang")"
        echo ""
        print_color "$GREEN" "  1. $(get_string "COPY_PROMPT_TO_CLIPBOARD" "$interface_lang")"
        print_color "$GREEN" "  2. $(get_string "COPY_SPECIFIC_LANGUAGE" "$interface_lang")"
        print_color "$GREEN" "  3. $(get_string "BACK_TO_CATEGORY" "$interface_lang") ($category_name)"
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo -n "$(get_string "SELECT_OPTION_1_3_PROMPT" "$interface_lang") "
        read -r action_choice </dev/tty
        
        case $action_choice in
            1)
                copy_prompt_to_clipboard "$prompt_content"
                ;;
            2)
                copy_language_version "$prompt_content"
                ;;
            3)
                print_color "$BLUE" "$(get_string "RETURNING_TO_CATEGORY_VIEW" "$interface_lang")"
                # Return to category view
                browse_category_prompts "$category_name"
                return
                ;;
            *)
                print_color "$RED" "$(get_string "INVALID_CHOICE_SELECT_1_3" "$interface_lang")"
                ;;
        esac
    done
}

# Function to copy specific language version
copy_language_version() {
    local prompt_content="$1"
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    echo ""
    print_color "$BOLD$CYAN" "$(get_string "SELECT_LANGUAGE_VERSION" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  1. $(get_string "ENGLISH_EN" "$interface_lang")"
    print_color "$GREEN" "  2. $(get_string "JAPANESE_JP" "$interface_lang")"
    print_color "$GREEN" "  3. $(get_string "CHINESE_ZH" "$interface_lang")"
    print_color "$GREEN" "  4. $(get_string "GERMAN_DE" "$interface_lang")"
    print_color "$GREEN" "  5. $(get_string "FRENCH_FR" "$interface_lang")"
    print_color "$GREEN" "  6. $(get_string "SPANISH_ES" "$interface_lang")"
    print_color "$GREEN" "  7. $(get_string "ITALIAN_IT" "$interface_lang")"
    print_color "$GREEN" "  8. $(get_string "PORTUGUESE_PT" "$interface_lang")"
    print_color "$GREEN" "  9. $(get_string "RUSSIAN_RU" "$interface_lang")"
    print_color "$GREEN" "  10. $(get_string "ARABIC_AR" "$interface_lang")"
    print_color "$GREEN" "  11. $(get_string "KOREAN_KO" "$interface_lang")"
    print_color "$GREEN" "  12. $(get_string "HINDI_HI" "$interface_lang")"
    print_color "$GREEN" "  13. $(get_string "BACK_TO_PROMPT_ACTIONS" "$interface_lang")"
    echo ""
    
    echo -n "$(get_string "SELECT_LANGUAGE_1_13" "$interface_lang") "
    read -r lang_choice </dev/tty
    
    case $lang_choice in
        1) copy_language_prompt "$prompt_content" "EN" ;;
        2) copy_language_prompt "$prompt_content" "JP" ;;
        3) copy_language_prompt "$prompt_content" "ZH" ;;
        4) copy_language_prompt "$prompt_content" "DE" ;;
        5) copy_language_prompt "$prompt_content" "FR" ;;
        6) copy_language_prompt "$prompt_content" "ES" ;;
        7) copy_language_prompt "$prompt_content" "IT" ;;
        8) copy_language_prompt "$prompt_content" "PT" ;;
        9) copy_language_prompt "$prompt_content" "RU" ;;
        10) copy_language_prompt "$prompt_content" "AR" ;;
        11) copy_language_prompt "$prompt_content" "KO" ;;
        12) copy_language_prompt "$prompt_content" "HI" ;;
        13|*) 
            print_color "$BLUE" "$(get_string "RETURNING_TO_PROMPT_ACTIONS" "$interface_lang")"
            show_prompt_action_menu "$prompt_content"
            return
            ;;
    esac
}

# Function to find prompt position by title in a category file
find_prompt_position() {
    local category_file="$1"
    local target_title="$2"
    
    local position=1
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]] ]]; then
            # Extract title, handling both numbered and non-numbered formats
            local line_title=""
            if [[ "$line" =~ ^###[[:space:]]+([0-9]+)\.[[:space:]]*(.+)$ ]]; then
                line_title="${BASH_REMATCH[2]}"
            elif [[ "$line" =~ ^###[[:space:]]+(.+)$ ]]; then
                line_title="${BASH_REMATCH[1]}"
            fi
            
            # Trim whitespace
            line_title=$(echo "$line_title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            target_title=$(echo "$target_title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [[ "$line_title" == "$target_title" ]]; then
                echo "$position"
                return 0
            fi
            ((position++))
        fi
    done < "$category_file"
    
    echo "0"  # Not found
}

# Function to get prompt by position in a category file
get_prompt_by_position() {
    local category_file="$1"
    local target_position="$2"
    
    local position=1
    local target_line_num=""
    
    # Find the line number of the target position
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]] ]]; then
            if [[ $position -eq $target_position ]]; then
                target_line_num=$(grep -n "^$(echo "$line" | sed 's/[[\.*^$()+?{|]/\\&/g')$" "$category_file" | head -1 | cut -d: -f1)
                break
            fi
            ((position++))
        fi
    done < "$category_file"
    
    if [[ -n "$target_line_num" ]]; then
        # Find the next prompt or end of file to determine the section boundary
        local next_prompt_line=$(sed -n "$((target_line_num + 1)),\$p" "$category_file" | grep -n "^###" | head -1 | cut -d: -f1)
        
        if [[ -n "$next_prompt_line" ]]; then
            # There's another prompt after this one
            local end_line=$((target_line_num + next_prompt_line - 1))
            local prompt_section=$(sed -n "${target_line_num},${end_line}p" "$category_file")
        else
            # This is the last prompt in the file
            local prompt_section=$(sed -n "${target_line_num},\$p" "$category_file")
        fi
        
        # Extract the prompt content (between ``` blocks)
        local prompt_text=$(echo "$prompt_section" | sed -n '/```/,/```/p' | sed '1d' | sed '$d')
        echo "$prompt_text"
    fi
}

# Function to copy prompt in specific language
copy_language_prompt() {
    local prompt_content="$1"
    local language="$2"
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BLUE" "$(get_string "LOOKING_FOR_LANGUAGE_VERSION" "$interface_lang") $language $(get_string "VERSION" "$interface_lang")"
    
    # Get the current prompt title and category from the search results
    local current_prompt_title=""
    local current_category=""
    
    # Extract prompt title from the current search result
    if [[ -n "${SEARCH_RESULTS_TITLES[0]}" ]]; then
        local title="${SEARCH_RESULTS_TITLES[0]}"
        # Extract title (remove ### and any numbering)
        if [[ "$title" =~ ^###\ ([0-9]+)\.\ (.+) ]]; then
            current_prompt_title="${BASH_REMATCH[2]}"
        elif [[ "$title" =~ ^###\ (.+) ]]; then
            current_prompt_title="${BASH_REMATCH[1]}"
        fi
        
        # Get category from the file path
        local file="${SEARCH_RESULTS_FILES[0]}"
        current_category=$(basename "$file" .md)
    fi
    
    if [[ -z "$current_prompt_title" ]] || [[ -z "$current_category" ]]; then
        print_color "$RED" "$(get_string "COULD_NOT_DETERMINE" "$interface_lang")"
        copy_prompt_to_clipboard "$prompt_content"
        return
    fi
    
    # Check if the language folder exists
    local language_dir="$SCRIPT_DIR/Prompts/$language"
    if [[ ! -d "$language_dir" ]]; then
        print_color "$YELLOW" "$(get_string "LANGUAGE_FOLDER_NOT_FOUND" "$interface_lang") $language_dir"
        print_color "$CYAN" "$(get_string "COPYING_ENGLISH_INSTEAD" "$interface_lang")"
        copy_prompt_to_clipboard "$prompt_content"
        return
    fi
    
    # Check if the category file exists in the language folder
    local language_category_file="$language_dir/$current_category.md"
    if [[ ! -f "$language_category_file" ]]; then
        print_color "$YELLOW" "$(get_string "CATEGORY_FILE_NOT_FOUND" "$interface_lang") $language_category_file"
        print_color "$CYAN" "$(get_string "COPYING_ENGLISH_INSTEAD" "$interface_lang")"
        copy_prompt_to_clipboard "$prompt_content"
        return
    fi
    
    # Find the position of the current prompt in the English file
    local english_category_file="$SCRIPT_DIR/Prompts/EN/$current_category.md"
    local prompt_position=$(find_prompt_position "$english_category_file" "$current_prompt_title")
    
    if [[ $prompt_position -eq 0 ]]; then
        print_color "$YELLOW" "$(get_string "COULD_NOT_FIND_PROMPT_POSITION" "$interface_lang") '$current_prompt_title'"
        print_color "$CYAN" "$(get_string "COPYING_ENGLISH_INSTEAD" "$interface_lang")"
        copy_prompt_to_clipboard "$prompt_content"
        return
    fi
    
    print_color "$CYAN" "$(get_string "FOUND_PROMPT_AT_POSITION" "$interface_lang") $prompt_position $(get_string "FOUND_PROMPT_AT_POSITION_SUFFIX" "$interface_lang") $current_category"
    
    # Get the prompt at the same position in the target language
    local translated_prompt=$(get_prompt_by_position "$language_category_file" "$prompt_position")
    
    if [[ -z "$translated_prompt" ]]; then
        print_color "$YELLOW" "$(get_string "COULD_NOT_FIND_AT_POSITION" "$interface_lang") $prompt_position $(get_string "NOT_FOUND_IN_LANGUAGE" "$interface_lang") $language"
        print_color "$CYAN" "$(get_string "COPYING_ENGLISH_INSTEAD" "$interface_lang")"
        copy_prompt_to_clipboard "$prompt_content"
        return
    fi
    
    # Copy the translated prompt to clipboard
    print_color "$GREEN" "$(get_string "FOUND_LANGUAGE_VERSION" "$interface_lang") $language $(get_string "LANGUAGE_VERSION_OF_PROMPT" "$interface_lang") '$current_prompt_title' $(get_string "POSITION" "$interface_lang") $prompt_position) $(get_string "IN" "$interface_lang") $current_category"
    copy_prompt_to_clipboard "$translated_prompt"
}

# Function for interactive search
interactive_search() {
    # Refresh prompts directory in case language changed
    refresh_prompts_directory
    
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    print_color "$BLUE" "$(get_string "SEARCH_TOOL_TITLE" "$interface_lang")"
    echo ""
    print_color "$CYAN" "Type 'quit' or 'q' to exit, 'help' for tips"
    echo ""
    
    while true; do
        echo -n "$(get_string "ENTER_SEARCH_KEYWORDS" "$interface_lang"): "
        read -r keywords </dev/tty
        
        if [[ "$keywords" == "quit" ]] || [[ "$keywords" == "q" ]]; then
            print_color "$GREEN" "Goodbye!"
            break
        fi
        
        if [[ "$keywords" == "help" ]]; then
            print_color "$YELLOW" "Search Tips:"
            print_color "$CYAN" "  • Use multiple words: 'machine learning neural'"
            print_color "$CYAN" "  • Be specific: 'data analysis' instead of just 'data'"
            print_color "$CYAN" "  • Try different terms: 'AI' or 'artificial intelligence'"
            echo ""
            continue
        fi
        
        if [[ -z "$keywords" ]]; then
            print_color "$YELLOW" "Please enter some keywords to search."
            continue
        fi
        
        echo ""
        print_color "$BLUE" "🔍 Searching for: '$keywords'"
        echo ""
        
        # Convert keywords to array
        read -ra search_terms <<< "$keywords"
        
        # Perform search
        clear_search_results
        for file in "$PROMPTS_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                search_in_file "$file" "${search_terms[@]}"
            fi
        done
        
        local total_results=$SEARCH_RESULTS_COUNT
        
        display_search_summary "$total_results"
        
        read -r selection </dev/tty
        
        if [[ -z "$selection" ]]; then
            print_color "$YELLOW" "Skipping prompt details."
        elif [[ "$selection" == "m" ]] || [[ "$selection" == "M" ]]; then
            print_color "$BLUE" "Returning to search options menu..."
            return 0
        elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le $total_results ]]; then
            show_prompt_details "$selection"
            # If user chose to go back to search results, redisplay them
            if [[ $? -eq 0 ]]; then
                echo ""
                display_search_summary "$total_results"
                read -r selection2 </dev/tty
                
                if [[ -z "$selection2" ]]; then
                    print_color "$YELLOW" "Skipping prompt details."
                elif [[ "$selection2" == "m" ]] || [[ "$selection2" == "M" ]]; then
                    print_color "$BLUE" "Returning to search options menu..."
                    return 0
                elif [[ "$selection2" =~ ^[0-9]+$ ]] && [[ $selection2 -ge 1 ]] && [[ $selection2 -le $total_results ]]; then
                    show_prompt_details "$selection2"
                else
                    print_color "$RED" "Invalid selection. Skipping prompt details."
                fi
            fi
        else
            print_color "$RED" "Invalid selection. Skipping prompt details."
        fi
        
        echo ""
    done
}

# Function to show search options menu
show_search_options_menu() {
    while true; do
        print_header
        local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
        
        print_color "$BOLD$CYAN" "$(get_string "SEARCH_MENU_TITLE" "$interface_lang")"
        echo ""
        print_color "$GREEN" "$(get_string "SIMPLE_SEARCH_OPTIONS" "$interface_lang")"
        echo ""
        print_color "$YELLOW" "  1. $(get_string "INTERACTIVE_SEARCH_RECOMMENDED" "$interface_lang")"
        print_color "$YELLOW" "  2. $(get_string "QUICK_KEYWORD_SEARCH" "$interface_lang")"
        print_color "$YELLOW" "  3. $(get_string "BROWSE_ALL_CATEGORIES" "$interface_lang")"
        print_color "$YELLOW" "  4. $(get_string "BACK_TO_MAIN_MENU" "$interface_lang")"
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo -n "$(get_string "SELECT_OPTION_1_4" "$interface_lang") "
        read -r search_choice </dev/tty
        
        case $search_choice in
            1)
                print_color "$BLUE" "$(get_string "LAUNCHING_INTERACTIVE_SEARCH" "$interface_lang")"
                echo ""
                interactive_search
                ;;
            2)
                echo ""
                echo -n "$(get_string "ENTER_KEYWORDS_TO_SEARCH" "$interface_lang") "
                read -r keywords </dev/tty
                if [[ -n "$keywords" ]]; then
                    echo ""
                    print_color "$BLUE" "$(get_string "SEARCHING_FOR" "$interface_lang") $keywords"
                    echo ""
                    perform_search "$keywords"
                fi
                ;;
            3)
                echo ""
                print_color "$BLUE" "$(get_string "LAUNCHING_CATEGORY_BROWSER" "$interface_lang")"
                show_category_browser
                
                # Check if user wants to return to search menu
                if [[ $? -eq 1 ]]; then
                    # User chose to go back to search menu, continue loop
                    continue
                fi
                ;;
            4|*)
                print_color "$BLUE" "$(get_string "RETURNING_TO_MAIN_MENU" "$interface_lang")"
                exit 0
                ;;
        esac
    done
}

# Function to perform search
perform_search() {
    local keywords="$1"
    local search_terms=("$@")
    
    # Refresh prompts directory in case language changed
    refresh_prompts_directory
    
    # Search in all prompts files in the current language directory
    clear_search_results
    for file in "$PROMPTS_DIR"/*.md; do
        if [[ -f "$file" ]]; then
            search_in_file "$file" "${search_terms[@]}"
        fi
    done
    
    local total_results=$SEARCH_RESULTS_COUNT
    
    if [[ $total_results -eq 0 ]]; then
        print_color "$YELLOW" "No results found for '$keywords'"
        print_color "$CYAN" "Try different keywords or be more specific"
        echo ""
        print_color "$BLUE" "Press Enter to return to search menu..."
        read -r input </dev/tty
        return
    fi
    
    display_search_summary "$total_results"
    
    read -r selection </dev/tty
    
    if [[ -z "$selection" ]]; then
        print_color "$YELLOW" "Skipping prompt details."
    elif [[ "$selection" == "m" ]] || [[ "$selection" == "M" ]]; then
        print_color "$BLUE" "Returning to search options menu..."
        return
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le $total_results ]]; then
        show_prompt_details "$selection"
        # If user chose to go back to search results, redisplay them
        if [[ $? -eq 0 ]]; then
            echo ""
            display_search_summary "$total_results"
            read -r selection2 </dev/tty
            
            if [[ -z "$selection2" ]]; then
                print_color "$YELLOW" "Skipping prompt details."
            elif [[ "$selection2" == "m" ]] || [[ "$selection2" == "M" ]]; then
                print_color "$BLUE" "Returning to search options menu..."
                return
            elif [[ "$selection2" =~ ^[0-9]+$ ]] && [[ $selection2 -ge 1 ]] && [[ $selection2 -le $total_results ]]; then
                show_prompt_details "$selection2"
            else
                print_color "$RED" "Invalid selection. Skipping prompt details."
            fi
        fi
    else
        print_color "$RED" "Invalid selection. Skipping prompt details."
    fi
}

# Function to print header
print_header() {
    clear
    print_color "$BOLD$BLUE" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$BOLD$BLUE" "║                                                              ║"
    print_color "$BOLD$BLUE" "║           🎓 AWESOME ACADEMIC PROMPTS TOOLKIT 🎓                 ║"
    print_color "$BOLD$BLUE" "║                                                              ║"
    print_color "$BOLD$BLUE" "║        Your Complete Academic AI Prompt Management           ║"
    print_color "$BOLD$BLUE" "║                     Command Center                           ║"
    print_color "$BOLD$BLUE" "║                                                              ║"
    print_color "$BOLD$BLUE" "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

# Main function
main() {
    # Refresh prompts directory to use correct language
    refresh_prompts_directory
    
    # Default options
    local INTERACTIVE=false
    local LIST_CATEGORIES=false
    local BROWSE_CATEGORIES=false
    local CATEGORY=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -l|--list-categories)
                LIST_CATEGORIES=true
                shift
                ;;
            -b|--browse-categories)
                BROWSE_CATEGORIES=true
                shift
                ;;
            -c|--category)
                CATEGORY="$2"
                shift 2
                ;;
            -*)
                print_color "$RED" "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Check if prompts directory exists
    if [[ ! -d "$PROMPTS_DIR" ]]; then
        print_color "$RED" "Error: Prompts directory not found at $PROMPTS_DIR"
        print_color "$YELLOW" "Make sure you're running this from the correct directory"
        exit 1
    fi
    
    # Handle special modes
    if [[ "$LIST_CATEGORIES" == "true" ]]; then
        list_categories
        exit 0
    fi
    
    if [[ "$BROWSE_CATEGORIES" == "true" ]]; then
        show_category_browser
        exit 0
    fi
    
    if [[ "$INTERACTIVE" == "true" ]]; then
        interactive_search
        exit 0
    fi
    
    # Handle category-specific search
    if [[ -n "$CATEGORY" ]]; then
        local category_file="$PROMPTS_DIR/$CATEGORY.md"
        if [[ ! -f "$category_file" ]]; then
            print_color "$RED" "Error: Category file not found: $category_file"
            print_color "$YELLOW" "Use -l to list available categories"
            exit 1
        fi
        
        if [[ $# -eq 0 ]]; then
            print_color "$YELLOW" "No search terms provided for category search"
            print_color "$CYAN" "Usage: $0 -c $CATEGORY <keywords>"
            exit 1
        fi
        
        local search_terms=("$@")
        print_color "$BLUE" "🔍 Searching in category '$CATEGORY' for: $(IFS=' '; echo "${search_terms[*]}")"
        echo ""
        
        clear_search_results
        search_in_file "$category_file" "${search_terms[@]}"
        local total_results=$SEARCH_RESULTS_COUNT
        
        if [[ $total_results -eq 0 ]]; then
            print_color "$YELLOW" "No results found in category '$CATEGORY'"
        exit 0
    fi
    
        display_search_summary "$total_results"
        
        read -r selection </dev/tty
        
        if [[ -z "$selection" ]]; then
            print_color "$YELLOW" "Skipping prompt details."
        elif [[ "$selection" == "m" ]] || [[ "$selection" == "M" ]]; then
            print_color "$BLUE" "Returning to search options menu..."
            show_search_options_menu
        elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le $total_results ]]; then
            show_prompt_details "$selection"
        else
            print_color "$RED" "Invalid selection. Skipping prompt details."
        fi
        return 0
    fi
    
    # Regular keyword search
    if [[ $# -eq 0 ]]; then
        # Show search options menu when no arguments provided
        show_search_options_menu
        exit 0
    fi
    
    local search_terms=("$@")
    perform_search "${search_terms[@]}"
}

# Run main function
main "$@"
