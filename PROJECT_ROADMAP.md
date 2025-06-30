# Project Roadmap - claudepm

## Current Status
v0.1 released! 🎉 Available at https://github.com/mbosley/claudepm

A minimal memory system for Claude Code using three markdown files. The complete system includes CLAUDE.md (instructions), CLAUDE_LOG.md (append-only history), and PROJECT_ROADMAP.md (living state document). Now testing with real projects.

## Active Work
- [x] Released v0.1 with comprehensive documentation
- [x] Added roadmap best practices to templates
- [x] Created sub-agent report patterns for Manager Claude
- [x] Added brain dump processing pattern for Manager Claude
- [x] Implemented 6 slash commands as proper .claude/commands/ files
- [x] Added structured report formats for consistency
- [x] Documented PLANNED vs IMPLEMENTED distinction
- [x] Implemented project adoption functionality
- [x] Created /adopt-project slash command
- [x] Designed .claudepm marker file specification
- [x] Fixed /adopt-project to use full template content
- [x] Created .claudepm marker for claudepm itself
- [x] Designed Kanban module and Work Item ID system (future enhancement)
- [x] Created /orient command for instant context awareness
- [x] Added manager-level logging pattern
- [x] Documented parallel sub-agent pattern for efficiency
- [x] Updated installer to create manager CLAUDE_LOG.md
- [x] Added parallel work/merge conflict guidance
- [x] Implemented template version management (/doctor and /update)
- [x] Rewrote README.md with clear architecture explanation
- [x] Created MIT LICENSE file
- [x] Enhanced manager-level logging guidance with examples
- [ ] Test on 3-5 real projects [DUE: 2025-07-05]
- [ ] Test adoption on existing projects
- [ ] Refine templates based on actual usage
- [ ] Create v0.1.1 with any refinements from testing

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
- [ ] **Make claudepm accessible to Claude**
  - Install claudepm to PATH during setup
  - Add fallback: `~/.claudepm/bin/claudepm`
  - Update CLAUDE.md templates with command examples
  - Teach Claude to check if claudepm exists

### v0.3 - Basic Log Search (Critical for Usefulness)
- [ ] **Within-project search**
  - ALREADY WORKS: `grep "pattern" CLAUDE_LOG.md` via Claude
  - FUTURE: `claudepm search [term]` CLI command
  - "Have I seen this error before?"
  - Return relevant log entries with context
- [ ] **Search integration in CLAUDE.md**
  - Teach Claude to search before solving
  - Add search examples to templates
- [ ] **Search-optimized log format**
  - ALREADY WORKS: Consistent patterns in our templates
  - Error format: `Error: [category] - detailed message`
  - Solution format: `Solved: [what] by [how]`
  - Decision format: `Decided: [choice] because [reasoning]`
  - Tags for filtering: #error #solution #decision #blocker

### v0.4 - Robust Installation & Discovery
- [ ] Enhanced installer
  - Install at root projects directory (configurable)
  - Interactive wizard with directory selection
  - Detect existing claudepm installation
- [ ] **Existing project adaptation**
  - ALREADY WORKS: Manual adoption via Manager Claude instructions
  - ALREADY WORKS: /adopt-project slash command
  - IMPLEMENTED: .claudepm marker file specification
  - FUTURE: `claudepm adopt [project]` CLI command
  - Sub-agent analyzes repo (tech stack, recent commits, README)
  - Generate initial PROJECT_ROADMAP.md based on analysis
  - Show summary for user confirmation before creating files
- [ ] **Metadata tracking**
  - .claudepm marker file in each project (local-only)
  - Central registry at ~/.claudepm/projects.json
  - Track initialization status and versions
  - Support for checking if projects need updates
- [ ] Doctor command
  - `claudepm doctor` - Health check for installation
  - List all projects in directory
  - Show which have claudepm installed
  - Identify incomplete installations
  - Check for outdated templates

### v0.5 - Cross-Project Basics
- [ ] Create claudepm CLI tool with commands:
  - `claudepm init` - Initialize new project with all 3 files
  - `claudepm status` - Show all projects status
  - `claudepm list` - List all projects with claudepm
- [ ] Automatic project discovery
- [ ] Basic multi-project status view

### v0.6 - Advanced Search & Intelligence
- [ ] **Cross-project search** 
  - Search all projects for similar problems
  - "How did I solve auth in other projects?"
  - Learn from past implementations
- [ ] **Smart search features**
  - Search by type: errors, blockers, solutions
  - Search by date range
  - Search in specific sections (Did/Next/Blocked)
- [ ] **Search from Claude**
  - Claude can search logs before attempting solutions
  - Reduces repeating past mistakes
  - Builds on accumulated knowledge

