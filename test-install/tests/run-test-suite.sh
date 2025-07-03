#!/bin/bash
# ClaudePM Test Suite Runner
# Uses parallel tester-claude instances for defined test scenarios
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCENARIOS_DIR="$(dirname "$0")/scenarios"
RESULTS_DIR="/tmp/claudepm-test-results-$(date +%Y%m%d-%H%M%S)"
MAX_PARALLEL="${MAX_PARALLEL:-3}"

# Ensure tester-claude exists
TESTER_CLAUDE="/Users/mitchellbosley/.claudepm/bin/tester-claude"
if [[ ! -x "$TESTER_CLAUDE" ]]; then
    echo -e "${RED}Error: tester-claude not found at $TESTER_CLAUDE${NC}"
    echo "Please ensure the wrapper script is installed"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}🧪 ClaudePM Test Suite${NC}"
echo "Results directory: $RESULTS_DIR"
echo "Max parallel tests: $MAX_PARALLEL"
echo ""

# Function to run a single test scenario
run_test_scenario() {
    local scenario_file="$1"
    local scenario_name=$(basename "$scenario_file" .md)
    local result_file="$RESULTS_DIR/${scenario_name}.json"
    
    echo -e "${BLUE}▶ Starting${NC}: $scenario_name"
    
    # Read the scenario content
    local scenario_content=$(cat "$scenario_file")
    
    # Spawn tester-claude with the scenario
    if $TESTER_CLAUDE -p --output-format json "
    Execute this test scenario and report results:
    
    $scenario_content
    
    Follow all steps exactly. Report PASS/FAIL for each step.
    Include execution time and any errors encountered.
    " > "$result_file" 2>&1; then
        echo -e "${GREEN}✓ Completed${NC}: $scenario_name"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}: $scenario_name"
        return 1
    fi
}

# Collect all test scenarios
echo "📋 Loading test scenarios..."
SCENARIOS=()
for scenario in "$SCENARIOS_DIR"/*.md; do
    if [[ -f "$scenario" ]]; then
        SCENARIOS+=("$scenario")
        echo "  - $(basename "$scenario" .md)"
    fi
done

echo ""
echo "🚀 Running ${#SCENARIOS[@]} test scenarios..."
echo ""

# Run tests with controlled parallelism
PIDS=()
FAILED=0

for scenario in "${SCENARIOS[@]}"; do
    # Wait if we're at max parallel
    while [[ ${#PIDS[@]} -ge $MAX_PARALLEL ]]; do
        # Check for completed processes
        NEW_PIDS=()
        for pid in "${PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                NEW_PIDS+=("$pid")
            else
                # Process completed, check exit status
                wait "$pid" || ((FAILED++))
            fi
        done
        PIDS=("${NEW_PIDS[@]}")
        sleep 0.1
    done
    
    # Launch test in background
    run_test_scenario "$scenario" &
    PIDS+=($!)
done

# Wait for remaining tests
echo ""
echo "⏳ Waiting for final tests to complete..."
for pid in "${PIDS[@]}"; do
    wait "$pid" || ((FAILED++))
done

# Generate summary report
echo ""
echo "📊 Generating test summary..."

SUMMARY_FILE="$RESULTS_DIR/summary.md"
{
    echo "# ClaudePM Test Suite Summary"
    echo "Generated: $(date)"
    echo ""
    echo "## Overview"
    echo "- Total Scenarios: ${#SCENARIOS[@]}"
    echo "- Passed: $((${#SCENARIOS[@]} - FAILED))"
    echo "- Failed: $FAILED"
    echo ""
    echo "## Detailed Results"
    
    for scenario in "${SCENARIOS[@]}"; do
        local name=$(basename "$scenario" .md)
        local result_file="$RESULTS_DIR/${name}.json"
        
        echo ""
        echo "### $name"
        
        if [[ -f "$result_file" ]]; then
            # Extract key information from JSON result
            local is_error=$(jq -r '.is_error // false' "$result_file" 2>/dev/null)
            
            if [[ "$is_error" == "false" ]]; then
                echo "**Status**: ✅ PASSED"
                echo ""
                echo "**Summary**:"
                jq -r '.result' "$result_file" 2>/dev/null | head -20
            else
                echo "**Status**: ❌ FAILED"
                echo ""
                echo "**Error**:"
                jq -r '.result // "Error details not available"' "$result_file" 2>/dev/null
            fi
        else
            echo "**Status**: ❌ NO RESULTS"
        fi
    done
} > "$SUMMARY_FILE"

# Display summary
echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ $FAILED tests failed${NC}"
fi

echo ""
echo "📄 Full report: $SUMMARY_FILE"
echo "📁 Individual results: $RESULTS_DIR/"

# Exit with appropriate code
exit $FAILED