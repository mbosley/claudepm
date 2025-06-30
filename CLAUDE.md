# Project: claudepm

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
### YYYY-MM-DD HH:MM - [feature/search] - Added log search functionality
```

**Be precise about PLANNED vs IMPLEMENTED:**
- `IMPLEMENTED: Dynamic scoping in CLAUDE_MANAGER.md` (code written)
- `PLANNED: Manager report persistence in roadmap` (added to roadmap)
- `DOCUMENTED: Sub-agent patterns in templates` (docs updated)
- `FIXED: Timestamp accuracy with date command` (bug resolved)

2. Update PROJECT_ROADMAP.md:
- Check off completed items
- Move items between sections as needed
- Add any new discoveries
- Update "Last updated" date

## Project Context
Type: Developer tool / Meta project management system
Language: Bash, Markdown
Purpose: Simple memory system for Claude Code sessions

## Project Philosophy
- **Start dead simple** - Just markdown files
- **One feature at a time** - Add only after real need proven
- **Test on ourselves** - claudepm manages claudepm development
- **Resist complexity** - Every addition must justify itself

## Development Approach
1. Use claudepm to develop claudepm (meta!)
2. Feel the friction points personally
3. Only add features we've needed multiple times
4. Keep the core under 200 lines total

## Useful Resources
- Claude Code Best Practices: https://www.anthropic.com/engineering/claude-code-best-practices
- Especially see sections on slash commands and project memory

## Common Patterns to Follow

### When asked to add a feature:
1. First try to modify existing templates
2. Test with manual process before automating
3. Make the smallest change possible
4. Update our own CLAUDE_LOG.md

### Before committing:
1. **ALWAYS update PROJECT_ROADMAP.md first**
2. Move completed items to Completed section
3. Update Active Work with current state
4. Check if any version milestones are complete
5. Then write commit message that accurately reflects changes

### When something isn't working:
1. Check if it's a behavioral issue (update CLAUDE.md)
2. Check if it's a process issue (update README)
3. Only then consider code changes

### When tempted to create a new file:
- Can this guidance live in existing templates?
- Are we solving a real problem or imagined one?
- Have we hit this issue more than twice?

### CRITICAL: Where claudepm content goes
- **Feature plans** → PROJECT_ROADMAP.md Upcoming section
- **Design decisions** → PROJECT_ROADMAP.md Notes section  
- **Development tips** → This file (CLAUDE.md)
- **User guides** → README.md or QUICKSTART.md
- **Work history** → CLAUDE_LOG.md

Examples of files NOT to create: BETA_FEATURES.md, ARCHITECTURE.md, DESIGN.md, TODO.md

## Handling Parallel Work

When merging CLAUDE_LOG.md conflicts from branches/worktrees:
1. Keep BOTH sections (yours and theirs)
2. Add a merge marker entry
3. Continue from the most recent Next: entry

Example merge marker:
```
### YYYY-MM-DD HH:MM - Merged parallel work
Did: Merged logs from feature/v0.2 and feature/v0.3 branches
Next: Continue v0.3 search implementation
Notes: Parallel work on template improvements and search feature
```

Remember: The log is our shared memory. Write clearly for your future self.