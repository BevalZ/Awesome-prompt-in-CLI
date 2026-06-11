#!/usr/bin/env bash

# Main Menu Script for Awesome Academic Prompts
# Entry point for all available CLI tools

set -euo pipefail

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_FILE="$SCRIPT_DIR/Profiles/user_profile.conf"

# Load cross-platform common library
SCRIPT_LIB="$SCRIPT_DIR/scripts/lib/common.sh"
if [[ -f "$SCRIPT_LIB" ]]; then
    source "$SCRIPT_LIB"
else
    echo "Warning: common.sh not found, path conversion disabled"
fi

# Load language strings
source "$SCRIPT_DIR/Profiles/language_strings.sh" 2>/dev/null || true

# Function to calculate display width accounting for emojis
# Emojis display as 2 characters but count as 1 in bash
get_display_width() {
    local text="$1"
    # Count emoji characters (common emojis)
    local emoji_count=$(echo "$text" | grep -o '[🎓⚙️🔍📊💾🌐📝🏷️📋📚🚪🔙]' 2>/dev/null | wc -l)
    emoji_count=$((emoji_count + 0))  # Ensure it's a number
    local char_count=${#text}
    # Subtract emoji count (they're counted in char_count) and add 2 per emoji for display width
    echo $((char_count + emoji_count))
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
# Function to print header
print_header() {
    clear
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    local title=$(get_string "MAIN_TITLE" "$interface_lang")
    local subtitle=$(get_string "MAIN_SUBTITLE" "$interface_lang")
    local subtitle2=$(get_string "MAIN_SUBTITLE2" "$interface_lang")
    
    # Calculate dynamic width based on content using display width
    local title_len=$(get_display_width "$title")
    local subtitle_len=$(get_display_width "$subtitle")
    local subtitle2_len=$(get_display_width "$subtitle2")
    
    # Find the longest line and add padding
    local max_len=$((title_len > subtitle_len ? title_len : subtitle_len))
    max_len=$((max_len > subtitle2_len ? max_len : subtitle2_len))
    max_len=$((max_len + 8))  # Add padding
    
    # Ensure minimum width
    if [[ $max_len -lt 60 ]]; then
        max_len=60
    fi
    
    # Create border line
    local border_line=""
    for ((i=0; i<max_len; i++)); do
        border_line="${border_line}═"
    done
    
    # Create empty line
    local empty_line=""
    for ((i=0; i<max_len; i++)); do
        empty_line="${empty_line} "
    done
    
    # Center the text with proper padding
    local title_left_pad=$(( (max_len - title_len) / 2 ))
    local title_right_pad=$(( max_len - title_len - title_left_pad ))
    
    local subtitle_left_pad=$(( (max_len - subtitle_len) / 2 ))
    local subtitle_right_pad=$(( max_len - subtitle_len - subtitle_left_pad ))
    
    local subtitle2_left_pad=$(( (max_len - subtitle2_len) / 2 ))
    local subtitle2_right_pad=$(( max_len - subtitle2_len - subtitle2_left_pad ))
    
    local title_spaces_left=""
    local title_spaces_right=""
    local subtitle_spaces_left=""
    local subtitle_spaces_right=""
    local subtitle2_spaces_left=""
    local subtitle2_spaces_right=""
    
    for ((i=0; i<title_left_pad; i++)); do
        title_spaces_left="${title_spaces_left} "
    done
    for ((i=0; i<title_right_pad; i++)); do
        title_spaces_right="${title_spaces_right} "
    done
    
    for ((i=0; i<subtitle_left_pad; i++)); do
        subtitle_spaces_left="${subtitle_spaces_left} "
    done
    for ((i=0; i<subtitle_right_pad; i++)); do
        subtitle_spaces_right="${subtitle_spaces_right} "
    done
    
    for ((i=0; i<subtitle2_left_pad; i++)); do
        subtitle2_spaces_left="${subtitle2_spaces_left} "
    done
    for ((i=0; i<subtitle2_right_pad; i++)); do
        subtitle2_spaces_right="${subtitle2_spaces_right} "
    done
    
    print_color "$BOLD$BLUE" "╔${border_line}╗"
    print_color "$BOLD$BLUE" "║${empty_line}║"
    print_color "$BOLD$BLUE" "║${title_spaces_left}${title}${title_spaces_right}║"
    print_color "$BOLD$BLUE" "║${empty_line}║"
    print_color "$BOLD$BLUE" "║${subtitle_spaces_left}${subtitle}${subtitle_spaces_right}║"
    print_color "$BOLD$BLUE" "║${subtitle2_spaces_left}${subtitle2}${subtitle2_spaces_right}║"
    print_color "$BOLD$BLUE" "║${empty_line}║"
    print_color "$BOLD$BLUE" "╚${border_line}╝"
    echo ""
}

# Function to show main menu
show_main_menu() {
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$CYAN" "$(get_string "AVAILABLE_TOOLS" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  1. $(get_string "ADD_PROMPT" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "ADD_PROMPT_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  2. $(get_string "SEARCH_PROMPTS" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "SEARCH_PROMPTS_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  3. $(get_string "MANAGE_CATEGORIES" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "MANAGE_CATEGORIES_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  4. $(get_string "REPO_STATS" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "REPO_STATS_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  5. $(get_string "TRANSLATION_TOOLS" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "TRANSLATION_TOOLS_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  6. $(get_string "DOCUMENTATION" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "DOCUMENTATION_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  7. $(get_string "SETTINGS" "$interface_lang")"
    print_color "$YELLOW" "     └─ $(get_string "SETTINGS_DESC" "$interface_lang")"
    echo ""
    print_color "$GREEN" "  8. $(get_string "EXIT" "$interface_lang")"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Function to show statistics
show_statistics() {
    # Save current shell options
    local old_opts=$(set +o)
    
    # Disable strict error handling for this function
    set +euo pipefail
    
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    print_color "$BOLD$CYAN" "$(get_string "STATS_MENU_TITLE" "$interface_lang")"
    echo ""
    
    local prompts_dir="$SCRIPT_DIR/Prompts/EN"
    
    if [[ ! -d "$prompts_dir" ]]; then
        print_color "$RED" "❌ Prompts directory not found at: $prompts_dir"
        print_color "$BLUE" "Press Enter or type 'q' to return to main menu..."
        read -r input </dev/tty
        if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
            return
        fi
        return
    fi
    
    local total_files=0
    local total_prompts=0
    local total_research_areas=0
    local total_prompt_categories=0
    
    print_color "$BLUE" "📂 Categories Overview:"
    echo ""
    
    for file in "$prompts_dir"/*.md; do
        [[ -f "$file" ]] || continue
        
        ((total_files++))
        local category=$(basename "$file" .md)
        local title=$(head -n 1 "$file" | sed 's/^# //')
        
        # Count prompts
        local prompt_count=0
        if grep -q "^### " "$file" 2>/dev/null; then
            prompt_count=$(grep -c "^### " "$file" 2>/dev/null)
        fi
        
        # Count research areas
        local research_count=0
        if sed -n '/## Research Areas/,/^## /p' "$file" | grep -q '^- ' 2>/dev/null; then
            research_count=$(sed -n '/## Research Areas/,/^## /p' "$file" | grep -c '^- ' 2>/dev/null)
        fi
        
        # Count prompt categories
        local category_count=0
        if sed -n '/## Prompt Categories/,/^## /p' "$file" | grep -q '^- ' 2>/dev/null; then
            category_count=$(sed -n '/## Prompt Categories/,/^## /p' "$file" | grep -c '^- ' 2>/dev/null)
        fi
        
        total_prompts=$((total_prompts + prompt_count))
        total_research_areas=$((total_research_areas + research_count))
        total_prompt_categories=$((total_prompt_categories + category_count))
        
        printf "  %-25s %s\n" "$category" "($prompt_count prompts)"
        print_color "$YELLOW" "    └─ $title"
        echo ""
    done
    
    if [[ $total_files -eq 0 ]]; then
        print_color "$YELLOW" "No category files found in $prompts_dir"
        print_color "$BLUE" "Press Enter or type 'q' to return to main menu..."
        read -r input </dev/tty
        if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
            return
        fi
        return
    fi
    
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BOLD$GREEN" "📈 Summary:"
    echo ""
    print_color "$CYAN" "  📁 Categories:        $total_files"
    print_color "$CYAN" "  📝 Total Prompts:     $total_prompts"
    print_color "$CYAN" "  🔬 Research Areas:    $total_research_areas"
    print_color "$CYAN" "  📋 Prompt Categories: $total_prompt_categories"
    echo ""
    
    # Restore original shell options
    eval "$old_opts"
    
    # Add return to main menu option
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    print_color "$GREEN" "  1. $(get_string "RETURN_TO_MAIN" "$interface_lang")"
    print_color "$GREEN" "  2. $(get_string "VIEW_STATS_AGAIN" "$interface_lang")"
    echo ""
    
    while true; do
        echo -n "Select option (1-2) or type 'q' to return: "
        read -r stat_choice </dev/tty
        
        case $stat_choice in
            1|q|Q|"")
                break
                ;;
            2)
                show_statistics
                return
                ;;
            *)
                print_color "$RED" "Invalid choice. Please select 1-2 or type 'q' to return."
                sleep 1
                ;;
        esac
    done
}

# Function to show documentation menu
show_documentation_menu() {
    while true; do
        print_header
        local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
        
        print_color "$BOLD$CYAN" "$(get_string "DOC_MENU_TITLE" "$interface_lang")"
        echo ""
        print_color "$GREEN" "  1. $(get_string "QUICK_START_COMMON" "$interface_lang")"
        print_color "$YELLOW" "     └─ Most frequently used commands and workflows"
        echo ""
        print_color "$GREEN" "  2. $(get_string "TOOLS_OVERVIEW" "$interface_lang")"
        print_color "$YELLOW" "     └─ Complete tool capabilities and features summary"
        echo ""
        print_color "$GREEN" "  3. $(get_string "REPO_STRUCTURE" "$interface_lang")"
        print_color "$YELLOW" "     └─ Project organization and prompt formatting guide"
        echo ""
        print_color "$GREEN" "  4. $(get_string "COMPLETE_DOCS" "$interface_lang")"
        print_color "$YELLOW" "     └─ Full comprehensive documentation"
        echo ""
        print_color "$GREEN" "  5. $(get_string "COMMAND_HELP" "$interface_lang")"
        print_color "$YELLOW" "     └─ Tool help commands and usage examples"
        echo ""
        print_color "$GREEN" "  6. $(get_string "LANGUAGES_CATEGORIES" "$interface_lang")"
        print_color "$YELLOW" "     └─ Multilingual support and category overview"
        echo ""
        print_color "$GREEN" "  7. $(get_string "SMART_NAVIGATION" "$interface_lang")"
        print_color "$YELLOW" "     └─ Role-based documentation paths"
        echo ""
        print_color "$GREEN" "  8. $(get_string "BACK_TO_MENU" "$interface_lang")"
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo -n "$(get_string "SELECT_OPTION" "$interface_lang") (1-8) or type 'q' to return: "
        read -r choice </dev/tty
        
        case $choice in
            1)
                show_quick_start_guide
                ;;
            2)
                show_tools_overview
                ;;
            3)
                show_structure_and_format
                ;;
            4)
                if [[ -f "$SCRIPT_DIR/README.md" ]]; then
                    less "$SCRIPT_DIR/README.md"
                    print_color "$BLUE" "Press Enter or type 'q' to return to documentation menu..."
                    read -r input </dev/tty
                    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
                        break
                    fi
                else
                    print_color "$RED" "README.md not found!"
                    print_color "$BLUE" "Press Enter or type 'q' to return to documentation menu..."
                    read -r input </dev/tty
                    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
                        break
                    fi
                fi
                ;;
            5)
                show_command_help
                ;;
            6)
                show_languages_categories_guide
                ;;
            7)
                show_smart_navigation_guide
                ;;
            8|q|Q|"")
                break
                ;;
            *)
                print_color "$RED" "Invalid choice. Please select 1-8 or type 'q' to return."
                sleep 1
                ;;
        esac
    done
}

# Function to show quick start guide
show_quick_start_guide() {
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BOLD$CYAN" "$(get_string "QUICK_START_TITLE" "$interface_lang")"
    echo ""
    print_color "$GREEN" "🔍 Most Common Commands:"
    echo ""
    print_color "$YELLOW" "Find a Prompt:"
    print_color "$CYAN" "  ./scripts/search_prompts.sh machine learning"
    print_color "$CYAN" "  ./scripts/search_prompts.sh -i  # interactive mode"
    echo ""
    print_color "$YELLOW" "Add a New Prompt:"
    print_color "$CYAN" "  ./scripts/add_prompt.sh"
    print_color "$CYAN" "  # Follow the interactive prompts"
    echo ""
    print_color "$YELLOW" "Browse Categories:"
    print_color "$CYAN" "  ./scripts/search_prompts.sh -l  # list all categories"
    print_color "$CYAN" "  ./scripts/manage_categories.sh -l  # list areas/categories"
    echo ""
    print_color "$YELLOW" "Use Different Languages:"
    print_color "$CYAN" "  Navigate to: Prompts/[LANGUAGE]/ (e.g., Prompts/ZH/, Prompts/JP/)"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BLUE" "$(get_string "PRESS_ENTER_RETURN" "$interface_lang") documentation menu..."
    read -r input </dev/tty
    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
        return
    fi
}

# Function to show tools overview
show_tools_overview() {
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BOLD$CYAN" "$(get_string "TOOLS_OVERVIEW_TITLE" "$interface_lang")"
    echo ""
    print_color "$GREEN" "📝 Add Prompt Tool (add_prompt.sh):"
    print_color "$CYAN" "  • Interactive prompt creation with validation"
    print_color "$CYAN" "  • Auto-numbering and category selection"
    print_color "$CYAN" "  • English content detection and preview"
    echo ""
    print_color "$GREEN" "🔍 Search Tool (search_prompts.sh):"
    print_color "$CYAN" "  • Keyword search across all prompts"
    print_color "$CYAN" "  • Category filtering and tag-based search"
    print_color "$CYAN" "  • Interactive mode and verbose output"
    echo ""
    print_color "$GREEN" "🏷️ Category Management (manage_categories.sh):"
    print_color "$CYAN" "  • View and add Research Areas"
    print_color "$CYAN" "  • Manage Prompt Categories"
    print_color "$CYAN" "  • Batch operations and duplicate prevention"
    echo ""
    print_color "$GREEN" "🌍 Translation Tools (translate_prompts.sh):"
    print_color "$CYAN" "  • Status checking across 12 languages"
    print_color "$CYAN" "  • Consistency verification"
    print_color "$CYAN" "  • Prompt counting and statistics"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BLUE" "$(get_string "PRESS_ENTER_RETURN" "$interface_lang") documentation menu..."
    read -r input </dev/tty
    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
        return
    fi
}

# Function to show structure and format guide
show_structure_and_format() {
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BOLD$CYAN" "$(get_string "STRUCTURE_FORMAT_TITLE" "$interface_lang")"
    echo ""
    print_color "$GREEN" "📂 Directory Structure:"
    print_color "$CYAN" "  Prompts/"
    print_color "$CYAN" "  ├── EN/ (English)     ├── JP/ (Japanese)   ├── ZH/ (Chinese)"
    print_color "$CYAN" "  ├── DE/ (German)      ├── FR/ (French)     ├── ES/ (Spanish)"
    print_color "$CYAN" "  ├── IT/ (Italian)     ├── PT/ (Portuguese) ├── RU/ (Russian)"
    print_color "$CYAN" "  ├── AR/ (Arabic)      ├── KO/ (Korean)     └── HI/ (Hindi)"
    echo ""
    print_color "$GREEN" "📋 Prompt Format:"
    print_color "$CYAN" "  ### [Number]. [Descriptive Title]"
    print_color "$CYAN" "  **Tags:** \`Research Area\` | \`Prompt Category\`"
    print_color "$CYAN" "  **Description:** Brief explanation..."
    print_color "$CYAN" "  **Prompt:**"
    print_color "$CYAN" "  \`\`\`"
    print_color "$CYAN" "  [The actual prompt text goes here]"
    print_color "$CYAN" "  \`\`\`"
    echo ""
    print_color "$GREEN" "📊 Categories (9 per language):"
    print_color "$CYAN" "  • business-management.md    • computer-science.md"
    print_color "$CYAN" "  • engineering.md           • general.md"
    print_color "$CYAN" "  • humanities.md            • mathematics-statistics.md"
    print_color "$CYAN" "  • medical-sciences.md      • natural-sciences.md"
    print_color "$CYAN" "  • social-sciences.md"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BLUE" "$(get_string "PRESS_ENTER_RETURN" "$interface_lang") documentation menu..."
    read -r input </dev/tty
    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
        return
    fi
}

# Function to show command help
show_command_help() {
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BOLD$CYAN" "$(get_string "COMMAND_HELP_TITLE" "$interface_lang")"
    echo ""
    print_color "$GREEN" "🛠️ Tool Help Commands:"
    echo ""
    print_color "$YELLOW" "Add Prompt Tool:"
    print_color "$CYAN" "  ./scripts/add_prompt.sh --help"
    echo ""
    print_color "$YELLOW" "Search Tool:"
    print_color "$CYAN" "  ./scripts/search_prompts.sh --help"
    print_color "$CYAN" "  ./scripts/search_prompts.sh machine learning"
    print_color "$CYAN" "  ./scripts/search_prompts.sh -c computer-science neural"
    print_color "$CYAN" "  ./scripts/search_prompts.sh -t \"Data Analysis\""
    echo ""
    print_color "$YELLOW" "Category Management:"
    print_color "$CYAN" "  ./scripts/manage_categories.sh --help"
    print_color "$CYAN" "  ./scripts/manage_categories.sh -c computer-science"
    print_color "$CYAN" "  ./scripts/manage_categories.sh -l"
    echo ""
    print_color "$YELLOW" "Translation Tools:"
    print_color "$CYAN" "  ./scripts/translate_prompts.sh --help"
    print_color "$CYAN" "  ./scripts/translate_prompts.sh -s  # status"
    print_color "$CYAN" "  ./scripts/translate_prompts.sh -v  # verify"
    print_color "$CYAN" "  ./scripts/translate_prompts.sh -c  # count"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BLUE" "$(get_string "PRESS_ENTER_RETURN" "$interface_lang") documentation menu..."
    read -r input </dev/tty
    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
        return
    fi
}

# Function to show languages and categories guide
show_languages_categories_guide() {
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BOLD$CYAN" "$(get_string "LANGUAGES_GUIDE_TITLE" "$interface_lang")"
    echo ""
    print_color "$GREEN" "🌐 Supported Languages (12 total):"
    echo ""
    print_color "$CYAN" "🇺🇸 EN - English      🇯🇵 JP - Japanese    🇨🇳 ZH - Chinese"
    print_color "$CYAN" "🇩🇪 DE - German       🇫🇷 FR - French      🇪🇸 ES - Spanish"
    print_color "$CYAN" "🇮🇹 IT - Italian      🇵🇹 PT - Portuguese  🇷🇺 RU - Russian"
    print_color "$CYAN" "🇸🇦 AR - Arabic       🇰🇷 KO - Korean      🇮🇳 HI - Hindi"
    echo ""
    print_color "$GREEN" "📚 Academic Disciplines:"
    print_color "$CYAN" "  • Computer Science: AI, ML, Software Engineering, Data Science"
    print_color "$CYAN" "  • Natural Sciences: Physics, Chemistry, Biology, Environmental"
    print_color "$CYAN" "  • Engineering: Mechanical, Electrical, Civil, Biomedical"
    print_color "$CYAN" "  • Medical Sciences: Clinical Research, Public Health, Biomedical"
    print_color "$CYAN" "  • Social Sciences: Psychology, Sociology, Political Science"
    print_color "$CYAN" "  • Humanities: Literature, Philosophy, History, Cultural Studies"
    print_color "$CYAN" "  • Mathematics & Statistics: Pure Math, Applied Math, Statistical"
    print_color "$CYAN" "  • Business & Management: Strategy, Marketing, Finance, Operations"
    print_color "$CYAN" "  • General Academic: Interdisciplinary, Academic Writing, Research"
    echo ""
    print_color "$BOLD$GREEN" "Total: 108 category files across 12 languages"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BLUE" "$(get_string "PRESS_ENTER_RETURN" "$interface_lang") documentation menu..."
    read -r input </dev/tty
    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
        return
    fi
}

# Function to show smart navigation guide
show_smart_navigation_guide() {
    print_header
    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
    
    print_color "$BOLD$CYAN" "$(get_string "SMART_NAV_TITLE" "$interface_lang")"
    echo ""
    print_color "$GREEN" "Choose your path based on your role:"
    echo ""
    print_color "$YELLOW" "🆕 New User (Just getting started?):"
    print_color "$CYAN" "  1. Read Overview section in README.md"
    print_color "$CYAN" "  2. Try Quick Start & Common Tasks (option 1)"
    print_color "$CYAN" "  3. Use Search Tool: ./scripts/search_prompts.sh -i"
    print_color "$CYAN" "  4. Add your first prompt: ./scripts/add_prompt.sh"
    echo ""
    print_color "$YELLOW" "🔍 Prompt Hunter (Looking for existing prompts?):"
    print_color "$CYAN" "  1. Use Search Tool (Main Menu → 2)"
    print_color "$CYAN" "  2. Browse Categories: ./scripts/search_prompts.sh -l"
    print_color "$CYAN" "  3. Check Languages & Categories Guide (option 6)"
    print_color "$CYAN" "  4. Explore other languages in Prompts/ folders"
    echo ""
    print_color "$YELLOW" "✍️ Content Creator (Want to add prompts?):"
    print_color "$CYAN" "  1. Use Add Prompt Tool (Main Menu → 1)"
    print_color "$CYAN" "  2. Read Repository Structure & Format (option 3)"
    print_color "$CYAN" "  3. Review Command Help & Examples (option 5)"
    print_color "$CYAN" "  4. Check complete README.md for contribution guidelines"
    echo ""
    print_color "$YELLOW" "🛠️ Power User (Need advanced features?):"
    print_color "$CYAN" "  1. All Tools Reference: Command Help & Examples (option 5)"
    print_color "$CYAN" "  2. Translation Tools (Main Menu → 5)"
    print_color "$CYAN" "  3. Category Management (Main Menu → 3)"
    print_color "$CYAN" "  4. Complete Documentation: README.md (option 4)"
    echo ""
    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$BLUE" "$(get_string "PRESS_ENTER_RETURN" "$interface_lang") documentation menu..."
    read -r input </dev/tty
    if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
        return
    fi
}

# Function to show DeepLX translation menu
show_deeplx_menu() {
    while true; do
        print_header
        local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
        local deeplx_enabled=$(read_profile_value "DEEPLX_API_ENABLED" "false")
        
        print_color "$BOLD$CYAN" "$(get_string "DEEPLX_TRANSLATION_TITLE" "$interface_lang")"
        echo ""
        
        if [[ "$deeplx_enabled" != "true" ]]; then
            print_color "$YELLOW" "⚠️  DeepLX API is not configured"
            echo ""
        fi
        
        print_color "$GREEN" "  1. $(get_string "DEEPLX_ENABLE_API" "$interface_lang")"
        print_color "$YELLOW" "     └─ Configure or disable DeepLX API"
        echo ""
        
        if [[ "$deeplx_enabled" == "true" ]]; then
            print_color "$GREEN" "  2. $(get_string "DEEPLX_TRANSLATE_PROMPT" "$interface_lang")"
            print_color "$YELLOW" "     └─ Translate a single prompt"
            echo ""
            print_color "$GREEN" "  3. $(get_string "DEEPLX_TRANSLATE_FILE" "$interface_lang")"
            print_color "$YELLOW" "     └─ Translate a full category file"
            echo ""
            print_color "$GREEN" "  4. $(get_string "DEEPLX_BATCH_TRANSLATE" "$interface_lang")"
            print_color "$YELLOW" "     └─ Batch translate multiple files"
            echo ""
            print_color "$GREEN" "  5. $(get_string "BACK_TO_MENU" "$interface_lang")"
        else
            print_color "$GREEN" "  2. $(get_string "BACK_TO_MENU" "$interface_lang")"
        fi
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        local max_option=2
        if [[ "$deeplx_enabled" == "true" ]]; then
            max_option=5
            echo -n "$(get_string "SELECT_OPTION" "$interface_lang") (1-5) or type 'q' to return: "
        else
            echo -n "$(get_string "SELECT_OPTION" "$interface_lang") (1-2) or type 'q' to return: "
        fi
        read -r choice </dev/tty
        
        case $choice in
            1)
                print_header
                "$SCRIPT_DIR/scripts/translate_prompts.sh" --configure-api
                echo ""
                print_color "$BLUE" "Press Enter to continue..."
                read -r input </dev/tty
                ;;
            2)
                if [[ "$deeplx_enabled" != "true" ]]; then
                    break
                fi
                print_header
                print_color "$BOLD$CYAN" "$(get_string "DEEPLX_TRANSLATE_PROMPT" "$interface_lang")"
                echo ""
                print_color "$CYAN" "Interactive prompt translation is not yet implemented."
                print_color "$CYAN" "Please use the command line:"
                echo "  ./scripts/translate_prompts.sh --translate-prompt \\"
                echo "    --source-lang EN --target-lang ZH --category general \\"
                echo "    --prompt-title \"Your Prompt Title\""
                echo ""
                print_color "$BLUE" "Press Enter to continue..."
                read -r input </dev/tty
                ;;
            3)
                if [[ "$deeplx_enabled" != "true" ]]; then
                    break
                fi
                print_header
                print_color "$BOLD$CYAN" "$(get_string "DEEPLX_TRANSLATE_FILE" "$interface_lang")"
                echo ""
                print_color "$CYAN" "Interactive file translation is not yet implemented."
                print_color "$CYAN" "Please use the command line:"
                echo "  ./scripts/translate_prompts.sh --translate-file \\"
                echo "    --source-lang EN --target-lang ZH --category general"
                echo ""
                print_color "$BLUE" "Press Enter to continue..."
                read -r input </dev/tty
                ;;
            4)
                if [[ "$deeplx_enabled" != "true" ]]; then
                    break
                fi
                print_header
                print_color "$BOLD$CYAN" "$(get_string "DEEPLX_BATCH_TRANSLATE" "$interface_lang")"
                echo ""
                print_color "$CYAN" "Interactive batch translation is not yet implemented."
                print_color "$CYAN" "Please use the command line:"
                echo "  ./scripts/translate_prompts.sh --batch-translate \\"
                echo "    --source-lang EN --target-lang ZH,FR,DE"
                echo ""
                print_color "$BLUE" "Press Enter to continue..."
                read -r input </dev/tty
                ;;
            5)
                if [[ "$deeplx_enabled" == "true" ]]; then
                    break
                fi
                ;;
            q|Q|"")
                break
                ;;
            *)
                print_color "$RED" "Invalid choice. Please select a valid option or type 'q'."
                sleep 1
                ;;
        esac
    done
}

# Function to show translation menu
show_translation_menu() {
    while true; do
        print_header
        local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
        
        print_color "$BOLD$CYAN" "$(get_string "TRANSLATION_MENU_TITLE" "$interface_lang")"
        echo ""
        print_color "$GREEN" "  1. $(get_string "TRANSLATION_STATUS" "$interface_lang")"
        print_color "$YELLOW" "     └─ View translation status across all 12 languages"
        echo ""
        print_color "$GREEN" "  2. $(get_string "VERIFY_CONSISTENCY" "$interface_lang")"
        print_color "$YELLOW" "     └─ Check file consistency across all languages"
        echo ""
        print_color "$GREEN" "  3. $(get_string "COUNT_PROMPTS" "$interface_lang")"
        print_color "$YELLOW" "     └─ Count prompts in each language"
        echo ""
        print_color "$GREEN" "  4. $(get_string "LANGUAGE_OVERVIEW" "$interface_lang")"
        print_color "$YELLOW" "     └─ Show supported languages and statistics"
        echo ""
        print_color "$GREEN" "  5. $(get_string "DEEPLX_TRANSLATION_TITLE" "$interface_lang")"
        print_color "$YELLOW" "     └─ DeepLX API translation tools (configure API first)"
        echo ""
        print_color "$GREEN" "  6. $(get_string "BACK_TO_MENU" "$interface_lang")"
        echo ""
        print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo -n "$(get_string "SELECT_OPTION" "$interface_lang") (1-6) or type 'q' to return: "
        read -r choice </dev/tty
        
        case $choice in
            1)
                print_header
                "$SCRIPT_DIR/scripts/translate_prompts.sh" -s
                echo ""
                print_color "$BLUE" "Press Enter or type 'q' to return to translation menu..."
                read -r input </dev/tty
                if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
                    break
                fi
                ;;
            2)
                print_header
                "$SCRIPT_DIR/scripts/translate_prompts.sh" -v
                echo ""
                print_color "$BLUE" "Press Enter or type 'q' to return to translation menu..."
                read -r input </dev/tty
                if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
                    break
                fi
                ;;
            3)
                print_header
                "$SCRIPT_DIR/scripts/translate_prompts.sh" -c
                echo ""
                print_color "$BLUE" "Press Enter or type 'q' to return to translation menu..."
                read -r input </dev/tty
                if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
                    break
                fi
                ;;
            4)
               print_header
               print_color "$BOLD$CYAN" "🌐 Supported Languages Overview"
               echo ""
               print_color "$BLUE" "The repository supports 12 major academic languages:"
               echo ""
               print_color "$GREEN" "🇺🇸 EN - English      🇯🇵 JP - Japanese    🇨🇳 ZH - Chinese"
               print_color "$GREEN" "  DE - German       🇫🇷 FR - French      🇪🇸 ES - Spanish"
               print_color "$GREEN" "🇮🇹 IT - Italian      🇵🇹 PT - Portuguese  🇷🇺 RU - Russian"
               print_color "$GREEN" "🇸🇦 AR - Arabic       🇰🇷 KO - Korean      🇮🇳 HI - Hindi"
               echo ""
               print_color "$YELLOW" "Each language contains 9 category files:"
               print_color "$CYAN" "• business-management.md    • computer-science.md"
               print_color "$CYAN" "• engineering.md           • general.md"
               print_color "$CYAN" "• humanities.md            • mathematics-statistics.md"
               print_color "$CYAN" "• medical-sciences.md      • natural-sciences.md"
               print_color "$CYAN" "• social-sciences.md"
               echo ""
               print_color "$BOLD$GREEN" "Total: 108 category files across 12 languages"
               echo ""
               print_color "$BLUE" "Press Enter or type 'q' to return to translation menu..."
               read -r input </dev/tty
               if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
                   break
               fi
               ;;
            5)
               show_deeplx_menu
               ;;
            6|q|Q|"")
               break
               ;;
            *)
               print_color "$RED" "Invalid choice. Please select 1-6 or type 'q' to return."
               sleep 1
               ;;
            esac
    done
}

# Function to check if scripts exist
check_scripts() {
    local missing_scripts=()
    
    if [[ ! -f "$SCRIPT_DIR/scripts/add_prompt.sh" ]]; then
        missing_scripts+=("scripts/add_prompt.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/scripts/search_prompts.sh" ]]; then
        missing_scripts+=("scripts/search_prompts.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/scripts/manage_categories.sh" ]]; then
        missing_scripts+=("scripts/manage_categories.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/scripts/translate_prompts.sh" ]]; then
        missing_scripts+=("scripts/translate_prompts.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/scripts/manage_profile.sh" ]]; then
        missing_scripts+=("scripts/manage_profile.sh")
    fi
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        print_color "$RED" "⚠️  Warning: Missing scripts:"
        for script in "${missing_scripts[@]}"; do
            print_color "$YELLOW" "  - $script"
        done
        echo ""
        print_color "$BLUE" "Some menu options may not work properly."
        echo ""
        print_color "$BLUE" "Press Enter to continue anyway..."
        read -r </dev/tty
    fi
}

# Function to run tool with error handling
run_tool() {
    local tool="$1"
    local tool_name="$2"
    
    if [[ ! -f "$SCRIPT_DIR/$tool" ]]; then
        print_color "$RED" "❌ Error: $tool not found!"
        print_color "$BLUE" "Press Enter to continue..."
        read -r </dev/tty
        return
    fi
    
    if [[ ! -x "$SCRIPT_DIR/$tool" ]]; then
        print_color "$YELLOW" "Making $tool executable..."
        chmod +x "$SCRIPT_DIR/$tool"
    fi
    
    print_color "$BLUE" "🚀 Launching $tool_name..."
    echo ""
    
    # Run the tool and capture exit status
    "$SCRIPT_DIR/$tool"
    local exit_status=$?
    
    # If exit status is 0 (normal completion), show completion message
    # If exit status is non-zero (user cancelled/returned), just return to menu
    if [[ $exit_status -eq 0 ]]; then
        echo ""
        print_color "$GREEN" "✅ $tool_name completed."
        print_color "$BLUE" "Press Enter to return to main menu..."
        read -r </dev/tty
    fi
}

# Main function
main() {
    # Check for required scripts
    check_scripts
    
    while true; do
        print_header
        show_main_menu
        
        echo -n "Select option (1-8): "
        read -r choice </dev/tty
        
        case $choice in
            1)
                run_tool "scripts/add_prompt.sh" "Add Prompt Tool"
                ;;
            2)
                # Search options menu
                while true; do
                    print_header
                    local interface_lang=$(read_profile_value "INTERFACE_LANGUAGE" "EN")
                    
                    print_color "$BOLD$CYAN" "$(get_string "SEARCH_MENU_TITLE" "$interface_lang")"
                    echo ""
                    print_color "$GREEN" "🔍 Simple Search Options:"
                    echo ""
                    print_color "$YELLOW" "  1. Interactive Search (recommended)"
                    print_color "$YELLOW" "  2. Quick Keyword Search"
                    print_color "$YELLOW" "  3. Browse All Categories"
                    print_color "$YELLOW" "  4. Back to Main Menu"
                    echo ""
                    print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo ""
                    
                    echo -n "Select option (1-4): "
                    read -r search_choice </dev/tty
                    
                    case $search_choice in
                        1)
                            print_color "$BLUE" "🚀 Launching Interactive Search..."
                            echo ""
                            "$SCRIPT_DIR/scripts/search_prompts.sh" -i
                            echo ""
                            print_color "$GREEN" "✅ Interactive Search completed."
                            print_color "$BLUE" "Press Enter to return to search menu..."
                            read -r input </dev/tty
                            ;;
                        2)
                            echo ""
                            echo -n "Enter keywords to search: "
                            read -r keywords </dev/tty
                            if [[ -n "$keywords" ]]; then
                                echo ""
                                print_color "$BLUE" "🔍 Searching for: $keywords"
                                echo ""
                                "$SCRIPT_DIR/scripts/search_prompts.sh" $keywords
                                echo ""
                                print_color "$BLUE" "Press Enter to return to search menu..."
                                read -r input </dev/tty
                            fi
                            ;;
                        3)
                            echo ""
                            print_color "$BLUE" "📂 Launching Category Browser..."
                            "$SCRIPT_DIR/scripts/search_prompts.sh" -b
                            echo ""
                            print_color "$BLUE" "Press Enter to return to search menu..."
                            read -r input </dev/tty
                            ;;
                        4|*)
                            # Return to main menu
                            break
                            ;;
                    esac
                done
                ;;
            3)
                run_tool "scripts/manage_categories.sh" "Category Management Tool"
                ;;
            4)
                show_statistics
                ;;
            5)
                show_translation_menu
                ;;
            6)
                show_documentation_menu
                ;;
            7)
                run_tool "scripts/manage_profile.sh" "Profile Management Tool"
                ;;
            8)
                print_color "$GREEN" "👋 Thank you for using Awesome Academic Prompts Toolkit!"
                print_color "$BLUE" "Happy researching! 🎓✨"
                exit 0
                ;;
            *)
                print_color "$RED" "Invalid choice. Please select 1-8."
                sleep 1
                ;;
        esac
    done
}

# Show welcome message on first run
show_welcome() {
    # Check if welcome should be shown based on profile
    local show_welcome_setting=$(read_profile_value "SHOW_WELCOME" "true")
    
    if [[ "${1:-}" != "--no-welcome" ]] && [[ "$show_welcome_setting" == "true" ]]; then
        print_header
        print_color "$YELLOW" "Welcome to the Academic Prompts Toolkit! 🎉"
        echo ""
        print_color "$CYAN" "This toolkit provides comprehensive tools for managing academic AI prompts:"
        print_color "$CYAN" "• Add new prompts with proper formatting and validation"
        print_color "$CYAN" "• Search existing prompts by keywords, categories, or tags"
        print_color "$CYAN" "• Manage research areas and prompt categories"
        print_color "$CYAN" "• View repository statistics and documentation"
        print_color "$CYAN" "• Support for 12 major academic languages (108 total files)"
        echo ""
        print_color "$BLUE" "Press Enter to continue to the main menu..."
        read -r </dev/tty
    fi
}

# Run the application
show_welcome "$@"
main "$@"