# claudepm v0.3.0 Architecture Document

## Executive Summary

claudepm v0.3.0 represents a fundamental evolution from a "markdown memory system" to a "structured knowledge base" for AI-assisted development. This architecture maintains human-friendly markdown files while introducing robust parsing, semantic tools, and centralized template management.

The core innovation is the three-level behavioral hierarchy (Manager, Project Lead, Task Agent) that enables scalable AI-assisted development through carefully crafted behavioral instructions.

### Version
- Document Version: 1.0
- Target claudepm Version: 0.3.0
- Date: 2025-01-03
- Status: Approved for Implementation

### Core Problems This Architecture Solves

1. **Version Drift**: Projects using different claudepm versions with incompatible templates
2. **Template Sprawl**: Templates copied everywhere, becoming stale and inconsistent
3. **Brittle Operations**: Regex-based file manipulation prone to breaking
4. **Limited Queries**: Cannot easily find patterns across projects or time
5. **Unsafe Edits**: Direct file editing risks corrupting structure

## Architecture Overview

### Design Principles

1. **Centralized Core, Distributed Data**
   - Core templates and tools live in `~/.claudepm/`
   - Project-specific data stays in project directories
   - Clean separation between framework and content

2. **Structured Markdown with Progressive Enhancement**
   - Use markdown with embedded structured blocks
   - Gracefully handle unstructured legacy content
   - Human-readable even without tooling

3. **Semantic Tools Over Direct Manipulation**
   - Tools understand and preserve structure
   - Validate operations before executing
   - Enable rich queries and automation

4. **UUID-Based Identity System**
   - Every task, log, and note gets a unique ID
   - Enables cross-references and linking
   - Supports future knowledge graph features

## Core Behavioral Instructions: The Heart of claudepm

The most critical components of claudepm are the behavioral instruction files that define how Claude operates at each level. These files contain carefully crafted prompts that create a coherent, scalable development workflow. Everything else in claudepm is scaffolding to deliver these behavioral patterns.

### The Three-Level Hierarchy

#### 1. Manager Claude (CLAUDEPM-MANAGER.md)
Lives at `~/projects/`, coordinates multiple projects, never implements code directly.

**Key Behaviors:**
- Maintains cross-project awareness and context switching
- Routes updates from brain dumps to appropriate projects
- Spawns parallel sub-agents for efficiency (CRITICAL pattern)
- Logs coordination activities frequently
- Generates project health reports and summaries

**Core Philosophy:**
- Always prefer simple solutions
- One change at a time
- Memory over management
- Edit existing files rather than creating new ones

**Parallel Processing Pattern (Essential):**
```python
# Manager ALWAYS uses parallel Tasks for multi-project operations
Task: "Check project health", prompt: "In auth-service/, check: CLAUDE.md exists, git status, last log date"
Task: "Check project health", prompt: "In blog/, check: CLAUDE.md exists, git status, last log date"
# All execute simultaneously, 10x faster than sequential
```

#### 2. Project Lead Claude (CLAUDEPM-PROJECT.md)
Lives at `~/projects/my-app/`, always on dev branch, dispatches Task Agents.

**Key Behaviors:**
- Edits existing code rather than rewriting
- Makes minimal changes that solve problems
- Logs after each work block with precise PLANNED vs IMPLEMENTED
- Updates ROADMAP.md before committing
- Creates and manages worktrees for Task Agents
- Reviews and merges Task Agent PRs

**Logging Discipline:**
```bash
# Append-only pattern (NEVER edit past entries)
{
echo ""
echo ""
echo "### $(date '+%Y-%m-%d %H:%M') - [Brief summary]"
echo "Did:"
echo "- IMPLEMENTED: Feature X (code written)"
echo "- PLANNED: Feature Y (added to roadmap)"
echo "Next: [Immediate next task]"
echo ""
echo "---"
} >> LOG.md
```

**Task Agent Workflow:**
1. Stay on dev branch (NEVER switch branches as Project Lead)
2. Create worktree: `./tools/claudepm-admin.sh create-worktree feature-name`
3. Dispatch Task Agent with clear mission
4. Review PR when complete
5. Merge and cleanup worktree

#### 3. Task Agent Claude (CLAUDEPM-TASK.md)
Lives at `~/projects/my-app/worktrees/feature-name/`, implements in isolation.

**Key Behaviors:**
- Works only on assigned task in isolation
- Makes atomic commits with clear messages
- Tests thoroughly before creating PR
- Logs with branch prefix: `[feature/branch-name]`
- Creates PR and stops (no merging)

**PR Creation Pattern:**
```bash
gh pr create --base dev \
  --title "feat: Your feature description" \
  --body "## Summary
  [What was implemented]
  
  ## Testing
  [How it was tested]
  
  Implements: [Roadmap reference]"
```

### Critical Behavioral Patterns

#### 1. Append-Only Logging
ALL levels use append-only logging to LOG.md:
- NEVER use Write or Edit tools on LOG.md
- Only append with >> operator
- Creates reliable chronological history
- macOS: Protected with `uappnd` filesystem flag

#### 2. File Creation Discipline
Strong preference against creating new files:
```
Feature plans → ROADMAP.md (NOT new TODO.md)
Work notes → LOG.md (NOT new NOTES.md)
Architecture → ROADMAP.md Notes section (NOT ARCHITECTURE.md)
```

#### 3. Parallel Sub-Agent Pattern (Manager Level)
Manager Claude MUST use parallel execution for multi-project operations:
- Status checks across projects: Parallel
- Brain dump routing: Parallel updates
- Report generation: Parallel analysis
- 10x performance improvement over sequential

#### 4. Clear Ownership Boundaries
- Manager: Coordinates but never implements
- Project Lead: Implements on dev branch OR dispatches Task Agents
- Task Agent: Implements in isolation, never merges

### Complete Behavioral Templates

The following sections contain the complete behavioral instruction files that define claudepm's AI-assisted workflow. These are the core intellectual property of the system.

#### CLAUDEPM-MANAGER.md (Manager Level Instructions)

