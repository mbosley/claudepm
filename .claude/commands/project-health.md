Analyze project health and identify which need attention

Check all projects for blockers, overdue items, and stale work to prioritize interventions.

## Instructions:
1. For each project directory, check:
   - Last activity date (from CLAUDE_LOG.md)
   - Number of blocked items (in ROADMAP.md)
   - Git status (uncommitted changes)
   - Overdue deadlines (search for [DUE: dates] that have passed)
   - Days since last commit

2. Generate a health report:

```
## Project Health Report - [Date]

### Health Overview
🟢 Healthy: [count] projects
🟠 Needs Attention: [count] projects  
🔴 Critical: [count] projects
⚫ Stale: [count] projects

### By Status

#### 🔴 Critical (Immediate Action Needed)
**[Project Name]**
- Issue: [Overdue deadlines / Multiple blockers]
- Last Activity: [date]
- Action Needed: [Specific recommendation]

#### 🟠 Needs Attention
**[Project Name]**
- Issue: [Blocked items / Uncommitted changes]
- Days Since Activity: [count]
- Recommendation: [What to do]

#### ⚫ Stale (No Recent Activity)
**[Project Name]**
- Last Activity: [date]
- Last Commit: [date]
- Consider: [Archive / Revive / Get status update]

#### 🟢 Healthy
[List of active, unblocked projects]

### Recommendations
1. [Highest priority action]
2. [Second priority]
3. [Third priority]
```

3. Health Criteria:
   - 🟢 Healthy: Activity within 3 days, no blockers, no overdue items
   - 🟠 Needs Attention: Blocked items OR uncommitted changes OR inactive 4-7 days
   - 🔴 Critical: Overdue deadlines OR multiple blockers OR critical bugs
   - ⚫ Stale: No activity > 7 days