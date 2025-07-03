#!/bin/bash
# claudepm-test.sh - Test environment management for Tester Claude
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_BASE="$PROJECT_ROOT/tests/tester-claude"
ENVIRONMENTS_DIR="$TEST_BASE/environments"
RUNS_DIR="$TEST_BASE/runs"
MISSIONS_DIR="$TEST_BASE/missions"

# Ensure directories exist
mkdir -p "$ENVIRONMENTS_DIR" "$RUNS_DIR" "$MISSIONS_DIR"

# Usage function
usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init <test-name>    Initialize a test environment and prepare for testing"
    echo "  reset <test-name>   Reset a test environment to its initial state"
    echo "  list               List available test environments"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 init fresh-install"
    echo "  $0 reset legacy-project"
    exit 1
}

# Initialize a test environment for running
init_test() {
    local test_name="$1"
    local env_dir="$ENVIRONMENTS_DIR/$test_name"
    
    if [ ! -d "$env_dir" ]; then
        echo -e "${RED}Error: Test environment '$test_name' not found${NC}"
        echo "Available environments:"
        ls -1 "$ENVIRONMENTS_DIR" 2>/dev/null || echo "  (none)"
        exit 1
    fi
    
    # Check for lock
    local lock_dir="$env_dir/.lock"
    if ! mkdir "$lock_dir" 2>/dev/null; then
        echo -e "${RED}Error: Test environment '$test_name' is locked${NC}"
        echo "Another process may be using it."
        exit 1
    fi
    
    # Ensure lock is removed on exit
    trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT
    
    # Create run directory
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local run_id="${timestamp}-${test_name}"
    local run_dir="$RUNS_DIR/$run_id"
    local sandbox_dir="$run_dir/sandbox"
    
    echo -e "${BLUE}Initializing test environment: $test_name${NC}"
    echo "Run ID: $run_id"
    
    # Create run structure
    mkdir -p "$sandbox_dir"
    
    # Check if initial state exists, create if needed
    if [ ! -f "$env_dir/initial.tar.gz" ]; then
        echo -e "${YELLOW}Initial state not found. Running setup...${NC}"
        if [ -f "$env_dir/setup.sh" ]; then
            (cd "$env_dir" && bash setup.sh)
        else
            echo -e "${RED}Error: No setup.sh found for $test_name${NC}"
            exit 1
        fi
    fi
    
    # Extract initial state
    echo "Extracting initial state..."
    tar -xzf "$env_dir/initial.tar.gz" -C "$sandbox_dir"
    
    # Create manifest
    cat > "$run_dir/manifest.json" << EOF
{
  "run_id": "$run_id",
  "test_name": "$test_name",
  "claudepm_version": "$(cat "$PROJECT_ROOT/VERSION" 2>/dev/null || echo "unknown")",
  "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "initialized",
  "environment": {
    "os": "$(uname -s)",
    "initial_state": "$env_dir/initial.tar.gz"
  }
}
EOF
    
    # Export environment variables for Tester Claude
    echo -e "${GREEN}Test environment ready!${NC}"
    echo ""
    echo "Environment variables for Tester Claude:"
    echo "export CLAUDEPM_TEST_RUN_DIR=\"$run_dir\""
    echo "export CLAUDEPM_TEST_SANDBOX=\"$sandbox_dir\""
    echo "export CLAUDEPM_TEST_NAME=\"$test_name\""
    echo "export CLAUDEPM_TEST_TRACE_LOG=\"$run_dir/trace.log\""
    echo "export CLAUDEPM_TEST_REPORT=\"$run_dir/report.md\""
    echo ""
    echo "To spawn Tester Claude, use these paths in your prompt:"
    echo "- Working directory: $sandbox_dir"
    echo "- Report output: $run_dir/report.md"
    echo "- Command trace: $run_dir/trace.log"
    
    # Remove lock
    rmdir "$lock_dir"
    trap - EXIT
}

# Reset a test environment to initial state
reset_test() {
    local test_name="$1"
    local env_dir="$ENVIRONMENTS_DIR/$test_name"
    
    if [ ! -d "$env_dir" ]; then
        echo -e "${RED}Error: Test environment '$test_name' not found${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Resetting test environment: $test_name${NC}"
    
    # Remove old initial state
    rm -f "$env_dir/initial.tar.gz"
    
    # Run setup script
    if [ -f "$env_dir/setup.sh" ]; then
        echo "Running setup.sh..."
        (cd "$env_dir" && bash setup.sh)
        echo -e "${GREEN}Reset complete!${NC}"
    else
        echo -e "${RED}Error: No setup.sh found for $test_name${NC}"
        echo ""
        echo "Create $env_dir/setup.sh with:"
        echo "#!/bin/bash"
        echo "# Create initial state in a temp directory"
        echo "# Then: tar -czf initial.tar.gz -C \$TEMP_DIR ."
        exit 1
    fi
}

# List available test environments
list_environments() {
    echo -e "${BLUE}Available test environments:${NC}"
    echo ""
    
    if [ -d "$ENVIRONMENTS_DIR" ]; then
        for env in "$ENVIRONMENTS_DIR"/*; do
            if [ -d "$env" ]; then
                local name=$(basename "$env")
                local status="${RED}[not ready]${NC}"
                
                if [ -f "$env/initial.tar.gz" ]; then
                    status="${GREEN}[ready]${NC}"
                fi
                
                if [ -d "$env/.lock" ]; then
                    status="${YELLOW}[locked]${NC}"
                fi
                
                echo -e "  $name $status"
                
                if [ -f "$env/description.txt" ]; then
                    echo "    $(cat "$env/description.txt")"
                fi
            fi
        done
    else
        echo "  (none)"
    fi
    
    echo ""
    echo -e "${BLUE}Recent test runs:${NC}"
    if [ -d "$RUNS_DIR" ]; then
        ls -1t "$RUNS_DIR" 2>/dev/null | head -5 | while read run; do
            echo "  $run"
        done
    else
        echo "  (none)"
    fi
}

# Main command processing
case "${1:-help}" in
    init)
        if [ $# -lt 2 ]; then
            echo -e "${RED}Error: Test name required${NC}"
            usage
        fi
        init_test "$2"
        ;;
    reset)
        if [ $# -lt 2 ]; then
            echo -e "${RED}Error: Test name required${NC}"
            usage
        fi
        reset_test "$2"
        ;;
    list)
        list_environments
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        usage
        ;;
esac