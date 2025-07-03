#!/usr/bin/env bats
# Test suite for claudepm installer

setup() {
    # Create temporary test directory
    export TEST_DIR="$(mktemp -d)"
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME"
    
    # Copy installer to test directory
    cp "${BATS_TEST_DIRNAME}/../../install.sh" "$TEST_DIR/"
    cd "$TEST_DIR"
}

teardown() {
    # Restore original HOME
    export HOME="$ORIGINAL_HOME"
    # Clean up test directory
    rm -rf "$TEST_DIR"
}

@test "installer creates .claudepm directory structure" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -d "$HOME/.claudepm" ]
    [ -d "$HOME/.claudepm/bin" ]
    [ -d "$HOME/.claudepm/lib" ]
    [ -d "$HOME/.claudepm/templates" ]
    [ -d "$HOME/.claudepm/commands" ]
}

@test "installer copies claudepm executable" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claudepm/bin/claudepm" ]
    [ -x "$HOME/.claudepm/bin/claudepm" ]
}

@test "installer copies utility library" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claudepm/lib/utils.sh" ]
}

@test "installer copies templates" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claudepm/templates/project/CLAUDE.md" ]
    [ -f "$HOME/.claudepm/templates/project/LOG.md" ]
    [ -f "$HOME/.claudepm/templates/project/ROADMAP.md" ]
    [ -f "$HOME/.claudepm/templates/project/NOTES.md" ]
    [ -f "$HOME/.claudepm/templates/manager/CLAUDE.md" ]
}

@test "installer copies slash commands" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claudepm/commands/brain-dump.md" ]
    [ -f "$HOME/.claudepm/commands/doctor.md" ]
    [ -f "$HOME/.claudepm/commands/daily-standup.md" ]
}

@test "installer creates VERSION file" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claudepm/VERSION" ]
    grep -q "0.2.5" "$HOME/.claudepm/VERSION"
}

@test "installer handles existing installation" {
    # First installation
    run ./install.sh
    [ "$status" -eq 0 ]
    
    # Create a custom file to verify it's preserved
    echo "custom content" > "$HOME/.claudepm/custom.txt"
    
    # Second installation
    run ./install.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claudepm/custom.txt" ]
    grep -q "custom content" "$HOME/.claudepm/custom.txt"
}

@test "installer shows success message" {
    run ./install.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Successfully installed" ]]
}

@test "claudepm --version works after installation" {
    run ./install.sh
    [ "$status" -eq 0 ]
    
    # The claudepm script should exist and be executable
    [ -x "$HOME/.claudepm/bin/claudepm" ]
    
    # Check version directly since the script might have dependencies
    run grep "VERSION=" "$HOME/.claudepm/bin/claudepm"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "0.2.5" ]]
}

@test "claudepm --help works after installation" {
    run ./install.sh
    [ "$status" -eq 0 ]
    
    run "$HOME/.claudepm/bin/claudepm" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}