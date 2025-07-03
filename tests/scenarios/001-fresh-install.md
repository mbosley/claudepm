# Test Scenario 001: Fresh Installation

## Objective
Verify claudepm installs correctly on a fresh system with no prior configuration.

## Test Steps

1. **Prepare Clean Environment**
   - Create temporary test directory: `/tmp/claudepm-test-001-[timestamp]`
   - Ensure no existing ~/.claudepm directory
   - Set working directory to temp location

2. **Run Installer**
   - Copy install.sh from source
   - Execute: `./install.sh`
   - Capture all output

3. **Verify Installation**
   - Check ~/.claudepm directory structure exists:
     - `~/.claudepm/bin/claudepm`
     - `~/.claudepm/lib/utils.sh`
     - `~/.claudepm/templates/`
     - `~/.claudepm/commands/`
   - Verify claudepm is executable
   - Check VERSION file matches source

4. **Test Basic Commands**
   - Run: `~/.claudepm/bin/claudepm --version`
   - Run: `~/.claudepm/bin/claudepm --help`
   - Both should execute without errors

5. **Test Manager Init**
   - Create test projects directory
   - Run: `claudepm init manager`
   - Verify creates: CLAUDE.md, LOG.md, ROADMAP.md, NOTES.md

## Expected Results
- Installation completes without errors
- All files present with correct permissions
- Basic commands work
- Manager initialization successful

## Report Format
- PASS/FAIL for each step
- Any error messages encountered
- Execution time
- System details (OS, bash version)