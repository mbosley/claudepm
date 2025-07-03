# Tester Claude - Human-like QA Testing

Tester Claude is an exploratory testing pattern where Claude acts as a human QA tester, complementing our deterministic tests.

## Overview

Following Gemini's architectural guidance, Tester Claude provides:
- **Exploratory testing** that finds "unknown unknowns"
- **Compatibility testing** (like our bash 3.2 discoveries)
- **Usability testing** from a user's perspective
- **Integration testing** of the full claudepm experience

## Architecture

### Three-Tier Testing Strategy

1. **Tier 1: Bats Tests** (every commit)
   - Deterministic, fast unit tests
   - Test individual functions and commands
   
2. **Tier 2: AI Behavioral Tests** (every commit)
   - Scripted workflows using Claude SDK
   - Test specific behaviors programmatically

3. **Tier 3: Tester Claude** (pre-release/nightly)
   - Exploratory, human-like testing
   - Find edge cases and usability issues

### Key Components

- **`claudepm-test.sh`**: Test environment management tool (in tools/)
- **`environments/`**: Reusable test environment templates
- **`runs/`**: Historical test executions with reports
- **`missions/`**: Test scenarios for Tester Claude

## Running Tests

### 1. Prepare Test Environment

```bash
# Initialize a test environment
./tools/claudepm-test.sh init fresh-install

# This outputs environment variables and paths
```

### 2. Spawn Tester Claude

```python
# Read the mission
MISSION=$(cat tests/tester-claude/missions/init-testing.md)

# Include the environment paths in the prompt
Task: "Test claudepm init", prompt: """
$MISSION

Use these paths:
- Working directory: [sandbox path from init output]
- Write report to: [report path from init output]
- Log commands to: [trace log path from init output]
"""
```

### 3. Review Results

```bash
# Read the test report
cat tests/tester-claude/runs/[run-id]/report.md

# Check command trace
cat tests/tester-claude/runs/[run-id]/trace.log

# View test metadata
cat tests/tester-claude/runs/[run-id]/manifest.json
```

## Creating New Test Environments

1. Create directory: `environments/your-test/`
2. Write `setup.sh` that creates `initial.tar.gz`
3. Add `description.txt` (one line description)
4. Run `./tools/claudepm-test.sh reset your-test` to build
5. Create mission in `missions/your-test.md`

### Example setup.sh
```bash
#!/bin/bash
set -euo pipefail

# Get script directory first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Build your test state in $TEMP_DIR
cd "$TEMP_DIR"
mkdir -p your-test-structure
# ... create files ...

# Archive it
tar -czf initial.tar.gz -C . your-test-structure

# Move to environment directory
mv initial.tar.gz "$SCRIPT_DIR/"
echo "Test environment created!"
```

## Test Environment Management

The `claudepm-test.sh` tool provides:

### MVP Commands (v0.2.5)
- `init <test-name>` - Initialize test environment and get paths
- `reset <test-name>` - Rebuild environment from setup.sh
- `list` - Show available environments and recent runs

### Environment Features
- **Tar.gz archives** for atomic, compressed snapshots
- **Locking mechanism** to prevent concurrent test conflicts
- **Environment variables** passed to Tester Claude
- **Manifest tracking** for test history

### Coming in v0.3
- `diff` - Compare before/after states
- `clean` - Archive old test runs
- Searchable test history with index.json

## Cost Management

- **MAX_TURNS=10**: Prevents runaway sessions
- **Run strategically**: Pre-release and nightly, not every commit
- **Use Haiku model**: Cheaper for testing tasks
- **Preserve sandboxes**: Rerun validation without API calls

## Current Test Scenarios

### 01-init-fresh
Tests fresh claudepm installation and project initialization, including:
- Installation process
- Directory structure creation
- Basic command functionality
- Bash compatibility

### 02-adopt-existing  
Tests adopting a legacy project with:
- package.json parsing
- TODO extraction from code
- Command discovery
- File preservation

## Future Scenarios

- `03-upgrade-templates`: Test template version upgrades
- `04-task-management`: Test CPM::TASK operations
- `05-multi-project`: Test manager-level operations
- `06-error-handling`: Test failure scenarios

## Integration with CI

```yaml
# .github/workflows/tester-claude.yml
name: Tester Claude
on:
  schedule:
    - cron: '0 2 * * *'  # Nightly at 2 AM
  workflow_dispatch:      # Manual trigger

jobs:
  exploratory-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tester Claude
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          ./tests/tester-claude/run-tester.sh 01-init-fresh
          ./tests/tester-claude/run-tester.sh 02-adopt-existing
```

## Key Insights from Gemini

1. **Task Agent pattern** works perfectly for testing
2. **Environment variables** connect infrastructure to agents
3. **Tar.gz archives** provide atomic, compressed snapshots
4. **Separate tool** (claudepm-test.sh) maintains clean separation
5. **MVP approach** delivers value immediately for v0.2.5
6. **Tiered testing** balances speed, cost, and thoroughness

## Debugging Failed Tests

1. Check the report in `reports/` for the full conversation
2. Examine the preserved sandbox to see final state
3. Run validation manually: `cd sandboxes/[test] && ../../scenarios/[test]/validate.sh`
4. Adjust MISSION.md or validate.sh based on findings

Remember: Tester Claude finds the bugs that "should never happen" but always do!