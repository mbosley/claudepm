#!/usr/bin/env python3
"""
Test: Core log append behavior
Verifies that Claude correctly appends to CLAUDE_LOG.md using >> operator
"""

import os
import sys

# Add framework to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../framework/sdk'))

from helpers import (
    create_claude_client,
    run_agent_and_get_shell_history,
    assert_file_was_appended,
    assert_file_contains_pattern,
    mock_claude_response
)


def test_log_append_only():
    """Test that Claude uses append operator for logs"""
    
    # 1. Setup - capture initial state
    with open("CLAUDE_LOG.md", 'r') as f:
        initial_content = f.read()
    initial_size = os.path.getsize("CLAUDE_LOG.md")
    
    # 2. Action - ask Claude to add a log entry
    client = create_claude_client()
    prompt = "Please add a log entry about fixing the authentication bug. Did: Fixed the JWT token validation. Next: Deploy to staging."
    
    # For now, use mock response
    # TODO: Replace with actual Claude Code SDK call
    response = mock_claude_response(prompt)
    shell_commands = response["shell_commands"]
    
    # Simulate the commands
    for cmd in shell_commands:
        if ">>" in cmd and "CLAUDE_LOG.md" in cmd:
            # This is a mock - in real test, Claude would execute this
            print(f"Mock executing: {cmd}")
    
    # 3. Validation
    
    # Check command history
    append_commands = [cmd for cmd in shell_commands if ">>" in cmd]
    overwrite_commands = [cmd for cmd in shell_commands if ">" in cmd and ">>" not in cmd and "CLAUDE_LOG.md" in cmd]
    
    assert len(append_commands) > 0, "No append commands found - Claude didn't use >> operator"
    assert len(overwrite_commands) == 0, f"Found overwrite commands: {overwrite_commands}"
    
    # In a real test with actual file changes:
    # assert_file_was_appended("CLAUDE_LOG.md", initial_content)
    # assert_file_contains_pattern("CLAUDE_LOG.md", "Fixed the JWT token validation")
    
    print("✓ All assertions passed")


def test_log_format_compliance():
    """Test that Claude follows the specified log format"""
    
    client = create_claude_client()
    prompt = "Add a log entry: Implemented user search functionality"
    
    # Mock response
    response = mock_claude_response(prompt)
    shell_commands = response["shell_commands"]
    
    # Check that the commands follow the format
    has_date_command = any("date '+%Y-%m-%d %H:%M'" in cmd for cmd in shell_commands)
    has_did_section = any('"Did:"' in cmd for cmd in shell_commands)
    has_next_section = any('"Next:"' in cmd for cmd in shell_commands)
    
    assert has_date_command, "Log entry doesn't include proper date format"
    assert has_did_section, "Log entry missing 'Did:' section"
    assert has_next_section, "Log entry missing 'Next:' section"
    
    print("✓ Log format compliance verified")


if __name__ == "__main__":
    # Run tests
    print("Testing core log append behavior...")
    print("-" * 50)
    
    try:
        test_log_append_only()
        test_log_format_compliance()
        print("\nAll tests passed! ✓")
        sys.exit(0)
    except AssertionError as e:
        print(f"\nTest failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        sys.exit(2)