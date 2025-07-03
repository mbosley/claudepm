---
title: Daily Standup
command: daily-standup
description: Morning check across all projects
---

Perform a daily standup check across all projects:

1. For each active project (modified in last 7 days):
   - Check last log entry's "Next:" item
   - Note any blockers
   - Identify today's priorities

2. Use parallel Task agents for efficiency:
   ```
   Task: "Standup check", prompt: "In [project]/, read last 3 LOG.md entries and current ROADMAP.md tasks"
   ```

3. Summarize in this format:
   ## Daily Standup - {{date}}
   
   ### Project Name
   **Today's Focus**: [from Next: entries]
   **Blockers**: [if any]
   
   ### Overall Priorities
   1. [Most urgent across all projects]
   2. [Second priority]
   3. [Third priority]