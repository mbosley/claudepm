#!/bin/bash
# Environment setup for claudepm tests

# Export test environment variables
export CLAUDEPM_TEST_MODE=1
export CLAUDEPM_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CLAUDEPM_PROJECT_ROOT="$(cd "$CLAUDEPM_TEST_DIR/.." && pwd)"

# Function to check test dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for bats
    if ! command -v bats >/dev/null 2>&1; then
        missing_deps+=("bats-core")
    fi
    
    # Check for Python 3
    if ! command -v python3 >/dev/null 2>&1; then
        missing_deps+=("python3")
    fi
    
    # Check for jq (for JSON parsing)
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    # Check for git
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing test dependencies:"
        printf ' - %s\n' "${missing_deps[@]}"
        echo ""
        echo "Install instructions:"
        echo "  macOS:   brew install bats-core jq"
        echo "  Ubuntu:  sudo apt-get install bats jq"
        echo "  Python:  Ensure python3 is installed"
        return 1
    fi
    
    return 0
}

# Function to setup Python environment
setup_python_env() {
    local venv_dir="$CLAUDEPM_TEST_DIR/.venv"
    
    if [ ! -d "$venv_dir" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv "$venv_dir"
    fi
    
    # Activate virtual environment
    source "$venv_dir/bin/activate"
    
    # Install dependencies if requirements.txt exists
    if [ -f "$CLAUDEPM_TEST_DIR/framework/sdk/requirements.txt" ]; then
        pip install -q -r "$CLAUDEPM_TEST_DIR/framework/sdk/requirements.txt"
    fi
}

# Function to validate API key
check_api_key() {
    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        echo "Warning: ANTHROPIC_API_KEY not set"
        echo "AI behavioral tests will be skipped"
        echo ""
        echo "To run AI tests, set your API key:"
        echo "  export ANTHROPIC_API_KEY='your-key-here'"
        return 1
    fi
    return 0
}

# Main setup function
setup_test_environment() {
    echo "Setting up test environment..."
    
    if ! check_dependencies; then
        return 1
    fi
    
    # Only setup Python if we're running AI tests
    if [[ "${1:-}" == *"ai"* ]] || [[ "${1:-}" == "all" ]]; then
        setup_python_env
        check_api_key
    fi
    
    echo "Test environment ready!"
    return 0
}