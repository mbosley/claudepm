#!/usr/bin/env bats
# Test suite for claudepm adopt command

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
    
    # Create test project directory
    mkdir -p "$TEST_DIR/legacy-project"
    cd "$TEST_DIR/legacy-project"
    
    # Add claudepm to PATH
    export PATH="$HOME/.claudepm/bin:$PATH"
}

teardown() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_DIR"
}

@test "claudepm adopt creates all required files" {
    # Create a simple existing project
    echo "# Legacy Project" > README.md
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    [ -f "CLAUDE.md" ]
    [ -f "LOG.md" ]
    [ -f "ROADMAP.md" ]
    [ -f "NOTES.md" ]
    [ -f ".claudepm" ]
}

@test "claudepm adopt preserves existing README" {
    echo "# My Project" > README.md
    echo "Important content" >> README.md
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    [ -f "README.md" ]
    grep -q "Important content" README.md
}

@test "claudepm adopt extracts TODOs from README" {
    cat > README.md << 'EOF'
# Test Project
TODO: Add authentication
TODO: Improve performance
FIXME: Memory leak in worker
EOF
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    grep -q "Add authentication" ROADMAP.md
    grep -q "Improve performance" ROADMAP.md
    grep -q "Memory leak in worker" ROADMAP.md
}

@test "claudepm adopt detects Node.js project" {
    cat > package.json << 'EOF'
{
  "name": "test-app",
  "version": "1.0.0",
  "scripts": {
    "test": "jest",
    "build": "webpack"
  }
}
EOF
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    grep -q "Node.js" CLAUDE.md
    grep -q "npm test" CLAUDE.md
    grep -q "npm run build" CLAUDE.md
}

@test "claudepm adopt detects Python project" {
    echo "flask==2.0.0" > requirements.txt
    echo "pytest==6.0.0" >> requirements.txt
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    grep -q "Python" CLAUDE.md
}

@test "claudepm adopt handles project with no special files" {
    echo "Just a simple file" > file.txt
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    [ -f "CLAUDE.md" ]
    grep -q "Project:" CLAUDE.md
}

@test "claudepm adopt preserves existing CLAUDE.md" {
    echo "# Existing CLAUDE.md" > CLAUDE.md
    echo "Custom content" >> CLAUDE.md
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    grep -q "Custom content" CLAUDE.md
}

@test "claudepm adopt creates .claudepm with adoption metadata" {
    echo "# Test" > README.md
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    [ -f ".claudepm" ]
    grep -q '"adopted": true' .claudepm
}

@test "claudepm adopt extracts inline TODOs from source files" {
    mkdir src
    cat > src/app.js << 'EOF'
// TODO: Refactor this function
function oldCode() {
  // FIXME: Handle edge case
}
EOF
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    grep -q "Refactor this function" ROADMAP.md
    grep -q "Handle edge case" ROADMAP.md
}

@test "claudepm adopt limits TODO extraction to reasonable number" {
    # Create file with many TODOs
    for i in {1..100}; do
        echo "TODO: Task number $i" >> README.md
    done
    
    run claudepm adopt
    [ "$status" -eq 0 ]
    # Should not have 100+ lines in roadmap
    [ $(wc -l < ROADMAP.md) -lt 200 ]
}