# Project: claudepm

<!-- This file contains claudepm-specific development instructions -->
<!-- Core claudepm instructions are automatically loaded from CLAUDEPM-PROJECT.md -->

## Project Context
Type: Developer tool / Meta project management system
Language: Bash, Markdown
Purpose: Simple memory system for Claude Code sessions

## Project-Specific Commands
- Test: `./install.sh` (test installation)
- Check: `ls -la ~/.claude/templates/` (verify templates)
- Version: `cat VERSION` (current template version)

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

**0. Feature Scoping and Planning (for non-trivial features)**
- [ ] Define the feature clearly - what problem does it solve?
- [ ] For structured scoping: Run `/scope-feature` for guided requirements gathering
- [ ] For architectural review: Run `/architect-feature` with a comprehensive description
- [ ] **REVIEW: Read the complete plan carefully**
- [ ] **DECIDE: Approve, adjust, or cancel based on the plan's alignment**
- [ ] Use the plan to guide all subsequent implementation steps

**Note:** Use scope-first for: new features, user-facing changes, workflow improvements. Use architect-first for: features touching multiple files, new concepts, refactoring, complex integrations. Skip both for: typo fixes, simple doc updates, single-line changes.

**1. Code/Script Updates**
- [ ] Update `install.sh` if feature affects installation
- [ ] Update relevant slash commands in `.claude/commands/`
- [ ] Create new slash commands if needed

**2. Template Updates**
- [ ] Update `CLAUDE.md` (this file!)
- [ ] Update `templates/project/CLAUDE.md` 
- [ ] Update `templates/manager/CLAUDE.md` (if affects manager level)
- [ ] Update `templates/project/ROADMAP.md` (if affects roadmap structure)

**3. Version Management**
- [ ] Bump version in `VERSION`
- [ ] Add entry to `CHANGELOG.md` with:
  - Version number and date
  - Added/Changed/Fixed sections
  - Clear description of what changed

**4. Documentation Updates**
- [ ] Update `README.md` if feature is user-facing
- [ ] Update `ROADMAP.md`:
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
- [ ] Add LOG.md entry using the append pattern
- [ ] Update ROADMAP.md before committing
- [ ] **COMMIT NOW** - Don't wait, commit completed work immediately
- [ ] Push if appropriate (after testing or when requested)

### Before committing:
1. **ALWAYS update ROADMAP.md first**
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
- **Feature plans** → ROADMAP.md Upcoming section
- **Design decisions** → ROADMAP.md Notes section  
- **Development tips** → This file (CLAUDE.md)
- **User guides** → README.md or QUICKSTART.md
- **Work history** → LOG.md

Examples of files NOT to create: BETA_FEATURES.md, ARCHITECTURE.md, DESIGN.md, TODO.md

## Handling Parallel Work

When merging LOG.md conflicts from branches/worktrees:
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

## Task Agent Development Workflow

**CRITICAL:** The Project Lead **MUST** stay on the `dev` branch. All worktree operations **MUST** be performed using the `./tools/claudepm-admin.sh` script to prevent errors.

This workflow enables isolated feature development using git worktrees within the project directory.

### Three-Level Claude Hierarchy

1. **Manager Claude** (e.g., ~/projects/)
   - Lives at the top-level projects directory
   - Coordinates across multiple projects
   - Never implements features directly

2. **Project Lead Claude** (e.g., ~/projects/claudepm/ on dev branch)
   - Lives in a specific project directory
   - Always stays on the dev branch
   - Dispatches Task Agents for features
   - Reviews PRs and manages merges

3. **Task Agent Claude** (e.g., ~/projects/claudepm/worktrees/add-search/)
   - Lives in temporary worktrees within the project
   - Implements specific features in isolation
   - Creates PRs back to dev
   - Gets terminated after merge

### Visual Role Indicators (Recommended)

To avoid confusion between Project Lead and Task Agent roles, add the following function to your shell profile (`~/.bashrc`, `~/.zshrc`). This will change your command prompt to clearly display your current role.

**Add this to your `~/.bashrc` or `~/.zshrc`:**
```bash
function claudepm_ps1() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
        if [[ "$branch" == "dev" ]]; then
            PS1="[PROJECT LEAD @ dev] \$ "
        elif [[ "$branch" == "main" ]]; then
            PS1="[!!! MAIN BRANCH !!!] \$ "
        elif [[ "$branch" =~ ^feature/ ]]; then
            PS1="[TASK AGENT @ $branch] \$ "
        else
            PS1="[$branch] \$ "
        fi
    else
        # Default prompt if not in a git repo
        PS1="\h:\W \u\$ "
    fi
}
# For Bash, set the prompt command
PROMPT_COMMAND="claudepm_ps1"

# For Zsh, use precmd hook
# precmd() { claudepm_ps1 }
```

After adding this, source your profile (`source ~/.bashrc`) or open a new terminal. Your prompt will now look like this:
- **Project Lead:** `[PROJECT LEAD @ dev] $`
- **Task Agent:** `[TASK AGENT @ feature/add-search] $`

Remember: The log is our shared memory. Write clearly for your future self.