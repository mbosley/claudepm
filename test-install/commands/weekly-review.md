---
title: Weekly Review
command: weekly-review
description: Comprehensive week summary with patterns
---

Generate a comprehensive weekly review:

1. Spawn parallel Task agents for each project:
   ```
   Task: "Weekly review", prompt: "In [project]/, analyze last 7 days of LOG.md, note completions, blockers, and patterns"
   ```

2. Aggregate results into:
   ## Weekly Review - Week {{week_number}}, {{year}}
   
   ### Accomplishments by Project
   - **Project**: What got done
   
   ### Common Patterns
   - Technical challenges faced
   - Solutions that worked
   - Recurring blockers
   
   ### Next Week Priorities
   1. [Cross-project priority 1]
   2. [Cross-project priority 2]
   3. [Cross-project priority 3]
   
   ### Projects Needing Attention
   - Stale projects
   - Blocked projects
   - Version updates needed

3. Update manager LOG.md with summary