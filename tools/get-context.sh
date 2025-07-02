#!/bin/bash

# claudepm get-context helper
# Assembles full context by concatenating CLAUDE.md + CLAUDEPM-*.md
# This centralizes the logic for all slash commands

# Check if we're in a claudepm-managed directory
if [ ! -f ".claudepm" ]; then
    # Legacy support - if CLAUDE.md exists but no .claudepm, assume it's a project
    if [ -f "CLAUDE.md" ]; then
        cat CLAUDE.md
        exit 0
    fi
    echo "Error: Not in a claudepm-managed directory" >&2
    exit 1
fi

# Read the role from .claudepm
ROLE=$(grep -o '"role"[[:space:]]*:[[:space:]]*"[^"]*"' .claudepm | sed 's/.*"role"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# Default to project if role not found
if [ -z "$ROLE" ]; then
    ROLE="project"
fi

# Output local CLAUDE.md first (if it exists)
if [ -f "CLAUDE.md" ]; then
    cat CLAUDE.md
fi

# Then append the appropriate CLAUDEPM file from core
CORE_FILE="$HOME/.claude/core/CLAUDEPM-${ROLE^^}.md"
if [ -f "$CORE_FILE" ]; then
    # Add a separator for clarity
    echo ""
    echo "<!-- ===== CLAUDEPM CORE INSTRUCTIONS BELOW ===== -->"
    echo ""
    cat "$CORE_FILE"
else
    # Fallback for installations that haven't migrated yet
    # Just return what we have
    exit 0
fi