```markdown
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

**macOS Protection**: On macOS, LOG.md has filesystem-level append-only protection (`uappnd` flag). Write/Edit operations will fail with EPERM. To temporarily remove: `chflags nouappnd LOG.md`

Examples of when to log:

**After /doctor command:**
```
### 2025-06-30 15:10 - Ran health check across all projects
Did:
- CHECKED: 8 projects total, 5 healthy, 2 outdated templates, 1 stale
- IDENTIFIED: auth-service and blog need template updates (v0.1 → v0.1.1)
- FOUND: payment-api stale for 10 days
Projects affected: All (system scan)
Next: Update outdated templates, check on payment-api blockage
```

**After /brain-dump processing:**
```
### 2025-06-29 21:00 - Processed brain dump from client meeting
Did:
- ROUTED: 3 updates to auth-service, 2 to blog project
- IDENTIFIED: payment-api blocked on Stripe keys
- ADDED: Hard deadline to auth-service roadmap [DUE: 2025-07-01]
Projects affected: auth-service, blog, payment-api
Next: Follow up on Stripe key blocker with client
```

**After parallel sub-agent tasks:**
```
### 2025-06-30 16:00 - Generated weekly review reports
Did:
- SPAWNED: 5 parallel sub-agents for project analysis
- COMPLETED: All weekly reviews in 2 minutes (vs 10 sequential)
- IDENTIFIED: Common pattern - 3 projects blocked on external dependencies
Projects affected: All active projects
Next: Create summary report of external blockers for client
```

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

**3. Brain Dump Routing - ALWAYS parallelize updates:**
```python
# ✅ GOOD - After parsing brain dump, route in parallel
Task: "Update auth roadmap", prompt: "In auth-service/, add 'Deploy by Friday [DUE: 2025-07-05]' to ROADMAP.md"
Task: "Update blog roadmap", prompt: "In blog/, move 'Publish announcement' to Active Work"
Task: "Update payment roadmap", prompt: "In payment-api/, move 'Stripe integration' to Blocked section"

# ❌ BAD - Doing updates sequentially
First update auth, wait for completion, then blog, wait, then payments...
```

### Parallel Patterns for Common Commands

**/doctor command should use:**
```python
# Spawn parallel health checks
Task: "Check project health", prompt: "In auth-service/, check for: 1) CLAUDE.md exists, 2) .claudepm version, 3) git status, 4) last log date"
Task: "Check project health", prompt: "In blog/, check for: 1) CLAUDE.md exists, 2) .claudepm version, 3) git status, 4) last log date"
# ... one task per project
```

**/weekly-review should use:**
```python
# Parallel weekly analysis
Task: "Weekly review", prompt: "In auth-service/, read last 7 days of LOG.md and summarize: accomplishments, blockers, patterns"
Task: "Weekly review", prompt: "In blog/, read last 7 days of LOG.md and summarize: accomplishments, blockers, patterns"
# Aggregate results after all complete
```

### Why Parallel is Essential

1. **Speed**: 10 projects checked in parallel = 30 seconds. Sequential = 5 minutes.
2. **Memory**: Each sub-agent gets fresh context. Manager stays light.
3. **Accuracy**: Sub-agents can deep-dive without contaminating Manager's context.
4. **Scalability**: Works the same for 3 projects or 30 projects.

### The Golden Rule

> If you're about to check/read/update more than ONE project, use parallel Tasks.
> If you find yourself thinking "first I'll check X, then Y" - STOP and parallelize!

For comprehensive project summaries, spawn sub-agents with dynamic scope:

### Daily Standup (Morning)
```bash
claude -p "You are in [project] directory. For DAILY STANDUP:
1. Read ROADMAP.md Active Work section
2. Read LOG.md - only last 3 entries or yesterday's entries
3. Identify: What's planned for today based on 'Next:' items
4. Report using this format:
   **[Project Name] - Daily Standup**
   Today's Focus: [1-2 sentences on priorities]
   Key Items: [List 2-3 specific tasks from Next: entries]"
```

### Daily Review (Evening)
```bash
claude -p "You are in [project] directory. For DAILY REVIEW:
1. Read ROADMAP.md for context
2. Read LOG.md - ONLY entries from today ($(date +%Y-%m-%d))
3. Check git commits from today
4. Report using this format:
   ## Daily Review - [Project Name] - [Date]
   ### Completed
   - [List what got done]
   ### Blocked
   - [Any blockers, or 'None']
   ### Next Steps
   - [Immediate priorities]
   ### Key Insights
   - [Any lessons learned or patterns noticed]"
```

### Weekly Review
```bash
claude -p "You are in [project] directory. For WEEKLY REVIEW:
1. Read ROADMAP.md - note completed items
2. Read LOG.md - entries from last 7 days
3. Check git commits from: $(date -d '7 days ago' +%Y-%m-%d) to today
4. Report using this format:
   ## Weekly Review - [Project Name]
   ### Major Accomplishments
   - [Completed features/milestones]
   ### Patterns & Insights
   - [Recurring themes, lessons learned]
   ### Next Week Priorities
   1. [Most important]
   2. [Second priority]
   3. [Third priority]
   ### Metrics
   - Log entries: [count]
   - Commits: [count]
   - Roadmap progress: [e.g., v0.1 complete, v0.2 started]"
```

### Project Health Check
```bash
claude -p "You are in [project] directory. For PROJECT HEALTH:
1. Check ROADMAP.md Blocked section
2. Search LOG.md for recent 'Blocked:' entries
3. Run git status for uncommitted changes
4. Report using this format:
   **[Project Name] Health: [🟢/🟠/🔴/⚫]**
   - Blockers: [count and brief description, or 'None']
   - Git status: [Clean/X uncommitted changes]
   - Last activity: [date from most recent log]
   - Recommendation: [Continue/Needs attention/Review blockers]"
```

### Cross-Project Pattern Analysis
```bash
claude -p "You are in [project] directory. For PATTERN ANALYSIS:
1. Read LOG.md focusing on Error:, Solved:, and Notes: sections
2. Look for recurring themes and lessons learned
3. Report using this format:
   ## Pattern Analysis - [Project Name]
   ### Common Errors
   - [Pattern]: [How it was solved]
   ### Key Lessons
   - [Lesson]: [Why it matters]
   ### Reusable Solutions
   - [Problem type]: [Solution approach]"
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

## Slash Commands for Manager Claude

These commands are implemented as files in `.claude/commands/` following Claude Code best practices.
When you type `/` in Claude, these commands become available:

### /brain-dump
Process unstructured updates and route to appropriate projects:
```
/brain-dump
Had a client call. They need auth system deployed by July 1st. 
Payment integration is blocked on Stripe keys.
Blog post about claudepm should go out this week.
Found a bug in the CSV export feature.
```

### /daily-standup
Quick morning check across all projects - what's on deck today?

### /daily-review  
Evening wrap-up - what got done, what's blocked?

### /weekly-review
Comprehensive week summary with patterns and priorities

### /project-health
Which projects need attention? Check for blockers and stale work

