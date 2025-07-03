# How Project Lead Claude Spawns Tester Claude

## The Correct Architecture

Project Lead Claude (on dev branch) spawns Tester Claude as a Task Agent, similar to how we spawn Task Agents for feature development.

## Tool Availability Note

When spawning Task agents (including Tester Claude), they inherit the same tool access as the parent. We cannot restrict tools programmatically, but we can provide clear instructions about which tools to use.

## Example: Spawning Tester Claude for Init Testing

```python
# Project Lead Claude uses Task tool:
Task: "Test claudepm init", prompt: """
You are Tester Claude, a QA specialist testing claudepm v0.2.5.

## Your Available Tools
- Bash: For running commands
- Read: For examining files
- Write: For creating reports
- LS: For directory listings

Do NOT use Edit/MultiEdit (you're testing, not fixing) or Task (no sub-agents).

Your working directory is: ~/projects/claudepm/tests/tester-claude/sandboxes/init-test-001

Your mission:
1. Create your sandbox directory
2. Copy claudepm source from ~/projects/claudepm/ to your sandbox
3. Test the installation process as a new user would
4. Test 'claudepm init project' and 'claudepm init manager'
5. Try edge cases (wrong arguments, missing directories, etc.)
6. Look for bash compatibility issues (you're on macOS with bash 3.2)

Document your findings in a report at:
~/projects/claudepm/tests/tester-claude/reports/init-test-001.md

Use this format:
# Test Report: Init Testing
Date: [date]

## Test Steps
[Document each command you ran and its output]

## Issues Found
[List any problems, errors, or unexpected behavior]

## Edge Cases Tested
[List the edge cases you tried]

## Recommendations
[Suggest improvements]

## Result: PASS/FAIL
[Overall assessment]
"""
```

## After Tester Claude Completes

Project Lead Claude then reads the report:

```bash
cat tests/tester-claude/reports/init-test-001.md
```

## Key Differences from run-tester.sh

1. **No orchestration script needed** - Project Lead manages the conversation
2. **Direct Task Agent spawning** - Uses existing Task Agent pattern
3. **Project Lead maintains control** - Can guide Tester Claude if needed
4. **Simpler infrastructure** - Just needs mission templates and report locations

## Creating Reusable Test Missions

Store missions as templates that Project Lead can use:

```bash
tests/tester-claude/missions/
├── init-testing.md
├── adopt-testing.md
├── upgrade-testing.md
└── edge-cases.md
```

Then Project Lead can:
```bash
MISSION=$(cat tests/tester-claude/missions/init-testing.md)
# Use Task tool with $MISSION
```