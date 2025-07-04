# Project: [Project Name]

## The claudepm Protocol

You MUST use claudepm commands for ALL project memory operations. This ensures consistent behavior across every project, whether it's a Python CLI, Node.js app, or Rust library.

### Why This Protocol Exists
- **Consistency**: Same commands work in every project
- **Reliability**: Never lose work due to format errors
- **Evolution**: Protocol improves based on your patterns

## Start Every Session

```bash
claudepm context
```

This command gives you everything needed to start working:
- Recent work from LOG.md
- Active tasks from ROADMAP.md
- Current git status
- What to work on next

**NEVER** manually grep through files at session start. The protocol ensures you always get complete context.

## During Your Work

### When you discover new work:
```bash
claudepm task add "Fix memory leak in auth module"
```
This ensures proper UUID, timestamp, and format in ROADMAP.md.

### When you complete a task:
```bash
claudepm task done <uuid>
```

### When you're blocked:
```bash
claudepm task block <uuid> "Waiting for API credentials"
```

### To see what to work on:
```bash
claudepm next
```
This intelligently prioritizes based on in-progress work, blockers, and dependencies.

## After Each Work Block

```bash
# Simple log
claudepm log "Fixed authentication bug"

# Log with details (structure as you see fit)
claudepm log "Implemented OAuth flow" "Did:
- Added Google OAuth provider  
- Created JWT token generation
- Set up refresh token rotation
Commits: abc123, def456
PR: #89
Next: Add OAuth tests"

# Error tracking (your format choice)
claudepm log "Debug session" "Found memory leak in WebSocket handler
Error: MaxListenersExceededWarning
Did: Identified unclosed event listeners
Next: Add cleanup in componentWillUnmount
#bug #memory-leak"

# Decision logging
claudepm log "Architecture review" "Decided: Use event-driven architecture
Reasoning: Need real-time updates, bidirectional communication
Participants: @alice @bob
Options considered: Polling, SSE, WebSocket
#architecture #decision"
```

The protocol provides structure (timestamp + title). You provide the content in whatever format makes sense for the situation.

**NEVER** use manual appends (`>>`) or heredocs. This breaks the protocol and risks data loss.

## Protocol Layers

### Layer 1: Protocol Commands (Use 95% of the time)
All state changes MUST use claudepm:
- `claudepm log` - Record work
- `claudepm task add/done/block` - Manage tasks
- `claudepm context` - Get oriented

### Layer 2: Structured Data (When needed)
```bash
claudepm task list --json  # For complex parsing
claudepm status --json     # For automation
```

### Layer 3: Read-Only Verification (Allowed)
You may use `cat`, `grep`, `ls` to double-check or explore.

### Layer 4: Direct Writes (FORBIDDEN)
**NEVER** use `>>`, `sed -i`, or `echo >` on protocol files.
These break consistency and risk corruption.

## Core Principles

1. **Edit, don't create** - Modify existing code rather than rewriting
2. **Small changes** - Make the minimal change that solves the problem  
3. **Test immediately** - Verify each change before moving on
4. **Use the protocol** - claudepm commands for ALL memory operations
5. **Report patterns** - Note repetitive tasks for protocol evolution

## Protocol Evolution

When you find yourself repeatedly doing something manually:

```bash
# Don't work around it - report it!
echo "PATTERN: Often need to search tasks by keyword" >> NOTES.md
echo "MANUAL: grep -i 'auth' ROADMAP.md" >> NOTES.md  
echo "NEEDED: claudepm task search <keyword>" >> NOTES.md
```

This helps claudepm evolve to meet your actual needs.

## Common Workflows

### Starting a new feature:
```bash
claudepm context                          # Get oriented
claudepm task add "Implement new feature" # Track it
# ... do work ...
claudepm log "Started feature X" --next "Complete tests"
```

### Investigating an issue:
```bash
claudepm context                    # See current state
claudepm task list --blocked        # Check blockers
cat specific-file.js               # Read code (allowed)
claudepm task add "Fix issue Y"    # Track the fix
```

### Ending a session:
```bash
claudepm log "Fixed auth bug, all tests passing" --next "Deploy to staging"
claudepm task done <uuid>          # Mark completed work
```

### Searching logs (allowed read operations):
```bash
# Find all security-related work
grep "#security" LOG.md

# Find work with specific people
grep "@alice" LOG.md

# Find all errors encountered
grep "^Error:" LOG.md

# Find all decisions made
grep "^Decided:" LOG.md

# Find work by commit
grep "bee8c91" LOG.md

# Find all blocked items
grep "^Blocked:" LOG.md
```

## Git Integration

Before committing, ALWAYS:
1. Run `claudepm status` to see what changed
2. Update task states with `claudepm task done`
3. Use `claudepm log` to record the work

<!-- All content above this line is part of the standard claudepm template. -->
<!-- CLAUDEPM_CUSTOMIZATION_START -->

## Project Context
Type: [Web app, CLI tool, library, etc.]
Language: [Python, JS, etc.]
Purpose: [What this project does]

## Project-Specific Commands
Test: [npm test, pytest, etc.]
Build: [npm run build, make, etc.]
Run: [npm start, python main.py, etc.]

<!-- Add any project-specific patterns or workflows below -->

<!-- CLAUDEPM_CUSTOMIZATION_END -->
<!-- All content below this line is part of the standard claudepm template. -->

## Quick Reference

Essential commands:
- `claudepm context` - Start here every session
- `claudepm task add/list/done/block` - Manage work
- `claudepm log <message> --next <task>` - Record progress
- `claudepm next` - What to work on
- `claudepm status` - Current project state

Remember: The protocol exists to make your work consistent and reliable across all projects.