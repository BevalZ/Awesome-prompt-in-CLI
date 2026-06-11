#!/bin/bash
#
# Extract Prompts from Markdown Files
# Generates JSON entries for missing categories to synchronize with index
#

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="${SCRIPT_DIR}/Prompts"

# Category mapping and ID prefixes
declare -A ID_PREFIXES=(
    [business-management]="busm"
    [engineering]="eng"
    [humanities]="hum"
    [natural-sciences]="natsci"
    [social-sciences]="socsci"
)

# Extract prompt count from markdown file
count_prompts() {
    local file=$1
    grep -c "^### " "$file" 2>/dev/null || echo 0
}

# Extract prompt titles from markdown file
extract_prompt_titles() {
    local file=$1
    grep "^### " "$file" 2>/dev/null | sed 's/^### //' || echo ""
}

# Generate index entries for a category
generate_category_entry() {
    local category=$1
    local file="${PROMPTS_DIR}/EN/${category}.md"
    local prefix="${ID_PREFIXES[$category]}"
    
    if [ ! -f "$file" ]; then
        echo "File not found: $file" >&2
        return 1
    fi
    
    local prompt_count=$(count_prompts "$file")
    
    echo "    \"$category\": {"
    echo "      \"prompts\": ["
    
    if [ "$prompt_count" -gt 0 ]; then
        local titles=$(extract_prompt_titles "$file")
        local position=1
        
        while IFS= read -r title; do
            # Clean the title
            title=$(echo "$title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [ -z "$title" ]; then
                continue
            fi
            
            # Generate ID
            local id_num=$(printf "%03d" "$position")
            local id="${prefix}_${id_num}"
            
            echo "        {"
            echo "          \"id\": \"${id}\","
            echo "          \"position\": ${position},"
            echo "          \"en_title\": \"${title}\","
            echo "          \"description\": \"[Auto-extracted from markdown - review and update]\""
            
            if [ "$position" -lt "$prompt_count" ]; then
                echo "        },"
            else
                echo "        }"
            fi
            
            ((position++))
        done <<< "$titles"
    fi
    
    echo "      ]"
    echo "    }"
}

# Main script
main() {
    echo -e "${BOLD}${BLUE}Extracting Prompts from Markdown Files${NC}\n"
    
    # Missing categories
    local missing_cats=(business-management engineering humanities natural-sciences social-sciences)
    
    echo -e "${BOLD}Categories to synchronize:${NC}"
    for cat in "${missing_cats[@]}"; do
        local count=$(count_prompts "${PROMPTS_DIR}/EN/${cat}.md")
        echo -e "${GREEN}✓${NC} ${cat}: ${count} prompts"
    done
    
    # Generate JSON structure
    echo -e "\n${BOLD}${BLUE}Generated JSON for Missing Categories:${NC}\n"
    
    echo "{"
    for i in "${!missing_cats[@]}"; do
        local cat="${missing_cats[$i]}"
        generate_category_entry "$cat"
        
        if [ "$i" -lt $((${#missing_cats[@]} - 1)) ]; then
            echo ","
        fi
    done
    echo "}"
    
    # Generate statistics
    echo -e "\n${BOLD}${BLUE}Statistics:${NC}\n"
    
    local total=0
    for cat in "${missing_cats[@]}"; do
        local count=$(count_prompts "${PROMPTS_DIR}/EN/${cat}.md")
        echo "- ${cat}: ${count} prompts"
        ((total += count))
    done
    echo ""
    echo "Total prompts to add: ${total}"
    echo "Total indexed prompts (current): 113"
    echo "Total after sync: $((113 + total))"
}

main "$@"
