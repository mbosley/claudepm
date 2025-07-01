# claudepm - Simple Project Memory for Claude

A minimal memory system that helps Claude maintain context across sessions using just three markdown files per project.

## What is claudepm?

claudepm solves the "Claude has no memory" problem by creating a simple, persistent memory system using markdown files. It enables two levels of Claude operation:

- **Manager Claude** - Orchestrates multiple projects from your root directory
- **Worker Claude** - Focuses on individual project implementation

## Quick Start

```bash
# Clone claudepm
git clone https://github.com/mbosley/claudepm.git
cd claudepm

# Install at your projects root
./install.sh
# When prompted: ~/projects (or wherever you keep your projects)

# Go to your projects directory
cd ~/projects

# Try these commands:
/orient                    # Understand where you are
/adopt-project my-app      # Add claudepm to existing project
/doctor                    # Check health of all projects
```

## How It Works

### 1. Install Once at Projects Root
```bash
cd ~/projects
/path/to/claudepm/install.sh
```

This installs:
- Manager instructions (CLAUDE.md at root)
- Slash commands in .claude/commands/
- Project templates in .claude/templates/

### 2. Use Manager Claude for Orchestration
From `~/projects`, you have access to slash commands:

- `/adopt-project [name]` - Add claudepm to existing project
- `/doctor` - Health check all projects, find outdated templates  
- `/update [project]` - Update project to latest templates
- `/brain-dump` - Process unstructured notes and route to projects
- `/daily-standup` - Morning overview across all projects
- `/weekly-review` - Week summary with patterns and priorities
- `/project-health` - Find stale or blocked projects
- `/orient` - Quick context check

### 3. Use Worker Claude for Implementation
```bash
cd ~/projects/my-web-app
# Claude now reads this project's CLAUDE.md and works at project level
```

## Architecture

```
~/projects/                    # Your projects root (where you install)
├── CLAUDE.md                  # Manager-level instructions
├── CLAUDE_LOG.md             # Manager activity log
├── .claude/                  # claudepm installation
│   ├── commands/            # Slash commands work here
│   │   ├── brain-dump.md
│   │   ├── adopt-project.md
│   │   ├── doctor.md
│   │   └── ... (10 total)
│   └── templates/           # Project templates
│       ├── manager/         # Manager-level templates
│       │   └── CLAUDE.md
│       └── project/         # Project-level templates
│           ├── CLAUDE.md
│           └── PROJECT_ROADMAP.md
│
├── my-web-app/              # Individual project
│   ├── CLAUDE.md           # Project instructions
│   ├── CLAUDE_LOG.md       # Project work history
│   ├── PROJECT_ROADMAP.md  # Plans and current state
│   └── .claudepm           # Metadata (gitignored)
│
└── another-project/         # Another project
    └── ...                  # Same structure
```

## The Three Files

Each project has three markdown files:

1. **CLAUDE.md** - Instructions for how to work on this project
2. **CLAUDE_LOG.md** - Append-only work history (your shared memory)
3. **PROJECT_ROADMAP.md** - Current state, plans, and roadmap

## Common Workflows

### Adding claudepm to Existing Project
```bash
cd ~/projects
/adopt-project my-existing-app
```

This analyzes your project and creates the three files with discovered information.

### Processing Meeting Notes
```bash
/brain-dump
Just had a call. Auth service needs JWT by Friday.
Payment integration blocked on Stripe keys.
Blog post about launch should go out next week.
```

Manager Claude will parse this and update the appropriate project roadmaps.

### Checking Project Health
```bash
cd ~/projects
/doctor

## claudepm Doctor Report
✅ System healthy
⚠️ 2 projects have outdated templates
❌ 1 project missing roadmap
```

### Updating Templates
As claudepm evolves, update your projects:
```bash
/doctor                    # See which need updates
/update my-web-app         # Update specific project
```

## Example Log Entry
```markdown
### 2025-06-29 14:30 - Implemented user authentication
Did: Created login form, Firebase integration, session management
Next: Add password reset functionality
Blocked: Need Firebase credentials from client
```

## Key Principles

- **Install once, use everywhere** - One installation at project root manages all projects
- **Two Claude modes** - Manager (orchestration) and Worker (implementation)
- **Three documents only** - CLAUDE.md, CLAUDE_LOG.md, PROJECT_ROADMAP.md per project
- **Logs are append-only** - Never edit past entries
- **Simple tooling** - Just markdown and slash commands

## Template Versioning

claudepm's templates evolve as we discover better patterns, but your existing projects shouldn't break. Our versioning system ensures:

- **Current version: v0.1.3** (see TEMPLATE_CHANGELOG.md for changes)
- **No forced updates** - Projects continue working with their current templates
- **Backward compatibility** - Updates preserve your customizations
- **Informed decisions** - The changelog explains what you'd gain by updating

### How it works:
1. Each project's `.claudepm` file tracks its template version
2. `/doctor` identifies which projects have outdated templates
3. Review TEMPLATE_CHANGELOG.md to see what's new
4. `/update [project]` refreshes templates while preserving your customizations

### Why this matters:
Without versioning, you'd face an impossible choice: miss out on improvements or risk breaking working projects. Template versioning gives you the best of both worlds - stability when you need it, improvements when you want them.

### Check your version:
```bash
# Check a specific project
cat my-project/.claudepm | grep template_version

# Check all projects at once
/doctor  # Shows which projects need updates
```

## Philosophy

The magic isn't in the tool - it's in establishing consistent patterns that Claude can follow:
- No daemon processes
- No complex state management  
- No external dependencies
- **Architect-first development** - AI-powered planning before implementation
- Just markdown and git

## Contributing

claudepm uses itself for development! Check out our CLAUDE_LOG.md to see how it was built.

## License

MIT License - See LICENSE file for details