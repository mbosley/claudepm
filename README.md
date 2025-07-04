# claudepm - Simple Project Memory for Claude

A minimal memory system that helps Claude maintain context across sessions using just three markdown files per project. Features optional AI-powered architecture planning and isolated feature development workflows.

## What is claudepm?

claudepm solves the "Claude has no memory" problem by creating a simple, persistent memory system using markdown files. It enables three levels of Claude operation:

- **Manager Claude** - Orchestrates multiple projects from your root directory
- **Project Lead Claude** - Manages features and reviews within a project
- **Task Agent Claude** - Implements specific features in isolated environments

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

### 3. Use Project Lead Claude for Feature Management
```bash
cd ~/projects/my-web-app
```

At the project level, you can:

- `/scope-feature [name]` - Structured feature scoping with guided requirements gathering
- `/architect-feature` - Plan complex features with AI assistance
- `/dispatch-task [feature]` - Create isolated worktrees for Task Agents
- `/email-check` - Process project-specific emails and update roadmap
- Manage PRs and coordinate multiple feature implementations
- Manage tasks with human-readable markdown format

### Task Management

claudepm includes a built-in task management system that uses human-readable markdown format in your ROADMAP.md file.

#### Adding Tasks
```bash
# Simple task
claudepm task add "Fix authentication bug"

# Task with metadata
claudepm task add "Implement search" -p high -t feature -t search -d 2025-01-15 -e 2d

# Full example with all options
claudepm task add "Refactor database layer" \
  -p medium \
  -t backend -t refactor \
  -d 2025-02-01 \
  -a @alice \
  -e 1w
```

#### Task Format
Tasks are stored in a human-readable markdown format:
```markdown
## Tasks

### TODO
- [ ] Fix authentication bug [high] [#auth] [due:2025-01-15] [@alice] [8h]
  ID: e9ad54d0-b374-4265-a446-50b9d505de79

### IN PROGRESS
- [ ] Implement search functionality [high] [#search, #feature] [started:2025-01-04]
  ID: f8bc34e1-c485-5376-b557-61cad606e68a

### BLOCKED
- [ ] Deploy to production [blocked:AWS credentials needed]
  ID: b8de45g1-e697-5498-d779-83ecd828g8ac

### DONE
- [x] Set up CI/CD pipeline [completed:2025-01-03]
  ID: c9ef56h2-f7a8-6509-e88a-94fde939h9bd
```

#### Task Commands
```bash
# List all tasks
claudepm task list

# Filter tasks
claudepm task list --todo           # Show only TODO tasks
claudepm task list --in-progress    # Show tasks being worked on
claudepm task list -p high          # Filter by priority
claudepm task list -t bug           # Filter by tag
claudepm task list --overdue        # Show overdue tasks
claudepm task list -f               # Show full details

# Start working on a task
claudepm task start <uuid>          # Moves to IN PROGRESS

# Complete a task
claudepm task done <uuid>           # Marks as complete

# Block a task
claudepm task block <uuid> "Waiting for API keys"

# Update task metadata
claudepm task update <uuid> -p high -d 2025-01-20
```

#### Migration from Old Format
If you have existing tasks in the old `CPM::TASK` format, they will be automatically migrated when you run `claudepm upgrade`.

### 4. Deploy Task Agents for Implementation
```bash
# Create and dispatch a Task Agent for a feature
/dispatch-task add-user-auth

# Or use the automated admin script
./tools/claudepm-admin.sh create-worktree feature-name
```

Task Agents work in isolated `worktrees/` directories, implementing features without affecting the main codebase until PR review.

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
│   │   └── ... (13 total)
│   └── templates/           # Project templates
│       ├── manager/         # Manager-level templates
│       │   └── CLAUDE.md
│       └── project/         # Project-level templates
│           ├── CLAUDE.md
│           ├── ROADMAP.md
│           └── TASK_PROMPT.template.md
│
├── my-web-app/              # Individual project
│   ├── CLAUDE.md           # Project instructions
│   ├── CLAUDE_LOG.md       # Project work history
│   ├── ROADMAP.md  # Plans and current state
│   ├── .claudepm           # Metadata (gitignored)
│   ├── tools/              # Utility scripts
│   │   ├── claudepm-admin.sh # Git worktree management
│   │   └── get-timestamp.sh  # Timestamp helper
│   ├── worktrees/          # Task Agent workspaces (gitignored)
│   │   └── add-auth/       # Feature implementation
│   │       └── TASK_PROMPT.md
│   └── .prompts_archive/   # Completed Task Agent missions
│       └── 2025-01-02-add-auth.md
│
└── another-project/         # Another project
    └── ...                  # Same structure
