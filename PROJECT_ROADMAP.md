# Project Roadmap - claudepm

## Current Status
v0.1 released! 🎉 Available at https://github.com/mbosley/claudepm

A minimal memory system for Claude Code using three markdown files. The complete system includes CLAUDE.md (instructions), CLAUDE_LOG.md (append-only history), and PROJECT_ROADMAP.md (living state document). Now testing with real projects.

## Active Work
- [ ] Make within-project behavior rock solid
  - [ ] Test on 3-5 real projects
  - [ ] Refine templates based on actual use
  - [ ] Ensure Claude consistently follows instructions
  - [ ] Validate the three-document flow works
- [ ] Document best practices from real usage
- [ ] Create v0.1.1 with refinements

## Upcoming

### v0.1 Release (Complete! 🎉)
- [x] Create GitHub repository
- [x] Tag v0.1 release
- [x] Push to https://github.com/mbosley/claudepm

### v0.2 - Perfect the Within-Project Experience
- [ ] Refine templates based on real usage patterns
- [ ] Add project initialization helper (simple script)
- [ ] Create troubleshooting guide
- [ ] Add more examples to templates
- [ ] Test with different project types (web, CLI, library)

### v0.3 - Git Integration
- [ ] Auto-append to log on git commit (git hook)
- [ ] Show uncommitted changes in status
- [ ] Branch awareness in logs
- [ ] Commit message templates using recent logs

### v0.4 - Git Workflow Support
- [ ] Automatic feature branch creation
  - `claudepm feature start [name]` creates branch and logs it
  - Updates PROJECT_ROADMAP.md to track feature branch
- [ ] Pull request integration
  - `claudepm feature pr` creates PR with summary from logs
  - Links PR to roadmap item
- [ ] Branch-aware logging
  - Logs show which branch work was done on
  - Automatic log entry when switching branches
- [ ] Review workflow
  - Template for code review feedback in logs
  - Track PR status in roadmap

### v0.5 - Cross-Project Management (Manager Level)
- [ ] Create claudepm CLI tool with commands:
  - `claudepm init` - Initialize project with all 3 files
  - `claudepm status` - Show all projects status
  - `claudepm recap` - Weekly/daily summaries
- [ ] Automatic project discovery
- [ ] Stale project detection
- [ ] Manager-level dashboard

### v0.6 - Log Management
- [ ] Log archiving (move old entries to archive)
- [ ] Log search (within project first, then across projects)
- [ ] Maximum log size handling
- [ ] Log entry templates

### v0.7 - Beta Release
- [ ] Interactive setup wizard
- [ ] Stale project detection
- [ ] Weekly recap generation
- [ ] Migration tool for existing projects

### Testing Strategy (Needs Design)
- [ ] **Script Testing** (Traditional)
  - Installer creates correct directories
  - Handles existing files properly
  - Works on bash/zsh/fish
  - Error handling for missing dependencies
- [ ] **Template Testing** (Semi-automated)
  - Markdown linting for syntax
  - Required sections present
  - Example entries are valid
  - Timestamp formats correct
- [ ] **Behavioral Testing** (The Hard Part)
  - Mock Claude sessions to test instruction following
  - Create test scenarios: "You haven't seen this project in 2 weeks"
  - Measure: How long to restore context?
  - Test: Does Claude actually append to logs?
  - Test: Does Claude avoid creating new files?
- [ ] **System Testing**
  - Create sandbox with 5-10 mock projects
  - Test manager-level scanning
  - Test status detection (active/stale/blocked)
  - Performance with many projects
- [ ] **Dogfooding**
  - claudepm must manage its own development
  - Every PR must show logs/roadmap updates
  - Real usage is the best test

### Future Ideas (Post-Beta)
- [ ] VS Code extension
- [ ] GitHub Actions integration
- [ ] Project templates by type
- [ ] Export formats

## Completed
- [x] Initial templates created
- [x] Install script working
- [x] Manager level CLAUDE.md installed
- [x] Using claudepm to develop claudepm (meta!)
- [x] Core principles documented
- [x] Three-document system implemented
- [x] Timestamp accuracy solved with date command

## Blocked
None currently

## Notes
- Keep it under 200 lines total
- Resist adding features until proven necessary
- The three-document system (instructions, history, roadmap) provides past/present/process
- Everything is just markdown - no tools, no complexity
- Git workflow features (v0.4) are aspirational - focus on core memory system first
- Features should emerge from real usage patterns, not speculation

### Future Vision: Roadmap as Automation Driver
The PROJECT_ROADMAP.md isn't just documentation - it's structured context for future automation:
- Brain dumps get encoded into actionable features
- Future Claude instances can read roadmap to understand scope
- Enables "work on these features" commands to spawn focused agents
- Markdown format is both human and machine readable
- Rich context preservation enables intelligent task distribution

---
Last updated: 2025-06-29 18:24