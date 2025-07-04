#!/bin/bash
# Simple test script for human-readable task functionality

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Change to tests directory
cd "$(dirname "$0")"

# Disable strict mode for tests
set +e

# Source the utils
source "../lib/utils.sh"

# Keep error handling off for tests
# set -e

# Helper function for tests
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
}

echo "=== Testing Input Validation ==="

# Test 1: Special characters escaping
result=$(escape_for_markdown "Fix [bug] in *parser*")
assert_equals "Fix \\[bug\\] in \\*parser\\*" "$result" "Escape special characters"

# Test 2: Task description validation - ID pattern
set +e  # Temporarily disable exit on error
validate_task_description "Fix bug ID: 123" 2>/dev/null
result=$?
set -e
if [[ $result -eq 0 ]]; then
    echo -e "${RED}✗${NC} Should reject 'ID:' pattern"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓${NC} Correctly rejects 'ID:' pattern"
    ((TESTS_PASSED++))
fi

# Test 3: Valid task description
set +e
validate_task_description "Fix bug in parser" 2>/dev/null
result=$?
set -e
if [[ $result -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} Accepts valid description"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Should accept valid description"
    ((TESTS_FAILED++))
fi

echo ""
echo "=== Testing Parse and Render ==="

# Create test ROADMAP.md
cat > ROADMAP.md << 'EOF'
# Test Project

## Tasks

### TODO
- [ ] First task [high] [#bug]
  ID: test-uuid-1

### IN PROGRESS
- [ ] Active task [started:2025-01-04]
  ID: test-uuid-2

### BLOCKED
- [ ] Blocked task [blocked:Waiting for API]
  ID: test-uuid-3

### DONE
- [x] Completed task [completed:2025-01-03]
  ID: test-uuid-4

## Notes
Test content
EOF

# Test parsing
parse_roadmap

# Test 4: Correct number of tasks parsed
assert_equals "4" "${#TASK_UUIDS[@]}" "Parse task count"

# Test 5: Task sections parsed correctly
assert_equals "TODO" "${TASK_SECTIONS[0]}" "First task in TODO"
assert_equals "IN_PROGRESS" "${TASK_SECTIONS[1]}" "Second task in IN_PROGRESS"
assert_equals "DONE" "${TASK_SECTIONS[3]}" "Fourth task in DONE"

# Test 6: Task UUIDs parsed correctly
assert_equals "test-uuid-1" "${TASK_UUIDS[0]}" "First task UUID"
assert_equals "test-uuid-4" "${TASK_UUIDS[3]}" "Fourth task UUID"

echo ""
echo "=== Testing Migration (Force) ==="

# Create old format ROADMAP
cat > ROADMAP.md << 'EOF'
# Test Project

## Current Tasks

CPM::TASK::abc-123::TODO::2025-01-04::Implement feature ||priority:high|| ||tags:feature||
CPM::TASK::def-456::DOING::2025-01-03::Fix critical bug
CPM::TASK::ghi-789::BLOCKED::2025-01-02::Deploy to prod (waiting for approval)
CPM::TASK::jkl-012::DONE::2025-01-01::Setup CI/CD

## Notes
Some notes here
EOF

# Force migration without prompts
migrate_tasks_force >/dev/null 2>&1

# Test 7: Migration successful
if ! grep -q "CPM::TASK::" ROADMAP.md && grep -q "^## Tasks" ROADMAP.md; then
    echo -e "${GREEN}✓${NC} Migration completed successfully"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Migration should remove old format and add new"
    ((TESTS_FAILED++))
fi

# Test 8: Tasks migrated correctly
if grep -q "- \[ \] Implement feature \[high\] \[#feature\]" ROADMAP.md; then
    echo -e "${GREEN}✓${NC} Tasks migrated with metadata"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Tasks should have metadata after migration"
    ((TESTS_FAILED++))
fi

# Cleanup
rm -f ROADMAP.md

echo ""
echo "=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi