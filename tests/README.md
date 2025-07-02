# claudepm Test Suite

This directory contains the comprehensive test suite for claudepm, using a hybrid approach of traditional bash tests and AI behavioral validation.

## Quick Start

### 1. Install Dependencies

```bash
# Install test dependencies (macOS with Homebrew)
./tests/setup-dependencies.sh

# Or manually:
brew install bats-core jq    # macOS
sudo apt-get install bats jq # Ubuntu
```

### 2. Run Tests

```bash
# Run all tests
./tests/framework/run-tests.sh

# Run only traditional tests (no API key needed)
./tests/framework/run-tests.sh traditional

# Run only AI behavioral tests (requires ANTHROPIC_API_KEY)
export ANTHROPIC_API_KEY="your-key-here"
./tests/framework/run-tests.sh ai-behavioral
```

## Test Architecture

### Traditional Tests (Bats)
- Located in `scenarios/traditional/`
- Test deterministic components (scripts, file operations)
- Fast, reliable, no API costs
- Run on every commit

### AI Behavioral Tests (Python + Claude Code SDK)
- Located in `scenarios/ai-behavioral/`
- Test actual Claude behavior in controlled environments
- Require Anthropic API key
- Run on PRs and releases

## Test Structure

Each test scenario is self-contained:

```
scenarios/
├── traditional/
│   └── installer/
│       └── test.bats         # Bats test script
└── ai-behavioral/
    └── core_log_append/
        ├── setup/            # Initial environment
        │   ├── CLAUDE.md     # Instructions
        │   └── CLAUDE_LOG.md # Test data
        └── test.py           # Python test script
```

## Writing New Tests

### Traditional Test Example

```bash
#!/usr/bin/env bats
# tests/scenarios/traditional/my_feature/test.bats

load '../../../framework/test-helpers.bash'

@test "my feature works correctly" {
    run ./my-script.sh
    assert_success
    assert_output --partial "expected output"
    assert_file_exists "expected-file.txt"
}
```

### AI Behavioral Test Example

```python
#!/usr/bin/env python3
# tests/scenarios/ai-behavioral/my_behavior/test.py

from helpers import create_claude_client, run_agent_and_get_shell_history

def test_my_behavior():
    client = create_claude_client()
    shell_history = run_agent_and_get_shell_history(
        client, 
        "Do something specific"
    )
    
    # Verify behavior
    assert any("expected_command" in cmd for cmd in shell_history)
    
    # Verify outcome
    assert os.path.exists("expected_file.txt")
```

## Test Phases

### Phase 1: Foundation (Current)
- Basic installer tests
- Core AI behaviors (log appending, role adherence)
- Test infrastructure setup

### Phase 2: Core Workflows
- Project adoption
- Task agent lifecycle
- Template updates

### Phase 3: Advanced Features
- Multi-project coordination
- Edge cases and error handling

See `roadmap.md` for full testing expansion plan.

## Cost Management

- AI tests use Claude 3 Haiku by default ($0.25/1M tokens)
- Typical test: ~1K tokens = $0.00025
- Run expensive tests only on releases
- Mock expensive operations (Gemini API)

## CI Integration

Tests run automatically via GitHub Actions:
- Every commit: Traditional tests only
- Every PR: Traditional + core AI tests
- Weekly/Release: Full test suite

## Current Status

- [x] Test framework created
- [x] First traditional test (installer)
- [x] First AI behavioral test (log append)
- [ ] Claude Code SDK integration
- [ ] GitHub Actions workflow
- [ ] Full test coverage

## Notes

- Tests run in isolated temporary directories
- Each test is independent and repeatable
- AI tests use flexible assertions (patterns, not exact matches)
- Focus on testing outcomes, not implementation details