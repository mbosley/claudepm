I'll orient myself to understand my current directory and role.

First, let me check where I am and what claudepm structure exists here.

1. **Detect current location**:
   ```bash
   pwd
   # Check if we're at manager level (~/projects) or in a specific project
   ```

2. **If at Manager Level** (~/projects or similar):
   ```
   You are Manager Claude, overseeing multiple projects.
   
   Found CLAUDE.md at this level - reading for manager instructions...
   [Read and summarize key sections of CLAUDE.md]
   
   Your responsibilities:
   - Monitor project health across all subdirectories
   - Process brain dumps and route to appropriate projects
   - Generate cross-project reports and insights
   - Identify stale or blocked projects
   
   Available commands:
   - /brain-dump - Process unstructured updates
   - /daily-standup - Morning project overview
   - /project-health - Identify projects needing attention
   - /adopt-project - Set up claudepm for existing projects
   
   Quick status:
   [Run quick scan of subdirectories for CLAUDE_LOG.md files]
   - Active projects: [count]
   - Projects with recent activity: [list]
   - Potential adoption candidates: [directories without claudepm]
   ```

3. **If in a Project Directory**:
   ```
   You are Worker Claude for project: [project name]
   
   Checking claudepm files...
   ✓ CLAUDE.md found - reading project instructions
   ✓ ROADMAP.md found - checking current status
   ✓ CLAUDE_LOG.md found - reviewing recent work
   ✓ .claudepm found - checking version
   
   Project: [name from CLAUDE.md]
   Type: [from Project Context section]
   Current Status: [from ROADMAP.md]
   Template Version: [version from .claudepm]
   [If outdated: "⚠️ Templates outdated (current: vX.X, latest: v0.1.4) - run /update to refresh"]
   
   Last Activity:
   [Show last log entry with Next: items]
   
   Active Work:
   [List items from ROADMAP.md Active Work]
   
   Your immediate focus:
   1. Check git status for uncommitted work
   2. Review "Next:" from last log entry
   3. Pick up where the last session left off
   
   Key Commands:
   [List discovered commands from CLAUDE.md]
   
   Remember:
   - Update CLAUDE_LOG.md after each work block
   - Use PLANNED/IMPLEMENTED/FIXED prefixes
   - Check roadmap before committing
   ```

4. **If No claudepm Structure Found**:
   ```
   No claudepm files found in this directory.
   
   Current location: [pwd]
   
   Options:
   1. If this is a project directory:
      - Return to ~/projects
      - Run: /adopt-project [this directory name]
   
   2. If this is your projects root:
      - Run the installer to set up Manager Claude
      - Or manually create CLAUDE.md from template
   
   3. If you're in the wrong location:
      - Navigate to ~/projects for manager role
      - Or cd into a specific project for worker role
   ```

5. **Quick Reference Section**:
   ```
   ## Quick Orientation Summary
   
   Location: [current directory]
   Role: [Manager Claude / Worker Claude / Unknown]
   Context: [Project name or "Managing X projects"]
   Next Action: [Most relevant immediate task]
   
   Key Files Status:
   - CLAUDE.md: [✓/✗]
   - ROADMAP.md: [✓/✗]  
   - CLAUDE_LOG.md: [✓/✗]
   - .claudepm: [✓/✗]
   
   For full instructions, read CLAUDE.md in this directory.
   ```

## Examples:

**Manager Level Output**:
```
You are Manager Claude at ~/projects
Managing 8 projects, 3 with activity today
Run /daily-standup for morning overview
```

**Project Level Output**:
```
You are Worker Claude for: auth-service
Template Version: v0.1.2 ⚠️ (latest: v0.1.4)
Last worked on: Implementing JWT tokens
Next: Add refresh token support
2 items in active work, 0 blocked
```