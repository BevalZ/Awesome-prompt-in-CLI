#!/usr/bin/env bash

# Translation Helper Script for Academic Prompts
# This script helps maintain consistency across all 12 language versions
# and provides DeepLX API integration for automated translation

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Script directory (parent of scripts folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/Prompts"
PROFILE_FILE="$SCRIPT_DIR/Profiles/user_profile.conf"

# Load cross-platform common library
SCRIPT_LIB="$SCRIPT_DIR/scripts/lib/common.sh"
if [[ -f "$SCRIPT_LIB" ]]; then
    source "$SCRIPT_LIB"
fi

# Load language strings
source "$SCRIPT_DIR/Profiles/language_strings.sh" 2>/dev/null || true

# Supported languages and their DeepLX codes
LANGUAGES=("EN" "JP" "ZH" "DE" "FR" "ES" "IT" "PT" "RU" "AR" "KO" "HI")
LANGUAGE_NAMES=("English" "Japanese" "Chinese" "German" "French" "Spanish" "Italian" "Portuguese" "Russian" "Arabic" "Korean" "Hindi")

# DeepLX language codes mapping
declare -A DEEPLX_LANG_MAP=(
    [EN]="EN"
    [JP]="JA"
    [ZH]="ZH"
    [DE]="DE"
    [FR]="FR"
    [ES]="ES"
    [IT]="IT"
    [PT]="PT"
    [RU]="RU"
    [AR]="AR"
    [KO]="KO"
    [HI]="HI"
)

# Function to read profile value
read_profile_value() {
    local key="$1"
    local default_value="$2"
    
    if [[ -f "$PROFILE_FILE" ]]; then
        local value=$(grep "^$key=" "$PROFILE_FILE" 2>/dev/null | cut -d'=' -f2 | cut -d'#' -f1 | tr -d ' ' || echo "")
        if [[ -n "$value" ]]; then
            echo "$value"
        else
            echo "$default_value"
        fi
    else
        echo "$default_value"
    fi
}

# Function to write profile value
write_profile_value() {
    local key="$1"
    local value="$2"
    
    if [[ ! -f "$PROFILE_FILE" ]]; then
        touch "$PROFILE_FILE"
    fi
    
    if grep -q "^$key=" "$PROFILE_FILE" 2>/dev/null; then
        sed -i.bak "s|^$key=.*|$key=$value|" "$PROFILE_FILE"
        rm -f "$PROFILE_FILE.bak"
    else
        echo "$key=$value" >> "$PROFILE_FILE"
    fi
}

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

# Function to get DeepLX language code
get_deeplx_code() {
    local lang="$1"
    echo "${DEEPLX_LANG_MAP[$lang]:-$lang}"
}

# Function to validate API configuration
validate_api_config() {
    local api_enabled=$(read_profile_value "DEEPLX_API_ENABLED" "false")
    local api_key=$(read_profile_value "DEEPLX_API_KEY" "")
    
    if [[ "$api_enabled" != "true" ]]; then
        print_color "$RED" "$(get_string "DEEPLX_API_NOT_CONFIGURED" "EN")"
        return 1
    fi
    
    if [[ -z "$api_key" ]]; then
        print_color "$RED" "$(get_string "DEEPLX_API_KEY_REQUIRED" "EN")"
        return 1
    fi
    
    return 0
}

# Function to call DeepLX API
call_deeplx_api() {
    local text="$1"
    local source_lang="$2"
    local target_lang="$3"
    local api_endpoint=$(read_profile_value "DEEPLX_API_ENDPOINT" "https://api.deeplx.org/translate")
    local api_key=$(read_profile_value "DEEPLX_API_KEY" "")
    local max_retries=3
    local retry_count=0
    
    source_lang=$(get_deeplx_code "$source_lang")
    target_lang=$(get_deeplx_code "$target_lang")
    
    while [[ $retry_count -lt $max_retries ]]; do
        local response
        response=$(curl -s -X POST "$api_endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $api_key" \
            -d "{\"text\":\"$text\",\"source_language\":\"$source_lang\",\"target_language\":\"$target_lang\"}" \
            2>/dev/null) || true
        
        if [[ -z "$response" ]]; then
            print_color "$YELLOW" "$(get_string "DEEPLX_TIMEOUT_ERROR" "EN")"
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                sleep 2
            fi
            continue
        fi
        
        # Check for errors in response
        if echo "$response" | grep -q "error"; then
            local error_msg=$(echo "$response" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
            if [[ "$error_msg" == *"429"* ]] || [[ "$error_msg" == *"rate"* ]]; then
                print_color "$YELLOW" "$(get_string "DEEPLX_RATE_LIMIT" "EN")"
                ((retry_count++))
                if [[ $retry_count -lt $max_retries ]]; then
                    sleep $((2 ** retry_count))
                fi
                continue
            elif [[ "$error_msg" == *"401"* ]] || [[ "$error_msg" == *"auth"* ]]; then
                print_color "$RED" "$(get_string "DEEPLX_AUTH_ERROR" "EN")"
                return 1
            else
                print_color "$RED" "$(get_string "DEEPLX_API_ERROR" "EN") $error_msg"
                return 1
            fi
        fi
        
        # Extract translated text
        local translated=$(echo "$response" | grep -o '"data":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [[ -n "$translated" ]]; then
            echo "$translated"
            return 0
        fi
        
        ((retry_count++))
    done
    
    return 1
}

# Function to preserve markdown formatting
preserve_markdown_formatting() {
    local text="$1"
    local source_lang="$2"
    local target_lang="$3"
    
    # Extract markdown structure (headings, lists, etc.)
    local lines=()
    local translated_lines=()
    
    while IFS= read -r line; do
        # Check if line is markdown element
        if [[ "$line" =~ ^[#\*\-\+\ ]*$ ]] || [[ "$line" =~ ^[0-9]+\. ]] || [[ -z "$line" ]]; then
            # Preserve empty lines and structure
            translated_lines+=("$line")
        else
            # Translate content lines
            local translated
            translated=$(call_deeplx_api "$line" "$source_lang" "$target_lang") || translated="$line"
            translated_lines+=("$translated")
        fi
    done <<< "$text"
    
    printf '%s\n' "${translated_lines[@]}"
}

# Function to translate a single prompt
translate_prompt() {
    local source_lang="$1"
    local target_lang="$2"
    local category="$3"
    local prompt_title="$4"
    
    local source_file="$PROMPTS_DIR/$source_lang/$category.md"
    
    if [[ ! -f "$source_file" ]]; then
        print_color "$RED" "Source file not found: $source_file"
        return 1
    fi
    
    # Extract prompt content
    local prompt_content=$(awk "/^### $prompt_title$/,/^###/ {if (!/^###$/ || NR==1) print}" "$source_file" | sed '$d')
    
    if [[ -z "$prompt_content" ]]; then
        print_color "$RED" "Prompt not found: $prompt_title"
        return 1
    fi
    
    print_color "$CYAN" "$(get_string "DEEPLX_TRANSLATING" "EN")"
    
    local translated
    translated=$(call_deeplx_api "$prompt_content" "$source_lang" "$target_lang") || return 1
    
    echo "$translated"
    return 0
}

# Function to translate a full file
translate_file() {
    local source_lang="$1"
    local target_lang="$2"
    local category="$3"
    
    local source_file="$PROMPTS_DIR/$source_lang/$category.md"
    local target_file="$PROMPTS_DIR/$target_lang/$category.md"
    
    if [[ ! -f "$source_file" ]]; then
        print_color "$RED" "Source file not found: $source_file"
        return 1
    fi
    
    print_color "$CYAN" "$(get_string "DEEPLX_TRANSLATION_IN_PROGRESS" "EN")"
    
    local translated
    translated=$(preserve_markdown_formatting "$(cat "$source_file")" "$source_lang" "$target_lang") || return 1
    
    # Backup existing file if it exists
    if [[ -f "$target_file" ]]; then
        cp "$target_file" "$target_file.bak"
    fi
    
    # Write translated content
    echo "$translated" > "$target_file"
    
    print_color "$GREEN" "✅ Translated $category.md to $target_lang"
    return 0
}

# Function to batch translate multiple files
batch_translate() {
    local source_lang="$1"
    local target_langs="$2"
    
    local categories=("business-management" "computer-science" "engineering" "general" "humanities" "mathematics-statistics" "medical-sciences" "natural-sciences" "social-sciences")
    
    # Convert comma-separated target languages to array
    IFS=',' read -ra target_lang_array <<< "$target_langs"
    
    for target_lang in "${target_lang_array[@]}"; do
        target_lang=$(echo "$target_lang" | xargs)  # Trim whitespace
        
        print_color "$BOLD$CYAN" "Translating to $target_lang..."
        
        for category in "${categories[@]}"; do
            if translate_file "$source_lang" "$target_lang" "$category"; then
                :
            fi
        done
    done
    
    print_color "$GREEN" "$(get_string "DEEPLX_TRANSLATION_COMPLETE" "EN")"
}

show_usage() {
    print_color "$BLUE" "$(get_string "TRANSLATION_HELPER_TITLE" "EN")"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Status and Verification:"
    echo "  -h, --help              Show this help message"
    echo "  -s, --status            Show translation status across all languages"
    echo "  -v, --verify            Verify file consistency across languages"
    echo "  -c, --count             Count prompts in each language"
    echo ""
    echo "DeepLX Translation (requires API configuration):"
    echo "  --translate-prompt      Translate a single prompt"
    echo "  --translate-file        Translate a full category file"
    echo "  --batch-translate       Batch translate multiple files"
    echo "  --source-lang LANG      Source language code (default: EN)"
    echo "  --target-lang LANG      Target language code(s) (comma-separated for batch)"
    echo "  --category NAME         Category file to translate (without .md)"
    echo "  --prompt-title TITLE    Prompt title to translate"
    echo ""
    echo "Configuration:"
    echo "  --configure-api         Configure DeepLX API settings"
    echo ""
    echo "Examples:"
    echo "  $0 -s                              # Show status"
    echo "  $0 --translate-file --source-lang EN --target-lang ZH --category general"
    echo "  $0 --batch-translate --source-lang EN --target-lang ZH,FR,DE"
    echo ""
}

show_status() {
    print_color "$BLUE" "$(get_string "TRANSLATION_STATUS_TITLE" "EN")"
    echo ""
    
    for i in "${!LANGUAGES[@]}"; do
        local lang="${LANGUAGES[$i]}"
        local lang_name="${LANGUAGE_NAMES[$i]}"
        local lang_dir="$PROMPTS_DIR/$lang"
        
        if [[ -d "$lang_dir" ]]; then
            local file_count=$(find "$lang_dir" -name "*.md" -type f | wc -l)
            printf "%-12s %-15s %s files\n" "🌍 $lang" "$lang_name" "$file_count"
        else
            printf "%-12s %-15s %s\n" "❌ $lang" "$lang_name" "Missing"
        fi
    done
    echo ""
}

verify_consistency() {
    print_color "$BLUE" "$(get_string "VERIFY_CONSISTENCY_TITLE" "EN")"
    echo ""
    
    local categories=("business-management" "computer-science" "engineering" "general" "humanities" "mathematics-statistics" "medical-sciences" "natural-sciences" "social-sciences")
    
    for category in "${categories[@]}"; do
        print_color "$YELLOW" "Checking $category.md:"
        
        for lang in "${LANGUAGES[@]}"; do
            local file_path="$PROMPTS_DIR/$lang/$category.md"
            if [[ -f "$file_path" ]]; then
                echo "  ✅ $lang"
            else
                echo "  ❌ $lang (missing)"
            fi
        done
        echo ""
    done
}

count_prompts() {
    print_color "$BLUE" "📈 Prompt Count by Language"
    echo ""
    
    for i in "${!LANGUAGES[@]}"; do
        local lang="${LANGUAGES[$i]}"
        local lang_name="${LANGUAGE_NAMES[$i]}"
        local lang_dir="$PROMPTS_DIR/$lang"
        
        if [[ -d "$lang_dir" ]]; then
            local total_prompts=0
            for file in "$lang_dir"/*.md; do
                if [[ -f "$file" ]]; then
                    local prompt_count=$(grep -c "^### " "$file" 2>/dev/null || echo "0")
                    if [[ "$prompt_count" =~ ^[0-9]+$ ]]; then
                        total_prompts=$((total_prompts + prompt_count))
                    fi
                fi
            done
            printf "%-12s %-15s %s prompts\n" "🌍 $lang" "$lang_name" "$total_prompts"
        else
            printf "%-12s %-15s %s\n" "❌ $lang" "$lang_name" "Missing"
        fi
    done
    echo ""
}

configure_api() {
    print_color "$BOLD$CYAN" "DeepLX API Configuration"
    echo ""
    
    read -p "Enable DeepLX API? (y/N): " -r enable_api
    
    if [[ $enable_api =~ ^[Yy]$ ]]; then
        read -p "$(get_string "DEEPLX_ENTER_API_KEY" "EN") " -r api_key
        
        if [[ -z "$api_key" ]]; then
            print_color "$RED" "API key cannot be empty"
            return 1
        fi
        
        read -p "$(get_string "DEEPLX_API_ENDPOINT" "EN") " -r api_endpoint
        api_endpoint=${api_endpoint:-"https://api.deeplx.org/translate"}
        
        write_profile_value "DEEPLX_API_ENABLED" "true"
        write_profile_value "DEEPLX_API_KEY" "$api_key"
        write_profile_value "DEEPLX_API_ENDPOINT" "$api_endpoint"
        
        print_color "$GREEN" "$(get_string "DEEPLX_CONFIG_SAVED" "EN")"
        return 0
    else
        write_profile_value "DEEPLX_API_ENABLED" "false"
        print_color "$YELLOW" "DeepLX API disabled"
        return 0
    fi
}

main() {
    local action="${1:-}"
    
    case "$action" in
        -h|--help)
            show_usage
            ;;
        -s|--status)
            show_status
            ;;
        -v|--verify)
            verify_consistency
            ;;
        -c|--count)
            count_prompts
            ;;
        --configure-api)
            configure_api
            ;;
        --translate-prompt)
            if ! validate_api_config; then
                exit 1
            fi
            
            local source_lang="${3:-EN}"
            local target_lang="${5:-}"
            local category="${7:-}"
            local prompt_title="${9:-}"
            
            if [[ -z "$target_lang" ]] || [[ -z "$category" ]] || [[ -z "$prompt_title" ]]; then
                print_color "$RED" "Missing required arguments for --translate-prompt"
                echo "Usage: $0 --translate-prompt --source-lang LANG --target-lang LANG --category CAT --prompt-title TITLE"
                exit 1
            fi
            
            translate_prompt "$source_lang" "$target_lang" "$category" "$prompt_title"
            ;;
        --translate-file)
            if ! validate_api_config; then
                exit 1
            fi
            
            shift
            local source_lang="EN"
            local target_lang=""
            local category=""
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --source-lang)
                        source_lang="$2"
                        shift 2
                        ;;
                    --target-lang)
                        target_lang="$2"
                        shift 2
                        ;;
                    --category)
                        category="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            if [[ -z "$target_lang" ]] || [[ -z "$category" ]]; then
                print_color "$RED" "Missing required arguments for --translate-file"
                echo "Usage: $0 --translate-file --source-lang LANG --target-lang LANG --category CAT"
                exit 1
            fi
            
            translate_file "$source_lang" "$target_lang" "$category"
            ;;
        --batch-translate)
            if ! validate_api_config; then
                exit 1
            fi
            
            shift
            local source_lang="EN"
            local target_langs=""
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --source-lang)
                        source_lang="$2"
                        shift 2
                        ;;
                    --target-lang)
                        target_langs="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            if [[ -z "$target_langs" ]]; then
                print_color "$RED" "Missing required target languages for --batch-translate"
                echo "Usage: $0 --batch-translate --source-lang LANG --target-lang LANG1,LANG2,..."
                exit 1
            fi
            
            batch_translate "$source_lang" "$target_langs"
            ;;
        "")
            show_status
            ;;
        *)
            print_color "$RED" "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