### /start-work [project]
Quick briefing before diving into a specific project

### /email-check
Process emails as project updates via apple-mcp integration. Reads emails and suggests updates to project files without auto-updating. Maintains human control over what gets incorporated.

**Note**: These commands are stored in `.claude/commands/*.md` and can be customized or extended.
See https://www.anthropic.com/engineering/claude-code-best-practices for more on slash commands.

## Starting Work on a Project

When the user wants to work on a project:
1. Remind them to `cd [project]`
2. In the new Claude session, first read LOG.md
3. Check git status
4. Look for "Next:" in the last log entry

## Creating New Projects

When creating a new project:
1. Create directory and init git
2. Create CLAUDE.md from template
3. Create ROADMAP.md from template
4. Create initial LOG.md entry
5. Update roadmap with initial goals
6. Create .claudepm marker file (see below)

## Adopting Existing Projects

To add claudepm to an existing project:

### 1. Check if already initialized
```bash
# Look for claudepm marker
if [ -f "project/.claudepm" ]; then
  echo "Already initialized with claudepm"
  exit
fi
```

### 2. Analyze the project
Examine the project to understand:
- Project type (check package.json, requirements.txt, Cargo.toml, etc.)
- Existing documentation (README.md, docs/)
- Current TODOs (grep for TODO/FIXME comments, look for TODO.md)
- Recent activity (git log --oneline -10)
- Test/build commands (from package.json scripts, Makefile, etc.)

### 3. Generate initial files
**CLAUDE.md**: Include discovered commands and project-specific info
```markdown
# Project: [Name from package.json/README]

## Start Every Session
[Standard template content]

## Project Context
Type: [Discovered type - Node.js app, Python CLI, etc.]
Language: [Primary language]
Purpose: [From README or package.json description]

## Discovered Commands
- Test: [npm test, pytest, cargo test, etc.]
- Build: [npm run build, make, etc.]
- Run: [npm start, python main.py, etc.]
```

**ROADMAP.md**: Import existing TODOs and infer from recent commits
```markdown
## Current Status
[Summarize from README and recent commits]

## Active Work
[Import any TODO/FIXME comments found]
[Infer from recent commit messages]

## Upcoming
[Any roadmap/TODO files content]
```

**LOG.md**: First entry documenting adoption
```markdown
### YYYY-MM-DD HH:MM - Adopted project into claudepm
Did:
- ANALYZED: Project structure and discovered [type] project
- FOUND: [X] existing TODOs imported to roadmap
- DISCOVERED: Test command: [command], Build: [command]
- CREATED: Initial claudepm files based on analysis
Next: Review imported items and update roadmap
Notes: Adoption found [interesting discoveries]. Existing documentation preserved in roadmap Notes section.
```

### 4. Create .claudepm marker
```json
{
  "claudepm": {
    "version": "0.1",
    "initialized": "YYYY-MM-DD HH:MM:SS"
  },
  "adoption": {
    "adopted_from_existing": true,
    "discovered_type": "node-web-app",
    "imported_todos": 5,
    "found_commands": ["npm test", "npm run build"]
  }
}
```

### 5. Update .gitignore
Add `.claudepm` to the project's .gitignore to keep it local

## Roadmap Best Practices

When updating any ROADMAP.md:
- **Version features**: Group into v0.1, v0.2, etc. (future git branches)
- **Make actionable**: "Add auth" → "Add JWT authentication with refresh tokens"
- **Include why**: Brief rationale for each feature
- **Think PR-sized**: Each version should be one coherent pull request
- **Enable automation**: Clear enough that "work on v0.2" is unambiguous

**Before ANY commit**: Always check if ROADMAP.md needs updating:
- Have you completed items that should move to Completed?
- Are there new tasks discovered during work?
- Has the Current Status changed?
- Update "Last updated" timestamp

Remember: Roadmaps aren't just plans - they're executable specifications for future work.

## Project CLAUDE.md Template

```markdown
# Project: [Name]

## Start Every Session
1. Read LOG.md - understand where we left off
2. Run git status - see uncommitted work
3. Look for "Next:" in recent logs

## After Each Work Block
Add to LOG.md (use `date '+%Y-%m-%d %H:%M'` for timestamp):
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
2. **LOG.md** - What happened (append-only history)  
3. **ROADMAP.md** - What's next (current state, plans, features)

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

### Multi-Project Report Aggregation

When running reports across multiple projects, use PARALLEL execution:

```python
# Spawn all agents AT ONCE (parallel)
Task: "Generate daily review for auth-service"
Task: "Generate daily review for blog"  
Task: "Generate daily review for payment-api"
# Wait for all to complete, then synthesize

# Then synthesize results
"Given these individual project reports:
[results from parallel tasks]

Create an executive summary with:
## Multi-Project Summary - [Date]
### Projects Overview
- 🟢 Active: [list]
- 🟠 Blocked: [list]
- 🔴 Needs attention: [list]
- ⚫ Stale: [list]

### Cross-Project Patterns
- Common blockers: [identify themes]
- Shared solutions: [reusable patterns]
- Resource conflicts: [competing priorities]

### Recommended Actions
1. [Highest priority across all projects]
2. [Second priority]
3. [Third priority]"
```

### Efficient Log Filtering

Teach sub-agents to filter logs by date:
```bash
# Today's entries only
grep "^### $(date +%Y-%m-%d)" LOG.md -A 20

# This week's entries
for i in {0..6}; do
  date -d "$i days ago" +%Y-%m-%d
done | xargs -I {} grep "^### {}" LOG.md -A 20

# Last N entries
tail -n 100 LOG.md | awk '/^###/{p=1} p'
```

This ensures sub-agents read only relevant portions, making reports faster and more focused.

### Saving Manager Reports (Future Feature)

Once manager report persistence is implemented (v0.7), reports will be saved:
```bash
# Daily summaries
~/.claudepm/reports/daily/2025-06-29.md

# Weekly summaries  
~/.claudepm/reports/weekly/2025-W26.md

# Monthly aggregations
~/.claudepm/reports/monthly/2025-06.md
```

This creates searchable manager-level memory:
- "What were common blockers last month?"
- "When did we last work on auth issues?"
- "Show me all weekly reviews mentioning performance"

## Brain Dump Processing (Inbox Pattern)

Manager Claude can parse unstructured updates and route them to appropriate projects. 
Use the `/brain-dump` slash command for quick access, or follow these patterns:

### Basic Brain Dump
```bash
claude -p "BRAIN DUMP PROCESSING:
I need to process this update and route items to relevant projects:

