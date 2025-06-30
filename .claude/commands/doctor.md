Check health of claudepm installation and projects

I'll run a comprehensive health check of your claudepm setup.

First, let me check the overall claudepm environment:

1. **Check claudepm installation**:
   - Manager CLAUDE.md exists?
   - Templates directory exists?
   - Slash commands installed?
   - Current template version?

2. **Scan all projects**:
   ```bash
   # Find all projects with claudepm
   for dir in */; do
     if [ -f "$dir/CLAUDE.md" ] || [ -f "$dir/.claudepm" ]; then
       echo "Checking $dir..."
     fi
   done
   ```

3. **For each claudepm project, check**:
   - CLAUDE.md exists and readable
   - PROJECT_ROADMAP.md exists
   - CLAUDE_LOG.md exists
   - .claudepm marker file exists
   - Template version (from .claudepm)
   - Last activity (from CLAUDE_LOG.md)
   - Git status (uncommitted changes?)
   - Any blocked items in roadmap

4. **Report issues found**:
   ```
   ## claudepm Doctor Report - [Date]
   
   ### System Status
   - claudepm version: [from .claudepm in claudepm project]
   - Templates: [version]
   - Commands: [count] installed
   
   ### Projects Overview
   Total projects: [count]
   Healthy: [count] ✅
   Warnings: [count] ⚠️
   Issues: [count] ❌
   
   ### Outdated Templates
   [List projects with old template versions]
   Current version: v[X.X]
   Run /update [project] to update templates
   
   ### Stale Projects (>7 days)
   [List projects with no recent activity]
   
   ### Projects with Issues
   [List any missing files, git problems, etc.]
   
   ### Recommendations
   1. [Highest priority fix]
   2. [Second priority]
   3. [Third priority]
   ```

5. **Check for common issues**:
   - Missing .claudepm marker files
   - Template version mismatches
   - Incomplete installations
   - Very old log entries
   - Large uncommitted changes
   - Projects without roadmaps

Example output:
```
## claudepm Doctor Report - 2025-06-29

### System Status
✅ claudepm v0.1 installed
✅ Templates v0.1.1 (latest)
✅ 8 commands available

### Projects Overview
Total projects: 5
Healthy: 2 ✅
Warnings: 2 ⚠️ 
Issues: 1 ❌

### Outdated Templates
⚠️ auth-service: v0.1 (current: v0.1.1)
⚠️ blog: v0.1 (current: v0.1.1)
Run /update [project] to refresh templates

### Projects with Issues
❌ payment-api: Missing PROJECT_ROADMAP.md
```

**IMPORTANT**: After running doctor, add an entry to ~/projects/CLAUDE_LOG.md documenting what was found!