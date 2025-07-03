# Specialized Claude Instances

## Overview

Claude Code's Task tool currently inherits environment variables only from the parent Claude's initial startup environment. Variables set during a conversation are not passed to Task agents. This document describes our wrapper script pattern for creating specialized Claude instances with custom configurations.

## The Environment Inheritance Pattern

```
Human → Specialized Wrapper → Orchestration Claude → Task Agents
         (sets env vars)      (inherits env)        (inherit same env)
```

### Current Limitations (as of Claude Code v1.0.41)
- Task tool only accepts `description` and `prompt` parameters
- No programmatic control over model, tools, or permissions for Task agents
- Environment variables set during conversation are NOT inherited by Task agents
- Only the initial startup environment is passed to spawned agents

### Our Solution: Command Wrappers
Create specialized wrapper scripts that launch Claude with specific configurations and environment variables at startup time.

## Implementation Example: tester-claude

Located at: `tools/tester-claude`

```bash
#!/bin/bash
# Launch Claude configured for testing tasks

# Set configuration
MODEL="claude-3-5-sonnet-20241022"  # Sonnet for speed/cost
PERMISSION_MODE="bypassPermissions"  # Skip confirmations
MAX_TURNS="20"                       # Reasonable limit

# Set custom environment variables that Task agents will inherit
export CLAUDEPM_ROLE="tester"
export CLAUDEPM_TEST_MODE="true"

# Launch with custom system prompt
exec claude \
    --model "$MODEL" \
    --permission-mode "$PERMISSION_MODE" \
    --max-turns "$MAX_TURNS" \
    --system-prompt "You are Tester Claude, a QA specialist..." \
    "$@"
```

## Creating New Specialized Claudes

### 1. Create the Wrapper Script

```bash
#!/bin/bash
# tools/researcher-claude
set -euo pipefail

# Configuration for research tasks
MODEL="claude-3-5-sonnet-20241022"  # Balance of capability and cost
PERMISSION_MODE="default"            # Keep confirmations for safety
MAX_TURNS="50"                       # Research may take longer

# Set role-specific environment variables
export CLAUDEPM_ROLE="researcher"
export RESEARCH_DEPTH="thorough"

# System prompt for the role
SYSTEM_PROMPT="You are Researcher Claude, specialized in thorough code analysis and documentation research. Always cite sources and verify claims."

# Launch Claude
exec claude \
    --model "$MODEL" \
    --permission-mode "$PERMISSION_MODE" \
    --max-turns "$MAX_TURNS" \
    --system-prompt "$SYSTEM_PROMPT" \
    "$@"
```

### 2. Make Executable and Link

```bash
chmod +x tools/researcher-claude
ln -sf $PWD/tools/researcher-claude ~/.claudepm/bin/
```

### 3. Usage Patterns

#### Direct Usage
```bash
researcher-claude -p "Analyze the authentication patterns in this codebase"
```

#### As Orchestrator for Task Agents
```bash
tester-claude -p "Run comprehensive tests on all commands"
# This Tester Claude can spawn Task agents that inherit CLAUDEPM_ROLE="tester"
```

## Environment Variables Strategy

### Role Identification
```bash
export CLAUDEPM_ROLE="tester|researcher|architect|reviewer"
```

### Role-Specific Configuration
```bash
# For testers
export CLAUDEPM_TEST_MODE="true"
export CLAUDEPM_TEST_SANDBOX="/path/to/sandbox"

# For architects
export CLAUDEPM_DESIGN_PRINCIPLES="simple|maintainable|extensible"

# For reviewers
export CLAUDEPM_REVIEW_FOCUS="security|performance|style"
```

### Detection in Spawned Agents
Task agents can check their inherited role:
```bash
if [ "$CLAUDEPM_ROLE" = "tester" ]; then
    echo "Running in test mode - will not modify production files"
fi
```

## Best Practices

### 1. Wrapper Script Guidelines
- Always use `exec` to replace the wrapper process
- Set `set -euo pipefail` for error handling
- Document the role's purpose in comments
- Choose appropriate model for the task type
- Set reasonable max_turns limits

### 2. Environment Variable Conventions
- Prefix with `CLAUDEPM_` to avoid conflicts
- Use UPPER_CASE for environment variables
- Document what each variable controls
- Provide sensible defaults

### 3. System Prompt Design
- Clearly define the role and restrictions
- Specify which tools should/shouldn't be used
- Include output format expectations
- Add domain-specific guidelines

## Common Specialized Roles

### Tester Claude
- **Purpose**: QA testing without fixing bugs
- **Model**: Sonnet (fast/cheap)
- **Permissions**: Bypass (no interruptions)
- **Restrictions**: No Edit tools, no Git commits

### Architect Claude
- **Purpose**: Design and architecture decisions
- **Model**: Opus (maximum capability)
- **Permissions**: Default (careful consideration)
- **Features**: Extended thinking time

### Reviewer Claude
- **Purpose**: Code review and security analysis
- **Model**: Sonnet (good balance)
- **Permissions**: Default (safety checks)
- **Focus**: Read-only analysis

### Builder Claude
- **Purpose**: Rapid prototyping
- **Model**: Haiku (fastest)
- **Permissions**: Accept edits (semi-auto)
- **Mode**: High productivity

## Advanced Pattern: Orchestration via CLI Spawning

We've discovered that Claude can spawn other specialized Claude instances through the Task tool by executing wrapper scripts with the `-p` flag. This enables powerful orchestration patterns:

```python
# Project Lead Claude spawns parallel specialized instances
Task: "Run test A", prompt: """
Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "Test the init command comprehensively"
"""

Task: "Run test B", prompt: """
Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "Test the adopt command with edge cases"
"""
```

Benefits:
- True parallel execution (separate processes)
- Each instance has its own configuration
- No environment variable inheritance needed
- Results returned to orchestrator

See `ORCHESTRATION_PATTERN.md` for detailed documentation of this advanced pattern.

## Future Considerations

When Claude Code adds native support for Task agent configuration, we can:
1. Migrate from wrapper scripts to native options
2. Keep wrappers as convenience shortcuts
3. Use hybrid approach with both patterns

For now, this wrapper pattern provides a robust solution for specialized Claude instances that need consistent configuration and environment variables across orchestrator and Task agent sessions.

## Testing the Pattern

1. **Verify Environment Inheritance**:
```bash
tester-claude -p "Check env: echo \$CLAUDEPM_ROLE and spawn a Task agent to do the same"
```

2. **Confirm Configuration**:
```bash
tester-claude -p "What model are you using? What's your role?"
```

3. **Test Task Agent Inheritance**:
```bash
tester-claude -p "Spawn a Task agent to verify it inherited CLAUDEPM_ROLE=tester"
```