### v0.7 - Manager Intelligence & Commands
- [ ] Advanced status commands:
  - `claudepm recap` - Weekly/daily summaries
  - `claudepm health` - Project health check
- [ ] Stale project detection
- [ ] Manager Claude slash commands
  - `/daily-standup` - What's on deck today across all projects?
  - `/daily-review` - What got done today? What's blocked?
  - `/weekly-review` - Week summary, completed items, next week priorities
  - `/project-health` - Which projects need attention?
  - `/start-work [project]` - Quick briefing before diving into project
  - `/brain-dump` - Process unstructured updates and route to projects
- [ ] Sub-agent report generation pattern
  - Manager spawns one agent per project for deep analysis
  - Each agent reads three documents + git history
  - Reports synthesized for cross-project insights
  - Dynamic scoping: daily = today only, weekly = 7 days, etc.
  - Efficient log filtering with grep by date patterns
- [ ] **Brain Dump Processing** (Intelligent Inbox)
  - ALREADY WORKS: Manager Claude can manually process brain dumps using documented patterns
  - ALREADY WORKS: Sub-agent spawning via Task tool to update roadmaps
  - FUTURE: CLI command `claudepm inbox "update text"` for convenience
  - FUTURE: Automated report saving after processing
  - FUTURE: Batch processing of multiple updates
  - NOTE: Core functionality works today through Claude's intelligence, not code
- [ ] **Manager Report Persistence** (Hierarchical Memory)
  - Save daily summaries to `~/.claudepm/reports/daily/YYYY-MM-DD.md`
  - Save weekly summaries to `~/.claudepm/reports/weekly/`
  - Monthly reports can aggregate daily summaries
  - Makes manager insights searchable over time
  - Enables trend analysis: "What were common blockers last month?"

### v0.8 - Git Integration
- [ ] Auto-append to log on git commit (git hook)
- [ ] Show uncommitted changes in status
- [ ] Branch awareness in logs
- [ ] Commit message templates using recent logs

### v0.9 - Git Workflow Support
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

### v1.0 - Log Management & Beta Release
- [ ] Log archiving (move old entries to archive)
- [ ] Maximum log size handling
- [ ] Log entry templates
- [ ] Log compression for old entries
- [ ] Interactive setup wizard
- [ ] Migration tool for existing projects
- [ ] Full documentation
- [ ] Example workflows

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
- [ ] **Kanban Module** (Optional Enhancement)
  - Visual project state using markdown-based boards
  - Core insight: PROJECT_ROADMAP.md already IS a kanban board (Upcoming=Backlog, Active=In Progress)
  - Kanban as a VIEW of existing data, not new storage
  - `/kanban` command renders roadmap as board
  - `/kanban-all` shows cross-project board
  