[Your brain dump here - can be messy notes, meeting outcomes, random thoughts]

For each item:
1. Identify which project it relates to (check */ directories)
2. Extract any deadlines, blockers, or priority changes
3. Spawn sub-agent to update that project's ROADMAP.md
4. Report what was updated and what couldn't be matched"
```

### Structured Brain Dump (Easier to Parse)
```
project-name: Update or deadline or blocker
auth-system: Deploy by July 1st - hard deadline from client
blog: Publish claudepm article this week 
payment-app: BLOCKED - waiting on Stripe API keys
ml-project: Prioritize data pipeline over model work
general: Team wants to move standup to 10am
```

### Processing Example
```bash
claude -p "BRAIN DUMP from client meeting:

'Client wants auth system live by July 1st, that's non-negotiable. 
The payment integration is blocked until we get Stripe keys. 
For the blog, we should publish the claudepm article to coincide with PyCon.
Oh and someone reported a bug in the CSV export feature.'

Process this:
1. Find matching projects
2. Update roadmaps with deadlines [DUE: YYYY-MM-DD]
3. Move blocked items to Blocked section
4. Add bugs to Active Work
5. Show me what was updated"
```

### Sub-Agent Routing Pattern
Manager Claude spawns focused updates:
```bash
# For each identified project
claude -p "You are in auth-system/ directory.
Update ROADMAP.md:
- Add to Active Work: Deploy to production [DUE: 2025-07-01]
- Note in context: Hard deadline from client meeting 2025-06-29"
```

### What Gets Extracted
- **Deadlines**: "by July 1st", "due Friday", "ship this week" → [DUE: YYYY-MM-DD]
- **Blockers**: "blocked on", "waiting for", "need X first" → Move to Blocked section
- **Priorities**: "focus on", "prioritize", "urgent" → Reorder in roadmap
- **Bugs**: "bug in", "broken", "not working" → Add to Active Work
- **Context**: "client said", "team decided" → Add to Notes section

### Unmatched Items
Items that can't be matched to a project:
```markdown
## Inbox Pending - 2025-06-29
- "Move weekly standup to 10am" - no project context
- "Consider upgrading to Python 3.12" - which project?
```

This pattern scales from quick notes to meeting transcripts!
```

#### CLAUDEPM-PROJECT.md (Project Lead Instructions)

```markdown
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
- **Work history/decisions** → Goes in LOG.md  
- **Instructions/setup** → Goes in CLAUDE.md or README.md
- **Only create new files for actual code or truly new categories**

Example: Beta features, roadmaps, plans, ideas, TODOs → All go in ROADMAP.md, not new files!

### claudepm Files
- **CLAUDE.md** - Project-specific instructions (check in to git)
- **LOG.md** - Append-only work history (check in to git)  
- **ROADMAP.md** - Living state document (check in to git)
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
```

#### CLAUDEPM-TASK.md (Task Agent Instructions)

```markdown
# Task Agent Instructions

You are a Task Agent working in an isolated worktree. Your role is to implement a specific feature or fix without affecting the main codebase.

## Core Principles
1. **Stay focused** - Work only on your assigned task
2. **Atomic commits** - Make small, logical commits
3. **Test thoroughly** - Ensure your changes work before PR
4. **Document changes** - Update relevant docs and logs
5. **Clean implementation** - Follow existing patterns

## Your Workflow

1. **Start in your worktree**: You should be in `worktrees/[feature-name]/`
2. **Read context**: Check TASK_PROMPT.md for your mission
3. **Understand the codebase**: Read LOG.md and ROADMAP.md
4. **Implement**: Make your changes following the architectural plan
5. **Test**: Verify your implementation works
6. **Commit**: Use clear, descriptive commit messages
7. **Create PR**: When complete, create a PR back to dev branch
8. **Stop**: Your work ends when the PR is created

## Logging

Add entries to LOG.md with your branch prefix:

```bash
{
echo ""
echo ""
echo "### $(date '+%Y-%m-%d %H:%M') - [feature/your-branch] - Brief summary"
echo "Did:"
echo "- Specific accomplishment"
echo "Next: Immediate next step"
echo ""
echo "---"
} >> LOG.md
```

## Git Workflow

1. **Regular commits**: Commit as you complete each logical piece
2. **Clear messages**: 
   ```
   feat: Add search functionality to logs
   
   - Added search command with regex support
   - Implemented date filtering
   - Added tests for search features
   ```
3. **Don't merge**: Just create the PR, Project Lead handles merging

## Creating Your PR

When your implementation is complete:

```bash
gh pr create --base dev \
  --title "feat: Your feature description" \
  --body "## Summary
  
  Brief description of what you implemented
  
  ## Changes
  - List of specific changes
  
  ## Testing
  - How you tested the changes
  
  ## Notes
  - Any additional context
  
  Implements: [Reference to roadmap item or issue]"
```

## Important Reminders

- **Never switch branches** - Stay in your feature branch
- **Don't modify other features** - Focus only on your task
- **Ask if unclear** - Better to clarify than assume
- **Log progress** - Keep LOG.md updated
- **Test before PR** - Ensure everything works

## Common Patterns

### Feature Implementation
1. Read architectural plan in TASK_PROMPT.md
2. Implement step by step
3. Add tests if applicable
4. Update documentation
5. Create comprehensive PR

### Bug Fix
1. Reproduce the issue
2. Identify root cause
3. Implement minimal fix
4. Test the fix thoroughly
5. Document what caused the bug

### Refactoring
1. Understand current implementation
2. Plan the refactoring approach
3. Make incremental changes
4. Ensure tests still pass
5. Document why refactoring was needed

Remember: You're working in isolation. Your changes won't affect the main branch until the Project Lead reviews and merges your PR.
```

## Detailed Specifications

### Directory Structure

