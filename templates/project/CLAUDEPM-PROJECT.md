# Project: [Project Name]

## Core Principles
1. **Edit, don't create** - Modify existing code rather than rewriting
2. **Small changes** - Make the minimal change that solves the problem
3. **Test immediately** - Verify each change before moving on
4. **Preserve what works** - Don't break working features for elegance
5. **LOG.md is append-only** - Never edit past entries, only add new ones
6. **Commit completed work** - Don't let finished features sit uncommitted

## Start Every Session
1. Read ROADMAP.md - see current state and priorities
2. Read recent LOG.md - understand last session's work
3. Run git status - see uncommitted work

## After Each Work Block
1. Add to LOG.md using append-only pattern:
```bash
# Simple, clean append that always works
{
echo ""
echo ""
echo "### $(date '+%Y-%m-%d %H:%M') - [Brief summary]"
echo "Did:"
echo "- [First accomplishment]"
echo "- [Second accomplishment]"
echo "Next: [Immediate next task]"
echo "Blocked: [Any blockers - only if blocked]"
echo ""
echo "---"
} >> LOG.md
```

**CRITICAL: NEVER use Write or Edit tools on LOG.md** - only append with >> operator. This prevents accidental history loss.

**macOS Protection**: On macOS, LOG.md has filesystem-level append-only protection (`uappnd` flag). Write/Edit operations will fail with EPERM. To temporarily remove: `chflags nouappnd LOG.md`

If working on a feature branch, include branch name in the summary:
```bash
### $(date '+%Y-%m-%d %H:%M') - [feature/auth] - Implemented JWT tokens
```

**Be precise about PLANNED vs IMPLEMENTED:**
- `IMPLEMENTED: User authentication with JWT tokens` (code written)
- `PLANNED: User authentication feature in roadmap` (added to roadmap)
- `DOCUMENTED: Authentication flow in README` (docs updated)
- `FIXED: Login redirect loop issue` (bug resolved)
This prevents confusion when reading logs later!

2. Update ROADMAP.md following these principles:
- Check off completed items
- Update status of in-progress work
- Add any new tasks discovered
- **Structure for searchability**: Use consistent headings
- **Version your features**: Group by v0.1, v0.2, etc.
- **Make items actionable**: "Add search" → "Add claudepm search command for logs"
- **Include context**: Not just what, but why
- **Think git branches**: Each version could be a feature branch
- **Enable automation**: Clear enough that future Claude could execute

## Task Management

**IMPORTANT**: Use claudepm commands for all task operations. Never manually edit task formats.

```bash
# Add a new task
claudepm task add "Fix authentication bug" -p high -t auth -d 2025-01-15

# List tasks
claudepm task list                # All tasks
claudepm task list --todo         # Only TODO tasks
claudepm task list -p high        # High priority tasks

# Work on tasks
claudepm task start <uuid>        # Move to IN PROGRESS
claudepm task done <uuid>         # Mark as complete
claudepm task block <uuid> "reason"  # Mark as blocked

# Update task metadata
claudepm task update <uuid> -p medium -d 2025-01-20
```

Tasks use human-readable markdown format with rich metadata:
- `[priority]` - high, medium, low
- `[#tags]` - For categorization
- `[due:date]` - Deadlines
- `[@assignee]` - Responsibility
- `[estimate]` - Time estimates (2h, 1d, 1w)

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

#### For non-trivial features (touching multiple files, new concepts):
1. Define the feature clearly - what problem does it solve?
2. Run `/architect-feature` with a comprehensive description
3. **REVIEW: Read Gemini's complete architectural plan carefully**
4. **DECIDE: Approve, adjust, or cancel based on the plan's alignment**
5. Use the plan to guide all subsequent implementation steps

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
- **Planning/Features/Ideas** → Goes in ROADMAP.md
- **Work history** → Goes in LOG.md
- **Patterns/insights** → Goes in NOTES.md  
- **Instructions/setup** → Goes in CLAUDE.md or README.md
- **Only create new files for actual code or truly new categories**

Example: Beta features, roadmaps, plans, ideas, TODOs → All go in ROADMAP.md, not new files!

### The Four Core Files
- **CLAUDE.md** - HOW to work (instructions, behavioral patterns)
- **LOG.md** - WHAT happened (append-only chronological history)  
- **ROADMAP.md** - WHAT's next (plans, priorities, current state)
- **NOTES.md** - WHY it matters (patterns, insights, meta-observations)

### File Usage Distinction
- **LOG.md** - Written by Claude during work (chronological record)
- **NOTES.md** - Written by humans observing patterns (insights and reflections)
- Both provide memory, but from different perspectives