- [ ] **Work Item ID System** (Enables Kanban & Traceability)
  - Structured IDs: [TYPE-##] (FEAT-01, BUG-15, TASK-03)
  - Metadata in HTML comments: <!--- ID: AUTH-01 | STARTED: 2025-06-29 -->
  - IDs flow through roadmap → logs → git commits
  - Enables full traceability: "Show me everything about AUTH-01"
  - Worker Claude rules for state transitions
  - Cross-referencing pattern:
    - Roadmap: <!--- ID: AUTH-01 | STARTED: date -->
    - Logs: "Working on: AUTH-01 - Description"
    - Commits: "feat(AUTH-01): Add JWT token generation"
  - Powerful queries: timeline per feature, velocity tracking, bottleneck detection
  - Manager Claude can show cross-project patterns (e.g., all AUTH work across projects)

## Completed

### v0.1 Development (2025-06-29)
- [x] Initial templates created
- [x] Install script working
- [x] Manager level CLAUDE.md installed
- [x] Using claudepm to develop claudepm (meta!)
- [x] Core principles documented
- [x] Three-document system implemented
- [x] Timestamp accuracy solved with date command
- [x] GitHub repository created and pushed
- [x] Comprehensive roadmap through v1.0
- [x] Search-optimized log format designed
- [x] Git branching strategy mapped to versions
- [x] Manager sub-agent patterns documented
- [x] Dynamic scoping for reports added
- [x] Slash commands properly implemented in .claude/commands/ (10 commands)
- [x] Brain dump processing pattern documented and tested
- [x] Structured report formats for all report types
- [x] PLANNED vs IMPLEMENTED distinction documented
- [x] Claude Code best practices link added as resource
- [x] Project adoption functionality with /adopt-project command
- [x] .claudepm marker file specification
- [x] 48 log entries documenting the journey

## Blocked
None currently

## Notes
- Keep it under 200 lines total
- Resist adding features until proven necessary
- The three-document system (instructions, history, roadmap) provides past/present/process
- Everything is just markdown - no tools, no complexity
- Git workflow features (v0.4) are aspirational - focus on core memory system first
- Features should emerge from real usage patterns, not speculation

### What Already Works (No CLI Needed)
- **Slash commands**: /brain-dump, /daily-standup, /daily-review, /weekly-review, /project-health, /start-work, /adopt-project, /orient, /doctor, /update
- **Brain dump processing**: Manager Claude follows documented patterns to parse and route updates
- **Project adoption**: Manager Claude can analyze and adopt existing projects
- **Quick orientation**: /orient instantly tells Claude their role and context
- **Deadline scanning**: Simple bash loops + grep find all [DUE:] dates
- **Sub-agent reports**: Claude's Task tool spawns focused agents for each project
- **Log searching**: grep commands work for finding patterns
- **Multi-project status**: Bash loops show overview across all projects

The power is in Claude's intelligence + simple markdown patterns, not complex tooling!

### .claudepm Marker File Specification

Each claudepm-managed project contains a `.claudepm` file (gitignored) that tracks:

```json
{
  "claudepm": {
    "version": "0.1",              // claudepm version that created this
    "template_version": "0.1.1",   // template version in use
    "initialized": "2025-06-29T20:30:00Z",
    "last_template_update": "2025-06-29T20:30:00Z"
  },
  "project": {
    "adopted": true,               // false if created new, true if adopted
    "type": "node-web-api",        // discovered project type
    "language": "javascript",      // primary language
    "discovered_commands": {
      "test": "npm test",
      "build": "npm run build",
      "run": "npm start"
    }
  },
  "metadata": {
    "imported_todos": 5,           // if adopted
    "has_roadmap": true,           // found existing roadmap
    "last_activity_check": "2025-06-29T20:30:00Z"
  }
}
```

This enables:
- Quick identification of managed projects
- Version tracking for updates
- Adoption history and discovered features
- Future migration support

### Git Branching Strategy for Roadmap

Each version becomes a feature branch:
```
main
├── feature/v0.2-perfect-experience
├── feature/v0.3-basic-search  
├── feature/v0.4-installation
├── feature/v0.5-cross-project
└── feature/v0.6-advanced-search
```

Workflow:
1. `git checkout -b feature/v0.2-perfect-experience`
2. Work on all v0.2 features
3. PR back to main when complete
4. Tag release: `git tag v0.2`
5. Start next: `git checkout -b feature/v0.3-basic-search`

Benefits:
- Clear scope per branch
- Can work on multiple versions in parallel
- Easy to track progress
- PRs document each version's changes
- Roadmap items map directly to git history

### Future Vision: Roadmap as Automation Driver
The PROJECT_ROADMAP.md isn't just documentation - it's structured context for future automation:
- Brain dumps get encoded into actionable features
- Future Claude instances can read roadmap to understand scope
- Enables "work on these features" commands to spawn focused agents
- Markdown format is both human and machine readable
- Rich context preservation enables intelligent task distribution

### How Claude Accesses claudepm Commands

Two-part strategy for Claude integration:

1. **Installation puts claudepm in standard location**:
   ```bash
   # Primary: /usr/local/bin/claudepm (requires sudo)
   # Fallback: ~/.claudepm/bin/claudepm (no sudo needed)
   # Last resort: ~/projects/.claudepm/bin/claudepm
   ```

2. **CLAUDE.md teaches Claude to use it**:
   ```markdown
   ## Using claudepm
   Check if available: `which claudepm || echo "Using fallback"`
   Fallback: `~/.claudepm/bin/claudepm [command]`
   
   Common commands:
   - `claudepm search "error message"` - Search logs
   - `claudepm status` - Check all projects
   - `claudepm log` - Add log entry
   ```

This ensures Claude can always find and use claudepm commands via Bash tool.

### Why Log Search is Critical
Log search transforms claudepm from a memory system to a knowledge system:
- "Have I seen this error before?" → Find past solutions instantly
- "How did I implement auth last time?" → Reuse successful patterns
- Accumulated knowledge across all projects becomes searchable
- Claude can search before attempting solutions, avoiding repeated mistakes
- The more you use claudepm, the smarter it gets

### Search-Optimized Log Format Ideas
Example of searchable log entry:
```
### 2025-06-29 18:50 - Fixed authentication bug #error #solution
Did: 
- Error: [Auth] - "TypeError: Cannot read property 'user' of undefined"
- Debugged: User object not initialized in session
- Solved: Initialize empty user object in middleware by adding `req.session.user = req.session.user || {}`
- Tested: Login flow now works correctly
Next: Add proper TypeScript types for session
Tags: #authentication #session #middleware #typescript
```

Key patterns for search:
- Error: [category] - "exact error message"
- Solved: [problem] by [solution]
- Decided: [choice] because [reasoning]
- Command: `exact command used`
- Tags: #category #technology #concept

---
Last updated: 2025-06-30 15:16