#!/usr/bin/env python3
"""
Helper functions for AI behavioral testing with Claude Code SDK
"""

import os
import sys
import json
import subprocess
import tempfile
from typing import List, Dict, Any, Optional
from pathlib import Path


class ClaudeTestClient:
    """Wrapper for Claude Code SDK testing"""
    
    def __init__(self, model: str = "claude-3-haiku-20240307"):
        self.model = model
        self.api_key = os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY environment variable not set")
    
    def run_in_directory(self, prompt: str, cwd: str, max_turns: int = 3) -> Dict[str, Any]:
        """
        Run Claude Code in a specific directory and return results
        
        Returns dict with:
        - success: bool
        - messages: list of messages
        - shell_commands: list of shell commands executed
        - file_changes: dict of file changes
        """
        # For now, return a mock response
        # TODO: Implement actual Claude Code SDK integration
        return {
            "success": True,
            "messages": ["Mock response - Claude Code SDK integration pending"],
            "shell_commands": [],
            "file_changes": {}
        }


def create_claude_client(model: str = "claude-3-haiku-20240307") -> ClaudeTestClient:
    """Create a Claude test client"""
    return ClaudeTestClient(model=model)


def run_agent_and_get_shell_history(client: ClaudeTestClient, prompt: str) -> List[str]:
    """
    Run Claude agent and extract shell command history
    
    This is a key function for behavioral testing - we can verify
    that Claude used the correct commands (like >> for appending)
    """
    result = client.run_in_directory(prompt, os.getcwd())
    return result.get("shell_commands", [])


def assert_file_was_appended(filepath: str, original_content: str) -> None:
    """Assert that a file was appended to, not overwritten"""
    with open(filepath, 'r') as f:
        current_content = f.read()
    
    if not current_content.startswith(original_content):
        raise AssertionError(f"File {filepath} was overwritten, not appended to")
    
    if len(current_content) <= len(original_content):
        raise AssertionError(f"No content was added to {filepath}")


def assert_file_contains_pattern(filepath: str, pattern: str) -> None:
    """Assert that a file contains a specific pattern"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    if pattern not in content:
        raise AssertionError(f"File {filepath} does not contain pattern: {pattern}")


def capture_file_state(directory: str) -> Dict[str, str]:
    """Capture the state of all files in a directory"""
    state = {}
    for root, dirs, files in os.walk(directory):
        # Skip .git and other hidden directories
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for file in files:
            if not file.startswith('.'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    state[filepath] = f.read()
    
    return state


def get_file_changes(before_state: Dict[str, str], after_state: Dict[str, str]) -> Dict[str, Any]:
    """Compare file states and return changes"""
    changes = {
        "created": [],
        "modified": [],
        "deleted": []
    }
    
    # Check for created and modified files
    for filepath, content in after_state.items():
        if filepath not in before_state:
            changes["created"].append(filepath)
        elif before_state[filepath] != content:
            changes["modified"].append(filepath)
    
    # Check for deleted files
    for filepath in before_state:
        if filepath not in after_state:
            changes["deleted"].append(filepath)
    
    return changes


# Test execution helpers
def run_test_scenario(test_name: str, test_func) -> bool:
    """Run a test scenario and report results"""
    print(f"Running test: {test_name}")
    
    try:
        test_func()
        print(f"✓ {test_name} passed")
        return True
    except Exception as e:
        print(f"✗ {test_name} failed: {str(e)}")
        return False


# Mock implementation for testing the test framework itself
def mock_claude_response(prompt: str) -> Dict[str, Any]:
    """Mock Claude responses for testing without API calls"""
    
    # Simulate different responses based on prompt
    if "log entry" in prompt.lower():
        return {
            "success": True,
            "messages": ["I'll add a log entry for you."],
            "shell_commands": [
                'echo "" >> CLAUDE_LOG.md',
                'echo "### $(date +%Y-%m-%d) - Fixed auth bug" >> CLAUDE_LOG.md',
                'echo "Did: Fixed authentication issue" >> CLAUDE_LOG.md',
                'echo "Next: Deploy the fix" >> CLAUDE_LOG.md',
                'echo "" >> CLAUDE_LOG.md'
            ],
            "file_changes": {"CLAUDE_LOG.md": "modified"}
        }
    
    elif "/adopt-project" in prompt:
        return {
            "success": True,
            "messages": ["I'll adopt this project into claudepm."],
            "shell_commands": [
                "cd my-app",
                "cat > CLAUDE.md << 'EOF'\\n# Project: my-app\\nEOF",
                "cat > CLAUDE_LOG.md << 'EOF'\\n# Log\\nEOF",
                "cat > PROJECT_ROADMAP.md << 'EOF'\\n# Roadmap\\nEOF"
            ],
            "file_changes": {
                "my-app/CLAUDE.md": "created",
                "my-app/CLAUDE_LOG.md": "created",
                "my-app/PROJECT_ROADMAP.md": "created"
            }
        }
    
    return {
        "success": True,
        "messages": ["Generic response"],
        "shell_commands": [],
        "file_changes": {}
    }