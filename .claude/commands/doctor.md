Check health of claudepm installation and projects

I'll run a comprehensive health check of your claudepm setup.

First, let me check the overall claudepm environment:

1. **Check claudepm installation**:
   - Manager CLAUDE.md exists?
   - Templates directory exists?
   - Slash commands installed?
   - Current template version?

2. **Scan all projects** (get list first):
   ```bash
   # Find all projects with claudepm
   PROJECTS=()
   for dir in */; do
     if [ -f "$dir/CLAUDE.md" ] || [ -f "$dir/.claudepm" ]; then
       PROJECTS+=("$dir")
     fi
   done
   echo "Found ${#PROJECTS[@]} projects to check"
   ```

3. **Check all projects IN PARALLEL using Tasks**:
   ```python
   # IMPORTANT: Spawn all checks simultaneously!
   for project in PROJECTS:
     Task: "Health check {project}", 
       prompt: "Check {project}: 1) All 3 files exist? 2) Template version from .claudepm 3) Git status 4) Last activity from CLAUDE_LOG.md"
   
   # Wait for all to complete, then aggregate results
   ```

4. **For each claudepm project, the sub-agent checks**:
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
   
   ### Migration Needed (v0.2.0)
   [List projects without core_version in .claudepm]
   These projects use legacy single-file architecture
   Run /migrate-project [project] to migrate
   
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
   - **NEW**: Legacy single-file architecture (missing core_version)

6. **Check for v0.2.0 migration needs**:
   ```bash
   # For each project with .claudepm
   if [ -f "$PROJECT/.claudepm" ]; then
     CORE_VERSION=$(grep -o '"core_version"' "$PROJECT/.claudepm")
     if [ -z "$CORE_VERSION" ]; then
       echo "⚠️  $PROJECT: Uses legacy single-file architecture"
       echo "   Run: /migrate-project $PROJECT"
     fi
   fi
   ```

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