```
~/.claudepm/                              # Central installation (NOT ~/.claude)
├── VERSION                               # Current claudepm version (e.g., "0.3.0")
├── config.json                           # Global configuration
├── bin/                                  # Executable commands
│   └── claudepm                          # Main CLI entry point
├── templates/                            # Template library
│   ├── default/                          # Default template set
│   │   ├── manager/
│   │   │   ├── CLAUDEPM-MANAGER.md      # Core manager instructions
│   │   │   ├── CLAUDE.md                # Template for new managers
│   │   │   ├── NOTES.md                 # Manager notes template
│   │   │   └── ROADMAP.md               # Cross-project roadmap template
│   │   ├── project/
│   │   │   ├── CLAUDEPM-PROJECT.md      # Core project instructions
│   │   │   ├── CLAUDE.md                # Project template
│   │   │   ├── NOTES.md                 # Project notes template
│   │   │   └── ROADMAP.md               # Project roadmap template
│   │   └── task-agent/
│   │       ├── CLAUDEPM-TASK.md         # Core task agent instructions
│   │       └── TASK_PROMPT.md           # Task prompt template
│   └── custom/                           # User-defined templates
├── lib/                                  # Core libraries
│   ├── parser.py                         # Markdown block parser
│   ├── tools.py                          # Semantic tool implementations
│   ├── context.py                        # Context assembly logic
│   └── index.py                          # Indexing/query engine
├── cache/                                # Performance cache
│   ├── index.db                          # SQLite index of all blocks
│   └── context/                          # Cached context assemblies
└── logs/                                 # claudepm operation logs
    └── operations.log                    # Tool usage history

~/projects/                               # Manager workspace
├── CLAUDE.md                            # Manager customizations
├── LOG.md                        # Cross-project activity log  
├── ROADMAP.md                           # Aggregated deadlines/status
├── NOTES.md                             # Strategic notes
├── .claudepm                            # Marks as claudepm directory
└── .claudepm-lock.json                  # Template version lock

~/projects/web-app/                       # Project workspace
├── CLAUDE.md                            # Project instructions
├── LOG.md                        # Project work history
├── ROADMAP.md                           # Tasks and deadlines
├── NOTES.md                             # Decisions and context
├── .claudepm                            # Project configuration
├── .claudepm-lock.json                  # Locked template versions
└── worktrees/                           # Task agent workspaces
    └── add-auth/
        ├── TASK_PROMPT.md               # Specific task instructions
        └── .claudepm                    # Task agent config
```

### Configuration Files

#### .claudepm (Project Configuration)
```json
{
  "claudepm": {
    "version": "0.3.0",
    "role": "project",
    "parent": "../..",  // For task agents only
    "context": {
      "logs": {
        "mode": "hybrid",
        "last_n": 5,
        "days": 7,
        "max": 10
      },
      "notes": {
        "mode": "days",
        "days": 14
      }
    }
  }
}
```

#### .claudepm-lock.json (Version Lock)
```json
{
  "claudepmVersion": "0.3.0",
  "templateSet": "default",
  "templateVersion": "1.2.1",
  "lastSync": "2025-01-03T10:30:00Z"
}
```

### Structured Block Format

All structured data uses HTML comments with CPM (ClaudePM) markers for unambiguous parsing:

#### Task Block
```markdown
<!-- CPM:TASK ID="7f3b4e5d-9a2c-4d1e-b8f6-3c7a8d9e1f2a" STATUS="TODO" PRIORITY="A" -->
## Implement JWT authentication :backend:security: @alice

**Goal:** Add JWT token-based authentication to all API endpoints
**Created:** 2025-01-03T10:00:00Z
**Deadline:** 2025-01-07
**Effort:** 8h
**Blocking:** user-dashboard, api-v2

### Description
We need to implement JWT tokens for API authentication to replace the current session-based system.

### Checklist
- [ ] Create login endpoint
- [ ] Generate and validate JWT tokens  
- [ ] Add authentication middleware
- [ ] Update API documentation
- [ ] Write integration tests

### Updates
<!-- CPM:LOG ID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" PARENT="7f3b4e5d-9a2c-4d1e-b8f6-3c7a8d9e1f2a" -->
**2025-01-04T14:30:00Z** - Started implementation. Login endpoint complete, working on token generation.
<!-- CPM:END -->

<!-- CPM:END -->
```

#### Note Block
```markdown
<!-- CPM:NOTE ID="8e4c5f6e-0b3d-5e2f-c9g7-4d8b9e0f3b" TYPE="decision" -->
## Architecture Decision: PostgreSQL over MySQL

**Date:** 2025-01-03T10:00:00Z
**Type:** decision
**Tags:** database, architecture, performance
**Attendees:** @alice, @bob, @charlie
**Expires:** 2025-12-31

### Context
We need to choose between PostgreSQL and MySQL for our main database.

### Decision
We chose PostgreSQL because:
- JSONB support for flexible schema evolution
- Better query planner for complex queries
- Team has 3+ years PostgreSQL experience
- Performance benchmarks show 2x improvement

### Consequences
- Need to train new hires on PostgreSQL
- Can leverage advanced features like CTEs
- Better scaling path for the future
<!-- CPM:END -->
```

#### Log Entry Block
```markdown
<!-- CPM:LOG ID="9f5d6g7f-1c4e-6f3g-d0h8-5e9c0f1g4c" -->
### 2025-01-03 14:30 - Completed authentication system

**Tags:** backend, security, milestone  
**Keywords:** jwt, auth, login, tokens
**Refs:** 7f3b4e5d-9a2c-4d1e-b8f6-3c7a8d9e1f2a, PR-145

**Did:**
- IMPLEMENTED: JWT token generation and validation
- TESTED: All authentication endpoints with full coverage
- DOCUMENTED: API authentication guide for developers
- FIXED: Token expiration edge case in refresh flow

**Next:** Deploy to staging environment for security review

**Blocked:** Need security team approval before production deploy
<!-- CPM:END -->
```

### Block Attributes Specification

#### Common Attributes
- `ID` (required): UUID v4 format
- `CREATED` (auto): ISO 8601 timestamp
- `MODIFIED` (auto): ISO 8601 timestamp

#### Task Attributes
- `STATUS`: TODO | DOING | BLOCKED | DONE
- `PRIORITY`: A | B | C
- `ASSIGNEE`: Username without @
- `DEADLINE`: YYYY-MM-DD format
- `EFFORT`: Duration (e.g., "8h", "2d")
- `BLOCKING`: Comma-separated task IDs
- `BLOCKED_BY`: Task ID or description

#### Note Attributes
- `TYPE`: meeting | decision | idea | email | research
- `TAGS`: Comma-separated keywords
- `ATTENDEES`: Comma-separated usernames
- `EXPIRES`: YYYY-MM-DD (for time-sensitive info)

#### Log Attributes
- `PARENT`: Task ID (if related to task)
- `TAGS`: Comma-separated keywords
- `REFS`: Comma-separated IDs or external refs

## Core Tools Specification

### Command Line Interface