```

## The Three Files

Each project has three markdown files:

1. **CLAUDE.md** - Instructions for how to work on this project
2. **CLAUDE_LOG.md** - Append-only work history (your shared memory)
3. **ROADMAP.md** - Current state, plans, and roadmap

## Common Workflows

### Adding claudepm to Existing Project
```bash
cd ~/projects
/adopt-project my-existing-app
```

This analyzes your project and creates the three files with discovered information.

### Frictionless Feature Development

The Scope → Setup → Execute pattern reduces friction from idea to implementation:

```bash
# 1. Scope: Structured requirements gathering
/scope-feature user-notifications

# 2. Setup: Worktree automatically created with TASK_PROMPT
# 3. Execute: Task Agent implements autonomously
cd worktrees/user-notifications
claude --dangerously-skip-permission
```

Note: The `/scope-feature` slash command handles the scoping workflow. A future `claudepm scope` CLI command may provide this from the command line.

### Processing Meeting Notes
```bash
/brain-dump
Just had a call. Auth service needs JWT by Friday.
Payment integration blocked on Stripe keys.
Blog post about launch should go out next week.
```

Manager Claude will parse this and update the appropriate project roadmaps.

### Structured Feature Development

claudepm provides a frictionless workflow from idea to implementation:

#### 1. Scope the Feature
```bash
cd ~/projects/my-app
/scope-feature real-time-collab

# Guided prompts:
> What problem does this solve?
Users can't see who else is editing...

> Key requirements?
1. WebSocket connection management
2. Presence indicators
3. Conflict resolution
```

The scoping session outputs a complete TASK_PROMPT ready for execution.

#### 2. Architectural Review (for complex features)
```bash
/architect-feature

I need to add real-time collaboration with WebSockets, 
including presence indicators and conflict resolution.
```

Gemini will analyze your codebase and provide a complete architectural plan.

#### 3. Execute with Task Agent
```bash
# After scoping, the worktree is ready
cd worktrees/real-time-collab
claude --dangerously-skip-permission
# "You are a Task Agent. Read TASK_PROMPT.md and implement."
```

### Deploying Task Agents
```bash
# Option 1: Use the scope workflow (recommended for non-trivial features)
/scope-feature add-websockets
# ... go through scoping process ...

# Option 2: Direct worktree creation (for simple tasks)
./tools/claudepm-admin.sh create-worktree add-websockets

# Start new Claude conversation with generated TASK_PROMPT
cd worktrees/add-websockets
claude --dangerously-skip-permission
# "You are a Task Agent. Read TASK_PROMPT.md and implement."

