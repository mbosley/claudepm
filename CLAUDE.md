# Project: claudepm

## Core Principles
1. **Edit, don't create** - Modify existing code rather than rewriting
2. **Small changes** - Make the minimal change that solves the problem
3. **Architect first** - For non-trivial features, use /architect-feature before implementing
4. **Test immediately** - Verify each change before moving on
5. **Preserve what works** - Don't break working features for elegance
6. **CLAUDE_LOG.md is append-only** - Never edit past entries, only add new ones
7. **Commit completed work** - Don't let finished features sit uncommitted

## Start Every Session
1. Read PROJECT_ROADMAP.md - see current state and priorities
2. Read recent CLAUDE_LOG.md - understand last session's work
3. Run git status - see uncommitted work

## After Each Work Block
1. Add to CLAUDE_LOG.md using append-only pattern:
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
} >> CLAUDE_LOG.md
```

**CRITICAL: NEVER use Write or Edit tools on CLAUDE_LOG.md** - only append with >> operator. This prevents accidental history loss.

**macOS Protection**: On macOS, CLAUDE_LOG.md has filesystem-level append-only protection (`uappnd` flag). Write/Edit operations will fail with EPERM. To temporarily remove: `chflags nouappnd CLAUDE_LOG.md`

If working on a feature branch, include branch name:
```
### YYYY-MM-DD HH:MM - [feature/search] - Added log search functionality
```

**Be precise about PLANNED vs IMPLEMENTED:**
- `IMPLEMENTED: Dynamic scoping in manager templates` (code written)
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

## Project-Specific Commands
- Test: `./install.sh` (test installation)
- Check: `ls -la ~/.claude/templates/` (verify templates)
- Version: `cat TEMPLATE_VERSION` (current template version)

## Useful Resources
- Claude Code Best Practices: https://www.anthropic.com/engineering/claude-code-best-practices
- Especially see sections on slash commands and project memory

## Common Patterns to Follow

### When asked to add a feature:
1. First try to modify existing templates
2. Test with manual process before automating
3. Make the smallest change possible
4. Follow this comprehensive checklist:

#### Feature Development Checklist

**0. Architectural Planning (for non-trivial features)**
- [ ] Define the feature clearly - what problem does it solve?
- [ ] Run `/architect-feature` with a comprehensive description
- [ ] **REVIEW: Read Gemini's complete architectural plan carefully**
- [ ] **DECIDE: Approve, adjust, or cancel based on the plan's alignment**
- [ ] Use the plan to guide all subsequent implementation steps

**Note:** Use architect-first for: features touching multiple files, new concepts, refactoring, complex integrations. Skip for: typo fixes, simple doc updates, single-line changes.

**1. Code/Script Updates**
- [ ] Update `install.sh` if feature affects installation
- [ ] Update relevant slash commands in `.claude/commands/`
- [ ] Create new slash commands if needed

**2. Template Updates**
- [ ] Update `CLAUDE.md` (this file!)
- [ ] Update `templates/project/CLAUDE.md` 
- [ ] Update `templates/manager/CLAUDE.md` (if affects manager level)
- [ ] Update `templates/project/PROJECT_ROADMAP.md` (if affects roadmap structure)

**3. Version Management**
- [ ] Bump version in `TEMPLATE_VERSION`
- [ ] Add entry to `TEMPLATE_CHANGELOG.md` with:
  - Version number and date
  - Added/Changed/Fixed sections
  - Clear description of what changed

**4. Documentation Updates**
- [ ] Update `README.md` if feature is user-facing
- [ ] Update `PROJECT_ROADMAP.md`:
  - Move feature from Upcoming to Active Work
  - Mark as completed when done
  - Update "Last updated" timestamp
- [ ] Add examples to relevant templates

**5. Testing Protocol**
- [ ] Test fresh installation
- [ ] Test adoption on existing project
- [ ] Test /update command with new templates
- [ ] Verify slash commands work as expected

**6. Logging and Commit**
- [ ] Add CLAUDE_LOG.md entry using the append pattern
- [ ] Update PROJECT_ROADMAP.md before committing
- [ ] **COMMIT NOW** - Don't wait, commit completed work immediately
- [ ] Push if appropriate (after testing or when requested)

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