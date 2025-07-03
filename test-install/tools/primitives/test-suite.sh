#!/bin/bash
# Evolution of parallel-test.sh based on usage experience
# Created: 2025-07-03 - v2 adds concurrency control and better reporting
set -euo pipefail

# Pattern evolution - I learned that:
# 1. Unlimited parallelism can overwhelm the system
# 2. Need real-time progress updates
# 3. Want markdown report generation

show_usage() {
    cat << EOF
test-suite - Intelligent parallel test orchestration

Usage: test-suite [options] <test-file>

Options:
    -p, --parallel <n>    Max parallel tests (default: 5)
    -m, --model <model>   Claude model to use (default: sonnet)
    -r, --report          Generate markdown report
    -w, --watch          Show real-time progress

Example test file format:
    test-name|description of what to test
    auth-test|Test authentication flow with edge cases
EOF
}

# Defaults
MAX_PARALLEL=5
MODEL="sonnet"
GENERATE_REPORT=false
WATCH_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--parallel) MAX_PARALLEL="$2"; shift 2 ;;
        -m|--model) MODEL="$2"; shift 2 ;;
        -r|--report) GENERATE_REPORT=true; shift ;;
        -w|--watch) WATCH_MODE=true; shift ;;
        -h|--help) show_usage; exit 0 ;;
        *) TEST_FILE="$1"; shift ;;
    esac
done

# Validate input
if [[ -z "${TEST_FILE:-}" || ! -f "$TEST_FILE" ]]; then
    show_usage
    exit 1
fi

# Setup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_DIR="/tmp/claudepm-tests-$TIMESTAMP"
mkdir -p "$RESULTS_DIR"

echo "🧪 Claude Test Suite v2"
echo "📁 Results: $RESULTS_DIR"
echo "🔧 Config: model=$MODEL, parallel=$MAX_PARALLEL"
echo ""

# Function to run a single test
run_test() {
    local name="$1"
    local command="$2"
    local output_file="$RESULTS_DIR/$name.json"
    
    echo "[$(date +%H:%M:%S)] ▶ Starting: $name"
    
    # Determine which specialist to use based on test name
    local specialist="tester-claude"
    [[ "$name" =~ security ]] && specialist="security-claude"
    [[ "$name" =~ performance ]] && specialist="perf-claude"
    
    # Run the test
    if /Users/mitchellbosley/.claudepm/bin/${specialist} -p --output-format json "$command" > "$output_file" 2>&1; then
        echo "[$(date +%H:%M:%S)] ✅ Completed: $name"
    else
        echo "[$(date +%H:%M:%S)] ❌ Failed: $name"
    fi
}

# Read tests into array
declare -a TESTS=()
while IFS='|' read -r name command; do
    [[ -z "$name" ]] && continue
    TESTS+=("$name|$command")
done < "$TEST_FILE"

echo "📊 Loaded ${#TESTS[@]} tests"
echo ""

# Run tests with controlled parallelism
ACTIVE_JOBS=0
for test in "${TESTS[@]}"; do
    IFS='|' read -r name command <<< "$test"
    
    # Wait if we're at max parallel
    while (( $(jobs -r | wc -l) >= MAX_PARALLEL )); do
        sleep 0.1
    done
    
    # Launch test in background
    run_test "$name" "$command" &
done

# Wait for all tests to complete
wait

# Generate report if requested
if [[ "$GENERATE_REPORT" == "true" ]]; then
    REPORT_FILE="$RESULTS_DIR/report.md"
    {
        echo "# Test Suite Report"
        echo "Generated: $(date)"
        echo ""
        echo "## Summary"
        
        local passed=0 failed=0
        for result in "$RESULTS_DIR"/*.json; do
            if jq -e '.is_error' "$result" >/dev/null 2>&1; then
                ((failed++))
            else
                ((passed++))
            fi
        done
        
        echo "- Total Tests: $((passed + failed))"
        echo "- Passed: $passed ✅"
        echo "- Failed: $failed ❌"
        echo "- Success Rate: $(( passed * 100 / (passed + failed) ))%"
        echo ""
        echo "## Detailed Results"
        
        for result in "$RESULTS_DIR"/*.json; do
            local test_name=$(basename "$result" .json)
            echo ""
            echo "### $test_name"
            
            if jq -e '.is_error' "$result" >/dev/null 2>&1; then
                echo "**Status**: ❌ FAILED"
                echo ""
                echo "**Error**:"
                echo '```'
                jq -r '.result' "$result" 2>/dev/null || echo "Error parsing result"
                echo '```'
            else
                echo "**Status**: ✅ PASSED"
                echo ""
                echo "**Result**:"
                jq -r '.result' "$result" 2>/dev/null | head -10
            fi
        done
    } > "$REPORT_FILE"
    
    echo ""
    echo "📄 Report generated: $REPORT_FILE"
fi

echo ""
echo "✨ Test suite complete!"