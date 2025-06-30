# Weekly Review

Generate a comprehensive weekly review across all projects.

## Instructions:
1. For each project, analyze the past 7 days:
   - Read PROJECT_ROADMAP.md for completed items and progress
   - Extract log entries from the past week
   - Check git commits: `git log --since="7 days ago" --oneline`
   - Note any items moved to/from Blocked section

2. Create a detailed weekly review:

```
## Weekly Review - Week of [Start Date]

### Executive Summary
[High-level view of the week's accomplishments and challenges]

### Major Accomplishments
- [Significant completed features/milestones across all projects]

### By Project

#### [Project Name]
- **Progress**: [Summary of advancement]
- **Completed**: [Number] items
- **Added**: [Number] new tasks
- **Blocked**: [Current blockers]
- **Key Decisions**: [Important choices made]
- **Next Week Focus**: [Top priorities]

### Patterns & Insights
- **Recurring Blockers**: [Common obstacles across projects]
- **Successful Solutions**: [What worked well]
- **Process Improvements**: [What we learned]

### Metrics
- Active Projects: [count]
- Total Commits: [count]
- Log Entries: [count]
- Completed Tasks: [count]
- New Blockers: [count]

### Next Week Priorities
1. [Cross-project priority 1]
2. [Cross-project priority 2]
3. [Cross-project priority 3]

### Projects Needing Attention
[List any stale or heavily blocked projects]
```

3. Look for trends:
   - Which types of tasks are getting blocked repeatedly?
   - Are certain projects consuming more time than planned?
   - What patterns emerge from the week's work?