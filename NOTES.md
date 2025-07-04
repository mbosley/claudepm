# claudepm Development Notes

## 2025-07-03 - Simplification Insights

### Why Remove Time Tracking
- Claude isn't good at estimating time
- Humans are notoriously bad at it too  
- Adds complexity without value
- Creates false precision

### Protocol Philosophy: Structure + Freedom
The protocol should:
1. **Enforce minimal structure** (timestamp, title, consistent format)
2. **Allow creative freedom** (Claude decides what details to include)
3. **Avoid prescriptive fields** (no forced categories)

### Simplified Commands

**Before (prescriptive):**
```bash
claudepm log "Fixed bug" --did "Found issue" --did "Applied fix" --time 2h --tag bug
```

**After (flexible):**
```bash
claudepm log "Fixed bug" "Found race condition in auth flow. Applied mutex lock."
```

Claude can still structure the content however makes sense:
```
### 2025-07-03 15:30 - Fixed authentication race condition
Did:
- Found race condition in session handler
- Applied mutex lock to critical section
- Added tests for concurrent access
Next: Monitor for similar patterns in other handlers
Tags: #bug #security #concurrency
```

But this structure comes from Claude's judgment, not rigid command flags.

### Benefits
1. **Simpler implementation** - Less code to maintain
2. **More flexible** - Claude adapts format to context
3. **Natural writing** - Like taking notes, not filling forms
4. **Easier to remember** - Fewer options to learn

### Task Simplification
Same principle for tasks:
```bash
# Old way
claudepm task add "Fix memory leak" -p high -t bug -d 2025-07-10

# New way  
claudepm task add "Fix memory leak" "HIGH PRIORITY - Due Friday - Bug in WebSocket handler"
```

The UUID and date are structural. Everything else is content.

## 2025-01-04 - Task Format Not Human Readable

The CPM::TASK format in ROADMAP.md is not easily human legible. Current format:
```
CPM::TASK::abc123::TODO::HIGH::Fix memory leak::2025-01-04::
```

This is hard to scan and read. Need to either:
1. Make the format more human-friendly while keeping it parseable
2. Use a different approach (maybe markdown task lists?)
3. Have a display format vs storage format

The whole point of claudepm is to be a bridge between Claude and humans, so both need to be able to work with it easily.

## 2025-01-04 - Need Agent Orchestration Pattern in Templates

We discovered a powerful pattern for orchestrating Claude agents:

**Core Pattern:**
1. Create wrapper script with configuration:
```bash
#!/bin/bash
exec claude --model "sonnet" --permission-mode "bypass" -p "$@"
```

2. Execute from Task tool:
```python
Task: "Run agent", prompt: 'Execute: /path/to/wrapper -p "Do task"'
```

This allows parallel execution of specialized Claude instances. Need to add this pattern to:
- Project CLAUDE.md template (in customization section)
- Manager CLAUDE.md template (for orchestration examples)
- Maybe create a new AGENTS.md template file?

The pattern is documented in docs/ORCHESTRATION_PATTERN.md but it's not easily discoverable for new Claude instances. Should be front and center in templates.

## 2025-01-04 - NOTES.md vs LOG.md Confusion

In user testing, project Claudes don't have a clear sense of when to add things to NOTES.md versus when to log in LOG.md.

**Proposed distinction:**
- **LOG.md** - For agent work logging (what Claude did, chronological history)
- **NOTES.md** - For human observations, patterns, insights, and meta-commentary

This actually makes sense:
- Agents log their actions as they work
- Humans add notes about patterns they observe or improvements needed
- Keeps the operational log clean and focused on work done
- Gives humans a place to capture meta-thoughts without cluttering the work log

## 2025-01-04 - Manager Claude Role Confusion

User testing revealed confusion when starting from Manager Claude and trying to do project-level work.

**What happened:**
- Started with Manager Claude at ~/projects level
- Manager started doing work in project directories
- Tried to use worktree generation patterns (meant for Project Lead)
- Patterns failed because Manager Claude doesn't have that context

**The issue:**
- Worktree patterns are only in Project CLAUDE.md template
- Manager CLAUDE.md doesn't include implementation patterns
- Users may not realize they need to switch contexts

**Potential solutions:**
1. Make role boundaries clearer in Manager template
2. Add explicit "DON'T" section to Manager CLAUDE.md
3. Better guide users on when to switch from Manager to Project Lead
4. Maybe add a reminder: "To implement features, cd into project and start new session"

The current role separation makes sense architecturally, but users need clearer guidance about when to switch contexts.

**Better approach:**
Add guidance to Manager CLAUDE.md template:
- If user starts trying to implement features or do real work in a project
- Manager should suggest: "I notice you're moving into implementation. For best results, let's start a fresh Project Lead session: `cd project-name` then start a new Claude"
- If user insists or it's trivial work, proceed but note the limitations
- This gentle nudge helps users discover the proper workflow naturally

