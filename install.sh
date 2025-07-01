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
cp TEMPLATE_VERSION "$PROJECTS_DIR/.claude/templates/VERSION"
echo "  ✓ Created $PROJECTS_DIR/.claude/templates/ (v$(cat TEMPLATE_VERSION))"

# Install slash commands if they exist
if [ -d ".claude/commands" ]; then
    echo "Installing slash commands..."
    mkdir -p "$PROJECTS_DIR/.claude/commands"
    cp .claude/commands/*.md "$PROJECTS_DIR/.claude/commands/" 2>/dev/null
    echo "  ✓ Installed $(ls .claude/commands/*.md | wc -l) slash commands"
fi

# Create initial manager CLAUDE_LOG.md if it doesn't exist
if [ ! -f "$PROJECTS_DIR/CLAUDE_LOG.md" ]; then
    echo "Creating manager-level CLAUDE_LOG.md..."
    cat > "$PROJECTS_DIR/CLAUDE_LOG.md" << 'EOF'
# Manager Claude Activity Log

## Overview
This log tracks manager-level activities across all projects in ~/projects. It documents brain dump processing, cross-project analyses, adoption activities, and coordination work.

---

### $(date '+%Y-%m-%d %H:%M') - Installed claudepm
Did: Set up claudepm for managing multiple projects
Projects affected: All future projects
Next: Try /orient to understand the system, then /adopt-project for existing projects

---
EOF
    echo "  ✓ Created manager activity log"
fi

# Apply append-only protection to CLAUDE_LOG.md (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Applying append-only protection to log files..."
    if [ -f "$PROJECTS_DIR/CLAUDE_LOG.md" ]; then
        chflags uappnd "$PROJECTS_DIR/CLAUDE_LOG.md" 2>/dev/null && \
            echo "  ✓ Protected CLAUDE_LOG.md (append-only)" || \
            echo "  ⚠ Could not protect CLAUDE_LOG.md (requires macOS)"
    fi
fi

echo
echo "Installation complete!"
echo
echo "Next steps:"
echo "1. cd $PROJECTS_DIR"
echo "2. code . (or your preferred editor)"
echo "3. Try these slash commands:"
echo "   - /orient - Get instant context awareness"
echo "   - /adopt-project - Add claudepm to existing projects"
echo "   - /brain-dump - Process unstructured updates"
echo "   - /daily-standup - Morning project overview"
echo "   - /project-health - Find projects needing attention"
echo "4. For new projects, create:"
echo "   - CLAUDE.md (from template)"
echo "   - PROJECT_ROADMAP.md (from template)"
echo "   - CLAUDE_LOG.md (start with first entry)"
echo
echo "Templates: $PROJECTS_DIR/.claude/templates/"
echo "Commands: $PROJECTS_DIR/.claude/commands/"

echo
echo "Note: When claudepm CLI is ready, install it to:"
echo "  ~/.claudepm/bin/claudepm (recommended)"
echo "  or /usr/local/bin/claudepm (requires sudo)"
echo
echo "Claude will be taught to check both locations."