#!/usr/bin/env bash

# Script to manage Research Areas and Prompt Categories in existing prompt files
# Shows existing items and allows adding new ones

set -euo pipefail

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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
    print_color "$BLUE" "📝 Research Areas and Prompt Categories Management Tool"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -l, --list              List all categories and their items"
    echo "  -c, --category FILE     Manage specific category file"
    echo "  -i, --interactive       Interactive mode (default)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive mode"
    echo "  $0 -c computer-science               # Manage computer-science.md"
    echo "  $0 -l                                # List all categories"
    echo ""
}

# Function to list all categories
list_categories() {
    print_color "$BLUE" "📂 Available Categories:"
    echo ""
    
    if [[ ! -d "$PROMPTS_DIR" ]]; then
        print_color "$RED" "Error: Prompts directory not found at $PROMPTS_DIR"
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

# Function to display existing research areas
show_research_areas() {
    local file="$1"
    local category=$(basename "$file" .md)
    
    print_color "$CYAN" "🔬 Current Research Areas in $category:"
    echo ""
    
    local areas=$(sed -n '/## Research Areas/,/^## /p' "$file" | grep '^- ' | sed 's/^- //')
    
    if [[ -z "$areas" ]]; then
        print_color "$YELLOW" "  No research areas found."
    else
        local count=1
        while IFS= read -r area; do
            printf "  %2d. %s\n" "$count" "$area"
            ((count++))
        done <<< "$areas"
    fi
    echo ""
}

# Function to display existing prompt categories
show_prompt_categories() {
    local file="$1"
    local category=$(basename "$file" .md)
    
    print_color "$MAGENTA" "📋 Current Prompt Categories in $category:"
    echo ""
    
    local categories=$(sed -n '/## Prompt Categories/,/^## /p' "$file" | grep '^- ' | sed 's/^- //')
    
    if [[ -z "$categories" ]]; then
        print_color "$YELLOW" "  No prompt categories found."
    else
        local count=1
        while IFS= read -r cat; do
            printf "  %2d. %s\n" "$count" "$cat"
            ((count++))
        done <<< "$categories"
    fi
    echo ""
}

# Function to add research area
add_research_area() {
    local file="$1"
    local category=$(basename "$file" .md)
    
    while true; do
        echo ""
        echo -n "$(get_string "ENTER_NEW_RESEARCH_AREA" "$interface_lang"): "
        read -r new_area </dev/tty
        
        if [[ "$new_area" == "done" ]] || [[ -z "$new_area" ]]; then
            if [[ -z "$new_area" ]]; then
                print_color "$YELLOW" "No research area entered."
            fi
            break
        fi
        
        # Check if area already exists
        local existing_areas=$(sed -n '/## Research Areas/,/^## /p' "$file" | grep '^- ' | sed 's/^- //')
        if echo "$existing_areas" | grep -q "^$new_area$"; then
            print_color "$YELLOW" "Research area '$new_area' already exists."
            continue
        fi
        
        # Find the line number of "## Research Areas"
        local research_line=$(grep -n "^## Research Areas" "$file" | cut -d: -f1)
        
        if [[ -z "$research_line" ]]; then
            print_color "$RED" "Error: Could not find '## Research Areas' section in $file"
            return
        fi
        
        # Find the line number where research areas end (before next ## section)
        local next_section_line=$(sed -n "$((research_line + 1)),\$p" "$file" | grep -n "^## " | head -n 1 | cut -d: -f1)
        
        if [[ -n "$next_section_line" ]]; then
            # There's another section after Research Areas
            local insert_line=$((research_line + next_section_line - 1))
        else
            # Research Areas is the last section, append at the end
            local insert_line=$(wc -l < "$file")
        fi
        
        # Insert the new research area with proper formatting
        sed -i '' "${insert_line}i\\
- $new_area" "$file"
        
        print_color "$GREEN" "✅ Added research area '$new_area' to $category"
        
        # Ask if user wants to add another
        echo -n "$(get_string "ADD_ANOTHER_RESEARCH_AREA" "$interface_lang"): "
        read -r continue_choice </dev/tty
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            break
        fi
    done
}

# Function to add prompt category
add_prompt_category() {
    local file="$1"
    local category=$(basename "$file" .md)
    
    while true; do
        echo ""
        echo -n "$(get_string "ENTER_NEW_PROMPT_CATEGORY" "$interface_lang"): "
        read -r new_category </dev/tty
        
        if [[ "$new_category" == "done" ]] || [[ -z "$new_category" ]]; then
            if [[ -z "$new_category" ]]; then
                print_color "$YELLOW" "No prompt category entered."
            fi
            break
        fi
        
        # Check if category already exists
        local existing_categories=$(sed -n '/## Prompt Categories/,/^## /p' "$file" | grep '^- ' | sed 's/^- //')
        if echo "$existing_categories" | grep -q "^$new_category$"; then
            print_color "$YELLOW" "Prompt category '$new_category' already exists."
            continue
        fi
        
        # Find the line number of "## Prompt Categories"
        local category_line=$(grep -n "^## Prompt Categories" "$file" | cut -d: -f1)
        
        if [[ -z "$category_line" ]]; then
            print_color "$RED" "Error: Could not find '## Prompt Categories' section in $file"
            return
        fi
        
        # Find the line number where prompt categories end (before next ## section or end of file)
        local next_section_line=$(sed -n "$((category_line + 1)),\$p" "$file" | grep -n "^## " | head -n 1 | cut -d: -f1)
        
        if [[ -n "$next_section_line" ]]; then
            # There's another section after Prompt Categories
            local insert_line=$((category_line + next_section_line - 1))
        else
            # Prompt Categories is the last section, append at the end
            local insert_line=$(wc -l < "$file")
        fi
        
        # Insert the new prompt category with proper formatting
        sed -i '' "${insert_line}i\\
- $new_category" "$file"
        
        print_color "$GREEN" "✅ Added prompt category '$new_category' to $category"
        
        # Ask if user wants to add another
        echo -n "$(get_string "ADD_ANOTHER_PROMPT_CATEGORY" "$interface_lang"): "
        read -r continue_choice </dev/tty
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            break
        fi
    done
}

# Function to select from list
select_from_list() {
    local title="$1"
    shift
    local options=("$@")
    
    echo ""
    print_color "$BLUE" "$title"
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}"
    done
    echo ""
    
    while true; do
        printf "Select (1-${#options[@]}): "
        read -r choice </dev/tty
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return 0
        else
            print_color "$RED" "Invalid choice. Please select 1-${#options[@]}"
        fi
    done
}