### Local Files
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
1. **Update ROADMAP.md first**:
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
   
   - IMPLEMENTED: Dynamic date filtering in manager templates
   - PLANNED: Manager report persistence to ~/.claudepm/reports/ (added to roadmap)
   - UPDATED: ROADMAP.md to show v0.1 complete
   ```
   
   **Bad commit message:**
   ```
   Implement manager report persistence
   
   [When you actually just added it to the roadmap]
   ```

Remember: Your "work session" might be 2 minutes or 2 hours - log based on tasks completed, not time elapsed

## Handling Parallel Work (Branches/Worktrees)

### When merging LOG.md conflicts:
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

## Git Workflow & Worktree Hygiene

When working with feature branches and worktrees:

1. **Create local worktree**: `git worktree add worktrees/feature-name feature/feature-name`
2. **Develop**: Make changes, test, commit regularly
3. **Create PR**: `gh pr create --base dev --title "feat: Description"`
4. **After merge - CRITICAL cleanup**:
   ```bash
   # From main project directory (not in worktree)
   # Remove worktree
   git worktree remove worktrees/feature-name
   # Delete local branch
   git branch -d feature/feature-name
   # Prune remote tracking
   git remote prune origin
   ```
5. **If feature is abandoned**: Use `--force` flag: `git worktree remove --force worktrees/feature-name`

**IMPORTANT**: Always ensure `worktrees/` is in your .gitignore to prevent accidental commits of worktree directories.

Always clean up worktrees after merging or abandoning features to prevent accumulation.

## Task Agent Development Workflow

This workflow enables isolated feature development using git worktrees within the project directory.

### Three-Level Claude Hierarchy

1. **Manager Claude** (e.g., ~/projects/)
   - Lives at the top-level projects directory
   - Coordinates across multiple projects
   - Never implements features directly

2. **Project Lead Claude** (e.g., ~/projects/my-app/ on dev branch)
   - Lives in a specific project directory
   - Always stays on the dev branch
   - Dispatches Task Agents for features
   - Reviews PRs and manages merges

3. **Task Agent Claude** (e.g., ~/projects/my-app/worktrees/add-auth/)
   - Lives in temporary worktrees within the project
   - Implements specific features in isolation
   - Creates PRs back to dev
   - Gets terminated after merge

### Project Lead Workflow

When you need to implement a feature:

1. **Stay on dev branch**: Never switch branches as Project Lead
2. **Create local worktree using claudepm-admin.sh**:
   ```bash
   ./tools/claudepm-admin.sh create-worktree feature-name
   ```
   This will:
   - Create the worktree and feature branch
   - Generate TASK_PROMPT.md from template
   - Include architectural review if found in .api-queries/
3. **Dispatch Task Agent**: Start a new conversation with implementation instructions
4. **Review PR**: When Task Agent completes, review their PR
5. **Merge and cleanup**:
   ```bash
   gh pr merge [PR-number] --squash --delete-branch
   ./tools/claudepm-admin.sh remove-worktree feature-name
   ```
   This will:
   - Archive TASK_PROMPT.md to .prompts_archive/
   - Remove the worktree and branch safely

### Task Agent Workflow

As a Task Agent, you:

1. **Work in isolation**: cd worktrees/your-feature
2. **Follow the plan**: Implement according to architectural guidance
3. **Log everything**: Update LOG.md with [feature/branch-name] prefix
4. **Commit often**: Small, atomic commits
5. **Create PR when done**:
   ```bash
   gh pr create --base dev --title "feat: Your feature" --body "..."
   ```
6. **Await review**: Stop after PR creation

### Why Local Worktrees?

- **Security**: Claude can access worktrees/ but not ../sibling-dirs
- **Organization**: All temporary work contained within project
- **Discovery**: `ls worktrees/` shows all active features
- **Cleanup**: Easy to find and remove stale worktrees

### Critical Requirements

- **MUST have worktrees/ in .gitignore** (prevents accidental commits)
- **MUST use git worktree remove** (not rm -rf)
- **MUST create worktrees from dev branch**

### Example: Dispatching a Task Agent

**Project Lead starts the process:**
```bash
# 1. Create the worktree (staying on dev branch)
git worktree add worktrees/add-search feature/add-search

# 2. Open a NEW Claude conversation and provide this prompt:
```

**Task Agent Prompt Template:**
```
You are a Task Agent for [project-name] working in the worktrees/add-search worktree.

Your mission: Implement search functionality for LOG.md files

Requirements:
- Add a `search` command that searches log entries
- Support date filtering with --from and --to flags
- Support keyword search with basic regex
- Format output clearly showing matches
- Include tests

Process:
1. cd worktrees/add-search
2. Read LOG.md and ROADMAP.md for context
3. Implement the feature
4. Test thoroughly
5. Update documentation
6. Commit with clear messages
7. Create PR back to dev branch
8. Report completion

Remember: You work in isolation. Make atomic commits. Focus only on this feature.
```

### Benefits of Local Worktrees

1. **No Access Issues**: Task Agents can work in worktrees/feature but can't access ../sibling-dirs
2. **Easy Discovery**: `ls worktrees/` shows all active development
3. **Clean Organization**: All feature work contained within the project
4. **Simple Cleanup**: Find and remove stale worktrees easily
5. **Parallel Development**: Multiple Task Agents can work simultaneously
6. **Automated TASK_PROMPT**: Each worktree gets a mission brief automatically
7. **Archived History**: Completed TASK_PROMPTs saved to .prompts_archive/

### Common Task Agent Patterns

**Feature Implementation:**
```bash
# Task Agent works in worktrees/feature-name
cd worktrees/add-auth
# Implements complete feature
# Creates PR when done
```

**Bug Fix:**
```bash
# Task Agent isolates bug in worktrees/fix-bug-name
cd worktrees/fix-date-parsing
# Reproduces, fixes, tests
# Creates focused PR
```

**Refactoring:**
```bash
# Task Agent refactors in worktrees/refactor-area
cd worktrees/refactor-cli
# Makes systematic improvements
# Ensures tests still pass
```

### When NOT to Use Task Agents

- **Quick typo fixes**: Just fix directly on dev
- **README updates only**: Too simple for isolation
- **Exploration**: Use dev branch for research
- **Emergency hotfixes**: Fix directly and backport

### Cleanup After Task Agent Completes

```bash
# After PR is merged (recommended approach)
gh pr merge 42 --squash --delete-branch
./tools/claudepm-admin.sh remove-worktree feature-name

# Manual cleanup if needed
git worktree remove --force worktrees/feature-name
git branch -D feature/feature-name
```

The `tools/claudepm-admin.sh remove-worktree` command will:
- Archive the TASK_PROMPT.md to .prompts_archive/YYYY-MM-DD-feature-name.md
- Safely remove the worktree
- Delete the feature branch

Remember: The log is our shared memory. Write clearly for your future self.
