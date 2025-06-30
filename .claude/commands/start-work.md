Get oriented before diving into project: $ARGUMENTS

Generate a briefing with current status, recent work, and immediate priorities for the specified project.

## Instructions:
1. Navigate to the specified project directory
2. Read the project's CLAUDE_LOG.md to understand recent work
3. Check PROJECT_ROADMAP.md for current priorities
4. Run git status to see any uncommitted work
5. Look for "Next:" in the most recent log entries

## Briefing Format:
```
## Starting Work on: $ARGUMENTS

### Current Status
[From PROJECT_ROADMAP.md Current Status section]

### Last Session ([Date])
**Completed:**
[From most recent "Did:" in log]

**Next Steps:**
[From most recent "Next:" in log]

**Blockers:**
[Any current blockers]

### Git Status
[Uncommitted changes if any]

### Today's Priorities
1. [Most immediate task from roadmap/logs]
2. [Second priority]
3. [Third priority if applicable]

### Context to Remember
- [Any important decisions from recent logs]
- [Current technical approach]
- [Dependencies or constraints]

### Quick Commands
- Continue where left off: [specific file or task]
- Run tests: [project-specific test command if known]
- Check status: git status
- View recent work: tail -50 CLAUDE_LOG.md
```

## Important Notes:
- Always check CLAUDE_LOG.md first to restore context
- Update the log after completing meaningful work
- If blocked, document it clearly in both log and roadmap