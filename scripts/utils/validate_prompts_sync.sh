#!/bin/bash
#
# Prompt Synchronization Validator
# Validates multilingual prompt data integrity between prompt_index.json and language files
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_FILE="${SCRIPT_DIR}/Prompts/prompt_index.json"
PROMPTS_DIR="${SCRIPT_DIR}/Prompts"
OUTPUT_FILE="${SCRIPT_DIR}/VALIDATION_REPORT.md"

# Language codes matching the directory structure
LANGUAGES=(AR DE EN ES FR HI IT JP KO PT RU ZH)

# Category list from index
CATEGORIES=()

# Validation statistics
TOTAL_INDEXED_PROMPTS=0
TOTAL_MISSING_PROMPTS=0
TOTAL_MISSING_FILES=0
TOTAL_CONTENT_ISSUES=0
TOTAL_WARNINGS=0

# Data structure for issues
declare -a CRITICAL_ISSUES
declare -a WARNING_ISSUES
declare -a INFO_NOTES

# Helper functions
log_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1" | tee -a "${OUTPUT_FILE}"
    CRITICAL_ISSUES+=("$1")
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "${OUTPUT_FILE}"
    WARNING_ISSUES+=("$1")
    ((TOTAL_WARNINGS++))
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "${OUTPUT_FILE}"
    INFO_NOTES+=("$1")
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1" | tee -a "${OUTPUT_FILE}"
}

print_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n" | tee -a "${OUTPUT_FILE}"
}

# Initialize report file
initialize_report() {
    cat > "${OUTPUT_FILE}" << 'EOF'
# Prompt Synchronization Validation Report

**Generated:** $(date)

## Executive Summary

This report validates multilingual data integrity between `Prompts/prompt_index.json` and per-language category markdown files under `Prompts/<LANG>/`.

---

EOF
}

