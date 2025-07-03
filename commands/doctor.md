---
title: Doctor
command: doctor
description: Check health of all claudepm projects
---

Run a comprehensive health check across all projects:

1. First run: claudepm doctor
2. For any outdated projects, suggest: claudepm upgrade
3. For any stale projects (>7 days), check their last log entry
4. For any blocked projects, list the blockers
5. Summarize overall system health

Show results in a clear table format with status indicators:
- 🟢 Active - worked on recently
- 🟠 Blocked - has blockers noted
- 🔴 Outdated - needs template update
- ⚫ Stale - no activity >7 days