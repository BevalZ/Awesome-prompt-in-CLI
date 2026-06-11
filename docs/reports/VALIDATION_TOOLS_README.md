# Prompt Synchronization Validation Tools

Complete documentation of shell/JQ-based validation scripts for checking multilingual prompt data integrity.

## Overview

This toolkit provides comprehensive validation of synchronization between:
- **Central Index:** `Prompts/prompt_index.json` 
- **Language Files:** `Prompts/<LANG>/*.md` (12 languages × 9 categories)

## Quick Start

```bash
# Run comprehensive analysis
bash analyze_sync_issues.sh

# Run advanced structural checks
bash validate_with_jq.sh

# Generate detailed report
bash validate_prompts_sync.sh
```

## Tools Included

### 1. analyze_sync_issues.sh
**Purpose:** Identify and prioritize synchronization issues  
**Output:** Console output + `SYNC_VALIDATION_REPORT.md`

**What it checks:**
- Categories on disk vs. in index
- Missing category entries
- Empty categories
- Language coverage
- Statistics and summary

**Features:**
- Color-coded output for easy reading
- Summary statistics
- Issue prioritization
- Root cause analysis hints

**Usage:**
```bash
bash analyze_sync_issues.sh
# Displays: Issues found, statistics, report location
```

**Sample Output:**
```
=== Prompt Synchronization Analysis ===
Categories on disk (EN/): 9
Categories in index: 4
Missing from index: 5 (55%)
Total indexed prompts: 113
```

---

### 2. validate_with_jq.sh
**Purpose:** Advanced structural and content validation using JQ  
**Output:** Detailed analysis to stdout

**What it checks:**
1. **Index Structure Validation**
   - Valid JSON syntax
   - Required fields present
   - Schema compliance

2. **Completeness Analysis**
   - Prompt definitions
   - Required metadata
   - Duplicate detection

3. **Position Validation**
   - Sequential positions
   - No gaps in position numbers
   - Per-category analysis

4. **Markdown File Validation**
   - File existence in all languages
   - Language coverage percentages
   - File stats (line counts)

