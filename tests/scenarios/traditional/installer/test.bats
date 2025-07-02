#!/usr/bin/env bats
# Test suite for install.sh

load '../../../framework/test-helpers.bash'

setup() {
    # Create a temporary test environment
    export TEST_PROJECTS_DIR="$BATS_TEST_TMPDIR/test-projects"
    mkdir -p "$TEST_PROJECTS_DIR"
    
    # Disable append-only protection during tests
    export CLAUDEPM_TEST_MODE=1
    
    # Copy the installer to the test directory
    cp "$PROJECT_ROOT/install.sh" "$BATS_TEST_TMPDIR/"
    
    # Copy necessary template files
    mkdir -p "$BATS_TEST_TMPDIR/templates/manager"
    mkdir -p "$BATS_TEST_TMPDIR/templates/project"
    mkdir -p "$BATS_TEST_TMPDIR/templates/task-agent"
    mkdir -p "$BATS_TEST_TMPDIR/.claude/commands"
    
    cp "$PROJECT_ROOT/templates/manager/CLAUDE.md" "$BATS_TEST_TMPDIR/templates/manager/" || true
    cp "$PROJECT_ROOT/templates/project/CLAUDE.md" "$BATS_TEST_TMPDIR/templates/project/" || true
    cp "$PROJECT_ROOT/templates/project/PROJECT_ROADMAP.md" "$BATS_TEST_TMPDIR/templates/project/" || true
    cp "$PROJECT_ROOT/VERSION" "$BATS_TEST_TMPDIR/" || echo "0.2.0-test" > "$BATS_TEST_TMPDIR/VERSION"
    
    # Copy core templates if they exist
    if [ -f "$PROJECT_ROOT/templates/project/CLAUDEPM-PROJECT.md" ]; then
        cp "$PROJECT_ROOT/templates/project/CLAUDEPM-PROJECT.md" "$BATS_TEST_TMPDIR/templates/project/"
        cp "$PROJECT_ROOT/templates/manager/CLAUDEPM-MANAGER.md" "$BATS_TEST_TMPDIR/templates/manager/"
        cp "$PROJECT_ROOT/templates/task-agent/CLAUDEPM-TASK.md" "$BATS_TEST_TMPDIR/templates/task-agent/"
    fi
    
    # Copy tools if they exist
    if [ -f "$PROJECT_ROOT/tools/get-context.sh" ]; then
        mkdir -p "$BATS_TEST_TMPDIR/tools"
        cp "$PROJECT_ROOT/tools/get-context.sh" "$BATS_TEST_TMPDIR/tools/"
    else
        # Create a minimal get-context.sh for testing
        mkdir -p "$BATS_TEST_TMPDIR/tools"
        echo '#!/bin/bash' > "$BATS_TEST_TMPDIR/tools/get-context.sh"
        echo 'echo "get-context helper"' >> "$BATS_TEST_TMPDIR/tools/get-context.sh"
        chmod +x "$BATS_TEST_TMPDIR/tools/get-context.sh"
    fi
    
    cd "$BATS_TEST_TMPDIR"
}

teardown() {
    # Cleanup is handled by bats temp directory
    cd "$OLDPWD"
}

@test "installer creates correct directory structure" {
    # Run installer with test directory
    run bash install.sh <<< "$TEST_PROJECTS_DIR"
    assert_success
    
    # Check core directories exist
    assert_dir_exists "$TEST_PROJECTS_DIR/.claude"
    assert_dir_exists "$TEST_PROJECTS_DIR/.claude/templates"
    assert_dir_exists "$TEST_PROJECTS_DIR/.claude/templates/project"
    assert_dir_exists "$TEST_PROJECTS_DIR/.claude/templates/manager"
    assert_dir_exists "$TEST_PROJECTS_DIR/.claude/core"
    assert_dir_exists "$TEST_PROJECTS_DIR/.claude/bin"
}

@test "installer copies manager CLAUDE.md" {
    run bash install.sh <<< "$TEST_PROJECTS_DIR"
    assert_success
    
    assert_file_exists "$TEST_PROJECTS_DIR/CLAUDE.md"
}

@test "installer creates initial CLAUDE_LOG.md" {
    run bash install.sh <<< "$TEST_PROJECTS_DIR"
    assert_success
    
    assert_file_exists "$TEST_PROJECTS_DIR/CLAUDE_LOG.md"
    assert_file_contains "$TEST_PROJECTS_DIR/CLAUDE_LOG.md" "Manager Claude Activity Log"
}

@test "installer backs up existing CLAUDE.md" {
    # Create existing CLAUDE.md
    echo "Existing content" > "$TEST_PROJECTS_DIR/CLAUDE.md"
    
    # Run installer and choose to replace
    run bash install.sh <<< "$TEST_PROJECTS_DIR"$'\n'"y"
    assert_success
    
    # Check backup was created
    assert_file_exists "$TEST_PROJECTS_DIR/CLAUDE.md.backup"
    assert_file_contains "$TEST_PROJECTS_DIR/CLAUDE.md.backup" "Existing content"
}

@test "installer copies project templates" {
    run bash install.sh <<< "$TEST_PROJECTS_DIR"
    assert_success
    
    assert_file_exists "$TEST_PROJECTS_DIR/.claude/templates/project/CLAUDE.md"
    assert_file_exists "$TEST_PROJECTS_DIR/.claude/templates/project/PROJECT_ROADMAP.md"
    assert_file_exists "$TEST_PROJECTS_DIR/.claude/templates/VERSION"
}

@test "installer copies core CLAUDEPM files for v0.2.0" {
    run bash install.sh <<< "$TEST_PROJECTS_DIR"
    assert_success
    
    # Only check if source files exist
    if [ -f "templates/project/CLAUDEPM-PROJECT.md" ]; then
        assert_file_exists "$TEST_PROJECTS_DIR/.claude/core/CLAUDEPM-PROJECT.md"
        assert_file_exists "$TEST_PROJECTS_DIR/.claude/core/CLAUDEPM-MANAGER.md"
        assert_file_exists "$TEST_PROJECTS_DIR/.claude/core/CLAUDEPM-TASK.md"
    fi
}

@test "installer copies get-context helper" {
    run bash install.sh <<< "$TEST_PROJECTS_DIR"
    assert_success
    
    # Only check if source file exists
    if [ -f "tools/get-context.sh" ]; then
        assert_file_exists "$TEST_PROJECTS_DIR/.claude/bin/get-context"
        # Check it's executable
        [ -x "$TEST_PROJECTS_DIR/.claude/bin/get-context" ]
    fi
}

@test "installer handles non-existent directory" {
    run bash install.sh <<< "/non/existent/directory"
    assert_failure
    assert_output --partial "Error: Directory /non/existent/directory does not exist"
}

@test "installer requires running from claudepm directory" {
    cd /tmp
    run bash "$BATS_TEST_TMPDIR/install.sh" <<< "$TEST_PROJECTS_DIR"
    assert_failure
    assert_output --partial "Error: Please run this from the claudepm directory"
}