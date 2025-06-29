# claudepm - Simple Project Memory for Claude

A minimal system for maintaining context across Claude Code sessions.

## The Problem
Every time you start a new Claude session, you lose context. You spend 15-30 minutes remembering what you were doing, what decisions you made, and what comes next.

## The Solution
Three simple markdown files per project:
- `CLAUDE.md` - Instructions for Claude (how to work)
- `CLAUDE_LOG.md` - Running log of work (what happened)
- `PROJECT_ROADMAP.md` - Current state and plans (what's next)

## Setup

### Quick Install
```bash
./install.sh
```

This will:
1. Install manager CLAUDE.md to ~/projects
2. Create templates in ~/.claude/templates/
3. You're ready to go!

### Per-Project Setup
For each project:
```bash
cd ~/projects/myproject
cp ~/.claude/templates/CLAUDE.md .
cp ~/.claude/templates/PROJECT_ROADMAP.md .
# Edit both to add project-specific context
# Create CLAUDE_LOG.md with first entry
```

## Usage

### Manager Claude (at ~/projects)
- Ask "What's the status of my projects?"
- Claude will scan for logs and show activity

### Project Claude (in each project)  
- Claude reads CLAUDE_LOG.md on start
- Claude adds log entries after work
- You always know where you left off

## Example Log Entry
```markdown
### 2025-06-29 14:30 - Implemented user authentication
Did: Created login form, Firebase integration, session management
Next: Add password reset functionality
Blocked: Need Firebase credentials from client
```

## Key Principles
- **Three documents only** - CLAUDE.md, CLAUDE_LOG.md, PROJECT_ROADMAP.md
- **Logs are append-only** - Never edit past entries
- **Use timestamps** - Run `date '+%Y-%m-%d %H:%M'` for accuracy
- **Edit, don't create** - Resist making new files

## That's It
No complex tooling. Just three markdown files that create a shared memory between you and Claude.

The magic is in the consistency, not the technology.