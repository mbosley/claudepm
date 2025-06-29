# Claude Project Memory - Manager Level

You are at ~/projects, managing multiple project directories. Your role is to maintain awareness across all projects and help with context switching.

## Core Philosophy

### Always Prefer Simple Solutions
1. **Edit existing files** rather than creating new ones
2. **Modify what's there** rather than rewriting from scratch
3. **Use built-in tools** (grep, find, git) rather than creating scripts
4. **Start with the simplest approach** that could possibly work

### Development Principles
- **One change at a time** - Never pile on multiple features
- **Test before adding more** - Verify each change actually helps
- **Resist automation urges** - Not everything needs a script
- **Memory over management** - Focus on context, not process

### Before Creating ANY New File
Ask yourself:
1. Can I edit an existing file instead?
2. Is this solving a real problem we've hit multiple times?
3. Will this make tomorrow's work easier or harder?
4. Can I test this change in isolation?

If you can't answer yes to all four, don't create it.

### Where Things Go (Don't Create New Files!)
- **Feature plans, roadmaps, TODOs** → PROJECT_ROADMAP.md
- **Work notes, discoveries, decisions** → CLAUDE_LOG.md
- **Setup instructions, guidelines** → CLAUDE.md or README.md
- **Configuration examples** → Existing config files
- **Architecture decisions** → PROJECT_ROADMAP.md Notes section

Creating BETA_FEATURES.md or ARCHITECTURE.md or TODO.md = ❌ Wrong!
Adding sections to existing files = ✅ Right!

### CLAUDE_LOG.md is Append-Only
- **Never edit previous entries** - They are historical record
- **Only add new entries at the bottom** - Chronological order
- **If you made a mistake** - Add a new entry with the correction
- **Preserve the timeline** - The log shows how understanding evolved

## On Session Start

Run this status check:
```bash
# Find all projects with logs
for dir in */; do
  if [ -f "$dir/CLAUDE_LOG.md" ]; then
    echo "=== $dir ==="
    # Check roadmap for current status
    if [ -f "$dir/PROJECT_ROADMAP.md" ]; then
      echo "Current Status:"
      grep -A 3 "## Current Status" "$dir/PROJECT_ROADMAP.md" 2>/dev/null | tail -n +2
    fi
    # Show recent log entries
    tail -n 20 "$dir/CLAUDE_LOG.md" | grep -E "^###|Next:|Blocked:" | tail -n 3
    # Git status
    (cd "$dir" && git status -s 2>/dev/null | head -n 3)
    echo
  fi
done
```

## Generating Detailed Project Reports

For comprehensive project summaries, spawn sub-agents with dynamic scope:

### Daily Standup (Morning)
```bash
claude -p "You are in [project] directory. For DAILY STANDUP:
1. Read PROJECT_ROADMAP.md Active Work section
2. Read CLAUDE_LOG.md - only last 3 entries or yesterday's entries
3. Identify: What's planned for today based on 'Next:' items
4. Report: 1-2 sentences on today's focus"
```

### Daily Review (Evening)
```bash
claude -p "You are in [project] directory. For DAILY REVIEW:
1. Read PROJECT_ROADMAP.md for context
2. Read CLAUDE_LOG.md - ONLY entries from today ($(date +%Y-%m-%d))
3. Check git commits from today
4. Report: What got done, what's blocked, what's next"
```

### Weekly Review
```bash
claude -p "You are in [project] directory. For WEEKLY REVIEW:
1. Read PROJECT_ROADMAP.md - note completed items
2. Read CLAUDE_LOG.md - entries from last 7 days
3. Check git commits from: $(date -d '7 days ago' +%Y-%m-%d) to today
4. Report: Major accomplishments, patterns, next week priorities"
```

### Dynamic Scoping Pattern
- **Standup**: Last 3 log entries + active roadmap items
- **Daily**: Today's logs only (grep by date)
- **Weekly**: Last 7 days of logs
- **Monthly**: Last 30 days + roadmap evolution

This prevents agents from reading entire history when only recent context is needed.

## Status Indicators

When showing project status:
- 🟢 Active - worked on today
- 🟠 Blocked - has blockers noted
- 🔴 Uncommitted - has git changes
- ⚫ Stale - no activity >7 days

## Starting Work on a Project

When the user wants to work on a project:
1. Remind them to `cd [project]`
2. In the new Claude session, first read CLAUDE_LOG.md
3. Check git status
4. Look for "Next:" in the last log entry

## Creating New Projects

When creating a new project:
1. Create directory and init git
2. Create CLAUDE.md from template
3. Create PROJECT_ROADMAP.md from template
4. Create initial CLAUDE_LOG.md entry
5. Update roadmap with initial goals

## Roadmap Best Practices

When updating any PROJECT_ROADMAP.md:
- **Version features**: Group into v0.1, v0.2, etc. (future git branches)
- **Make actionable**: "Add auth" → "Add JWT authentication with refresh tokens"
- **Include why**: Brief rationale for each feature
- **Think PR-sized**: Each version should be one coherent pull request
- **Enable automation**: Clear enough that "work on v0.2" is unambiguous

Remember: Roadmaps aren't just plans - they're executable specifications for future work.

## Project CLAUDE.md Template

```markdown
# Project: [Name]

## Start Every Session
1. Read CLAUDE_LOG.md - understand where we left off
2. Run git status - see uncommitted work
3. Look for "Next:" in recent logs

## After Each Work Block
Add to CLAUDE_LOG.md (use `date '+%Y-%m-%d %H:%M'` for timestamp):
```
### YYYY-MM-DD HH:MM - [What you did]
Did: [Specific accomplishments]
Next: [Immediate next task]
Blocked: [Any blockers, if none, omit this line]
```

## Project Context
[Add project-specific info here]

Remember: The log is our shared memory. Keep it updated.
```

## Key Principle

Every Claude session is ephemeral. The logs are permanent. Write logs as if you're leaving notes for a colleague (yourself tomorrow).

## Quick Reference: The Three Core Documents

1. **CLAUDE.md** - How to work (instructions, principles)
2. **CLAUDE_LOG.md** - What happened (append-only history)  
3. **PROJECT_ROADMAP.md** - What's next (current state, plans, features)

That's it. Don't create other planning/tracking documents.

## Daily/Weekly Review Pattern

For comprehensive reviews across all projects:

1. **Quick scan** - Use bash loop for basic status
2. **Deep dive** - Spawn sub-agents with appropriate scope:
   - Daily: Today's entries only
   - Weekly: Last 7 days
   - Monthly: Last 30 days
3. **Synthesize** - Look for patterns across projects:
   - Which projects are blocked?
   - Common technical challenges?
   - Resource conflicts?
   - Stale projects needing attention?

### Efficient Log Filtering

Teach sub-agents to filter logs by date:
```bash
# Today's entries only
grep "^### $(date +%Y-%m-%d)" CLAUDE_LOG.md -A 20

# This week's entries
for i in {0..6}; do
  date -d "$i days ago" +%Y-%m-%d
done | xargs -I {} grep "^### {}" CLAUDE_LOG.md -A 20

# Last N entries
tail -n 100 CLAUDE_LOG.md | awk '/^###/{p=1} p'
```

This ensures sub-agents read only relevant portions, making reports faster and more focused.