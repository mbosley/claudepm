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

## 2025-01-04 - The Meta-Pattern: Scope → Setup → Execute

The most powerful pattern emerging:

1. **Collaborative Scoping** - Human + Claude (+ Gemini) develop feature plan through conversation
2. **Automated Setup** - Create worktree with scoped plan as TASK_PROMPT
3. **Independent Execution** - Human launches Task Agent in separate terminal
4. **Completion** - Task Agent commits and creates PR

**Current Friction Points:**
- Manual process between scoping and setup
- No structured format for scoping output
- TASK_PROMPT creation is manual
- No integration with Gemini consultation
- Lots of copy-paste between scoping conversation and task setup

**Ideas to Reduce Friction:**

1. **Scoping Phase:**
   - `/scope-feature` slash command to start structured scoping
   - Template for feature scoping conversations
   - Output format that directly feeds TASK_PROMPT
   - Integrated Gemini consultation when needed
   - Save scoping artifacts to `.scoping/feature-name.md`

2. **Transition Phase:**
   - `claudepm scope "feature-name"` - interactive scoping workflow
   - Automatically generates TASK_PROMPT from scoping output
   - Single command from scope to ready worktree
   - Preserve architectural decisions for PR review

3. **Execution Phase:**
   - Generated launch command with optimal params
   - Progress dashboard for multiple worktrees
   - PR review integration comparing implementation to original scope

**The Ideal Flow:**
```bash
# 1. Start scoping with Project Lead
claudepm scope auth-refactor

# 2. Interactive planning session:
# - Describe the feature
# - Get Gemini's architectural input
# - Refine requirements
# - Output: Complete TASK_PROMPT

# 3. Automatic setup:
# - Creates worktree
# - Installs TASK_PROMPT with all context
# - Saves scoping history for reference

# 4. Ready to execute:
# "Ready! Run: cd worktrees/auth-refactor && claude --dangerously-skip-permission"
```

This would reduce the entire workflow to:
1. One command to start
2. Collaborative scoping conversation
3. Immediate readiness for execution

The friction reduction is in:
- Structured scoping that outputs actionable plans
- Automatic worktree setup from scoping output
- Clear handoff point with generated launch command
- Preserved context for PR review against original plan