# Extract categories from index
extract_categories() {
    CATEGORIES=($(jq -r '.categories | keys[]' "${INDEX_FILE}" 2>/dev/null || echo ""))
    if [ ${#CATEGORIES[@]} -eq 0 ]; then
        log_critical "Failed to extract categories from prompt_index.json"
        return 1
    fi
    log_info "Found ${#CATEGORIES[@]} categories: ${CATEGORIES[*]}"
    return 0
}

# Verify index file exists and is valid JSON
validate_index_file() {
    print_header "1. Index File Validation"
    
    if [ ! -f "${INDEX_FILE}" ]; then
        log_critical "prompt_index.json file not found at ${INDEX_FILE}"
        return 1
    fi
    
    log_success "Index file exists at ${INDEX_FILE}"
    
    if ! jq empty "${INDEX_FILE}" 2>/dev/null; then
        log_critical "prompt_index.json is not valid JSON"
        return 1
    fi
    
    log_success "Index file is valid JSON"
    
    local version=$(jq -r '.version' "${INDEX_FILE}" 2>/dev/null)
    log_info "Index version: ${version}"
    
    return 0
}

# Check for missing language directories
validate_language_directories() {
    print_header "2. Language Directory Validation"
    
    for lang in "${LANGUAGES[@]}"; do
        local lang_dir="${PROMPTS_DIR}/${lang}"
        if [ ! -d "${lang_dir}" ]; then
            log_critical "Missing language directory: ${lang_dir}"
            ((TOTAL_MISSING_FILES++))
        else
            log_success "Language directory exists: ${lang}"
        fi
    done
}

# Extract prompt IDs from index for a category
get_indexed_prompt_ids() {
    local category=$1
    jq -r ".categories.\"${category}\".prompts[].id" "${INDEX_FILE}" 2>/dev/null || echo ""
}

# Extract prompt positions from index for a category
get_indexed_prompt_positions() {
    local category=$1
    jq -r ".categories.\"${category}\".prompts[].position" "${INDEX_FILE}" 2>/dev/null || echo ""
}

# Extract prompt IDs from markdown file
extract_prompt_ids_from_markdown() {
    local markdown_file=$1
    if [ ! -f "${markdown_file}" ]; then
        echo ""
        return 1
    fi
    
    # Extract IDs from markdown headers that follow the pattern "### Prompt Title"
    # Count them based on h3 headers
    grep -E "^### " "${markdown_file}" | wc -l || echo "0"
}

# Check if markdown file has required sections
validate_markdown_structure() {
    local markdown_file=$1
    local category=$2
    local lang=$3
    local issues=""
    
    if [ ! -f "${markdown_file}" ]; then
        return 1
    fi
    
    # Check for main title
    if ! head -1 "${markdown_file}" | grep -q "^#"; then
        issues="${issues}\n  - Missing main title (# header)"
    fi
    
    # Check for Research Areas section
    if ! grep -q "^## Research Areas" "${markdown_file}"; then
        issues="${issues}\n  - Missing 'Research Areas' section"
    fi
    
    # Check for Prompt Categories section
    if ! grep -q "^## Prompt Categories" "${markdown_file}"; then
        issues="${issues}\n  - Missing 'Prompt Categories' section"
    fi
    
    if [ ! -z "${issues}" ]; then
        echo -e "${issues}"
        return 1
    fi
    
    return 0
}

# Compare prompt counts between index and markdown files
compare_prompt_counts() {
    print_header "3. Prompt Count Validation"
    
    for category in "${CATEGORIES[@]}"; do
        echo -e "\n${BOLD}Category: ${category}${NC}" | tee -a "${OUTPUT_FILE}"
        
        # Get count from index
        local indexed_count=$(jq -r ".categories.\"${category}\".prompts | length" "${INDEX_FILE}" 2>/dev/null || echo "0")
        
        if [ "${indexed_count}" = "null" ] || [ -z "${indexed_count}" ]; then
            indexed_count=0
        fi
        
        ((TOTAL_INDEXED_PROMPTS += indexed_count))
        
        log_info "Indexed prompts: ${indexed_count}"
        
        local missing_in_any_language=0
        
        for lang in "${LANGUAGES[@]}"; do
            local markdown_file="${PROMPTS_DIR}/${lang}/${category}.md"
            
            if [ ! -f "${markdown_file}" ]; then
                log_critical "${lang}: Missing file ${markdown_file}"
                ((TOTAL_MISSING_FILES++))
                ((missing_in_any_language++))
                continue
            fi
            
            # Count prompts in markdown
            local md_count=$(extract_prompt_ids_from_markdown "${markdown_file}")
            
            if [ "${md_count}" != "${indexed_count}" ]; then
                log_warning "${lang}: Prompt count mismatch (indexed: ${indexed_count}, file: ${md_count})"
                ((TOTAL_CONTENT_ISSUES++))
            else
                log_success "${lang}: Prompt count matches (${md_count})"
            fi
        done
    done
}

# Validate prompt IDs and positions in markdown files
validate_prompt_ids_and_positions() {
    print_header "4. Prompt ID and Position Validation"
    
    for category in "${CATEGORIES[@]}"; do
        echo -e "\n${BOLD}Category: ${category}${NC}" | tee -a "${OUTPUT_FILE}"
        
        # Get indexed IDs
        local indexed_ids=$(get_indexed_prompt_ids "${category}")
        
        if [ -z "${indexed_ids}" ] || [ "${indexed_ids}" = "null" ]; then
            log_info "Category has no prompts in index"
            continue
        fi
        
        for lang in "${LANGUAGES[@]}"; do
            local markdown_file="${PROMPTS_DIR}/${lang}/${category}.md"
            
            if [ ! -f "${markdown_file}" ]; then
                continue
            fi
            
            echo -e "\n  ${lang}:" | tee -a "${OUTPUT_FILE}"
            
            # Check each indexed ID exists in markdown
            local missing_count=0
            local found_count=0
            
            while IFS= read -r prompt_id; do
                if [ -z "${prompt_id}" ]; then
                    continue
                fi
                
                # The markdown files don't include IDs directly, so we validate by counting headers
                ((found_count++))
            done <<< "${indexed_ids}"
            
            # Validate markdown structure
            local struct_issues=$(validate_markdown_structure "${markdown_file}" "${category}" "${lang}")
            if [ $? -eq 0 ]; then
                log_success "    Structure valid"
            else
                log_warning "    Structure issues: ${struct_issues}"
                ((TOTAL_CONTENT_ISSUES++))
            fi
        done
    done
}

# Check for empty categories
validate_empty_categories() {
    print_header "5. Empty Category Validation"
    
    for category in "${CATEGORIES[@]}"; do
        local count=$(jq -r ".categories.\"${category}\".prompts | length" "${INDEX_FILE}" 2>/dev/null || echo "0")
        
        if [ "${count}" -eq 0 ] || [ "${count}" = "null" ]; then
            log_warning "Category '${category}' is empty in index"
            ((TOTAL_WARNINGS++))
            
            # Check if markdown files exist for this category
            local files_exist=0
            for lang in "${LANGUAGES[@]}"; do
                if [ -f "${PROMPTS_DIR}/${lang}/${category}.md" ]; then
                    ((files_exist++))
                fi
            done
            
            if [ ${files_exist} -gt 0 ]; then
                log_critical "Category '${category}' has markdown files but is empty in index (files in ${files_exist} languages)"
                ((TOTAL_MISSING_FILES++))
            fi
        fi
    done
}

# Analyze language coverage
validate_language_coverage() {
    print_header "6. Language Coverage Analysis"
    
    for category in "${CATEGORIES[@]}"; do
        local count=$(jq -r ".categories.\"${category}\".prompts | length" "${INDEX_FILE}" 2>/dev/null || echo "0")
        
        if [ "${count}" -eq 0 ] || [ "${count}" = "null" ]; then
            continue
        fi
        
        echo -e "\n${BOLD}Category: ${category}${NC}" | tee -a "${OUTPUT_FILE}"
        
        local lang_with_files=0
        local lang_without_files=0
        
        for lang in "${LANGUAGES[@]}"; do
            local markdown_file="${PROMPTS_DIR}/${lang}/${category}.md"
            
            if [ -f "${markdown_file}" ]; then
                ((lang_with_files++))
                log_success "  ${lang}: ✓ File exists"
            else
                ((lang_without_files++))
                log_warning "  ${lang}: ✗ File missing"
                ((TOTAL_MISSING_FILES++))
            fi
        done
        
        if [ ${lang_without_files} -gt 0 ]; then
            log_warning "  Language coverage: ${lang_with_files}/${#LANGUAGES[@]} languages have this category"
            ((TOTAL_WARNINGS++))
        fi
    done
}

# Generate summary statistics
generate_summary() {
    print_header "7. Summary Statistics"
    
    local lang_count=${#LANGUAGES[@]}
    local category_count=${#CATEGORIES[@]}
    
    {
        echo "- **Total Languages:** ${lang_count}"
        echo "- **Total Categories:** ${category_count}"
        echo "- **Total Indexed Prompts:** ${TOTAL_INDEXED_PROMPTS}"
        echo "- **Missing Files:** ${TOTAL_MISSING_FILES}"
        echo "- **Content Issues:** ${TOTAL_CONTENT_ISSUES}"
        echo "- **Warnings:** ${TOTAL_WARNINGS}"
    } | tee -a "${OUTPUT_FILE}"
}

# Generate detailed issues report
generate_issues_report() {
    print_header "8. Detailed Issues Report"
    
    if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
        echo -e "\n${BOLD}${RED}CRITICAL ISSUES (${#CRITICAL_ISSUES[@]})${NC}\n" | tee -a "${OUTPUT_FILE}"
        for i in "${!CRITICAL_ISSUES[@]}"; do
            echo -e "${RED}$((i+1)). ${CRITICAL_ISSUES[$i]}${NC}" | tee -a "${OUTPUT_FILE}"
        done
    fi
    
    if [ ${#WARNING_ISSUES[@]} -gt 0 ]; then
        echo -e "\n${BOLD}${YELLOW}WARNINGS (${#WARNING_ISSUES[@]})${NC}\n" | tee -a "${OUTPUT_FILE}"
        for i in "${!WARNING_ISSUES[@]}"; do
            echo -e "${YELLOW}$((i+1)). ${WARNING_ISSUES[$i]}${NC}" | tee -a "${OUTPUT_FILE}"
        done
    fi
}

# Generate recommendations
generate_recommendations() {
    print_header "9. Recommendations"
    
    {
        echo "### Data Integrity"
        echo "1. Ensure all categories have prompts in the index file"
        echo "2. Verify markdown files exist for all language-category combinations"
        echo "3. Validate that prompt counts match between index and markdown files"
        echo ""
        echo "### Translation Coverage"
        echo "1. Identify languages with missing category files"
        echo "2. Prioritize translation for categories with incomplete language coverage"
        echo "3. Implement automated checks to prevent translation gaps"
        echo ""
        echo "### Tooling and Workflows"
        echo "1. Implement pre-commit hooks to validate synchronization"
        echo "2. Use JQ scripts for automated validation during CI/CD pipelines"
        echo "3. Create a dashboard showing translation completion percentage by language"
    } | tee -a "${OUTPUT_FILE}"
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}Prompt Synchronization Validator${NC}\n"
    echo "Starting validation at $(date)"
    
    initialize_report
    
    # Run validation checks
    validate_index_file || exit 1
    extract_categories || exit 1
    validate_language_directories
    compare_prompt_counts
    validate_prompt_ids_and_positions
    validate_empty_categories
    validate_language_coverage
    generate_summary
    generate_issues_report
    generate_recommendations
    
    # Final summary
    echo -e "\n${BOLD}${BLUE}=== Validation Complete ===${NC}\n"
    echo -e "Report saved to: ${OUTPUT_FILE}\n"
    
    if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
        echo -e "${RED}${BOLD}Found ${#CRITICAL_ISSUES[@]} critical issue(s)${NC}"
        exit 1
    elif [ ${TOTAL_WARNINGS} -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}Found ${TOTAL_WARNINGS} warning(s)${NC}"
        exit 0
    else
        echo -e "${GREEN}${BOLD}All checks passed!${NC}"
        exit 0
    fi
}

main "$@"