#### Task Management
```bash
# Create new task
claudepm task new "Implement user authentication" \
  --priority A \
  --assignee alice \
  --deadline 2025-01-15 \
  --tags backend,security \
  --effort 16h

# Update task
claudepm task update 7f3b4e5d \
  --status DOING \
  --add-blocking user-dashboard

# Move task status
claudepm task move 7f3b4e5d DONE \
  --note "All tests passing, deployed to production"

# Query tasks
claudepm task list --status TODO --assignee alice
claudepm task list --deadline-before 2025-01-10
claudepm task list --tag security --priority A
```

#### Log Management
```bash
# Add log entry
claudepm log add "Fixed authentication bug" \
  --did "Corrected JWT expiration calculation" \
  --did "Added comprehensive test coverage" \
  --next "Deploy hotfix to production" \
  --tags bugfix,security \
  --refs 7f3b4e5d,PR-156

# Query logs
claudepm log list --since 2025-01-01
claudepm log list --tag security
claudepm log list --refs 7f3b4e5d
```

#### Note Management  
```bash
# Add note
claudepm note add "Team Meeting: Q1 Planning" \
  --type meeting \
  --attendees alice,bob,charlie \
  --tags planning,roadmap \
  --content "Discussed Q1 priorities..."

# Query notes
claudepm note list --type meeting --since 2025-01-01
claudepm note list --attendee alice
claudepm note list --expires-before 2025-02-01
```

#### Context Assembly
```bash
# Default context (based on current directory)
claudepm context

# Specific queries
claudepm context --deadlines 7d
claudepm context --blocked
claudepm context --person alice
claudepm context --project web-app

# Predefined bundles
claudepm context --standup
claudepm context --weekly-report
```

### Python API

```python
from claudepm import TaskManager, LogManager, NoteManager, ContextBuilder

# Task operations
tasks = TaskManager("./ROADMAP.md")
task = tasks.create(
    title="Implement caching layer",
    priority="B",
    assignee="bob",
    deadline="2025-01-20"
)
tasks.update(task.id, status="DOING")
active_tasks = tasks.query(status="DOING")

# Log operations
logs = LogManager("./LOG.md")
logs.add(
    title="Caching implementation started",
    did=["Researched Redis vs Memcached", "Chose Redis"],
    next="Implement cache wrapper",
    refs=[task.id]
)

# Context building
context = ContextBuilder()
context.add_file("CLAUDE.md")
context.add_recent_logs(days=7)
context.add_upcoming_deadlines(days=14)
print(context.render())
```

## Parser Implementation

### Robust Block Parser

```python
import re
from typing import List, Dict, Optional
from dataclasses import dataclass
from datetime import datetime
import uuid

@dataclass
class Block:
    id: str
    type: str
    attributes: Dict[str, str]
    content: str
    start_line: int
    end_line: int

class BlockParser:
    """Fault-tolerant parser for CPM blocks in markdown."""
    
    # Regex for finding block markers
    START_PATTERN = re.compile(r'<!-- CPM:(\w+)(.*?) -->')
    END_PATTERN = re.compile(r'<!-- CPM:END -->')
    ATTR_PATTERN = re.compile(r'(\w+)="([^"]*)"')
    
    def parse_file(self, filepath: str) -> List[Block]:
        """Parse all CPM blocks from a markdown file."""
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        blocks = []
        i = 0
        
        while i < len(lines):
            # Look for start marker
            match = self.START_PATTERN.search(lines[i])
            if match:
                block_type = match.group(1)
                attrs_str = match.group(2)
                start_line = i
                
                # Parse attributes
                attributes = dict(self.ATTR_PATTERN.findall(attrs_str))
                
                # Find corresponding end marker
                content_lines = []
                i += 1
                while i < len(lines):
                    if self.END_PATTERN.search(lines[i]):
                        # Found end marker
                        blocks.append(Block(
                            id=attributes.get('ID', str(uuid.uuid4())),
                            type=block_type,
                            attributes=attributes,
                            content=''.join(content_lines),
                            start_line=start_line,
                            end_line=i
                        ))
                        break
                    content_lines.append(lines[i])
                    i += 1
                else:
                    # No end marker found - log error but continue
                    print(f"Warning: Unclosed CPM block at line {start_line}")
            i += 1
        
        return blocks
    
    def validate_block(self, block: Block) -> List[str]:
        """Validate a block against schema rules."""
        errors = []
        
        if block.type == 'TASK':
            # Validate task-specific rules
            if 'STATUS' in block.attributes:
                if block.attributes['STATUS'] not in ['TODO', 'DOING', 'BLOCKED', 'DONE']:
                    errors.append(f"Invalid STATUS: {block.attributes['STATUS']}")
            
            if 'PRIORITY' in block.attributes:
                if block.attributes['PRIORITY'] not in ['A', 'B', 'C']:
                    errors.append(f"Invalid PRIORITY: {block.attributes['PRIORITY']}")
            
            if 'DEADLINE' in block.attributes:
                try:
                    datetime.strptime(block.attributes['DEADLINE'], '%Y-%m-%d')
                except ValueError:
                    errors.append(f"Invalid DEADLINE format: {block.attributes['DEADLINE']}")
        
        return errors
```

### Index Manager

```python
import sqlite3
from typing import List, Dict, Any
import json

class IndexManager:
    """Manages the SQLite index for fast queries."""
    
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self._create_schema()
    
    def _create_schema(self):
        """Create index tables if they don't exist."""
        self.conn.executescript('''
            CREATE TABLE IF NOT EXISTS blocks (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                file_path TEXT NOT NULL,
                start_line INTEGER NOT NULL,
                end_line INTEGER NOT NULL,
                attributes TEXT NOT NULL,
                content_hash TEXT NOT NULL,
                created_at TEXT NOT NULL,
                modified_at TEXT NOT NULL
            );
            
            CREATE INDEX IF NOT EXISTS idx_type ON blocks(type);
            CREATE INDEX IF NOT EXISTS idx_file ON blocks(file_path);
            
            CREATE TABLE IF NOT EXISTS block_attributes (
                block_id TEXT NOT NULL,
                key TEXT NOT NULL,
                value TEXT NOT NULL,
                FOREIGN KEY (block_id) REFERENCES blocks(id)
            );
            
            CREATE INDEX IF NOT EXISTS idx_attr_key ON block_attributes(key);
            CREATE INDEX IF NOT EXISTS idx_attr_value ON block_attributes(value);
        ''')
        self.conn.commit()
    
    def update_file_index(self, file_path: str, blocks: List[Block]):
        """Update index for a specific file."""
        # Remove old entries for this file
        self.conn.execute('DELETE FROM blocks WHERE file_path = ?', (file_path,))
        
        # Insert new blocks
        for block in blocks:
            self.conn.execute('''
                INSERT INTO blocks (id, type, file_path, start_line, end_line, 
                                  attributes, content_hash, created_at, modified_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                block.id,
                block.type,
                file_path,
                block.start_line,
                block.end_line,
                json.dumps(block.attributes),
                hash(block.content),
                datetime.now().isoformat(),
                datetime.now().isoformat()
            ))
            
            # Insert attributes for querying
            for key, value in block.attributes.items():
                self.conn.execute('''
                    INSERT INTO block_attributes (block_id, key, value)
                    VALUES (?, ?, ?)
                ''', (block.id, key, value))
        
        self.conn.commit()
    
    def query(self, block_type: Optional[str] = None, 
              attributes: Optional[Dict[str, str]] = None) -> List[Dict[str, Any]]:
        """Query blocks with filters."""
        query = 'SELECT * FROM blocks WHERE 1=1'
        params = []
        
        if block_type:
            query += ' AND type = ?'
            params.append(block_type)
        
        results = []
        for row in self.conn.execute(query, params):
            block_dict = dict(row)
            block_dict['attributes'] = json.loads(block_dict['attributes'])
            
            # Apply attribute filters
            if attributes:
                match = True
                for key, value in attributes.items():
                    if block_dict['attributes'].get(key) != value:
                        match = False
                        break
                if not match:
                    continue
            
            results.append(block_dict)
        
        return results
```

