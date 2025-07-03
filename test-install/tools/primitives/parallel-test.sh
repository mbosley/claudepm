#!/bin/bash
# Auto-generated primitive by Claude after recognizing pattern
# Created: 2025-07-03 after noticing repeated test orchestration pattern
set -euo pipefail

# Usage: parallel-test.sh <test-description-file>
# Input file format:
# test-name-1|test-command-1
# test-name-2|test-command-2

TEST_FILE="${1:-}"
if [[ -z "$TEST_FILE" || ! -f "$TEST_FILE" ]]; then
    echo "Usage: parallel-test.sh <test-description-file>"
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_DIR="/tmp/claudepm-tests-$TIMESTAMP"
mkdir -p "$RESULTS_DIR"

echo "🚀 Launching parallel test suite..."
echo "📁 Results will be in: $RESULTS_DIR"

# Launch all tests in parallel
declare -a PIDS=()
while IFS='|' read -r name command; do
    [[ -z "$name" ]] && continue
    echo "  ▶ Spawning: $name"
    
    # Use tester-claude to execute each test
    /Users/mitchellbosley/.claudepm/bin/tester-claude -p --output-format json \
        "$command" > "$RESULTS_DIR/$name.json" 2>&1 &
    
    PIDS+=($!)
done < "$TEST_FILE"

# Wait for all tests
echo "⏳ Waiting for ${#PIDS[@]} tests to complete..."
for pid in "${PIDS[@]}"; do
    wait "$pid"
done

# Aggregate results
echo -e "\n📊 Test Results Summary:"
echo "========================"

PASSED=0
FAILED=0

for result_file in "$RESULTS_DIR"/*.json; do
    test_name=$(basename "$result_file" .json)
    
    if jq -e '.is_error' "$result_file" >/dev/null 2>&1; then
        echo "❌ $test_name: FAILED"
        ((FAILED++))
    else
        echo "✅ $test_name: PASSED"
        ((PASSED++))
        # Extract key info
        jq -r '.result' "$result_file" 2>/dev/null | head -3
    fi
    echo ""
done

echo "========================"
echo "Total: $((PASSED + FAILED)) | Passed: $PASSED | Failed: $FAILED"
echo "Detailed results in: $RESULTS_DIR"