5. **Content Structure Validation**
   - Main title presence (#)
   - Research Areas section
   - Prompt Categories section
   - Prompt count matching

6. **Data Drift Detection**
   - Orphaned files (on disk but not indexed)
   - Missing files (indexed but not on disk)
   - Content inconsistencies

7. **JSON Summary**
   - Statistics in machine-readable format
   - Language list
   - Category breakdown

**Usage:**
```bash
bash validate_with_jq.sh
# Shows: 7 validation sections with detailed analysis
```

**Key JQ Queries Used:**
```jq
# Extract all categories
.categories | keys[]

# Count prompts per category
.categories."<category>".prompts | length

# Check for duplicate IDs
map(.id) | group_by(.) | map(select(length > 1)) | flatten | length

# Validate position sequences
.categories."<category>".prompts | 
  (map(.position) | max) as $max |
  (map(.position) | min) as $min |
  (length) as $count |
  {count, expected: ($max - $min + 1), sequential: (count == expected)}
```

---

### 3. validate_prompts_sync.sh
**Purpose:** Comprehensive synchronization report generation  
**Output:** `VALIDATION_REPORT.md`

**What it checks:**
1. **Index File Validation** - JSON validity and structure
2. **Language Directory Validation** - All 12 languages exist
3. **Prompt Count Validation** - Index vs. markdown file alignment
4. **Prompt ID Validation** - Existence across languages
5. **Empty Category Validation** - Categories with 0 prompts
6. **Language Coverage Analysis** - Files per language per category
7. **Summary Statistics** - Overall metrics
8. **Issues Report** - Categorized by severity
9. **Recommendations** - Actionable next steps

**Features:**
- Color-coded severity levels
- Detailed evidence collection
- Root cause classification (Data/Process/Tooling)
- Remediation guidance

**Usage:**
```bash
bash validate_prompts_sync.sh
# Generates: VALIDATION_REPORT.md
# Exit codes: 0 (warnings only), 1 (critical issues)
```

**Report Structure:**
```
1. Index File Validation
2. Language Directory Validation
3. Prompt Count Validation
4. Prompt ID and Position Validation
5. Empty Category Validation
6. Language Coverage Analysis
7. Summary Statistics
8. Detailed Issues Report
9. Recommendations
```

---

### 4. analyze_sync_issues.sh
**Purpose:** Issue discovery and analysis  
**Output:** Console summary + `SYNC_VALIDATION_REPORT.md`

**Analysis Performed:**
- Category discovery (disk vs. index)
- Missing category detection
- Empty category identification
- Statistics generation
- Issue prioritization

**Usage:**
```bash
bash analyze_sync_issues.sh
```

**Output Example:**
```
Categories on disk (EN/):
  business-management
  computer-science
  engineering
  general
  humanities
  mathematics-statistics
  medical-sciences
  natural-sciences
  social-sciences

Missing Categories: 5
  ✗ business-management
  ✗ engineering
  ✗ humanities
  ✗ natural-sciences
  ✗ social-sciences
```

---

### 5. extract_missing_categories.sh
**Purpose:** Analyze missing categories and generate index entries  
**Output:** JSON structure for missing categories

**What it does:**
1. Counts prompts in markdown files
2. Extracts prompt titles
3. Generates ID schemes (e.g., `busm_001`)
4. Outputs JSON for adding to index

**Features:**
- Validates file existence
- Error handling for missing files
- Statistics generation
- JSON structure generation

**Usage:**
```bash
bash extract_missing_categories.sh
# Shows: Counts and JSON for missing categories
```

---

## Validation Results Summary

### Current State (As of Validation)

```
CATEGORIES
├── On Disk: 9
│   ├── business-management (stub, 0 prompts)
│   ├── computer-science (stub, 0 prompts)
│   ├── engineering (stub, 0 prompts)
│   ├── general (102 prompts)
│   ├── humanities (stub, 0 prompts)
│   ├── mathematics-statistics (8 prompts)
│   ├── medical-sciences (3 prompts)
│   ├── natural-sciences (stub, 0 prompts)
│   └── social-sciences (stub, 0 prompts)
│
├── In Index: 4
│   ├── computer-science (0 prompts, empty)
│   ├── general (102 prompts)
│   ├── mathematics-statistics (8 prompts)
│   └── medical-sciences (3 prompts)
│
└── Missing from Index: 5 (56%)
    ├── business-management
    ├── engineering
    ├── humanities
    ├── natural-sciences
    └── social-sciences

LANGUAGES
├── Coverage: 100%
├── Each language has: 9 categories
├── Total files: 108 (all exist)
└── Codes: AR, DE, EN, ES, FR, HI, IT, JP, KO, PT, RU, ZH

DATA INTEGRITY
├── Total Indexed Prompts: 113
├── Duplicate IDs: None
├── Missing Fields: None
├── Position Sequences: Valid
└── Orphaned Files: 5 categories
```

---

## Critical Issues Found

### Issue #1: 5 Categories Missing from Index (CRITICAL)
- **Categories:** business-management, engineering, humanities, natural-sciences, social-sciences
- **Impact:** Categories not discoverable through index
- **Status:** Orphaned but fully translated
- **Fix:** Add to prompt_index.json

### Issue #2: Empty computer-science Category (HIGH)
- **Status:** Indexed but has 0 prompts
- **Impact:** Inconsistent state, possible UI issues
- **Fix:** Add prompts OR mark as planned

### Issue #3: No Validation Automation (MEDIUM)
- **Problem:** No pre-commit hooks prevent desynchronization
- **Impact:** Issues can slip past code review
- **Fix:** Deploy validation scripts to CI/CD

---

## Integration Guide

### Option 1: Manual Validation

Run scripts manually during code review:

```bash
# Before approving PR
bash analyze_sync_issues.sh

# Check for critical issues
grep "CRITICAL" SYNC_VALIDATION_REPORT.md

# If clean, approve PR
```

---

### Option 2: Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
set -e
echo "Validating prompt synchronization..."
bash validate_prompts_sync.sh
echo "✓ Validation passed"
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

### Option 3: CI/CD Integration

Add to GitHub Actions workflow:

```yaml
- name: Validate Prompt Synchronization
  run: |
    bash validate_with_jq.sh
    bash analyze_sync_issues.sh
  continue-on-error: false
```

Add to GitLab CI:

```yaml
validate_prompts:
  script:
    - bash validate_prompts_sync.sh
```

---

### Option 4: Automated Dashboard

Create daily validation report:

```bash
#!/bin/bash
# Schedule daily via cron
0 9 * * * cd /path/to/repo && bash analyze_sync_issues.sh > /reports/sync_status.txt
```

---

## JQ Cheat Sheet

Common queries used in validation:

```jq
# List all categories
.categories | keys[]

# Count prompts per category
.categories | map_values(.prompts | length)

# Extract all prompt IDs
.categories[] | .prompts[].id

# Find empty categories
.categories | to_entries[] | select(.value.prompts | length == 0) | .key

# Check for duplicate IDs
.categories[] | .prompts[].id | [.] | group_by(.) | map(select(length > 1)) | flatten

# Validate position sequences
.categories[] | .prompts | group_by(.position) | map(select(length > 1))

# Extract all prompts with IDs
.categories | to_entries[] | {
  category: .key,
  prompts: .value.prompts | map({id, position, title: .en_title})
}
```

---

## Troubleshooting

### Script fails with "Command not found: jq"
```bash
# Install jq
sudo apt-get install jq  # Debian/Ubuntu
brew install jq          # macOS
```

### Permission denied when running script
```bash
chmod +x analyze_sync_issues.sh
chmod +x validate_with_jq.sh
chmod +x validate_prompts_sync.sh
```

### Output shows broken pipes or errors
```bash
# Run with error output to file
bash validate_with_jq.sh 2>&1 | tee validation.log
```

### False positive on orphaned files
Verify the file exists in all language directories:
```bash
for lang in AR DE EN ES FR HI IT JP KO PT RU ZH; do
  test -f Prompts/$lang/CATEGORY.md || echo "Missing: $lang"
done
```

---

## Reports Generated

### SYNC_VALIDATION_REPORT.md
Generated by `analyze_sync_issues.sh`
- Issue discovery
- Root cause analysis
- Priority recommendations
- Statistics

### VALIDATION_REPORT.md
Generated by `validate_prompts_sync.sh`
- Comprehensive validation results
- Severity categorization
- Evidence collection
- Remediation guidance

### FINAL_SYNC_VALIDATION_REPORT.md
Comprehensive analysis report
- Executive summary
- Detailed findings
- Root cause analysis
- Prioritized remediation plan
- Statistics and appendices

---

## Maintenance

### Adding New Categories

1. Create markdown file: `Prompts/{LANG}/{category}.md`
2. Create file in ALL 12 languages
3. Add category to `prompt_index.json`:
   ```json
   "{category}": {
     "prompts": [
       {
         "id": "{prefix}_{num:03d}",
         "position": {num},
         "en_title": "{title}",
         "description": "{description}"
       }
     ]
   }
   ```
4. Run validation: `bash analyze_sync_issues.sh`
5. Verify: No critical issues should be found

### Updating Existing Categories

1. Modify markdown files
2. Update `prompt_index.json` if needed
3. Maintain position sequences (1, 2, 3, ...)
4. Maintain unique IDs
5. Run validation before committing

---

## References

- **JQ Documentation:** https://stedolan.github.io/jq/
- **Bash Scripting:** https://www.gnu.org/software/bash/manual/
- **JSON Schema:** https://json-schema.org/

---

## Support

For issues with validation scripts:
1. Run script with verbose output: `bash -x script.sh`
2. Check script syntax: `bash -n script.sh`
3. Review generated reports for details
4. Verify file permissions and paths

---

**Last Updated:** December 7, 2025  
**Version:** 1.0  
**Status:** Production-Ready
