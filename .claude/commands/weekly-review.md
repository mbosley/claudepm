Generate comprehensive weekly review across all projects

Analyze the past week's progress using PARALLEL sub-agents for speed and accuracy.

## Instructions:

1. **First, identify all projects to review**:
   ```bash
   # Get list of active projects
   for dir in */; do
     if [ -f "$dir/CLAUDE_LOG.md" ]; then
       echo "Will review: $dir"
     fi
   done
   ```

2. **Spawn PARALLEL analysis tasks for ALL projects**:
   ```python
   # CRITICAL: Launch all reviews simultaneously!
   Task: "Weekly review auth-service",
     prompt: "In auth-service/, analyze past 7 days: Read CLAUDE_LOG.md entries, check git log --since='7 days ago', note completed items from ROADMAP.md"
   
   Task: "Weekly review blog",
     prompt: "In blog/, analyze past 7 days: Read CLAUDE_LOG.md entries, check git log --since='7 days ago', note completed items from ROADMAP.md"
   
   # ... one Task per project - ALL AT ONCE
   ```

3. **While sub-agents work, prepare the report structure**

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