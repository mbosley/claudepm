# claudepm Template Changelog

Track changes to CLAUDE.md and ROADMAP.md templates that affect existing projects.

## v0.2.6 - 2025-07-04

### Added
- **Human-Readable Task Format**: Complete rewrite of task management system
  - Tasks now use standard markdown checkboxes instead of CPM::TASK format
  - Organized in sections: TODO, IN PROGRESS, BLOCKED, DONE
  - Inline metadata in square brackets: [high], [#tag], [due:2025-01-15], [@alice], [8h]
  - UUID on separate line for easy parsing
- **New Task Commands**:
  - `task start <uuid>` - Move task to IN PROGRESS with timestamp
  - `task update <uuid> [options]` - Update task metadata
  - Enhanced filtering: --overdue, -f/--full for detailed view
- **Automatic Migration**: Old CPM::TASK format automatically converted during upgrade

### Changed
- Task storage format from `CPM::TASK::uuid::STATUS::date::description` to markdown checkboxes
- Task commands now support rich metadata options (-p, -t, -d, -a, -e)
- health_check, adopt_project, find_blocked, get_context, suggest_next all updated for new format
- Task sections are now standard markdown headings for better readability

### Benefits
- Tasks are scannable by humans without needing to parse special formats
- Standard markdown tools can work with task lists
- Easier to manually edit tasks when needed
- Better integration with markdown editors and viewers

## v0.2.6.0 - 2025-07-04

### Added
- **Scope → Setup → Execute Pattern**: New frictionless feature development workflow
  - `/scope-feature` command for structured requirements gathering
  - Guided scoping session with problem statement, requirements, and planning
  - Outputs ready-to-execute TASK_PROMPT for Task Agents
  - Automatic worktree creation with scoped requirements
  - `.scoping/` directory for preserving scoping artifacts (gitignored)
- **Documentation Updates**:
  - Task Agent workflow now mentions `/scope-feature` as preferred method
  - Feature development checklist updated with scope-first approach
  - README includes new "Frictionless Feature Development" section

### Changed
- Fixed outdated `--permission-mode bypassPermissions` flag to `--dangerously-skip-permission`
- Enhanced project template to document the Scope → Setup → Execute meta-pattern
- Updated feature development guidance to prefer scoping for non-trivial features

### Fixed
- Added `.scoping/` to .gitignore for local-only scoping artifacts
- Simplified `lib/scope.sh` to focus on worktree creation (removed interactive CLI mode)
- Added proper error handling and validation to scope.sh

### Benefits
- Reduced friction from idea to implementation-ready Task Agent
- Structured approach to feature requirements gathering
- Better alignment between requirements and implementation
- Historical record of feature scoping decisions in `.scoping/`

## v0.2.5.2 - 2025-07-03

### Changed
- **Simplified logging protocol**: Removed prescriptive options in favor of free-form content
  - `claudepm log "title" "content"` - Structure provided by Claude, not flags
  - Reduced log_work() from 183 to 37 lines
  - Removed time tracking (Claude isn't good at estimating)
- **Protocol philosophy**: "Structure + Freedom"
  - Minimal structure: timestamp, title, consistent format
  - Maximum freedom: Claude decides content format based on context
  - No prescriptive fields or forced categories

### Removed
- All log option flags (--did, --tag, --time, --with, --commit, etc.)
- Time estimation features
- Complex argument parsing

### Benefits
- Simpler code (utils.sh reduced from 820 to 676 lines)
- More natural logging (like taking notes, not filling forms)
- Flexible formatting (Claude adapts to context)
- Easier to maintain and extend

## v0.2.5.1 - 2025-07-03

### Added
- **claudepm as Protocol**: Complete rewrite to teach claudepm as Claude's native protocol
- **New Protocol Commands**:
  - `claudepm context` - Get complete session context on startup
  - `claudepm log <title> [options]` - Rich logging with multiple did items, blockers, and notes
  - `claudepm next` - Suggest what to work on based on state
- **Protocol Layers**: Clear hierarchy from commands to direct file access
- **Evolution Principle**: Protocol grows based on Claude's patterns
- **Ultra-Rich Log Command**: 
  - `--did` flag for multiple accomplishments (repeatable)
  - `--blocked` flag for documenting blockers
  - `--notes` flag for additional context
  - `--tag` flag for searchable keywords/hashtags (repeatable)
  - `--commit` flag for git commit references (repeatable)
  - `--with` flag for people mentions with @-tags (repeatable)
  - `--time` flag for time tracking (e.g., "2h", "30m")
  - `--pr` flag for PR/issue references
  - `--error` flag for error tracking
  - `--decided` flag for decision logging

### Changed
- Templates completely rewritten to teach protocol usage instead of file manipulation
- Emphasized "You MUST use claudepm commands for ALL project memory operations"
- Fixed delimiter parsing bug in task list display (replaced :: with | internally)
- Fixed date resolution in initial LOG.md entries
- Fixed count parsing issues with proper whitespace stripping
- Log command enhanced to support rich formatting matching manual logs

### Fixed
- Task list display now properly handles :: delimiters in descriptions
- Initial log entries now show resolved dates instead of literal $(date) commands
- Count operations no longer throw syntax errors from whitespace

## v0.2.0 - 2025-01-02

### Added
- **Two-File Architecture**: Split CLAUDE.md into custom + managed files
  - CLAUDEPM-PROJECT.md: Generic claudepm instructions (378 lines)
  - CLAUDEPM-MANAGER.md: Generic manager instructions (640 lines)
  - CLAUDEPM-TASK.md: Task Agent specific instructions (107 lines)
- **get-context Helper**: Central script to assemble full context
- **Core Templates Directory**: ~/.claude/core/ for managed templates
- **Migration Support**: /migrate-project command for v0.1.x → v0.2.0
- **Role-Based Loading**: .claudepm "role" field determines which CLAUDEPM file loads

### Changed
- Templates now split: User customizations in CLAUDE.md, generic in CLAUDEPM-*.md
- install.sh creates ~/.claude/core/ and ~/.claude/bin/ directories
- claudepm-admin.sh creates .claudepm with "role": "task-agent" in worktrees
- /doctor command detects legacy format and suggests migration
- Updates now deterministic - just replace files in ~/.claude/core/

### Benefits
- **Deterministic Updates**: No AI needed, just file replacement
- **Preserved Customizations**: User content never touched during updates
- **Faster Updates**: Simple file copy instead of complex parsing
- **Future Extensibility**: New roles just need new CLAUDEPM-*.md files

### Migration
Run `/migrate-project [project-name]` to migrate existing projects.

## v0.1.9 - 2025-01-02

### Added
- **Migration Markers**: Added HTML comment markers to enable future two-file architecture
  - `<!-- CLAUDEPM_CUSTOMIZATION_START -->` and `<!-- CLAUDEPM_CUSTOMIZATION_END -->`
  - Enables v0.2.0 migration path for splitting CLAUDE.md files
  - No functional changes - purely preparatory

### Changed
- Templates now include markers to delineate custom vs managed content
- Project template: Custom section starts at "## Project Context" 
- Manager template: Custom section at end for user additions

## v0.1.8 - 2025-01-02

### Added
- **Automated TASK_PROMPT Generation**: New TASK_PROMPT.template.md for standardized Task Agent mission briefs
- **TASK_PROMPT Archiving**: Completed TASK_PROMPTs automatically archived to .prompts_archive/
- **Enhanced claudepm-admin.sh**: Now generates and archives TASK_PROMPT.md files automatically
- **.gitignore Update**: Added .prompts_archive/ to track completed Task Agent missions

### Changed
- Updated Task Agent workflow to use claudepm-admin.sh for worktree management
- Project Lead workflow now emphasizes automated TASK_PROMPT generation
- Cleanup process now includes automatic TASK_PROMPT archiving

### Benefits
- **Consistency**: Every Task Agent receives a well-structured mission brief
- **Traceability**: Historical record of all Task Agent missions preserved
- **Integration**: Architectural reviews from .api-queries/ automatically included

## v0.1.6 - 2025-07-01

### Added
- Comprehensive Task Agent Development Workflow section
- Local worktrees pattern (worktrees/ instead of ../sibling-dirs)
- /dispatch-task command for easy Task Agent creation
- Security benefits explanation (Claude can't access ../dirs)

### Changed
- All Task Agent documentation now uses local worktrees
- Git Workflow section updated to use worktrees/feature-name
- Emphasized worktrees/ must be in .gitignore

### Fixed
- Claude's directory access limitation by using local worktrees
- Clearer separation of Project Lead vs Task Agent responsibilities

## v0.1.5 - 2025-07-01

### Added
- Reorganized templates into `templates/` directory structure
- Separate `manager/` and `project/` subdirectories for clarity
- Backward compatibility in `/update` command for legacy installations

### Changed
- Template files moved from root to organized structure:
  - `CLAUDE_MANAGER.md` → `templates/manager/CLAUDE.md`
  - `CLAUDE_PROJECT_TEMPLATE.md` → `templates/project/CLAUDE.md`
  - `PROJECT_ROADMAP_TEMPLATE.md` → `templates/project/ROADMAP.md`
- Updated all documentation references to new paths
- Install script now creates subdirectories in user's `.claude/templates/`

### Fixed
- Installer can now run from any directory (uses SCRIPT_DIR)
- Clearer separation between source templates and active files

## v0.1.4 - 2025-07-01

### Added
- Changelog references in template HTML comments
- Version status in /orient command output
- Template versioning explanation in README.md
- Template versioning design rationale in ROADMAP.md

### Changed
- Enhanced integration of template versioning throughout documentation
- Made template versioning a first-class concept rather than implementation detail

## v0.1.3 - 2025-07-01

### Added
- HTML comments in templates clarifying CLAUDE.md vs ROADMAP.md roles
- Structured Notes section in PROJECT_ROADMAP_TEMPLATE.md

### Changed
- Clarified separation: CLAUDE.md = HOW, ROADMAP.md = WHAT & WHY
- Added guidance for where to put philosophy vs instructions

## v0.1.2 - 2025-07-01

### Added
- Append-only logging pattern with command grouping
- Filesystem-level protection for CLAUDE_LOG.md (macOS)
- Automatic `chflags uappnd` in installer and adopt-project
- Documentation about append-only protection

### Changed
- Replaced heredoc pattern with cleaner `{ echo ... } >> file` pattern
- Updated all templates with new append pattern

### Security
- CLAUDE_LOG.md now protected from accidental overwrites at OS level

## v0.1.1 - 2025-06-29

### Added
- Parallel work guidance for branches/worktrees
- Branch name pattern in log entries: `[feature/branch]`
- Merge conflict resolution instructions
- Merge marker entries to explain timeline jumps
- PLANNED vs IMPLEMENTED distinction
- More detailed commit checklist

### Fixed
- Timestamp accuracy with explicit date command
- Log entry examples with better clarity

### Changed
- Expanded "Before committing" section with roadmap update checklist

## v0.1.0 - 2025-06-28

### Initial Release
- Three-document system (CLAUDE.md, CLAUDE_LOG.md, ROADMAP.md)
- Core principles (Edit don't create, append-only logs)
- Basic log format
- Roadmap structure
- Git vs log guidance