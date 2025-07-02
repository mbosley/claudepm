#!/bin/bash
# Main test runner for claudepm
# Orchestrates both traditional (bats) and AI behavioral tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TESTS_DIR="$PROJECT_ROOT/tests"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test mode from command line
MODE="${1:-all}"
EXTRA_ARGS="${@:2}"

# Function to print colored output
print_status() {
    local color=$1
    local status=$2
    local message=$3
    echo -e "${color}[${status}]${NC} ${message}"
}

# Function to run a test in an isolated environment
run_isolated_test() {
    local test_path=$1
    local test_type=$2
    local test_name=$(basename $(dirname "$test_path"))
    
    print_status "$BLUE" "RUN" "Testing: $test_name"
    
    # Create temporary directory for test isolation
    TEST_TMP=$(mktemp -d -t claudepm-test-XXXXXX)
    
    # Set up cleanup trap
    trap "rm -rf '$TEST_TMP'" EXIT
    
    # Copy test scenario to temp directory
    if [ -d "$(dirname "$test_path")/setup" ]; then
        cp -r "$(dirname "$test_path")/setup/"* "$TEST_TMP/"
    fi
    
    # Run the test based on type
    cd "$TEST_TMP"
    local exit_code=0
    
    if [ "$test_type" = "bats" ]; then
        if command -v bats >/dev/null 2>&1; then
            bats "$test_path" || exit_code=$?
        else
            print_status "$YELLOW" "SKIP" "bats not installed - skipping traditional tests"
            return 0
        fi
    elif [ "$test_type" = "python" ]; then
        if command -v python3 >/dev/null 2>&1; then
            python3 "$test_path" || exit_code=$?
        else
            print_status "$YELLOW" "SKIP" "python3 not installed - skipping AI behavioral tests"
            return 0
        fi
    fi
    
    cd - >/dev/null
    
    # Clean up (trap will handle this, but being explicit)
    rm -rf "$TEST_TMP"
    trap - EXIT
    
    if [ $exit_code -eq 0 ]; then
        print_status "$GREEN" "PASS" "$test_name"
    else
        print_status "$RED" "FAIL" "$test_name"
    fi
    
    return $exit_code
}

# Main test execution
main() {
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0
    
    echo "claudepm Test Suite"
    echo "=================="
    echo "Mode: $MODE"
    echo ""
    
    # Traditional tests (bats)
    if [ "$MODE" = "all" ] || [ "$MODE" = "traditional" ]; then
        print_status "$BLUE" "INFO" "Running traditional tests..."
        
        for test_file in "$TESTS_DIR"/scenarios/traditional/*/test.bats; do
            if [ -f "$test_file" ]; then
                ((total_tests++))
                if run_isolated_test "$test_file" "bats"; then
                    ((passed_tests++))
                else
                    ((failed_tests++))
                fi
            fi
        done
    fi
    
    # AI behavioral tests (python)
    if [ "$MODE" = "all" ] || [ "$MODE" = "ai-behavioral" ]; then
        print_status "$BLUE" "INFO" "Running AI behavioral tests..."
        
        # Check for API key
        if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
            print_status "$YELLOW" "WARN" "ANTHROPIC_API_KEY not set - skipping AI tests"
        else
            for test_file in "$TESTS_DIR"/scenarios/ai-behavioral/*/test.py; do
                if [ -f "$test_file" ]; then
                    ((total_tests++))
                    if run_isolated_test "$test_file" "python"; then
                        ((passed_tests++))
                    else
                        ((failed_tests++))
                    fi
                fi
            done
        fi
    fi
    
    # Summary
    echo ""
    echo "Test Summary"
    echo "============"
    echo "Total:   $total_tests"
    print_status "$GREEN" "PASS" "$passed_tests tests"
    if [ $failed_tests -gt 0 ]; then
        print_status "$RED" "FAIL" "$failed_tests tests"
    fi
    
    # Exit with appropriate code
    if [ $failed_tests -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Show help if requested
if [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ]; then
    echo "Usage: $0 [mode] [options]"
    echo ""
    echo "Modes:"
    echo "  all          Run all tests (default)"
    echo "  traditional  Run only traditional bats tests"
    echo "  ai-behavioral Run only AI behavioral tests"
    echo ""
    echo "Options:"
    echo "  --model=MODEL  Use specific model for AI tests (default: haiku)"
    echo ""
    echo "Environment variables:"
    echo "  ANTHROPIC_API_KEY  Required for AI behavioral tests"
    exit 0
fi

# Run main function
main