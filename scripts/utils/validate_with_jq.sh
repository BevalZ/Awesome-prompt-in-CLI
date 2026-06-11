#!/bin/bash
#
# Advanced JQ-based Prompt Validation
# Performs detailed structural and content analysis using JQ
#

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_FILE="${SCRIPT_DIR}/Prompts/prompt_index.json"
PROMPTS_DIR="${SCRIPT_DIR}/Prompts"

# Helper functions
log_section() {
    echo -e "\n${BOLD}${BLUE}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# 1. Index file structure validation
validate_index_structure() {
    log_section "1. INDEX FILE STRUCTURE ANALYSIS"
    
    echo -e "\nValidating JSON schema and structure..."
    
    if ! jq empty "${INDEX_FILE}" 2>/dev/null; then
        log_error "Invalid JSON in prompt_index.json"
        return 1
    fi
    
    log_success "Valid JSON structure"
    
    # Check required top-level fields
    local required_fields=("version" "description" "categories")
    for field in "${required_fields[@]}"; do
        if jq -e ".${field}" "${INDEX_FILE}" > /dev/null 2>&1; then
            log_success "Field '${field}' present"
        else
            log_error "Missing required field: ${field}"
        fi
    done
    
    # List all categories
    echo -e "\nCategories in index:"
    jq -r '.categories | keys[]' "${INDEX_FILE}" | while read -r category; do
        local count=$(jq -r ".categories.\"${category}\".prompts | length" "${INDEX_FILE}")
        echo -e "  • ${category}: ${count} prompts"
    done
}

# 2. Index completeness check
validate_index_completeness() {
    log_section "2. INDEX COMPLETENESS ANALYSIS"
    
    echo -e "\nChecking prompt definitions..."
    
    jq -r '.categories[] | .prompts[]?' "${INDEX_FILE}" | jq -s '
        {
            total_prompts: length,
            prompts_with_id: map(select(.id != null)) | length,
            prompts_with_position: map(select(.position != null)) | length,
            prompts_with_title: map(select(.en_title != null)) | length,
            prompts_with_description: map(select(.description != null)) | length,
            unique_ids: (map(.id) | unique | length),
            duplicate_ids: (
                (map(.id) | group_by(.) | map(select(length > 1)) | flatten | length) as $dup |
                if $dup > 0 then $dup else 0 end
            )
        }
    ' | jq . || {
        echo "Error analyzing prompt definitions"
        return 1
    }
    
    # Check for missing IDs or titles
    echo -e "\nPrompts with missing critical fields:"
    
    local missing_count=$(jq '[.categories[] | .prompts[]? | select(.id == null or .en_title == null or .description == null)] | length' "${INDEX_FILE}")
    
    if [ "${missing_count}" -gt 0 ]; then
        log_warning "Found ${missing_count} prompts with missing critical fields"
        jq -r '.categories[] | .prompts[]? | select(.id == null or .en_title == null) | "  - \(.id // "NO_ID"): \(.en_title // "NO_TITLE")"' "${INDEX_FILE}"
    else
        log_success "All prompts have required fields (id, en_title, description)"
    fi
}

