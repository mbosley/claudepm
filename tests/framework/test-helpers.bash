#!/bin/bash
# Helper functions for bats tests

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Common assertions
assert_success() {
    if [ "$status" -ne 0 ]; then
        echo "Command failed with exit code $status"
        echo "Output: $output"
        return 1
    fi
}

assert_failure() {
    if [ "$status" -eq 0 ]; then
        echo "Command succeeded but should have failed"
        echo "Output: $output"
        return 1
    fi
}

assert_output() {
    local expected
    case "$1" in
        --partial)
            expected="$2"
            if [[ "$output" != *"$expected"* ]]; then
                echo "Output does not contain expected string"
                echo "Expected substring: $expected"
                echo "Actual output: $output"
                return 1
            fi
            ;;
        *)
            expected="$1"
            if [ "$output" != "$expected" ]; then
                echo "Output does not match expected"
                echo "Expected: $expected"
                echo "Actual: $output"
                return 1
            fi
            ;;
    esac
}

assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "File does not exist: $file"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Directory does not exist: $dir"
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local content="$2"
    if [ ! -f "$file" ]; then
        echo "File does not exist: $file"
        return 1
    fi
    if ! grep -q "$content" "$file"; then
        echo "File does not contain expected content"
        echo "File: $file"
        echo "Expected content: $content"
        return 1
    fi
}

# Git-specific assertions
assert_git_branch_exists() {
    local branch="$1"
    if ! git branch --list "$branch" | grep -q "$branch"; then
        echo "Git branch does not exist: $branch"
        return 1
    fi
}

assert_git_clean() {
    if [ -n "$(git status --porcelain)" ]; then
        echo "Git working directory is not clean"
        git status --porcelain
        return 1
    fi
}

# Test setup helpers
create_test_git_repo() {
    git init -b main
    git config user.email "test@example.com"
    git config user.name "Test User"
    git commit --allow-empty -m "Initial commit"
}

create_test_project_structure() {
    # Create a minimal claudepm project structure
    mkdir -p .claude/commands
    mkdir -p .claude/templates/project
    mkdir -p tools
    
    # Copy necessary files from the real project
    if [ -f "$PROJECT_ROOT/tools/claudepm-admin.sh" ]; then
        cp "$PROJECT_ROOT/tools/claudepm-admin.sh" ./tools/
        chmod +x ./tools/claudepm-admin.sh
    fi
    
    if [ -f "$PROJECT_ROOT/templates/project/TASK_PROMPT.template.md" ]; then
        cp "$PROJECT_ROOT/templates/project/TASK_PROMPT.template.md" .claude/templates/project/
    fi
}

# Cleanup helper
cleanup_test_artifacts() {
    # Remove any test-specific files or directories
    rm -rf worktrees .prompts_archive
    git clean -fdx
}