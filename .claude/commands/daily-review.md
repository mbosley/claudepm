# Daily Review

Generate an evening review of work completed across all projects.

## Instructions:
1. For each project with today's activity:
   ```bash
   # Find today's log entries
   grep "^### $(date +%Y-%m-%d)" CLAUDE_LOG.md -A 20
   # Check git commits from today
   git log --since="today 00:00" --oneline
   ```

2. Create a comprehensive daily review:

```
## Daily Review - [Today's Date]

### Summary
[1-2 sentences on overall progress]

### By Project

#### [Project Name] [Status Emoji]
**Completed:**
- [What got done from "Did:" sections]

**Blocked:**
- [Any blockers encountered]

**Next Steps:**
- [From "Next:" sections]

**Key Insights:**
- [Any important discoveries or decisions]

### Cross-Project Patterns
- [Common themes or blockers]
- [Shared solutions discovered]

### Tomorrow's Priorities
1. [Most urgent across all projects]
2. [Second priority]
3. [Third priority]
```

3. Include metrics:
   - Total log entries added
   - Commits made
   - Items completed vs blocked