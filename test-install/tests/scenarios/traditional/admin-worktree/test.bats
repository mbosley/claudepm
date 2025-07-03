#!/usr/bin/env bats
# Test suite for claudepm-admin.sh worktree management

load '../../../framework/test-helpers.bash'

setup() {
    # Create a temporary test environment
    export TEST_DIR="$BATS_TEST_TMPDIR/test-worktree"
    mkdir -p "$TEST_DIR"
    
    cd "$TEST_DIR"
    
    # Initialize a git repo on main branch
    git init -b main
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Create and switch to dev branch
    git checkout -b dev
    echo "dev branch" > dev.txt
    git add dev.txt
    git commit -m "Dev branch commit"
    
    # Copy the admin script
    mkdir -p tools
    cp "$PROJECT_ROOT/tools/claudepm-admin.sh" ./tools/
    chmod +x ./tools/claudepm-admin.sh
    
    # Create template directory for TASK_PROMPT
    mkdir -p templates/project
    cat > templates/project/TASK_PROMPT.template.md <<'EOF'
# Task: {{FEATURE_NAME}}

## Objective
Implement the {{FEATURE_NAME}} feature.

{{ARCHITECTURAL_REVIEW}}

## Instructions
- Stay focused on this specific feature
- Create a PR when complete
EOF
}

teardown() {
    cd "$OLDPWD"
}

@test "create-worktree requires dev branch" {
    # Switch to main branch
    git checkout main
    
    # Try to create worktree from main
    run ./tools/claudepm-admin.sh create-worktree test-feature
    assert_failure
    # Check for error message (strip ANSI colors in the check)
    assert_output --partial "branch for safety reasons"
}

@test "create-worktree creates new feature branch and worktree" {
    # Should be on dev branch from setup
    run ./tools/claudepm-admin.sh create-worktree add-search
    assert_success
    
    # Check worktree was created
    assert_dir_exists "worktrees/add-search"
    
    # Check feature branch exists
    run git branch --list "feature/add-search"
    assert_success
    assert_output --partial "feature/add-search"
    
    # Check .claudepm file was created with correct role
    assert_file_exists "worktrees/add-search/.claudepm"
    assert_file_contains "worktrees/add-search/.claudepm" '"role": "task-agent"'
    
    # Check TASK_PROMPT.md was generated
    assert_file_exists "worktrees/add-search/TASK_PROMPT.md"
    assert_file_contains "worktrees/add-search/TASK_PROMPT.md" "Task: add-search"
}

@test "create-worktree fails if worktree already exists" {
    # Create first worktree
    ./tools/claudepm-admin.sh create-worktree test-feature
    
    # Try to create same worktree again
    run ./tools/claudepm-admin.sh create-worktree test-feature
    assert_failure
    assert_output --partial "ERROR: Worktree path"
    assert_output --partial "already exists"
}

@test "create-worktree fails if branch already exists" {
    # Create a branch manually
    git checkout -b feature/existing-feature
    git checkout dev
    
    # Try to create worktree with same feature name
    run ./tools/claudepm-admin.sh create-worktree existing-feature
    assert_failure
    assert_output --partial "ERROR: Branch"
    assert_output --partial "already exists"
}

@test "remove-worktree removes worktree and branch" {
    # Create a worktree first
    ./tools/claudepm-admin.sh create-worktree temp-feature
    
    # Verify it exists
    assert_dir_exists "worktrees/temp-feature"
    
    # Remove it (with auto-yes for testing)
    run bash -c 'echo "y" | ./tools/claudepm-admin.sh remove-worktree temp-feature'
    assert_success
    assert_output --partial "Cleanup complete"
    
    # Check worktree is gone
    run ls -la worktrees/
    [ ! -d "worktrees/temp-feature" ]
    
    # Check branch is gone
    run git branch --list "feature/temp-feature"
    refute_output --partial "feature/temp-feature"
}

@test "remove-worktree archives TASK_PROMPT.md" {
    # Create a worktree
    ./tools/claudepm-admin.sh create-worktree archive-test
    
    # Remove it
    run bash -c 'echo "y" | ./tools/claudepm-admin.sh remove-worktree archive-test'
    assert_success
    
    # Check archive was created
    assert_dir_exists ".prompts_archive"
    run ls .prompts_archive/*-archive-test.md
    assert_success
}

@test "remove-worktree requires dev branch" {
    # Create worktree from dev
    ./tools/claudepm-admin.sh create-worktree test-removal
    
    # Switch to main and try to remove
    git checkout main
    run ./tools/claudepm-admin.sh remove-worktree test-removal
    assert_failure
    assert_output --partial "branch for safety reasons"
}

@test "list-worktrees shows active worktrees" {
    # Create some worktrees
    ./tools/claudepm-admin.sh create-worktree feature-one
    ./tools/claudepm-admin.sh create-worktree feature-two
    
    # List worktrees
    run ./tools/claudepm-admin.sh list-worktrees
    assert_success
    assert_output --partial "worktrees/feature-one"
    assert_output --partial "worktrees/feature-two"
    assert_output --partial "feature/feature-one"
    assert_output --partial "feature/feature-two"
}

@test "script prevents any operation on main branch" {
    # Switch to main branch
    git checkout main
    
    # Try various commands - all should fail on main
    run ./tools/claudepm-admin.sh create-worktree test
    assert_failure
    assert_output --partial "branch for safety reasons"
    
    run ./tools/claudepm-admin.sh remove-worktree test
    assert_failure
    assert_output --partial "branch for safety reasons"
    
    # Even list-worktrees is blocked on main for safety
    run ./tools/claudepm-admin.sh list-worktrees
    assert_failure
    assert_output --partial "branch for safety reasons"
}

@test "architectural review inclusion in TASK_PROMPT" {
    # Create API queries directory with a review
    mkdir -p .api-queries
    cat > .api-queries/2025-01-01-add-ai-feature.md <<'EOF'
## Architectural Analysis for add-ai-feature

This feature should follow these patterns:
- Use existing AI SDK
- Implement rate limiting
- Add proper error handling
EOF
    
    # Create worktree
    run ./tools/claudepm-admin.sh create-worktree add-ai-feature
    assert_success
    
    # Check TASK_PROMPT includes the review
    assert_file_contains "worktrees/add-ai-feature/TASK_PROMPT.md" "Architectural Analysis for add-ai-feature"
    assert_file_contains "worktrees/add-ai-feature/TASK_PROMPT.md" "Use existing AI SDK"
}