# 3. Prompt position validation
validate_positions() {
    log_section "3. POSITION ORDERING VALIDATION"
    
    echo -e "\nChecking position sequences..."
    
    jq -r '.categories | keys[]' "${INDEX_FILE}" | while read -r category; do
        echo -e "\n  Category: ${category}"
        
        local result=$(jq -r ".categories.\"${category}\".prompts | 
            (map(.position) | max) as \$max |
            (map(.position) | min) as \$min |
            (length) as \$count |
            {
                start: \$min,
                end: \$max,
                count: \$count,
                expected_count: (\$max - \$min + 1),
                sequential: (\$count == (\$max - \$min + 1))
            }" "${INDEX_FILE}")
        
        local sequential=$(echo "${result}" | jq -r '.sequential')
        local count=$(echo "${result}" | jq -r '.count')
        local start=$(echo "${result}" | jq -r '.start')
        local end=$(echo "${result}" | jq -r '.end')
        
        if [ "${sequential}" = "true" ]; then
            log_success "Positions are sequential (1-${end}, ${count} prompts)"
        else
            log_warning "Position gaps detected (${start}-${end}, but only ${count} prompts)"
            
            # Show missing positions
            echo -e "\n    Position analysis:"
            jq -r ".categories.\"${category}\".prompts | map(.position) | sort[]" "${INDEX_FILE}" | \
            awk 'NR==1{last=$1; next} {if($1 != last+1) print "    Missing position(s): " (last+1) "-" ($1-1)} {last=$1}'
        fi
    done
}

# 4. Markdown file existence check
validate_markdown_files() {
    log_section "4. MARKDOWN FILE VALIDATION"
    
    local languages=(AR DE EN ES FR HI IT JP KO PT RU ZH)
    
    echo -e "\nChecking markdown file existence..."
    
    jq -r '.categories | keys[]' "${INDEX_FILE}" | while read -r category; do
        echo -e "\n  Category: ${category}"
        
        local expected=0
        local found=0
        
        for lang in "${languages[@]}"; do
            local filepath="${PROMPTS_DIR}/${lang}/${category}.md"
            ((expected++))
            
            if [ -f "${filepath}" ]; then
                ((found++))
                # Show file size
                local size=$(wc -l < "${filepath}")
                echo -e "    ${GREEN}✓${NC} ${lang}: ${size} lines"
            else
                echo -e "    ${RED}✗${NC} ${lang}: MISSING"
            fi
        done
        
        local coverage=$((found * 100 / expected))
        if [ ${found} -lt ${expected} ]; then
            log_warning "Language coverage: ${found}/${expected} (${coverage}%)"
        else
            log_success "Language coverage: ${found}/${expected} (100%)"
        fi
    done
}

# 5. Markdown content structure check
validate_markdown_content() {
    log_section "5. MARKDOWN CONTENT STRUCTURE"
    
    local languages=(AR DE EN ES FR HI IT JP KO PT RU ZH)
    
    echo -e "\nValidating markdown document structure..."
    
    jq -r '.categories | keys[]' "${INDEX_FILE}" | while read -r category; do
        echo -e "\n  Category: ${category}"
        
        for lang in "${languages[@]}"; do
            local filepath="${PROMPTS_DIR}/${lang}/${category}.md"
            
            if [ ! -f "${filepath}" ]; then
                continue
            fi
            
            echo -e "\n    Language: ${lang}"
            
            # Check for required sections
            local has_title=$(head -1 "${filepath}" | grep -c "^#" || echo 0)
            local has_research=$(grep -c "^## Research Areas" "${filepath}" || echo 0)
            local has_categories=$(grep -c "^## Prompt Categories" "${filepath}" || echo 0)
            local h3_count=$(grep -c "^### " "${filepath}" || echo 0)
            
            if [ "${has_title}" -gt 0 ]; then
                log_success "Has main title"
            else
                log_error "Missing main title"
            fi
            
            if [ "${has_research}" -gt 0 ]; then
                log_success "Has Research Areas section"
            else
                log_error "Missing Research Areas section"
            fi
            
            if [ "${has_categories}" -gt 0 ]; then
                log_success "Has Prompt Categories section"
            else
                log_error "Missing Prompt Categories section"
            fi
            
            local indexed_count=$(jq -r ".categories.\"${category}\".prompts | length" "${INDEX_FILE}")
            
            if [ "${h3_count}" -eq "${indexed_count}" ]; then
                log_success "Prompt count matches index (${h3_count})"
            else
                log_warning "Prompt count mismatch: Index=${indexed_count}, File=${h3_count}"
            fi
        done
    done
}

# 6. Data drift detection
detect_data_drift() {
    log_section "6. DATA DRIFT DETECTION"
    
    echo -e "\nAnalyzing for content inconsistencies..."
    
    # Check for title consistency across versions
    jq -r '.categories | keys[]' "${INDEX_FILE}" | while read -r category; do
        local indexed_count=$(jq -r ".categories.\"${category}\".prompts | length" "${INDEX_FILE}")
        
        if [ "${indexed_count}" -eq 0 ]; then
            log_warning "Category '${category}' has no prompts in index"
        fi
    done
    
    # Check for orphaned category files (categories in filesystem but not in index)
    echo -e "\nChecking for orphaned category files..."
    
    local orphaned=0
    for lang_dir in "${PROMPTS_DIR}"/*; do
        if [ ! -d "${lang_dir}" ]; then
            continue
        fi
        
        local lang=$(basename "${lang_dir}")
        [ "${lang}" = "prompt_index.json" ] && continue
        
        for md_file in "${lang_dir}"/*.md; do
            local category=$(basename "${md_file}" .md)
            
            if ! jq -e ".categories.\"${category}\"" "${INDEX_FILE}" > /dev/null 2>&1; then
                log_warning "Orphaned file: ${lang}/${category}.md (not in index)"
                ((orphaned++))
            fi
        done
    done
    
    if [ ${orphaned} -eq 0 ]; then
        log_success "No orphaned category files found"
    fi
}

# 7. Generate JSON summary
generate_json_summary() {
    log_section "7. VALIDATION SUMMARY (JSON)"
    
    jq '{
        validation_timestamp: now | todate,
        index_file: .version,
        statistics: {
            total_categories: (.categories | keys | length),
            total_prompts: [.categories[] | .prompts[]?] | length,
            categories_by_prompt_count: (
                .categories | 
                to_entries | 
                map({category: .key, count: (.value.prompts | length)}) |
                sort_by(-.count)
            ),
            languages_count: 12,
            language_codes: ["AR", "DE", "EN", "ES", "FR", "HI", "IT", "JP", "KO", "PT", "RU", "ZH"]
        }
    }' "${INDEX_FILE}" | jq .
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}Advanced JQ-based Prompt Validation${NC}"
    echo "Validation timestamp: $(date)"
    
    validate_index_structure
    validate_index_completeness
    validate_positions
    validate_markdown_files
    validate_markdown_content
    detect_data_drift
    generate_json_summary
    
    echo -e "\n${BOLD}${BLUE}Validation Complete${NC}\n"
}

main "$@"
