#!/usr/bin/env python3
"""
Test: Core log append behavior
Verifies that Claude correctly appends to CLAUDE_LOG.md using >> operator
"""

import os
import sys
import tempfile

# Add framework to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../framework/sdk'))

from helpers import (
    create_claude_client,
    run_claude_in_test_dir,
    setup_test_environment,
    cleanup_test_environment,
    assert_file_was_appended,
    assert_file_contains_pattern,
    assert_shell_commands_contain,
    assert_shell_commands_not_contain
)


def test_log_append_only():
    """Test that Claude uses append operator for logs"""
    
    # Use the setup directory for this test
    test_dir = os.path.join(os.path.dirname(__file__), 'setup')
    
    # Read initial state
    with open(os.path.join(test_dir, "CLAUDE_LOG.md"), 'r') as f:
        initial_content = f.read()
    
    # Simple prompt - the system prompt will provide context
    prompt = """Please add a log entry to CLAUDE_LOG.md about fixing the authentication bug. 
Did: Fixed the JWT token validation. 
Next: Deploy to staging."""
    
    # Run claude with CLAUDE.md as system prompt
    result = run_claude_in_test_dir(prompt, test_dir, 
                                   allowed_tools=["Bash"],
                                   with_claudepm_context=True,
                                   timeout=60)
    
    if not result["success"]:
        print(f"Claude command failed: {result['error']}")
        print(f"Output: {result['output']}")
        print(f"Exit code: {result['exit_code']}")
        raise AssertionError("Claude command failed")
    
    # Print output for debugging
    print("Claude output:")
    print("-" * 50)
    print(result["output"])
    print("-" * 50)
    
    # Check the actual file to verify it was appended
    with open(os.path.join(test_dir, "CLAUDE_LOG.md"), 'r') as f:
        final_content = f.read()
    
    # Verify file was appended to, not overwritten
    assert_file_was_appended(os.path.join(test_dir, "CLAUDE_LOG.md"), initial_content)
    
    # Check that the new content was added
    assert_file_contains_pattern(os.path.join(test_dir, "CLAUDE_LOG.md"), 
                                "Fixed the JWT token validation")
    assert_file_contains_pattern(os.path.join(test_dir, "CLAUDE_LOG.md"), 
                                "Deploy to staging")
    
    # Verify the format is correct (has timestamp)
    new_content = final_content.replace(initial_content, "")
    assert "###" in new_content, "Log entry missing timestamp header"
    assert "Did:" in new_content, "Log entry missing Did: section"
    assert "Next:" in new_content, "Log entry missing Next: section"
    
    print("✓ All assertions passed")


def test_claude_cli_available():
    """Test that claude CLI is available"""
    try:
        client = create_claude_client()
        print("✓ claude CLI is available")
    except ValueError as e:
        raise AssertionError(str(e))


if __name__ == "__main__":
    # Run tests
    print("Testing AI behavioral: core log append")
    print("=" * 50)
    
    try:
        test_claude_cli_available()
        test_log_append_only()
        print("\nAll tests passed! ✓")
        sys.exit(0)
    except AssertionError as e:
        print(f"\nTest failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        sys.exit(2)