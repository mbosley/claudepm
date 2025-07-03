---
title: Start Work
command: start-work
description: Quick context load before diving into a project
---

Prepare to start work on project: {{input}}

1. If project name provided, cd to that directory
2. Read the project's LOG.md (last 5 entries)
3. Check current ROADMAP.md tasks
4. Run git status
5. Provide brief summary:
   
   ## Starting work on [Project]
   
   **Last worked**: [date from log]
   **Last activity**: [brief summary]
   **Next task**: [from Next: in log]
   **Git status**: [clean/changes]
   
   **Active tasks**:
   - [TODO/IN_PROGRESS items from ROADMAP]
   
   **Blockers**:
   - [Any BLOCKED items]

6. Remind to update LOG.md after work session