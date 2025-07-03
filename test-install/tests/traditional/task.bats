#!/usr/bin/env bats
# Test suite for claudepm task command

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
    
    # Create and init test project
    mkdir -p "$TEST_DIR/test-project"
    cd "$TEST_DIR/test-project"
    
    # Add claudepm to PATH
    export PATH="$HOME/.claudepm/bin:$PATH"
    
    # Initialize project
    claudepm init project >/dev/null 2>&1
}

teardown() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_DIR"
}

@test "claudepm task list shows empty when no tasks" {
    # Clear any default tasks
    echo "# Tasks" > ROADMAP.md
    
    run claudepm task list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "No tasks found" ]] || [[ "$output" =~ "0" ]]
}

@test "claudepm task add creates a new task" {
    run claudepm task add "Implement user authentication"
    [ "$status" -eq 0 ]
    
    grep -q "CPM::TASK::Implement user authentication" ROADMAP.md
}

@test "claudepm task add requires description" {
    run claudepm task add
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Usage:" ]] || [[ "$output" =~ "Error:" ]]
}

@test "claudepm task list shows added tasks" {
    claudepm task add "First task" >/dev/null
    claudepm task add "Second task" >/dev/null
    
    run claudepm task list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "First task" ]]
    [[ "$output" =~ "Second task" ]]
}

@test "claudepm task list numbers tasks" {
    claudepm task add "Task one" >/dev/null
    claudepm task add "Task two" >/dev/null
    
    run claudepm task list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1" ]]
    [[ "$output" =~ "2" ]]
}

@test "claudepm task handles special characters" {
    run claudepm task add "Task with 'quotes' and special chars: $@!"
    [ "$status" -eq 0 ]
    
    grep -q "quotes" ROADMAP.md
}

@test "tasks are added to Active Work section" {
    claudepm task add "New feature" >/dev/null
    
    # Check that task appears after "Active Work" heading
    awk '/Active Work/,/^##/ { if (/CPM::TASK::New feature/) exit 0 } END { exit 1 }' ROADMAP.md
}

@test "claudepm task preserves existing roadmap content" {
    echo "## Custom Section" >> ROADMAP.md
    echo "Important content" >> ROADMAP.md
    
    run claudepm task add "New task"
    [ "$status" -eq 0 ]
    
    grep -q "Custom Section" ROADMAP.md
    grep -q "Important content" ROADMAP.md
}

@test "task command without subcommand shows usage" {
    run claudepm task
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "task list works with malformed CPM::TASK entries" {
    # Add a malformed task
    echo "- CPM::TASK:Missing second colon" >> ROADMAP.md
    echo "- CPM::TASK::Valid task" >> ROADMAP.md
    
    run claudepm task list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Valid task" ]]
}