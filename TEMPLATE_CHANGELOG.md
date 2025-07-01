# claudepm Template Changelog

Track changes to CLAUDE.md and PROJECT_ROADMAP.md templates that affect existing projects.

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
  - `PROJECT_ROADMAP_TEMPLATE.md` → `templates/project/PROJECT_ROADMAP.md`
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
- Template versioning design rationale in PROJECT_ROADMAP.md

### Changed
- Enhanced integration of template versioning throughout documentation
- Made template versioning a first-class concept rather than implementation detail

## v0.1.3 - 2025-07-01

### Added
- HTML comments in templates clarifying CLAUDE.md vs PROJECT_ROADMAP.md roles
- Structured Notes section in PROJECT_ROADMAP_TEMPLATE.md

### Changed
- Clarified separation: CLAUDE.md = HOW, PROJECT_ROADMAP.md = WHAT & WHY
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
- Three-document system (CLAUDE.md, CLAUDE_LOG.md, PROJECT_ROADMAP.md)
- Core principles (Edit don't create, append-only logs)
- Basic log format
- Roadmap structure
- Git vs log guidance