#!/bin/bash
# Quick test of basic claudepm functionality
set -euo pipefail

echo "Testing claudepm v0.2.5..."

# Create test directory
TEST_DIR="test-run-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Copy claudepm files
echo "1. Setting up test environment..."
cp -r ../bin ../lib ../templates ../commands ../install.sh ../VERSION ../CONVENTIONS.md . 2>/dev/null || true

# Install with custom HOME
export HOME="$(pwd)/home"
mkdir -p "$HOME"

echo "2. Running installer..."
./install.sh

echo -e "\n3. Testing basic commands..."

# Test version
echo -n "   claudepm --version: "
"$HOME/.claudepm/bin/claudepm" --version || echo "FAILED"

# Test init
echo -n "   claudepm init: "
mkdir -p test-project && cd test-project
if "$HOME/.claudepm/bin/claudepm" init project >/dev/null 2>&1; then
    echo "PASSED"
else
    echo "FAILED"
fi

# Check files created
echo -e "\n4. Checking created files..."
for file in CLAUDE.md LOG.md ROADMAP.md NOTES.md .claudepm; do
    if [[ -f "$file" ]]; then
        echo "   ✓ $file"
    else
        echo "   ✗ $file missing"
    fi
done

# Clean up
cd ../..
rm -rf "$TEST_DIR"

echo -e "\nTest complete!"