## Context Assembly System

### get-context.sh Implementation

```bash
#!/bin/bash
# get-context.sh - Dual-purpose context assembly tool

set -e

# Configuration
CLAUDEPM_HOME="${CLAUDEPM_HOME:-$HOME/.claudepm}"
CACHE_DIR="$CLAUDEPM_HOME/cache/context"
CACHE_DURATION=300  # 5 minutes

# Helper functions
get_role() {
    if [ -f ".claudepm" ]; then
        jq -r '.claudepm.role // "project"' .claudepm
    else
        echo "project"
    fi
}

include_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo "## $file"
        echo '```markdown'
        cat "$file"
        echo '```'
        echo
    fi
}

include_recent_logs() {
    local count=${1:-5}
    echo "## Recent Logs (last $count entries)"
    echo '```markdown'
    claudepm log list --limit "$count" --format markdown
    echo '```'
    echo
}

include_upcoming_deadlines() {
    local days=${1:-7}
    echo "## Upcoming Deadlines (next $days days)"
    echo '```markdown'
    claudepm task list --deadline-before "+${days}d" --format markdown
    echo '```'
    echo
}

include_blocked_items() {
    echo "## Blocked Items"
    echo '```markdown'
    claudepm task list --status BLOCKED --format markdown
    echo '```'
    echo
}

# Main logic
main() {
    # Check for cached context
    local cache_file="$CACHE_DIR/$(pwd | md5sum | cut -d' ' -f1).md"
    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file"))) -lt $CACHE_DURATION ]; then
        cat "$cache_file"
        return 0
    fi
    
    # Default mode - no arguments
    if [ $# -eq 0 ]; then
        ROLE=$(get_role)
        
        {
            echo "# Claude Context"
            echo "Generated: $(date '+%Y-%m-%d %H:%M')"
            echo "Role: $ROLE"
            echo
            
            case "$ROLE" in
                "manager")
                    include_file "CLAUDE.md"
                    include_file "$CLAUDEPM_HOME/templates/default/manager/CLAUDEPM-MANAGER.md"
                    include_file "ROADMAP.md"
                    include_recent_logs 3
                    include_upcoming_deadlines 7
                    include_blocked_items
                    ;;
                
                "project")
                    include_file "CLAUDE.md"
                    include_file "$CLAUDEPM_HOME/templates/default/project/CLAUDEPM-PROJECT.md"
                    include_file "ROADMAP.md"
                    include_recent_logs 5
                    include_upcoming_deadlines 14
                    ;;
                
                "task-agent")
                    include_file "TASK_PROMPT.md"
                    include_file "../../CLAUDE.md"
                    include_file "$CLAUDEPM_HOME/templates/default/task-agent/CLAUDEPM-TASK.md"
                    cd ../.. && include_recent_logs 10
                    ;;
            esac
        } | tee "$cache_file"
        
        return 0
    fi
    
    # Tool mode - process arguments
    case "$1" in
        --deadlines)
            shift
            days=${1:-7}
            include_upcoming_deadlines "$days"
            ;;
        
        --blocked)
            include_blocked_items
            ;;
        
        --person)
            shift
            person=$1
            echo "## Tasks for @$person"
            echo '```markdown'
            claudepm task list --assignee "$person" --format markdown
            echo '```'
            ;;
        
        --standup)
            echo "# Daily Standup - $(date '+%Y-%m-%d')"
            echo
            include_upcoming_deadlines 3
            include_blocked_items
            include_recent_logs 1d
            ;;
        
        --weekly-report)
            echo "# Weekly Report - Week of $(date '+%Y-%m-%d')"
            echo
            echo "## Completed This Week"
            claudepm task list --status DONE --completed-after '-7d' --format markdown
            echo
            echo "## Active Work"
            claudepm task list --status DOING --format markdown
            echo
            include_blocked_items
            include_upcoming_deadlines 14
            ;;
        
        *)
            echo "Usage: get-context.sh [OPTIONS]"
            echo "  No args          Generate default context based on role"
            echo "  --deadlines [N]  Show deadlines for next N days"
            echo "  --blocked        Show all blocked items"
            echo "  --person NAME    Show tasks for person"
            echo "  --standup        Daily standup bundle"
            echo "  --weekly-report  Weekly report bundle"
            exit 1
            ;;
    esac
}

# Create cache directory
mkdir -p "$CACHE_DIR"

# Run main function
main "$@"
```

## Migration Implementation

### Phase 1: Foundation (Weeks 1-2)

#### 1.1 Core Infrastructure
```bash
# Installation script
#!/bin/bash
# install-v3.sh

echo "Installing claudepm v0.3.0..."

# Create directory structure
mkdir -p ~/.claudepm/{bin,lib,templates/default,cache,logs}

