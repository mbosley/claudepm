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

1. Read CLAUDE_LOG.md at manager level (if exists)
2. Check for recent manager-level activities
3. Run quick status check or use /orient

## After Each Manager Work Session

Add to CLAUDE_LOG.md at this level:
```
### YYYY-MM-DD HH:MM - [Manager activity]
Did: [What coordination/analysis/routing was done]
Projects affected: [List projects touched]
Next: [What manager-level work is needed]
```

Example:
```
### 2025-06-29 21:00 - Processed brain dump and weekly review
Did:
- ROUTED: 3 updates to auth-service, 2 to blog project
- IDENTIFIED: payment-api blocked on Stripe keys
- GENERATED: Weekly review showing 80% velocity
Projects affected: auth-service, blog, payment-api
Next: Follow up on Stripe key blocker with client
```

## Generating Detailed Project Reports

**IMPORTANT: Use parallel sub-agents to avoid context overload**

When analyzing multiple projects, spawn agents IN PARALLEL:
```python
# Good - Parallel execution
Task: "Daily review for auth-service" 
Task: "Daily review for blog"
Task: "Daily review for payment-api"
# All three run simultaneously

# Bad - Sequential loading
for project in projects:
    read_entire_project_history()  # Context overload!
```

For comprehensive project summaries, spawn sub-agents with dynamic scope:

### Daily Standup (Morning)
```bash
claude -p "You are in [project] directory. For DAILY STANDUP:
1. Read PROJECT_ROADMAP.md Active Work section
2. Read CLAUDE_LOG.md - only last 3 entries or yesterday's entries
3. Identify: What's planned for today based on 'Next:' items
4. Report using this format:
   **[Project Name] - Daily Standup**
   Today's Focus: [1-2 sentences on priorities]
   Key Items: [List 2-3 specific tasks from Next: entries]"
```

### Daily Review (Evening)
```bash
claude -p "You are in [project] directory. For DAILY REVIEW:
1. Read PROJECT_ROADMAP.md for context
2. Read CLAUDE_LOG.md - ONLY entries from today ($(date +%Y-%m-%d))
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
1. Read PROJECT_ROADMAP.md - note completed items
2. Read CLAUDE_LOG.md - entries from last 7 days
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
1. Check PROJECT_ROADMAP.md Blocked section
2. Search CLAUDE_LOG.md for recent 'Blocked:' entries
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
1. Read CLAUDE_LOG.md focusing on Error:, Solved:, and Notes: sections
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

**Note**: These commands are stored in `.claude/commands/*.md` and can be customized or extended.
See https://www.anthropic.com/engineering/claude-code-best-practices for more on slash commands.

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

**PROJECT_ROADMAP.md**: Import existing TODOs and infer from recent commits
```markdown
## Current Status
[Summarize from README and recent commits]

## Active Work
[Import any TODO/FIXME comments found]
[Infer from recent commit messages]

## Upcoming
[Any roadmap/TODO files content]
```

**CLAUDE_LOG.md**: First entry documenting adoption
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

When updating any PROJECT_ROADMAP.md:
- **Version features**: Group into v0.1, v0.2, etc. (future git branches)
- **Make actionable**: "Add auth" → "Add JWT authentication with refresh tokens"
- **Include why**: Brief rationale for each feature
- **Think PR-sized**: Each version should be one coherent pull request
- **Enable automation**: Clear enough that "work on v0.2" is unambiguous

**Before ANY commit**: Always check if PROJECT_ROADMAP.md needs updating:
- Have you completed items that should move to Completed?
- Are there new tasks discovered during work?
- Has the Current Status changed?
- Update "Last updated" timestamp

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
grep "^### $(date +%Y-%m-%d)" CLAUDE_LOG.md -A 20

# This week's entries
for i in {0..6}; do
  date -d "$i days ago" +%Y-%m-%d
done | xargs -I {} grep "^### {}" CLAUDE_LOG.md -A 20

# Last N entries
tail -n 100 CLAUDE_LOG.md | awk '/^###/{p=1} p'
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
3. Spawn sub-agent to update that project's PROJECT_ROADMAP.md
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
Update PROJECT_ROADMAP.md:
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