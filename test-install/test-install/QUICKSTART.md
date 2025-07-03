# claudepm Quick Start

## 1. Install (30 seconds)
```bash
./install.sh
# When prompted, confirm ~/projects as your directory
```

## 2. Test Manager Claude (1 minute)
```bash
cd ~/projects
code .  # or your editor
```
Ask Claude: "What's the status of my projects?"

## 3. Add to a Project (2 minutes)

Pick any existing project:
```bash
cd ~/projects/your-project
```

Create CLAUDE.md:
```markdown
# Project: Your Project Name

## Start Every Session
1. Read CLAUDE_LOG.md
2. Run git status
3. Look for "Next:" in recent logs

## After Each Work Block
Add to CLAUDE_LOG.md:
```
### [Date] - [What you did]
Did: [Accomplishments]
Next: [Next task]
Blocked: [Any blockers]
```

## Project Context
Type: Web app
Language: Python
Purpose: Does amazing things
```

Create CLAUDE_LOG.md:
```markdown
# Work Log - Your Project

## Project Overview
Brief description of what this project does.

---

### 2024-06-29 - Initial setup
Did: Added Claude memory files
Next: Continue with current feature
```

## 4. Use It

Next time you open this project in Claude:
- Claude reads the log automatically
- You know exactly where you left off
- No more context loss!

## That's literally it. 

Two markdown files. Massive productivity boost.