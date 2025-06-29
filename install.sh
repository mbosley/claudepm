#!/bin/bash

# claudepm installer - Simple Project Memory for Claude

echo "claudepm - Simple Project Memory for Claude"
echo "=========================================="
echo

# Check if we're in the right place
if [ ! -f "CLAUDE_MANAGER.md" ]; then
    echo "Error: Please run this from the claudepm directory"
    exit 1
fi

# Get the target directory
read -p "Where is your projects directory? [~/projects]: " PROJECTS_DIR
PROJECTS_DIR=${PROJECTS_DIR:-~/projects}
PROJECTS_DIR=$(eval echo "$PROJECTS_DIR")

# Check if directory exists
if [ ! -d "$PROJECTS_DIR" ]; then
    echo "Error: Directory $PROJECTS_DIR does not exist"
    exit 1
fi

# Install manager CLAUDE.md
echo "Installing Manager CLAUDE.md..."
if [ -f "$PROJECTS_DIR/CLAUDE.md" ]; then
    echo "  Found existing CLAUDE.md"
    read -p "  Backup and replace? [y/N]: " REPLACE
    if [ "$REPLACE" = "y" ] || [ "$REPLACE" = "Y" ]; then
        cp "$PROJECTS_DIR/CLAUDE.md" "$PROJECTS_DIR/CLAUDE.md.backup"
        cp CLAUDE_MANAGER.md "$PROJECTS_DIR/CLAUDE.md"
        echo "  ✓ Installed (backup saved as CLAUDE.md.backup)"
    else
        echo "  Skipped"
    fi
else
    cp CLAUDE_MANAGER.md "$PROJECTS_DIR/CLAUDE.md"
    echo "  ✓ Installed"
fi

# Create .claude directory for templates
echo "Creating templates directory..."
mkdir -p "$PROJECTS_DIR/.claude/templates"
cp CLAUDE_PROJECT_TEMPLATE.md "$PROJECTS_DIR/.claude/templates/CLAUDE.md"
cp PROJECT_ROADMAP_TEMPLATE.md "$PROJECTS_DIR/.claude/templates/PROJECT_ROADMAP.md"
echo "  ✓ Created $PROJECTS_DIR/.claude/templates/"

echo
echo "Installation complete!"
echo
echo "Next steps:"
echo "1. cd $PROJECTS_DIR"
echo "2. code . (or your preferred editor)"
echo "3. Ask Claude about project status"
echo "4. For each project, create:"
echo "   - CLAUDE.md (from template)"
echo "   - PROJECT_ROADMAP.md (from template)"
echo "   - CLAUDE_LOG.md (start with first entry)"
echo
echo "Templates: $PROJECTS_DIR/.claude/templates/"