# Project: [Project Name]

## Core Principles
1. **Edit, don't create** - Modify existing code rather than rewriting
2. **Small changes** - Make the minimal change that solves the problem
3. **Test immediately** - Verify each change before moving on
4. **Preserve what works** - Don't break working features for elegance
5. **CLAUDE_LOG.md is append-only** - Never edit past entries, only add new ones

## Start Every Session
1. Read PROJECT_ROADMAP.md - see current state and priorities
2. Read recent CLAUDE_LOG.md - understand last session's work
3. Run git status - see uncommitted work

## After Each Work Block
1. Add to CLAUDE_LOG.md (use `date '+%Y-%m-%d %H:%M'` for timestamp):
```
### YYYY-MM-DD HH:MM - [Brief summary of what you did]
Did: [Specific accomplishments - what actually got done]
Next: [Immediate next task - specific and actionable]
Blocked: [Any blockers - only include if blocked]
```

If working on a feature branch, include branch name:
```
### YYYY-MM-DD HH:MM - [feature/auth] - Implemented JWT tokens
```

**Be precise about PLANNED vs IMPLEMENTED:**
- `IMPLEMENTED: User authentication with JWT tokens` (code written)
- `PLANNED: User authentication feature in roadmap` (added to roadmap)
- `DOCUMENTED: Authentication flow in README` (docs updated)
- `FIXED: Login redirect loop issue` (bug resolved)
This prevents confusion when reading logs later!

2. Update PROJECT_ROADMAP.md following these principles:
- Check off completed items
- Update status of in-progress work
- Add any new tasks discovered
- **Structure for searchability**: Use consistent headings
- **Version your features**: Group by v0.1, v0.2, etc.
- **Make items actionable**: "Add search" → "Add claudepm search command for logs"
- **Include context**: Not just what, but why
- **Think git branches**: Each version could be a feature branch
- **Enable automation**: Clear enough that future Claude could execute

## Project Context
Type: [Web app, CLI tool, library, etc.]
Language: [Python, JS, etc.]
Purpose: [What this project does]

## Log Examples

Good log entry:
```
### 2025-06-29 14:30 - Added user authentication
Did: Created login form, integrated Firebase Auth, added session management
Next: Implement password reset flow
Blocked: Need Firebase project credentials from client
```

Bad log entry:
```
### 2025-06-29 15:00 - Worked on stuff
Did: Various things
Next: Continue working
```

## Common Patterns to Follow

### When asked to add a feature:
1. First try to modify existing code
2. Look for similar patterns already in the codebase
3. Make the smallest change possible
4. Test that specific change before proceeding

### When something isn't working:
1. Read the existing code carefully first
2. Try small fixes before big rewrites
3. Preserve working parts while fixing broken ones
4. Document why the simple approach didn't work (if it didn't)

### When tempted to create a new file:
- Can this logic live in an existing file?
- Am I duplicating something that already exists?
- Will this make the project harder to understand?

### STOP! Before creating ANY new markdown file:
- **Planning/Features/Ideas** → Goes in PROJECT_ROADMAP.md
- **Work history/decisions** → Goes in CLAUDE_LOG.md  
- **Instructions/setup** → Goes in CLAUDE.md or README.md
- **Only create new files for actual code or truly new categories**

Example: Beta features, roadmaps, plans, ideas, TODOs → All go in PROJECT_ROADMAP.md, not new files!

### claudepm Files
- **CLAUDE.md** - Project-specific instructions (check in to git)
- **CLAUDE_LOG.md** - Append-only work history (check in to git)  
- **PROJECT_ROADMAP.md** - Living state document (check in to git)
- **.claudepm** - Local metadata marker (add to .gitignore)

## Git Commits vs Logs (Claude-specific)

### When to add a log entry:
- After completing any meaningful change
- Before the user might close the session
- When discovering something important
- If blocked or need user input
- After fixing a bug or error

### When to commit:
- When explicitly asked by user
- After tests pass on new feature
- Before switching to different task
- When reaching a working state
- Before risky changes

### Before committing - ALWAYS check:
1. **Update PROJECT_ROADMAP.md first**:
   - Move completed items from Active Work to Completed
   - Update progress on any in-progress items
   - Add any new work discovered
   - Check if version milestones are complete
   - Update the "Last updated" timestamp

2. **Then write accurate commit messages**:
   - Check for these common mistakes:
     - Claiming to "implement" features only added to roadmap
     - Using "add" when you mean "plan" or "document"
     - Being vague about what was done vs planned
   
   **Good commit message:**
   ```
   Add dynamic scoping to manager reports and plan persistence feature
   
   - IMPLEMENTED: Dynamic date filtering in CLAUDE_MANAGER.md
   - PLANNED: Manager report persistence to ~/.claudepm/reports/ (added to roadmap)
   - UPDATED: PROJECT_ROADMAP.md to show v0.1 complete
   ```
   
   **Bad commit message:**
   ```
   Implement manager report persistence
   
   [When you actually just added it to the roadmap]
   ```

Remember: Your "work session" might be 2 minutes or 2 hours - log based on tasks completed, not time elapsed

## Handling Parallel Work (Branches/Worktrees)

### When merging CLAUDE_LOG.md conflicts:
1. **Keep BOTH sections** - Never delete parallel work history
2. **Preserve chronological order** if easy, but don't stress about it
3. **Add a merge marker entry**:
```
### YYYY-MM-DD HH:MM - Merged parallel work
Did: Merged logs from feature/auth and feature/payments branches
Next: Continue from most recent Next: entry
Notes: Parallel work included auth implementation and payment integration
```

### Tips for parallel work:
- Include branch name in log entries when not on main
- Each worktree maintains its own log timeline
- Conflicts are good - they show parallel progress
- The merge marker helps explain any timeline jumps

Remember: The log is our shared memory. Write clearly for your future self.