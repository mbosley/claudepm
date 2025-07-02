#!/usr/bin/env bats
# Test suite for get-context.sh helper

load '../../../framework/test-helpers.bash'

setup() {
    # Create a temporary test environment
    export TEST_DIR="$BATS_TEST_TMPDIR/test-context"
    mkdir -p "$TEST_DIR"
    
    # Create .claude/core directory structure
    export TEST_CLAUDE_HOME="$BATS_TEST_TMPDIR/.claude"
    mkdir -p "$TEST_CLAUDE_HOME/core"
    
    # Override HOME for the test
    export HOME="$BATS_TEST_TMPDIR"
    
    # Copy get-context.sh to test location
    cp "$PROJECT_ROOT/tools/get-context.sh" "$TEST_DIR/"
    chmod +x "$TEST_DIR/get-context.sh"
    
    # Create core CLAUDEPM files
    echo "# CLAUDEPM Manager Instructions" > "$TEST_CLAUDE_HOME/core/CLAUDEPM-MANAGER.md"
    echo "Manager core content" >> "$TEST_CLAUDE_HOME/core/CLAUDEPM-MANAGER.md"
    
    echo "# CLAUDEPM Project Instructions" > "$TEST_CLAUDE_HOME/core/CLAUDEPM-PROJECT.md"
    echo "Project core content" >> "$TEST_CLAUDE_HOME/core/CLAUDEPM-PROJECT.md"
    
    echo "# CLAUDEPM Task Agent Instructions" > "$TEST_CLAUDE_HOME/core/CLAUDEPM-TASK.md"
    echo "Task agent core content" >> "$TEST_CLAUDE_HOME/core/CLAUDEPM-TASK.md"
    
    cd "$TEST_DIR"
}

teardown() {
    cd "$OLDPWD"
}

@test "get-context with project role" {
    # Create .claudepm file with project role
    cat > .claudepm <<EOF
{
  "role": "project"
}
EOF
    
    # Create local CLAUDE.md
    echo "# Local Project Instructions" > CLAUDE.md
    echo "Custom project content" >> CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Check output contains both files
    assert_output --partial "# Local Project Instructions"
    assert_output --partial "Custom project content"
    assert_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
    assert_output --partial "# CLAUDEPM Project Instructions"
    assert_output --partial "Project core content"
}

@test "get-context with manager role" {
    # Create .claudepm file with manager role
    cat > .claudepm <<EOF
{
  "role": "manager"
}
EOF
    
    # Create local CLAUDE.md
    echo "# Local Manager Instructions" > CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Check output contains manager core file
    assert_output --partial "# Local Manager Instructions"
    assert_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
    assert_output --partial "# CLAUDEPM Manager Instructions"
    assert_output --partial "Manager core content"
}

@test "get-context with task-agent role" {
    # Create .claudepm file with task-agent role
    cat > .claudepm <<EOF
{
  "role": "task-agent"
}
EOF
    
    # Create local CLAUDE.md
    echo "# Task Agent Instructions" > CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Check output contains task-agent core file
    assert_output --partial "# Task Agent Instructions"
    assert_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
    assert_output --partial "# CLAUDEPM Task Agent Instructions"
    assert_output --partial "Task agent core content"
}

@test "get-context legacy mode (no .claudepm)" {
    # Create only CLAUDE.md, no .claudepm
    echo "# Legacy Project" > CLAUDE.md
    echo "Legacy content" >> CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Should only output CLAUDE.md content
    assert_output --partial "# Legacy Project"
    assert_output --partial "Legacy content"
    # Should NOT contain core instructions
    refute_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
}

@test "get-context with missing role defaults to project" {
    # Create .claudepm without role field
    cat > .claudepm <<EOF
{
  "version": "0.2.0"
}
EOF
    
    # Create local CLAUDE.md
    echo "# Project with missing role" > CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Should default to project role
    assert_output --partial "# Project with missing role"
    assert_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
    assert_output --partial "# CLAUDEPM Project Instructions"
}

@test "get-context with no CLAUDE.md shows only core" {
    # Create .claudepm but no CLAUDE.md
    cat > .claudepm <<EOF
{
  "role": "project"
}
EOF
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Should show only core instructions
    assert_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
    assert_output --partial "# CLAUDEPM Project Instructions"
}

@test "get-context with missing core file fallback" {
    # Remove core files to test fallback
    rm -rf "$TEST_CLAUDE_HOME/core"
    
    # Create .claudepm and CLAUDE.md
    cat > .claudepm <<EOF
{
  "role": "project"
}
EOF
    echo "# Fallback Test" > CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Should only show local CLAUDE.md
    assert_output --partial "# Fallback Test"
    refute_output --partial "===== CLAUDEPM CORE INSTRUCTIONS BELOW ====="
}

@test "get-context not in claudepm directory" {
    # Remove .claudepm and CLAUDE.md
    rm -f .claudepm CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_failure
    assert_output --partial "Error: Not in a claudepm-managed directory"
}

@test "get-context role parsing with spaces" {
    # Create .claudepm with spaces in JSON
    cat > .claudepm <<EOF
{
  "role"  :  "manager"
}
EOF
    
    echo "# Manager with spaces" > CLAUDE.md
    
    # Run get-context
    run ./get-context.sh
    assert_success
    
    # Should parse role correctly despite spaces
    assert_output --partial "# CLAUDEPM Manager Instructions"
}