# After PR merge
./tools/claudepm-admin.sh remove-worktree add-websockets
```

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
- **Three Claude modes** - Manager (orchestration), Project Lead (review), Task Agent (implementation)
- **Three documents only** - CLAUDE.md, CLAUDE_LOG.md, ROADMAP.md per project
- **Logs are append-only** - Never edit past entries
- **Simple tooling** - Just markdown and slash commands
- **Architect-first development** - AI assistance for planning complex features

## Two-File Architecture (v0.2.0)

Starting with v0.2.0, claudepm uses a two-file architecture that separates generic instructions from your customizations:

- **CLAUDE.md** - Your project-specific customizations (small file, ~20 lines)
- **CLAUDEPM-*.md** - Generic claudepm instructions (managed centrally)

### Benefits:
- **Deterministic updates** - No AI needed, just replace core files
- **Preserved customizations** - Your content is never touched
- **Faster updates** - Simple file copy instead of complex parsing
- **Role-based instructions** - Different instructions for Manager/Project/Task Agent

### How it works:
1. Core instructions live in `~/.claude/core/CLAUDEPM-*.md`
2. Your customizations stay in your project's `CLAUDE.md`
3. Claude sees both files combined at runtime
4. Updates only touch the core files

### Migration:
If you have projects from v0.1.x, run `/migrate-project [name]` to switch to the new architecture.

## Template Versioning

claudepm's templates evolve as we discover better patterns, but your existing projects shouldn't break. Our versioning system ensures:

- **Current version: v0.2.0** (see CHANGELOG.md for changes)
- **No forced updates** - Projects continue working with their current templates
- **Backward compatibility** - Updates preserve your customizations
- **Informed decisions** - The changelog explains what you'd gain by updating

### How it works:
1. Each project's `.claudepm` file tracks its template version
2. `/doctor` identifies which projects have outdated templates
3. Review CHANGELOG.md to see what's new
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

## Advanced Features

### AI-Powered Architecture Planning

The `/architect-feature` command leverages Gemini 2.5 Pro's 1M token context window to analyze your entire codebase and create comprehensive architectural plans for complex features.

**How it works:**
1. You describe the feature you want to implement
2. Gemini analyzes your entire codebase
3. Generates a detailed architectural plan with:
   - Technical design decisions
   - File-by-file implementation plan
   - Integration points with existing code
   - Edge cases and testing strategy
4. You review and approve the plan
5. Claude implements following the architecture

**Cost Transparency:**
- Uses Gemini 2.5 Pro API (requires Google AI API key)
- Typical analysis: ~$0.10-0.50 depending on codebase size
- Costs shown before execution
- Only runs when you use the command

### Task Agent Development Workflow

The three-level hierarchy enables parallel feature development:

**Project Lead (you) workflow:**
```bash
# Stay on dev branch
./tools/claudepm-admin.sh create-worktree add-search

# This creates:
# - worktrees/add-search/ directory
# - feature/add-search branch
# - TASK_PROMPT.md with mission brief

# Dispatch a Task Agent in a new conversation
# Task Agent implements in isolation
# Review PR when complete

# Cleanup after merge
./tools/claudepm-admin.sh remove-worktree add-search
# Archives TASK_PROMPT to .prompts_archive/
```

**Benefits:**
- Multiple features developed in parallel
- Clean git history with atomic PRs
- Archived mission history for learning
- No conflicts between features

## Philosophy

The magic isn't in the tool - it's in establishing consistent patterns that Claude can follow:
- No daemon processes
- No complex state management  
- No external dependencies
- Just markdown and git
- Optional AI assistance for complex planning

## Requirements

- Git (for worktree functionality)
- Bash shell
- Optional: Google AI API key for `/architect-feature` command
- Optional: GitHub CLI (`gh`) for PR management

## Setup

### Basic Installation
```bash
git clone https://github.com/mbosley/claudepm.git
cd claudepm
./install.sh
# Enter your projects directory when prompted
```

### Optional: AI Architecture Planning
To use the `/architect-feature` command:
1. Get a Google AI API key from https://aistudio.google.com/app/apikey
2. Set the environment variable:
   ```bash
   export GOOGLE_AI_API_KEY="your-key-here"
   ```

### Optional: GitHub Integration
For automated PR creation:
```bash
# Install GitHub CLI
brew install gh  # macOS
# or see https://cli.github.com for other platforms

# Authenticate
gh auth login
```

### Optional: MCP Server Integration (Coming Soon)
claudepm can integrate with MCP (Model Context Protocol) servers for enhanced functionality:
- **apple-mcp**: Email, calendar, and macOS app integration
- **[llm-mcp-server](https://github.com/mbosley/llm-mcp-server)**: Additional AI model access (Gemini, GPT-4)
- **filesystem-server**: Enhanced file operations

Note: MCP server integration is currently manual. Future versions will include streamlined setup instructions and dependency management.

## Contributing

claudepm uses itself for development! Check out our CLAUDE_LOG.md to see how it was built.

## License

MIT License - See LICENSE file for details