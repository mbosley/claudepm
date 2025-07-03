#!/usr/bin/env bats
# Test suite for claudepm utility functions

setup() {
    # Create temporary test directory
    export TEST_DIR="$(mktemp -d)"
    
    # Source the utils library
    source "${BATS_TEST_DIRNAME}/../../lib/utils.sh"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "print_header displays formatted header" {
    run print_header "Test Header"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test Header" ]]
    [[ "$output" =~ "=" ]]  # Should have separator line
}

@test "print_success shows success message" {
    run print_success "Operation completed"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "✓" ]] || [[ "$output" =~ "Success" ]]
    [[ "$output" =~ "Operation completed" ]]
}

@test "print_error shows error message" {
    run print_error "Something went wrong"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "✗" ]] || [[ "$output" =~ "Error" ]]
    [[ "$output" =~ "Something went wrong" ]]
}

@test "print_info shows info message" {
    run print_info "Information message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ℹ" ]] || [[ "$output" =~ "Info" ]]
    [[ "$output" =~ "Information message" ]]
}

@test "ensure_file creates file if not exists" {
    local test_file="$TEST_DIR/test.txt"
    
    ensure_file "$test_file" "Default content"
    
    [ -f "$test_file" ]
    grep -q "Default content" "$test_file"
}

@test "ensure_file preserves existing file" {
    local test_file="$TEST_DIR/existing.txt"
    echo "Original content" > "$test_file"
    
    ensure_file "$test_file" "Default content"
    
    grep -q "Original content" "$test_file"
    ! grep -q "Default content" "$test_file"
}

@test "check_dependencies succeeds when commands exist" {
    # Test with commands that definitely exist
    run check_dependencies "sh" "echo" "test"
    [ "$status" -eq 0 ]
}

@test "check_dependencies fails when command missing" {
    run check_dependencies "this-command-does-not-exist"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "not found" ]] || [[ "$output" =~ "missing" ]]
}

@test "is_project_root detects project root" {
    cd "$TEST_DIR"
    touch .claudepm
    
    run is_project_root
    [ "$status" -eq 0 ]
}

@test "is_project_root fails in non-project directory" {
    cd "$TEST_DIR"
    
    run is_project_root
    [ "$status" -eq 1 ]
}

@test "is_manager_root detects manager root" {
    cd "$TEST_DIR"
    # Create manager files
    touch CLAUDE.md
    grep -q "Manager Claude" CLAUDE.md 2>/dev/null || echo "Manager Claude" > CLAUDE.md
    
    run is_manager_root
    [ "$status" -eq 0 ]
}

@test "get_project_name extracts directory name" {
    mkdir -p "$TEST_DIR/my-awesome-project"
    cd "$TEST_DIR/my-awesome-project"
    
    run get_project_name
    [ "$status" -eq 0 ]
    [ "$output" = "my-awesome-project" ]
}

@test "create_timestamp generates valid timestamp" {
    run create_timestamp
    [ "$status" -eq 0 ]
    # Check format YYYY-MM-DD HH:MM
    [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]
}

@test "backup_file creates backup with timestamp" {
    local test_file="$TEST_DIR/original.txt"
    echo "Original content" > "$test_file"
    
    run backup_file "$test_file"
    [ "$status" -eq 0 ]
    
    # Check backup was created
    ls "$TEST_DIR"/original.txt.backup_* >/dev/null 2>&1
}

@test "extract_todos finds TODO and FIXME comments" {
    local test_file="$TEST_DIR/code.js"
    cat > "$test_file" << 'EOF'
// TODO: Implement this feature
function test() {
  // FIXME: Handle error case
  return true;
}
// Random comment without todo
EOF
    
    local todos=$(extract_todos "$test_file")
    [[ "$todos" =~ "Implement this feature" ]]
    [[ "$todos" =~ "Handle error case" ]]
    ! [[ "$todos" =~ "Random comment" ]]
}