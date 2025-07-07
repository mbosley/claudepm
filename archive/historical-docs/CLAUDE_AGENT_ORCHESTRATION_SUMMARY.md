# Claude Agent Orchestration Pattern - Summary

## Overview

We developed an advanced pattern for running multiple Claude agents in parallel with specialized configurations. This enables orchestration of complex workflows where different agents have different roles, models, and permissions.

## Key Components

### 1. Python Test Framework (`tests/framework/sdk/helpers.py`)

The core wrapper that allows programmatic control of Claude CLI:

```python
class ClaudeTestClient:
    def run_in_directory(self, prompt: str, cwd: str, timeout: int = 30, 
                        allowed_tools: List[str] = None,
                        system_prompt: str = None) -> Dict[str, Any]:
        """
        Run claude CLI in a specific directory and return results
        """
        cmd = ['claude', '-p', prompt]
        
        # Add system prompt if specified
        if system_prompt:
            cmd.extend(['--system-prompt', system_prompt])
        
        # Add allowed tools if specified
        if allowed_tools:
            cmd.extend(['--allowedTools', ','.join(allowed_tools)])
        
        # Run claude with all flags
        result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
```

### 2. Specialized Wrapper Scripts (`tools/tester-claude`)

Bash wrappers that launch Claude with specific configurations:

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

### 3. Orchestration via Task Tool

The key discovery: Claude can spawn other Claude instances through the Task tool by executing wrapper scripts:

```python
# Project Lead Claude spawns parallel specialized instances
Task: "Run test A", prompt: """
Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "Test the init command comprehensively"
"""

Task: "Run test B", prompt: """
Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "Test the adopt command with edge cases"
"""
```

## The Architecture

```
Project Lead Claude (default config)
    │
    ├─ Task → tester-claude -p "Test A" (Sonnet, bypassPermissions)
    ├─ Task → tester-claude -p "Test B" (Sonnet, bypassPermissions)
    └─ Task → architect-claude -p "Design X" (Opus, careful mode)
```

## Key Advantages

1. **True Parallelization**: Each spawned instance runs in its own process simultaneously
2. **Configuration Isolation**: Each instance has its own model, permissions, system prompt
3. **Cost Optimization**: Use cheaper models (Sonnet) for simple tasks, expensive (Opus) for complex
4. **Role Specialization**: Each wrapper defines specific behavior (tester, architect, reviewer)

## Practical Example

```python
# Comprehensive test suite running in parallel
test_scenarios = [
    "Test installation on fresh system",
    "Test adoption of legacy project", 
    "Test upgrade from v0.1 to v0.2",
    "Test with spaces in paths",
    "Test with missing dependencies"
]

# Spawn all tests in parallel
for scenario in test_scenarios:
    Task: f"Run: {scenario}", prompt: f"""
    Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "{scenario}"
    """
```

## Environment Variable Strategy

The wrappers set environment variables that get inherited by Task agents:

```bash
# Role identification
export CLAUDEPM_ROLE="tester|researcher|architect|reviewer"

# Role-specific configuration
export CLAUDEPM_TEST_MODE="true"
export CLAUDEPM_TEST_SANDBOX="/path/to/sandbox"
```

Task agents can detect their role:
```bash
if [ "$CLAUDEPM_ROLE" = "tester" ]; then
    echo "Running in test mode - will not modify production files"
fi
```

## Creating New Specialized Agents

1. Create wrapper script in `tools/`:
```bash
#!/bin/bash
# tools/researcher-claude
MODEL="claude-3-5-sonnet-20241022"
PERMISSION_MODE="default"
export CLAUDEPM_ROLE="researcher"

exec claude \
    --model "$MODEL" \
    --permission-mode "$PERMISSION_MODE" \
    --system-prompt "You are Researcher Claude..." \
    "$@"
```

2. Make executable and link:
```bash
chmod +x tools/researcher-claude
ln -sf $PWD/tools/researcher-claude ~/.claudepm/bin/
```

3. Use in orchestration:
```python
Task: "Research auth patterns", prompt: """
Execute: researcher-claude -p "Analyze authentication patterns in the codebase"
"""
```

## Limitations

1. **Single-Turn Interactions**: Each spawned instance is limited to one interaction
2. **No Direct Communication**: Instances communicate through files/reports via orchestrator
3. **Process Overhead**: Each spawn creates a new Claude process (best for substantial tasks)

## Best Practices

1. **Clear Mission Statements**: Since interactions are single-turn, provide comprehensive instructions
2. **Structured Output**: Request specific output formats for easy aggregation
3. **Error Handling**: Handle wrapper script failures gracefully

## Use Cases

This pattern is particularly powerful for:
- **Comprehensive Testing**: Many test scenarios running in parallel
- **Multi-Perspective Analysis**: Architecture + security + performance reviews simultaneously
- **Large-Scale Refactoring**: Multiple files processed in parallel
- **Exploratory Tasks**: Different approaches tried simultaneously

## Technical Details

The pattern works because:
1. Claude's Task tool can execute arbitrary commands
2. The claude CLI accepts the `-p` flag for single prompts
3. Wrapper scripts can set environment and configuration before launching
4. Each instance runs independently with its own configuration

This enables a new paradigm: orchestrated swarms of specialized Claude agents working in parallel toward common goals.