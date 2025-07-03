#!/usr/bin/env bats
# Test suite for claudepm init command

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
    
    # Create test projects directory
    mkdir -p "$TEST_DIR/projects"
    cd "$TEST_DIR/projects"
    
    # Add claudepm to PATH
    export PATH="$HOME/.claudepm/bin:$PATH"
}

teardown() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_DIR"
}

@test "claudepm init manager creates manager files" {
    run claudepm init manager
    [ "$status" -eq 0 ]
    [ -f "CLAUDE.md" ]
    [ -f "LOG.md" ]
    [ -f "ROADMAP.md" ]
    [ -f "NOTES.md" ]
}

@test "claudepm init project creates project files" {
    mkdir test-project
    cd test-project
    
    run claudepm init project
    [ "$status" -eq 0 ]
    [ -f "CLAUDE.md" ]
    [ -f "LOG.md" ]
    [ -f "ROADMAP.md" ]
    [ -f "NOTES.md" ]
    [ -f ".claudepm" ]
}

@test "claudepm init with invalid type shows error" {
    run claudepm init invalid
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Unknown type" ]]
}

@test "claudepm init without type shows usage" {
    run claudepm init
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "claudepm init project includes project name in CLAUDE.md" {
    mkdir my-awesome-project
    cd my-awesome-project
    
    run claudepm init project
    [ "$status" -eq 0 ]
    grep -q "Project: my-awesome-project" CLAUDE.md
}

@test "claudepm init creates .claudepm marker with metadata" {
    mkdir test-project
    cd test-project
    
    run claudepm init project
    [ "$status" -eq 0 ]
    [ -f ".claudepm" ]
    grep -q '"version":' .claudepm
    grep -q '"role": "project"' .claudepm
}

@test "claudepm init manager does not create .claudepm file" {
    run claudepm init manager
    [ "$status" -eq 0 ]
    [ ! -f ".claudepm" ]
}

@test "claudepm init preserves existing files" {
    mkdir test-project
    cd test-project
    echo "existing content" > CLAUDE.md
    
    run claudepm init project
    [ "$status" -eq 0 ]
    grep -q "existing content" CLAUDE.md
}

@test "LOG.md starts with append-only header" {
    mkdir test-project
    cd test-project
    
    run claudepm init project
    [ "$status" -eq 0 ]
    head -1 LOG.md | grep -q "append-only"
}

@test "ROADMAP.md includes CPM::TASK format examples" {
    mkdir test-project
    cd test-project
    
    run claudepm init project
    [ "$status" -eq 0 ]
    grep -q "CPM::TASK" ROADMAP.md
}