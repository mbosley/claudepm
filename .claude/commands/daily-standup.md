# Daily Standup

Generate a morning standup report across all projects in ~/projects.

## Instructions:
1. For each project directory that contains CLAUDE_LOG.md:
   - Check PROJECT_ROADMAP.md Active Work section
   - Read last 3 entries from CLAUDE_LOG.md
   - Look for items marked [DUE: today] or [DUE: within 3 days]
   - Note any items marked as BLOCKED

2. Create a consolidated standup report:

```
## Daily Standup - [Today's Date]

### Today's Priorities
[List projects with urgent/due today items]

### Active Work
[For each active project, show 1-2 key tasks from Next: entries]

### Upcoming Deadlines
[Items due within 3 days]

### Blockers
[Any blocked items needing attention]
```

3. Use status indicators:
   - 🟢 Active project (worked on recently)
   - 🟠 Has blockers
   - 🔴 Has overdue items
   - ⏰ Has deadlines this week

Keep it concise - aim for quick morning overview that fits on one screen.