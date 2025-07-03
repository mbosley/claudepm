#!/bin/bash
# Run all bats tests for claudepm v0.2.5
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Find script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TRADITIONAL_DIR="$SCRIPT_DIR/traditional"

echo -e "${BLUE}🧪 ClaudePM v0.2.5 Test Suite (Bats)${NC}"
echo ""

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: bats not found${NC}"
    echo ""
    echo "Please install bats-core:"
    echo "  macOS:  brew install bats-core"
    echo "  Ubuntu: sudo apt-get install bats"
    echo "  Other:  npm install -g bats"
    echo ""
    echo "Or run without bats installation:"
    echo "  git clone https://github.com/bats-core/bats-core.git"
    echo "  ./bats-core/bin/bats tests/traditional/*.bats"
    exit 1
fi

# Run all test files
TOTAL_TESTS=0
FAILED_TESTS=0
TEST_FILES=(
    "installer.bats"
    "init.bats"
    "adopt.bats"
    "task.bats"
    "health.bats"
    "utils.bats"
)

echo "Running test suites:"
echo ""

for test_file in "${TEST_FILES[@]}"; do
    if [[ -f "$TRADITIONAL_DIR/$test_file" ]]; then
        echo -e "${BLUE}▶ Running $test_file${NC}"
        
        if bats "$TRADITIONAL_DIR/$test_file"; then
            echo -e "${GREEN}✓ $test_file passed${NC}"
        else
            echo -e "${RED}✗ $test_file failed${NC}"
            ((FAILED_TESTS++))
        fi
        
        ((TOTAL_TESTS++))
        echo ""
    else
        echo -e "${YELLOW}⚠️  Skipping $test_file (not found)${NC}"
    fi
done

# Summary
echo -e "${BLUE}Test Summary${NC}"
echo "============"
echo "Total test files: $TOTAL_TESTS"
echo "Passed: $((TOTAL_TESTS - FAILED_TESTS))"
echo "Failed: $FAILED_TESTS"
echo ""

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi