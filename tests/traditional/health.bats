#!/usr/bin/env bats
# Test suite for claudepm health and doctor commands

setup() {
    # Create temporary test directory
    export TEST_DIR="$(mktemp -d)"
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_DIR/home"
    mkdir -p "$HOME"
    
    # Install claudepm in test environment
    mkdir -p "$TEST_DIR/source"
    cp -r "${BATS_TEST_DIRNAME}/../../"* "$TEST_DIR/source/"
    cd "$TEST_DIR/source"
    ./install.sh >/dev/null 2>&1
    
    # Create test project
    mkdir -p "$TEST_DIR/test-project"
    cd "$TEST_DIR/test-project"
    
    # Add claudepm to PATH
    export PATH="$HOME/.claudepm/bin:$PATH"
}

teardown() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_DIR"
}

@test "claudepm health on uninitialized project shows not initialized" {
    run claudepm health
    [ "$status" -eq 0 ]
    [[ "$output" =~ "not initialized" ]] || [[ "$output" =~ "Not initialized" ]]
}

@test "claudepm health on initialized project shows healthy" {
    claudepm init project >/dev/null 2>&1
    
    run claudepm health
    [ "$status" -eq 0 ]
    [[ "$output" =~ "healthy" ]] || [[ "$output" =~ "Healthy" ]] || [[ "$output" =~ "✓" ]]
}

@test "claudepm health detects missing files" {
    claudepm init project >/dev/null 2>&1
    rm -f ROADMAP.md
    
    run claudepm health
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ROADMAP.md" ]]
}

@test "claudepm health shows version info" {
    claudepm init project >/dev/null 2>&1
    
    run claudepm health
    [ "$status" -eq 0 ]
    [[ "$output" =~ "0.2.5" ]]
}

@test "claudepm doctor checks installation" {
    run claudepm doctor
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Installation" ]] || [[ "$output" =~ "claudepm" ]]
}

@test "claudepm doctor in project shows project info" {
    claudepm init project >/dev/null 2>&1
    
    run claudepm doctor
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Project:" ]] || [[ "$output" =~ "test-project" ]]
}

@test "claudepm doctor detects outdated version" {
    claudepm init project >/dev/null 2>&1
    # Modify .claudepm to have old version
    sed -i.bak 's/0.2.5/0.1.0/' .claudepm 2>/dev/null || sed -i '' 's/0.2.5/0.1.0/' .claudepm
    
    run claudepm doctor
    [ "$status" -eq 0 ]
    [[ "$output" =~ "outdated" ]] || [[ "$output" =~ "update" ]] || [[ "$output" =~ "0.1.0" ]]
}

@test "health command checks all required files" {
    claudepm init project >/dev/null 2>&1
    
    run claudepm health
    [ "$status" -eq 0 ]
    [[ "$output" =~ "CLAUDE.md" ]]
    [[ "$output" =~ "LOG.md" ]]
    [[ "$output" =~ "ROADMAP.md" ]]
    [[ "$output" =~ "NOTES.md" ]]
}

@test "health command works in manager context" {
    claudepm init manager >/dev/null 2>&1
    
    run claudepm health
    [ "$status" -eq 0 ]
    # Should not complain about missing .claudepm
    ! [[ "$output" =~ ".claudepm" ]]
}

@test "doctor command suggests init for uninitialized project" {
    run claudepm doctor
    [ "$status" -eq 0 ]
    [[ "$output" =~ "init" ]] || [[ "$output" =~ "initialize" ]]
}