# Function to manage a specific file
manage_file() {
    local file="$1"
    local category=$(basename "$file" .md)
    
    if [[ ! -f "$file" ]]; then
        print_color "$RED" "Error: File not found: $file"
        return 1
    fi
    
    print_color "$GREEN" "📝 Managing: $category"
    local title=$(head -n 1 "$file" | sed 's/^# //')
    print_color "$BLUE" "Title: $title"
    echo ""
    
    while true; do
        # Show current state
        show_research_areas "$file"
        show_prompt_categories "$file"
        
        # Menu options
        print_color "$BLUE" "What would you like to do?"
        echo "$(get_string "ADD_RESEARCH_AREA" "$interface_lang")"
        echo "$(get_string "ADD_PROMPT_CATEGORY" "$interface_lang")"
        echo "$(get_string "REFRESH_DISPLAY" "$interface_lang")"
        echo "$(get_string "EXIT_OPTION" "$interface_lang")"
        echo ""
        
        echo -n "$(get_string "SELECT_OPTION_1_4_SHORT" "$interface_lang"): "
        read -r choice </dev/tty
        
        case $choice in
            1)
                add_research_area "$file"
                echo ""
                print_color "$BLUE" "Press Enter to continue..."
                read -r </dev/tty
                clear
                print_color "$GREEN" "📝 Managing: $category"
                print_color "$BLUE" "Title: $title"
                echo ""
                ;;
            2)
                add_prompt_category "$file"
                echo ""
                print_color "$BLUE" "Press Enter to continue..."
                read -r </dev/tty
                clear
                print_color "$GREEN" "📝 Managing: $category"
                print_color "$BLUE" "Title: $title"
                echo ""
                ;;
            3)
                clear
                print_color "$GREEN" "📝 Managing: $category"
                print_color "$BLUE" "Title: $title"
                echo ""
                ;;
            4)
                break
                ;;
            *)
                print_color "$RED" "Invalid choice. Please select 1-4."
                ;;
        esac
    done
}

