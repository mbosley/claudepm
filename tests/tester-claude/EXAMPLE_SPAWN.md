# Example: How to Spawn Tester Claude

This example shows how Project Lead Claude would spawn a Tester Claude to test fresh installation.

## Step 1: Initialize Test Environment

First, run:
```bash
./tools/claudepm-test.sh init fresh-install
```

This outputs paths like:
```
Working directory: /Users/.../tests/tester-claude/runs/20250703-145316-fresh-install/sandbox
Report output: /Users/.../tests/tester-claude/runs/20250703-145316-fresh-install/report.md
Command trace: /Users/.../tests/tester-claude/runs/20250703-145316-fresh-install/trace.log
```

## Step 2: Prepare the Task Prompt

```python
# Read the mission
MISSION=$(cat tests/tester-claude/missions/init-testing.md)

# Prepare the full prompt with paths
PROMPT="$MISSION

IMPORTANT - Use these specific paths:
- Your working directory: /Users/.../tests/tester-claude/runs/20250703-145316-fresh-install/sandbox
- Write your test report to: /Users/.../tests/tester-claude/runs/20250703-145316-fresh-install/report.md
- Log all commands you run to: /Users/.../tests/tester-claude/runs/20250703-145316-fresh-install/trace.log

Start by creating your working directory if needed, then begin testing."
```

## Step 3: Spawn Tester Claude

```python
Task: "Test claudepm fresh installation", prompt: "$PROMPT"
```

## Step 4: Review Results

After Tester Claude completes:

```bash
# Read the test report
cat tests/tester-claude/runs/20250703-145316-fresh-install/report.md

# Check what commands were run
cat tests/tester-claude/runs/20250703-145316-fresh-install/trace.log

# View test metadata
cat tests/tester-claude/runs/20250703-145316-fresh-install/manifest.json
```

## Complete Example Code Block

```python
# Initialize environment and get paths
RUN_OUTPUT=$(./tools/claudepm-test.sh init fresh-install)
SANDBOX=$(echo "$RUN_OUTPUT" | grep "Working directory:" | cut -d' ' -f3)
REPORT=$(echo "$RUN_OUTPUT" | grep "Report output:" | cut -d' ' -f3)  
TRACE=$(echo "$RUN_OUTPUT" | grep "Command trace:" | cut -d' ' -f3)

# Read mission
MISSION=$(cat tests/tester-claude/missions/init-testing.md)

# Spawn Tester Claude
Task: "Test claudepm installation", prompt: """
$MISSION

Use these paths:
- Working directory: $SANDBOX
- Test report: $REPORT
- Command trace: $TRACE
"""
```