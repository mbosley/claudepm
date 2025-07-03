#!/bin/bash
# Meta-primitive: Chains multiple primitives for PR validation
# Pattern recognized: I often run tests, security checks, and generate reports for PRs
set -euo pipefail

PR_BRANCH="${1:-HEAD}"

echo "🔍 Claude PR Validator"
echo "Validating changes in: $PR_BRANCH"
echo ""

# Step 1: Identify changed files
echo "📝 Analyzing changes..."
CHANGED_FILES=$(git diff --name-only origin/main...$PR_BRANCH)
echo "Found $(echo "$CHANGED_FILES" | wc -l) changed files"

# Step 2: Generate dynamic test suite based on changes
TEST_FILE="/tmp/pr-tests-$$.txt"
{
    # Always run core tests
    echo "core-functionality|Test: Verify core claudepm commands still work"
    
    # Add specific tests based on changed files
    if echo "$CHANGED_FILES" | grep -q "install.sh"; then
        echo "installer-test|Test: Verify installer works on fresh system"
    fi
    
    if echo "$CHANGED_FILES" | grep -q "utils.sh"; then
        echo "utils-test|Test: Verify all utility functions work correctly"
    fi
    
    # Add security test if any .sh files changed
    if echo "$CHANGED_FILES" | grep -qE "\.sh$"; then
        echo "security-scan|Test: Run security analysis on shell scripts"
    fi
} > "$TEST_FILE"

# Step 3: Run test suite with our primitive
echo ""
echo "🧪 Running test suite..."
/Users/mitchellbosley/projects/claudepm/tools/primitives/test-suite.sh \
    --parallel 3 \
    --report \
    "$TEST_FILE"

# Step 4: Additional validation
echo ""
echo "📋 Running additional checks..."

# Check for common issues (this could be another primitive)
echo -n "  Checking for debug statements... "
if git diff origin/main...$PR_BRANCH | grep -q "console.log\|print\|debug"; then
    echo "⚠️  Found potential debug statements"
else
    echo "✅"
fi

echo -n "  Checking for TODO comments... "
TODO_COUNT=$(git diff origin/main...$PR_BRANCH | grep -c "TODO\|FIXME" || true)
if [[ $TODO_COUNT -gt 0 ]]; then
    echo "📌 Found $TODO_COUNT new TODOs"
else
    echo "✅"
fi

# Step 5: Generate summary
echo ""
echo "📊 PR Validation Complete!"
echo ""
echo "Next steps:"
echo "1. Review the test report"
echo "2. Address any failing tests"
echo "3. Consider the warnings above"
echo ""

# Clean up
rm -f "$TEST_FILE"