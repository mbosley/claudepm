#!/bin/bash
# setup.sh - Create initial state for fresh claudepm installation test
set -euo pipefail

echo "Creating fresh installation test environment..."

# Get the script directory before changing directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create a temporary directory for initial state
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Create the initial state
cd "$TEMP_DIR"

# Just an empty directory - simulating a user who hasn't installed claudepm yet
mkdir -p home/test-user
cd home/test-user

# Add a marker file to show this is our test environment
cat > .test-environment << 'EOF'
This is a claudepm test environment.
Environment: fresh-install
Purpose: Test claudepm installation from scratch
EOF

# Create the archive from the home directory
cd "$TEMP_DIR"
tar -czf initial.tar.gz -C . home

# Move to final location
mv initial.tar.gz "$SCRIPT_DIR/"

echo "Initial state created successfully!"
echo "Archive contains: Empty home directory ready for claudepm installation"