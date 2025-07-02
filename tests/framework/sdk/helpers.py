#!/usr/bin/env python3
"""
Helper functions for AI behavioral testing with claude CLI
"""

import os
import sys
import json
import subprocess
import tempfile
import shutil
from typing import List, Dict, Any, Optional
from pathlib import Path


class ClaudeTestClient:
    """Wrapper for claude CLI testing"""
    
    def __init__(self, model: str = "claude-3-haiku-20240307"):
        self.model = model
        # Check if claude CLI is available
        result = subprocess.run(['which', 'claude'], capture_output=True, text=True)
        if result.returncode != 0:
            raise ValueError("claude CLI not found. Please install Claude Code.")
    
    def run_in_directory(self, prompt: str, cwd: str, timeout: int = 30, 
                        allowed_tools: List[str] = None,
                        system_prompt: str = None) -> Dict[str, Any]:
        """
        Run claude CLI in a specific directory and return results
        
        Returns dict with:
        - success: bool
        - output: string output from claude
        - shell_commands: list of shell commands executed (parsed from output)
        - exit_code: int
        """
        try:
            # Build command with necessary flags
            cmd = ['claude', '-p', prompt]
            
            # Add system prompt if specified
            if system_prompt:
                cmd.extend(['--system-prompt', system_prompt])
            
            # Add allowed tools if specified
            if allowed_tools:
                cmd.extend(['--allowedTools', ','.join(allowed_tools)])
            
            # Run claude with all flags
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            # Parse shell commands from output (look for bash blocks)
            shell_commands = self._extract_shell_commands(result.stdout)
            
            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr,
                "shell_commands": shell_commands,
                "exit_code": result.returncode
            }
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "output": "",
                "error": "Command timed out",
                "shell_commands": [],
                "exit_code": -1
            }
    
    def _extract_shell_commands(self, output: str) -> List[str]:
        """Extract shell commands from claude output"""
        commands = []
        in_bash_block = False
        current_block = []
        
        for line in output.split('\n'):
            if line.strip() == '```bash':
                in_bash_block = True
                current_block = []
            elif line.strip() == '```' and in_bash_block:
                in_bash_block = False
                if current_block:
                    commands.extend(current_block)
            elif in_bash_block:
                # Skip empty lines and comments
                if line.strip() and not line.strip().startswith('#'):
                    commands.append(line)
        
        return commands


def create_claude_client(model: str = "claude-3-haiku-20240307") -> ClaudeTestClient:
    """Create a Claude test client"""
    return ClaudeTestClient(model=model)


def run_claude_in_test_dir(prompt: str, test_dir: str, 
                          allowed_tools: List[str] = None,
                          with_claudepm_context: bool = False) -> Dict[str, Any]:
    """
    Run claude in a test directory and return results
    
    Args:
        prompt: The prompt to send to claude
        test_dir: Directory to run in
        allowed_tools: List of tools to allow (default: ["Read", "Bash"])
        with_claudepm_context: If True, use CLAUDE.md as system prompt
    """
    client = create_claude_client()
    
    # Default tools for claudepm testing
    if allowed_tools is None:
        allowed_tools = ["Read", "Bash", "Grep", "LS"]
    
    # If requested, use CLAUDE.md as system prompt
    system_prompt = None
    if with_claudepm_context:
        claude_md_path = os.path.join(test_dir, "CLAUDE.md")
        if os.path.exists(claude_md_path):
            with open(claude_md_path, 'r') as f:
                system_prompt = f.read()
    
    return client.run_in_directory(prompt, test_dir, 
                                 allowed_tools=allowed_tools,
                                 system_prompt=system_prompt)


def setup_test_environment(base_dir: str, setup_files: Dict[str, str]) -> str:
    """
    Create a test environment with specified files
    
    Args:
        base_dir: Base directory for test
        setup_files: Dict of filename -> content
    
    Returns:
        Path to test directory
    """
    test_dir = tempfile.mkdtemp(prefix="claudepm-test-", dir=base_dir)
    
    for filename, content in setup_files.items():
        filepath = os.path.join(test_dir, filename)
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(content)
    
    return test_dir


def cleanup_test_environment(test_dir: str):
    """Clean up test environment"""
    if os.path.exists(test_dir):
        # Remove append-only flag if present (macOS)
        if sys.platform == "darwin":
            subprocess.run(['find', test_dir, '-name', 'CLAUDE_LOG.md', '-exec', 
                          'chflags', 'nouappnd', '{}', ';'], stderr=subprocess.DEVNULL)
        shutil.rmtree(test_dir)


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


def assert_shell_commands_contain(commands: List[str], pattern: str) -> None:
    """Assert that shell commands contain a specific pattern"""
    for cmd in commands:
        if pattern in cmd:
            return
    raise AssertionError(f"No command contains pattern: {pattern}")


def assert_shell_commands_not_contain(commands: List[str], pattern: str) -> None:
    """Assert that shell commands don't contain a specific pattern"""
    for cmd in commands:
        if pattern in cmd:
            raise AssertionError(f"Command contains forbidden pattern: {pattern}\nCommand: {cmd}")


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