# Copy core files
cp -r src/* ~/.claudepm/
chmod +x ~/.claudepm/bin/claudepm

# Add to PATH
echo 'export PATH="$HOME/.claudepm/bin:$PATH"' >> ~/.bashrc

# Initialize cache database
python3 ~/.claudepm/lib/init_db.py

echo "Installation complete!"
```

#### 1.2 Parser Development
- Implement `BlockParser` class with comprehensive tests
- Add validation rules for each block type
- Create `claudepm doctor` command for validation

#### 1.3 Basic Tools
- Implement `task new`, `task update`, `task list`
- Implement `log add`, `log list`
- Implement `note add`, `note list`
- Create comprehensive test suite

### Phase 2: Migration Tools (Weeks 3-4)

#### 2.1 Legacy Support
```python
class LegacyParser:
    """Parse unstructured markdown using heuristics."""
    
    def parse_tasks(self, content: str) -> List[Dict]:
        """Extract tasks from legacy format."""
        tasks = []
        
        # Look for common patterns
        # - [ ] Task description
        # TODO: Task description
        # ## Task title
        
        for line in content.split('\n'):
            if line.strip().startswith('- [ ]'):
                tasks.append({
                    'title': line.replace('- [ ]', '').strip(),
                    'status': 'TODO'
                })
            elif line.strip().startswith('- [x]'):
                tasks.append({
                    'title': line.replace('- [x]', '').strip(),
                    'status': 'DONE'
                })
        
        return tasks
```

#### 2.2 Migration Command
```bash
claudepm migrate --dry-run  # Preview changes
claudepm migrate --backup   # Create backups before migrating
claudepm migrate --interactive  # Ask for user input on ambiguous items
```

### Phase 3: Advanced Features (Weeks 5-6)

#### 3.1 VS Code Extension
- Syntax highlighting for CPM blocks
- Command palette integration
- Tree view of tasks/notes
- Quick actions (complete task, add log)

#### 3.2 Performance Optimization
- Implement incremental indexing
- Add context caching with TTL
- Optimize queries with prepared statements

#### 3.3 Reporting
```bash
claudepm report weekly > report.md
claudepm report gantt > timeline.html
claudepm report metrics  # Task completion rates, velocity
```

## Testing Strategy

### Unit Tests
```python
# test_parser.py
def test_parse_valid_task_block():
    content = '''<!-- CPM:TASK ID="123" STATUS="TODO" -->
## Test task
Content here
<!-- CPM:END -->'''
    
    parser = BlockParser()
    blocks = parser.parse_string(content)
    
    assert len(blocks) == 1
    assert blocks[0].type == 'TASK'
    assert blocks[0].attributes['STATUS'] == 'TODO'

def test_parse_malformed_block():
    content = '''<!-- CPM:TASK ID="123"
## Missing end marker'''
    
    parser = BlockParser()
    blocks = parser.parse_string(content)
    
    assert len(blocks) == 0  # Should handle gracefully
```

### Integration Tests
```bash
# test_workflow.sh
#!/bin/bash

# Create test project
mkdir -p test_project
cd test_project
claudepm init project

# Create task
task_id=$(claudepm task new "Test task" --json | jq -r '.id')

# Update task
claudepm task update "$task_id" --status DOING

# Add log
claudepm log add "Started work" --refs "$task_id"

# Verify
claudepm task list --id "$task_id" | grep "DOING"
```

## Security Considerations

### File Locking
```python
import fcntl
import contextlib

@contextlib.contextmanager
def file_lock(filepath):
    """Acquire exclusive lock on file."""
    lockfile = f"{filepath}.lock"
    with open(lockfile, 'w') as f:
        try:
            fcntl.flock(f.fileno(), fcntl.LOCK_EX)
            yield
        finally:
            fcntl.flock(f.fileno(), fcntl.LOCK_UN)
            os.unlink(lockfile)
```

### Input Validation
```python
def validate_task_title(title: str) -> str:
    """Validate and sanitize task title."""
    if not title or len(title) > 200:
        raise ValueError("Title must be 1-200 characters")
    
    # Remove any CPM markers to prevent injection
    if 'CPM:' in title or '-->' in title:
        raise ValueError("Title contains invalid characters")
    
    return title.strip()
```

## Performance Targets

- **Parse 1000-line file**: < 100ms
- **Query 10,000 tasks**: < 50ms (with index)
- **Context assembly**: < 200ms (with cache)
- **Tool response time**: < 500ms for any operation

## Error Handling

### User-Friendly Messages
```python
class ClaudePMError(Exception):
    """Base exception with helpful messages."""
    
    def __init__(self, message: str, suggestion: str = None):
        super().__init__(message)
        self.suggestion = suggestion

class ParseError(ClaudePMError):
    """Error parsing markdown structure."""
    pass

# Usage
try:
    block = parser.parse_task(content)
except ParseError as e:
    print(f"Error: {e}")
    if e.suggestion:
        print(f"Suggestion: {e.suggestion}")
```

## Backward Compatibility

### Grace Period
- v0.3.0: Support both old and new formats
- v0.3.5: Deprecation warnings for old format
- v0.4.0: Remove legacy support

### Detection
```python
def detect_format(content: str) -> str:
    """Detect if file uses old or new format."""
    if '<!-- CPM:' in content:
        return 'structured'
    elif re.search(r'^- \[[ x]\]', content, re.MULTILINE):
        return 'legacy_checklist'
    else:
        return 'unstructured'
```

## Documentation

### User Guide Structure
1. **Quick Start**: 5-minute setup and first task
2. **Concepts**: Roles, blocks, context, tools
3. **Command Reference**: All CLI commands
4. **Migration Guide**: Step-by-step from v0.2
5. **API Reference**: Python library usage
6. **Troubleshooting**: Common issues and fixes

### Example Workflows
```markdown
# Daily Workflow

## Morning
1. `claudepm context --standup` - Review status
2. `claudepm task list --status BLOCKED` - Unblock items
3. `claudepm task move <id> DOING` - Start work

## During Work
1. `claudepm log add "Progress update" --refs <task-id>`
2. `claudepm note add "Decision made" --type decision`

## End of Day
1. `claudepm log add "EOD summary" --did "..." --next "..."`
2. `claudepm task list --status DOING` - Review progress
```

## Success Metrics

### Technical
- Parse success rate > 99%
- Query performance < 100ms
- Zero data corruption incidents
- Tool adoption > 80% of operations

### User Experience  
- Setup time < 5 minutes
- Learning curve < 1 hour
- Daily workflow time saved > 30%
- User satisfaction > 4.5/5

## Appendix: Complete Tool Specifications

[The appendix would contain detailed API documentation for every tool, parser method, and configuration option, making this document fully sufficient for implementation]

---

This architecture document provides a complete blueprint for implementing claudepm v0.3.0. Any developer with this document should be able to build the system without additional context.