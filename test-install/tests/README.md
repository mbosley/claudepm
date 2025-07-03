# ClaudePM Test Suite

## Overview

ClaudePM uses a hybrid testing approach optimized for different types of validation:

### 1. Traditional Tests (Bats)
Fast, deterministic unit tests for core functionality.

**Location**: `tests/traditional/`
**Run**: `./tests/run-bats-tests.sh`

### 2. AI Behavioral Tests
Quick Claude-based tests for complex behaviors.

**Location**: `tests/scenarios/` (WIP)
**Framework**: Python + Claude CLI

### 3. Tester Claude Integration Tests
Comprehensive exploratory testing using specialized Claude instances.

**Location**: `tests/tester-claude/`
**Run**: Via orchestration patterns

## Running Tests

### Quick Unit Tests (Every Commit)
```bash
# Install bats if needed
brew install bats-core  # macOS
# or
npm install -g bats     # Cross-platform

# Run all bats tests
./tests/run-bats-tests.sh

# Run specific test file
bats tests/traditional/installer.bats
```

### Comprehensive Testing (Before Release)
```bash
# Run full test suite including Tester Claude scenarios
./tests/run-test-suite.sh
```

## Test Structure

```
tests/
├── traditional/          # Bats unit tests
│   ├── installer.bats   # Test install.sh
│   ├── init.bats       # Test claudepm init
│   ├── adopt.bats      # Test claudepm adopt
│   ├── task.bats       # Test task management
│   ├── health.bats     # Test health/doctor commands
│   └── utils.bats      # Test utility functions
├── scenarios/           # Tester Claude test scenarios
│   ├── 001-fresh-install.md
│   ├── 002-adopt-project.md
│   └── 003-simple-demo.md
├── tester-claude/       # Tester Claude infrastructure
│   ├── missions/        # Test mission templates
│   ├── environments/    # Test environment setups
│   └── reports/         # Test execution reports
├── run-bats-tests.sh    # Run traditional tests
└── run-test-suite.sh    # Run full test suite
```

## Writing Tests

### Bats Tests
```bash
@test "descriptive test name" {
    run command_to_test
    [ "$status" -eq 0 ]
    [[ "$output" =~ "expected text" ]]
}
```

### Tester Claude Scenarios
Write markdown files with clear test steps, expected results, and report format.

## CI Integration

The test suite is designed for GitHub Actions:
- Fast bats tests run on every push
- AI behavioral tests run on PRs
- Full Tester Claude suite runs before releases

## Test Philosophy

1. **Unit tests** catch obvious breaks quickly
2. **AI tests** validate complex behaviors
3. **Tester Claude** discovers edge cases through exploration

This hybrid approach balances speed, coverage, and intelligent testing.
EOF < /dev/null