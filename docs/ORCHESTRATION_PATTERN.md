# Claude Orchestration Pattern: Spawning Specialized Instances

## Overview

This document describes a powerful orchestration pattern where Claude instances can spawn other specialized Claude instances using the Task tool and command-line wrappers. This enables parallel execution of specialized agents with different configurations.

## The Discovery

We discovered that Claude can spawn fully configured Claude instances through the Task tool by executing wrapper scripts with the `-p` (print) flag. This creates a new paradigm for orchestrating complex workflows.

## Architecture

```
Project Lead Claude (default config)
    │
    ├─ Task → tester-claude -p "Test A" (Sonnet, bypassPermissions)
    ├─ Task → tester-claude -p "Test B" (Sonnet, bypassPermissions)
    └─ Task → architect-claude -p "Design X" (Opus, careful mode)
```

## Implementation Pattern

### 1. Create Specialized Wrapper Scripts

Example: `tools/tester-claude`
```bash
#!/bin/bash
# Launch Claude configured for testing tasks
set -euo pipefail

# Configuration
MODEL="claude-3-5-sonnet-20241022"  # Sonnet for speed/cost
PERMISSION_MODE="bypassPermissions"  # Skip confirmations
MAX_TURNS="20"

# System prompt for role
SYSTEM_PROMPT="You are Tester Claude, a QA specialist..."

# Launch Claude
exec claude \
    --model "$MODEL" \
    --permission-mode "$PERMISSION_MODE" \
    --max-turns "$MAX_TURNS" \
    --system-prompt "$SYSTEM_PROMPT" \
    "$@"
```

### 2. Spawn from Project Lead Claude

```python
# Parallel execution of specialized instances
Task: "Run alpha test", prompt: """
Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "Test Alpha: Create /tmp/test-alpha, write file, verify"
"""

Task: "Run beta test", prompt: """
Execute: /Users/mitchellbosley/.claudepm/bin/tester-claude -p "Test Beta: Create /tmp/test-beta, count words"
"""
```

### 3. Results

Each specialized instance:
- Runs with its own configuration (model, permissions, system prompt)
- Executes independently in parallel
- Returns structured results to the orchestrator
- Maintains role-specific behavior

## Key Advantages

### 1. **True Parallelization**
Unlike sequential Task agents, spawned Claude instances run completely in parallel, each in their own process.

### 2. **Configuration Isolation**
Each instance has its own:
- Model selection (Sonnet for speed, Opus for complexity)
- Permission mode (bypass for testing, careful for production)
- System prompt (role-specific behavior)
- Max turns limit

### 3. **Cost Optimization**
- Use Sonnet for simple tasks (testing, validation)
- Use Opus only for complex reasoning (architecture, design)
- Run many cheap instances in parallel

### 4. **Role Specialization**
Each wrapper defines a specific role:
- `tester-claude`: QA mindset, no fixing, just testing
- `architect-claude`: Design focus, careful consideration
- `reviewer-claude`: Security and code quality focus
- `builder-claude`: Rapid prototyping, high productivity

## Practical Example: Comprehensive Test Suite

```python
# Project Lead Claude orchestrates a full test suite
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

## Limitations and Considerations

### 1. **Single-Turn Interactions**
- Each spawned instance is limited to one interaction
- Use detailed prompts with complete instructions
- Cannot have multi-turn conversations

### 2. **No Direct Communication**
- Spawned instances cannot talk to each other
- Communication happens through files/reports
- Orchestrator aggregates results

### 3. **Process Overhead**
- Each spawn creates a new Claude process
- There's startup time for each instance
- Best for substantial tasks, not micro-operations

## Best Practices

### 1. **Clear Mission Statements**
Since interactions are single-turn, provide comprehensive instructions:
```
BAD:  "Test the init command"
GOOD: "Test claudepm init: 1) Run with no args, 2) Run with invalid args, 
       3) Run with valid args, 4) Verify file creation, 5) Report all findings"
```

### 2. **Structured Output Requests**
Ask for specific output formats:
```
"Complete all tests and provide results in this format:
- Test name: [PASS/FAIL]
- Details: [what happened]
- Recommendations: [if any]"
```

### 3. **Error Handling**
The Task agent should handle wrapper script failures:
```
"Execute: /path/to/wrapper -p 'mission' || echo 'FAILED: wrapper not found'"
```

## Future Enhancements

### 1. **Session Persistence**
Once Claude Code improves `--continue` support, we could:
- Spawn an instance
- Get its session ID from JSON output
- Resume for multi-turn interactions

### 2. **Direct Tool Control**
If Task tool adds parameters for model/permissions:
- Could skip wrapper scripts
- Direct configuration in Task calls
- More dynamic orchestration

### 3. **Inter-Instance Communication**
Potential patterns for instance coordination:
- Shared file system locations
- Message passing through orchestrator
- Synchronized checkpoints

## Conclusion

This orchestration pattern enables sophisticated multi-agent workflows where a Project Lead Claude can coordinate multiple specialized instances running in parallel. Each instance maintains its own configuration and role-specific behavior, enabling efficient division of labor and cost optimization.

The pattern is particularly powerful for:
- Comprehensive testing (many scenarios in parallel)
- Multi-perspective analysis (architect + security + performance reviews)
- Large-scale refactoring (multiple files in parallel)
- Exploratory tasks (different approaches simultaneously)

This represents a new paradigm in Claude-based development: orchestrated swarms of specialized agents working in parallel toward a common goal.