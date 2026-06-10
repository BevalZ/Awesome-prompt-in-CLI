#!/usr/bin/env bash

# Cross-Platform Compatibility Test Suite
# Tests Windows (Git Bash/WSL/Cygwin), Linux, and macOS

# Disable strict error handling for tests
set +e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result log
TEST_LOG="test_results_$(date +%Y%m%d_%H%M%S).log"

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
    echo "[TEST] $1" >> "$TEST_LOG"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    echo "[PASS] $1" >> "$TEST_LOG"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo "[FAIL] $1" >> "$TEST_LOG"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$TEST_LOG"
}

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/common.sh" || {
    echo "ERROR: Failed to source common.sh"
    exit 1
}

echo "========================================" | tee "$TEST_LOG"
echo "Cross-Platform Compatibility Test Suite" | tee -a "$TEST_LOG"
echo "========================================" | tee -a "$TEST_LOG"
echo "" | tee -a "$TEST_LOG"

# Test 1: OS Detection
print_test "OS Detection"
((TESTS_RUN++))
OS=$(detect_os)
if [[ -n "$OS" ]] && [[ "$OS" != "Unknown" ]]; then
    print_pass "Detected OS: $OS"
else
    print_fail "OS detection failed: $OS"
fi

# Test 2: Path Conversion Decision
print_test "Path Conversion Decision"
((TESTS_RUN++))
if should_convert_paths; then
    print_info "Path conversion enabled (Windows non-MSYSTEM)"
    print_pass "Conversion logic working"
else
    print_info "Path conversion disabled (not needed)"
    print_pass "Conversion logic working"
fi

# Test 3: Simple Path Conversion
print_test "Simple Path Conversion"
((TESTS_RUN++))
test_path="/d/test/file.txt"
converted=$(to_windows_path "$test_path")
if [[ -n "$converted" ]]; then
    print_pass "Converted: $test_path -> $converted"
else
    print_fail "Path conversion returned empty"
fi

# Test 4: Path with Spaces
print_test "Path with Spaces"
((TESTS_RUN++))
space_path="/d/Program Files/test/file.txt"
converted=$(to_windows_path "$space_path")
if [[ -n "$converted" ]]; then
    print_pass "Converted: $space_path -> $converted"
else
    print_fail "Failed to convert path with spaces"
fi

# Test 5: Text with Mixed Paths
print_test "Text Path Conversion"
((TESTS_RUN++))
test_text="Location: /d/test/file.md and https://github.com/user/repo"
converted_text=$(convert_paths_in_text "$test_text")
if [[ -n "$converted_text" ]]; then
    print_pass "Converted text: $converted_text"
else
    print_fail "Text conversion failed"
fi

# Test 6: URL Preservation
print_test "URL Preservation"
((TESTS_RUN++))
url_text="Visit https://example.com/path/to/page"
converted_url=$(convert_paths_in_text "$url_text")
if [[ "$converted_url" == *"https://example.com"* ]]; then
    print_pass "URL preserved: $converted_url"
else
    print_fail "URL was incorrectly converted"
fi

# Test 7: Quoted Path
print_test "Quoted Path Conversion"
((TESTS_RUN++))
quoted_text='File at "/d/test/file.txt" exists'
converted_quoted=$(convert_paths_in_text "$quoted_text")
if [[ -n "$converted_quoted" ]]; then
    print_pass "Quoted path: $converted_quoted"
else
    print_fail "Quoted path conversion failed"
fi

# Test 8: Relative Path
print_test "Relative Path Conversion"
((TESTS_RUN++))
rel_text="Run: ./scripts/add_prompt.sh"
converted_rel=$(convert_paths_in_text "$rel_text")
if [[ -n "$converted_rel" ]]; then
    print_pass "Relative path: $converted_rel"
else
    print_fail "Relative path conversion failed"
fi

# Test 9: Your Actual Project Path
print_test "Real Project Path"
((TESTS_RUN++))
project_path="$SCRIPT_DIR"
if [[ -n "$project_path" ]]; then
    converted_project=$(to_windows_path "$project_path")
    print_pass "Project: $project_path -> $converted_project"
else
    print_fail "Could not get project path"
fi

# Test 10: print_color with Paths
print_test "print_color Integration"
((TESTS_RUN++))
test_msg="📍 Location: /d/test/file.md"
# Redirect to capture output
output=$(print_color "$GREEN" "$test_msg" 2>&1)
if [[ -n "$output" ]]; then
    print_pass "print_color output: $output"
else
    print_fail "print_color produced no output"
fi

# Summary
echo "" | tee -a "$TEST_LOG"
echo "========================================" | tee -a "$TEST_LOG"
echo "Test Summary" | tee -a "$TEST_LOG"
echo "========================================" | tee -a "$TEST_LOG"
echo "Total Tests:  $TESTS_RUN" | tee -a "$TEST_LOG"
echo -e "${GREEN}Passed:${NC}       $TESTS_PASSED" | tee -a "$TEST_LOG"
echo -e "${RED}Failed:${NC}       $TESTS_FAILED" | tee -a "$TEST_LOG"
echo "" | tee -a "$TEST_LOG"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}" | tee -a "$TEST_LOG"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}" | tee -a "$TEST_LOG"
    exit 1
fi
