# Project Roadmap - claudepm

## Current Status
A minimal memory system for Claude Code using three markdown files. The complete v0.1 system includes CLAUDE.md (instructions), CLAUDE_LOG.md (append-only history), and PROJECT_ROADMAP.md (living state document). Ready for testing with real projects.

## Active Work
- [x] Create basic CLAUDE.md and CLAUDE_LOG.md system
- [x] Add append-only principle to logs
- [x] Add PROJECT_ROADMAP.md as third core document
- [x] Update all templates to include roadmap
- [ ] Test three-document system with real project

## Upcoming

### v0.1 Release (Current)
- [ ] Create GitHub repository
- [ ] Tag v0.1 release
- [ ] Test with real projects

### v0.2 - Basic CLI Tool
- [ ] Create simple bash script with commands:
  - `claudepm init` - Initialize project with all 3 files
  - `claudepm status` - Show all projects status (fix current scanning)
  - `claudepm log` - Add entry interactively
- [ ] Automatic project discovery (find all repos)

### v0.3 - Git Integration
- [ ] Auto-append to log on git commit (git hook)
- [ ] Show uncommitted changes in status
- [ ] Branch awareness in logs
- [ ] Commit message templates using recent logs

### v0.4 - Log Management
- [ ] Log archiving (move old entries to archive)
- [ ] Log search across all projects
- [ ] Maximum log size handling
- [ ] Log entry templates

### v0.5 - Beta Release
- [ ] Interactive setup wizard
- [ ] Stale project detection
- [ ] Weekly recap generation
- [ ] Migration tool for existing projects

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

---
Last updated: 2025-06-29 18:02