#!/bin/bash
# gemini-prompt.sh - Construct prompts for Gemini with file content

set -euo pipefail

# Function to display usage
usage() {
    echo "Usage: $0 <prompt_text> <file1> [file2] [file3] ..."
    echo "Example: $0 'Please review this architecture' v0.2.5-architecture.md"
    exit 1
}

# Check minimum arguments
if [ $# -lt 2 ]; then
    usage
fi

# Get the prompt text
PROMPT="$1"
shift

# Start building the full prompt
echo "$PROMPT"
echo ""

# Add each file's content
for file in "$@"; do
    if [ -f "$file" ]; then
        echo "=== File: $file ==="
        echo '```'
        cat "$file"
        echo '```'
        echo ""
    else
        echo "Warning: File not found: $file" >&2
    fi
done