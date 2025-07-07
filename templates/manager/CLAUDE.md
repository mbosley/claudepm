# Manager Workspace

<!-- ==================== CLAUDEPM SECTION START ==================== -->
<!-- DO NOT EDIT THIS SECTION - Managed by claudepm v0.3.1 -->

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

### Where Things Go (Don't Create New Files!)
- **Feature plans, roadmaps, TODOs** → ROADMAP.md
- **Work notes, discoveries, decisions** → LOG.md
- **Setup instructions, guidelines** → CLAUDE.md or README.md
- **Configuration examples** → Existing config files
- **Architecture decisions** → ROADMAP.md Notes section

Creating BETA_FEATURES.md or ARCHITECTURE.md or TODO.md = ❌ Wrong!
Adding sections to existing files = ✅ Right!

### LOG.md is Append-Only
- **Never edit previous entries** - They are historical record
- **Only add new entries at the bottom** - Chronological order
- **If you made a mistake** - Add a new entry with the correction
- **Preserve the timeline** - The log shows how understanding evolved

## On Session Start

1. Read LOG.md at manager level (if exists)
2. Check for recent manager-level activities
3. Run quick status check or use /orient
4. **Log that you've started a manager session**

## When to Log (IMPORTANT)

Manager Claude should log MORE frequently than project Claude because coordination activities are easy to forget:

- **After ANY slash command** - Log what you ran and what you found
- **After routing updates** - Log which projects received updates
- **After status checks** - Log the overall health snapshot
- **After spawning sub-agents** - Log what analyses you requested
- **When blocked or waiting** - Log what you're waiting for
- **Before session ends** - Log any pending items

## Log Entry Format

Add to LOG.md at this level using append-only pattern:
```bash
# Simple, clean append that always works
{
echo ""
echo ""
echo "### $(date '+%Y-%m-%d %H:%M') - [Manager activity]"
echo "Did: [What coordination/analysis/routing was done]"
echo "Projects affected: [List projects touched]"
echo "Next: [What manager-level work is needed]"
echo ""
echo "---"
} >> LOG.md
```

**CRITICAL: NEVER use Write or Edit tools on LOG.md** - only append with >> operator

## Generating Detailed Project Reports

**CRITICAL: DEFAULT TO PARALLEL SUB-AGENTS**

Manager Claude should ALWAYS use parallel Tasks when dealing with multiple projects. This is faster and prevents context overload.

### When to Use Parallel Sub-Agents (Almost Always!)

**1. Status Checks - ALWAYS parallelize:**
```python
# ✅ GOOD - Parallel execution (takes 30 seconds)
Task: "Check git status", prompt: "Run git status in auth-service/"
Task: "Check git status", prompt: "Run git status in blog/"  
Task: "Check git status", prompt: "Run git status in payment-api/"
# All three complete simultaneously

# ❌ BAD - Sequential (takes 90 seconds)
Check auth-service, then blog, then payment-api...
```

**2. Project Analysis - ALWAYS parallelize:**
```python
# ✅ GOOD - Each agent focuses on one project
Task: "Analyze auth-service", prompt: "Read LOG.md and summarize last 3 days of work in auth-service/"
Task: "Analyze blog", prompt: "Read LOG.md and summarize last 3 days of work in blog/"
Task: "Analyze payments", prompt: "Read LOG.md and summarize last 3 days of work in payment-api/"

# ❌ BAD - Loading everything into Manager's context
Reading all logs myself and trying to remember everything...
```

### The Golden Rule

> If you're about to check/read/update more than ONE project, use parallel Tasks.

## Core Manager Commands

```bash
claudepm doctor              # Check health of all projects
claudepm find-blocked        # Find blocked tasks across projects
claudepm find-stale --days 7 # Find inactive projects
```

## Status Indicators

When showing project status:
- 🟢 Active - worked on today
- 🟠 Blocked - has blockers noted
- 🔴 Uncommitted - has git changes
- ⚫ Stale - no activity >7 days

## Slash Commands for Manager Claude

These commands are implemented as files in `.claude/commands/`:

- **/brain-dump** - Process unstructured updates and route to appropriate projects
- **/daily-standup** - Quick morning check across all projects
- **/daily-review** - Evening wrap-up
- **/weekly-review** - Comprehensive week summary with patterns
- **/project-health** - Which projects need attention?
- **/start-work [project]** - Quick briefing before diving into a specific project

## Starting Work on a Project

When the user wants to work on a project:
1. Remind them to `cd [project]`
2. In the new Claude session, first read LOG.md
3. Check git status
4. Look for "Next:" in the last log entry

## Creating New Projects

```bash
mkdir new-project && cd new-project
claudepm init project
```

## Adopting Existing Projects

```bash
cd existing-project
claudepm adopt
```

This:
- Analyzes project structure
- Imports existing TODOs
- Discovers test/build commands
- Creates all claudepm files

## Key Principle

Every Claude session is ephemeral. The logs are permanent. Write logs as if you're leaving notes for a colleague (yourself tomorrow).

## The Four Core Files

1. **CLAUDE.md** - HOW to work (instructions, principles)
2. **LOG.md** - WHAT happened (append-only history by Claude)  
3. **ROADMAP.md** - WHAT's next (current state, plans, features)
4. **NOTES.md** - WHY it matters (human insights and patterns)

That's it. Don't create other planning/tracking documents.

<!-- ==================== CLAUDEPM SECTION END ==================== -->

<!-- ==================== MANAGER CUSTOMIZATION START ==================== -->
<!-- The content below can be customized per workspace -->

## Manager-Specific Notes

[Add any workspace-specific coordination patterns or frequently managed projects here]

<!-- CLAUDEPM_CUSTOMIZATION_END -->
<!-- ==================== MANAGER CUSTOMIZATION END ==================== -->