# Function for interactive mode
interactive_mode() {
    print_color "$BLUE" "🎯 Interactive Category Management Mode"
    echo ""
    
    while true; do
        list_categories
        
        print_color "$BLUE" "Select a category to manage (or 'q' to quit):"
        echo -n "$(get_string "ENTER_CATEGORY_NUMBER_OR_NAME" "$interface_lang"): "
        read -r input </dev/tty
        
        if [[ "$input" == "q" ]] || [[ "$input" == "quit" ]]; then
            print_color "$GREEN" "Goodbye!"
            break
        fi
        
        local selected_file=""
        
        # Check if input is a number
        if [[ "$input" =~ ^[0-9]+$ ]]; then
            local count=1
            for file in "$PROMPTS_DIR"/*.md; do
                if [[ -f "$file" ]] && [[ $count -eq $input ]]; then
                    selected_file="$file"
                    break
                fi
                ((count++))
            done
        else
            # Check if input is a category name
            local potential_file="$PROMPTS_DIR/$input.md"
            if [[ -f "$potential_file" ]]; then
                selected_file="$potential_file"
            fi
        fi
        
        if [[ -z "$selected_file" ]]; then
            print_color "$RED" "Invalid selection. Please try again."
            echo ""
            continue
        fi
        
        clear
        manage_file "$selected_file"
        clear
    done
}

# Function to list all categories and their items
list_all_items() {
    print_color "$BLUE" "📋 All Categories with Research Areas and Prompt Categories"
    echo ""
    
    for file in "$PROMPTS_DIR"/*.md; do
        if [[ -f "$file" ]]; then
            local category=$(basename "$file" .md)
            local title=$(head -n 1 "$file" | sed 's/^# //')
            
            print_color "$GREEN" "📂 $category ($title)"
            echo ""
            
            # Show research areas
            print_color "$CYAN" "  🔬 Research Areas:"
            local areas=$(sed -n '/## Research Areas/,/^## /p' "$file" | grep '^- ' | sed 's/^- //')
            if [[ -z "$areas" ]]; then
                echo "    $(get_string "NONE" "$interface_lang")"
            else
                while IFS= read -r area; do
                    echo "    $(get_string "BULLET_POINT" "$interface_lang") $area"
                done <<< "$areas"
            fi
            echo ""
            
            # Show prompt categories
            print_color "$MAGENTA" "  📋 Prompt Categories:"
            local categories=$(sed -n '/## Prompt Categories/,/^## /p' "$file" | grep '^- ' | sed 's/^- //')
            if [[ -z "$categories" ]]; then
                echo "    $(get_string "NONE" "$interface_lang")"
            else
                while IFS= read -r cat; do
                    echo "    $(get_string "BULLET_POINT" "$interface_lang") $cat"
                done <<< "$categories"
            fi
            echo ""
            echo "----------------------------------------"
            echo ""
        fi
    done
}

# Main function
main() {
    local CATEGORY=""
    local LIST_ALL=false
    local INTERACTIVE=true
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--category)
                CATEGORY="$2"
                INTERACTIVE=false
                shift 2
                ;;
            -l|--list)
                LIST_ALL=true
                INTERACTIVE=false
                shift
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -*)
                print_color "$RED" "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                print_color "$RED" "Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if prompts directory exists
    if [[ ! -d "$PROMPTS_DIR" ]]; then
        print_color "$RED" "Error: Prompts directory not found at $PROMPTS_DIR"
        exit 1
    fi
    
    # Handle list mode
    if [[ "$LIST_ALL" == "true" ]]; then
        list_all_items
        exit 0
    fi
    
    # Handle specific category
    if [[ -n "$CATEGORY" ]]; then
        local category_file="$PROMPTS_DIR/$CATEGORY.md"
        if [[ ! -f "$category_file" ]]; then
            print_color "$RED" "Error: Category file not found: $category_file"
            exit 1
        fi
        manage_file "$category_file"
        exit 0
    fi
    
    # Default to interactive mode
    if [[ "$INTERACTIVE" == "true" ]]; then
        interactive_mode
    fi
}

# Run main function
main "$@"