## 2025-01-04 - Primary Worktree Pattern Should Be Manual

After real usage, the best pattern for Task Agents is:

**The Pattern:**
1. Project Lead Claude sets up the worktree and TASK_PROMPT.md
2. User manually `cd worktrees/feature-name`
3. User opens NEW Claude instance with desired parameters (e.g., `claude --permission-mode bypassPermissions`)
4. User can monitor and guide the Task Agent in real-time

**Why this is better:**
- User maintains control over Task Agent behavior
- Can watch progress and intervene if needed
- Can choose permission mode based on task risk
- More transparent than automated spawning
- Still gets benefit of isolated work environment

**Updated workflow:**
```bash
# Project Lead sets the table
./tools/claudepm-admin.sh create-worktree add-feature

# User takes control
cd worktrees/add-feature
claude --permission-mode bypassPermissions  # or whatever params needed

# In new Claude: "You are a Task Agent. Read TASK_PROMPT.md and implement."
```

This is "setting the table" for the Task Agent rather than fully automating it. More practical for real work.

**Parallel Workflow Benefits:**
- Project Lead can queue up multiple worktrees while Task Agents work
- Human can have multiple Claude windows open, each in different worktrees
- Natural task parallelism without complex orchestration

Example workflow:
```bash
# Terminal 1: Project Lead queues up work
./tools/claudepm-admin.sh create-worktree add-auth
./tools/claudepm-admin.sh create-worktree fix-tests
./tools/claudepm-admin.sh create-worktree update-docs

# Terminal 2: Task Agent 1
cd worktrees/add-auth
claude --permission-mode bypassPermissions

# Terminal 3: Task Agent 2  
cd worktrees/fix-tests
claude

# Terminal 4: Task Agent 3
cd worktrees/update-docs
claude --permission-mode acceptEdits
```

Project Lead becomes a "work dispatcher" preparing isolated environments while multiple Task Agents execute in parallel. Much more practical than fully automated orchestration.

## 2025-01-04 - Gemini PR Review Against Initial Plan

Need a way to have Gemini review the Task Agent's PR against the original architectural plan.

**The workflow:**
1. Project Lead gets architectural plan from Gemini (stored in .api-queries/)
2. Task Agent implements based on TASK_PROMPT.md
3. After PR creation, run Gemini review comparing:
   - Original architectural plan
   - Actual implementation in PR
   - Did the Task Agent follow the plan?
   - Any deviations or improvements?

**Implementation ideas:**
```bash
# After Task Agent creates PR
./tools/gemini-review-pr.sh feature-name PR-number

# Script would:
# 1. Read .api-queries/architect-feature-name.md
# 2. Get PR diff from GitHub
# 3. Send both to Gemini with review prompt
# 4. Save review to .api-queries/review-feature-name.md
```

This closes the loop:
- Gemini designs → Task Agent implements → Gemini reviews
- Ensures architectural intent is preserved
- Catches deviations early
- Creates audit trail of design decisions

## 2025-01-04 - claudepm Should Fill Gaps, Not Duplicate

Important realization: claudepm commands should only exist for things Claude can't already do well with existing tools.

**Good uses of claudepm:**
- `claudepm log` - Because append-only logging is hard/risky with Write tool
- `claudepm task` - Because structured task management needs consistent format
- `claudepm context` - Because gathering startup context from multiple sources is complex
- `claudepm doctor` - Because multi-project health checks need specialized logic

**Bad uses (don't need claudepm for these):**
- Reading files - Claude has Read tool
- Running commands - Claude has Bash tool
- Searching code - Claude has Grep tool
- Basic file operations - Already covered

**Design principle:**
claudepm should complement Claude's existing tools, not replace them. Only add commands where:
1. Claude's tools are insufficient (like safe appending)
2. Complex orchestration is needed (like multi-project doctor)
3. Structured data management is required (like task UUIDs)
4. Protocol consistency matters (like log format)

Don't add overhead for things Claude already does well.

## 2025-01-04 - Task Agents Need Clear Git/PR Instructions

Pain point: Task Agents complete their implementation but don't know to commit and create PRs.

**The problem:**
- Task Agent finishes the feature successfully
- But doesn't commit changes
- Doesn't push the feature branch
- Doesn't create PR back to dev
- User has to manually finish the git workflow

**Solution:**
Need to update TASK_PROMPT.md template or Task Agent instructions to include:
1. After implementation is complete, commit all changes
2. Push the feature branch: `git push -u origin feature/name`
3. Create PR: `gh pr create --base dev --title "feat: Description"`
4. Report the PR URL back to user

**Better Task Agent workflow:**
```
1. Read TASK_PROMPT.md for mission
2. Implement the feature
3. Test the implementation
4. Commit changes with good message
5. Push feature branch
6. Create PR to dev branch
7. Report: "PR #123 created: [url]"
```

This makes Task Agents truly autonomous - they complete the entire workflow.