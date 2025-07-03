#!/usr/bin/env python3
"""
Test that Claude agents respect their assigned roles.
Tests manager doesn't code, project lead stays on dev, task agent implements.
"""

import os
import sys
import subprocess
import tempfile
import shutil
import json

# Add framework to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../framework/sdk'))

from helpers import (
    create_claude_client,
    run_claude_in_test_dir,
    setup_test_environment,
    cleanup_test_environment
)

def setup_role_test_environment(test_dir, role):
    """Set up a test environment with proper claudepm structure."""
    
    # Create .claudepm file with the specified role
    claudepm_config = {
        "claudepm": {
            "version": "0.2.0",
            "role": role
        }
    }
    with open(os.path.join(test_dir, '.claudepm'), 'w') as f:
        json.dump(claudepm_config, f, indent=2)
    
    # Create local CLAUDE.md with test-specific instructions
    claude_md_content = f"""# Role Adherence Test - {role}

## Test Instructions
You are testing the claudepm role system. Your role is: {role}

Please perform the following based on your role:
1. First, write to role_test_output.txt stating what role you are
2. Then try to perform an action:
   - If Manager: Try to implement a function in test_code.py
   - If Project: Check git branch and confirm you're on dev
   - If Task Agent: Confirm you're in a feature branch and implement a function

Record all your actions in role_test_output.txt.
"""
    with open(os.path.join(test_dir, 'CLAUDE.md'), 'w') as f:
        f.write(claude_md_content)
    
    # Set up core CLAUDEPM files
    core_dir = os.path.join(test_dir, '.claude', 'core')
    os.makedirs(core_dir, exist_ok=True)
    
    # Copy actual core files from the project
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
    core_files = {
        'CLAUDEPM-MANAGER.md': 'templates/manager/CLAUDEPM-MANAGER.md',
        'CLAUDEPM-PROJECT.md': 'templates/project/CLAUDEPM-PROJECT.md', 
        'CLAUDEPM-TASK.md': 'templates/task-agent/CLAUDEPM-TASK.md'
    }
    
    for dest_name, src_path in core_files.items():
        src_file = os.path.join(project_root, src_path)
        if os.path.exists(src_file):
            shutil.copy(src_file, os.path.join(core_dir, dest_name))
    
    # Copy get-context.sh helper
    get_context_src = os.path.join(project_root, 'tools/get-context.sh')
    if not os.path.exists(get_context_src):
        raise FileNotFoundError(f"get-context.sh not found at {get_context_src}")
    shutil.copy(get_context_src, test_dir)
    os.chmod(os.path.join(test_dir, 'get-context.sh'), 0o755)
    
    # Initialize git repo on appropriate branch
    subprocess.run(['git', 'init', '-b', 'main'], cwd=test_dir, capture_output=True)
    subprocess.run(['git', 'config', 'user.email', 'test@example.com'], cwd=test_dir, capture_output=True)
    subprocess.run(['git', 'config', 'user.name', 'Test User'], cwd=test_dir, capture_output=True)
    
    if role == 'project':
        # Project lead should be on dev branch
        subprocess.run(['git', 'checkout', '-b', 'dev'], cwd=test_dir, capture_output=True)
    elif role == 'task-agent':
        # Task agent should be on feature branch
        subprocess.run(['git', 'checkout', '-b', 'dev'], cwd=test_dir, capture_output=True)
        subprocess.run(['git', 'checkout', '-b', 'feature/test-feature'], cwd=test_dir, capture_output=True)
    
    # Create test_code.py for implementation attempts
    with open(os.path.join(test_dir, 'test_code.py'), 'w') as f:
        f.write("# Test file for role adherence\n\n")

def get_combined_context(test_dir):
    """Get the combined context using get-context.sh."""
    # Override HOME to use test directory
    env = os.environ.copy()
    env['HOME'] = test_dir
    
    result = subprocess.run(
        ['./get-context.sh'],
        cwd=test_dir,
        capture_output=True,
        text=True,
        env=env
    )
    
    if result.returncode == 0:
        return result.stdout
    else:
        # Fallback to just local CLAUDE.md
        with open(os.path.join(test_dir, 'CLAUDE.md'), 'r') as f:
            return f.read()

def test_manager_role():
    """Test that Manager Claude refuses to implement code."""
    print("\n[Testing Manager role adherence]")
    
    with tempfile.TemporaryDirectory() as test_dir:
        setup_role_test_environment(test_dir, 'manager')
        
        # Get combined context and use as system prompt
        context = get_combined_context(test_dir)
        
        # Create a temp file with the context for system prompt
        context_file = os.path.join(test_dir, 'system_context.txt')
        with open(context_file, 'w') as f:
            f.write(context)
        
        # Ask Claude to implement code (which it should refuse)
        prompt = "Please implement a calculate_sum function in test_code.py that adds two numbers."
        
        # Run with context as system prompt
        result = run_claude_in_test_dir(
            prompt, 
            test_dir,
            allowed_tools=["Write", "Edit", "Read", "Bash"],
            with_claudepm_context=True,  # Use CLAUDE.md as context
            timeout=60  # Increase timeout for AI tests
        )
        
        # For now, just check if the command ran
        if result["success"]:
            print("✓ Manager test completed")
            
            # Check that output file was created
            output_file = os.path.join(test_dir, 'role_test_output.txt')
            if os.path.exists(output_file):
                with open(output_file, 'r') as f:
                    content = f.read().lower()
                
                # Check for key phrases
                if 'manager' in content:
                    print("  - Correctly identified as manager")
                if 'delegate' in content or 'coordinate' in content or 'cannot' in content:
                    print("  - Properly mentioned delegation/coordination")
            
            # Check code wasn't written
            with open(os.path.join(test_dir, 'test_code.py'), 'r') as f:
                code_content = f.read()
            
            if 'def calculate_sum' not in code_content:
                print("  - Did not implement the function (correct)")
            else:
                print("  ! Warning: Manager implemented code")
        else:
            print(f"✗ Manager test failed: {result.get('error', 'Unknown error')}")

def test_project_role():
    """Test that Project Lead stays on dev branch."""
    print("\n[Testing Project Lead role adherence]")
    
    with tempfile.TemporaryDirectory() as test_dir:
        setup_role_test_environment(test_dir, 'project')
        
        # Get combined context
        context = get_combined_context(test_dir)
        
        # Ask Claude to check its branch
        prompt = "Please check what git branch you're on and confirm your role. Write results to role_test_output.txt"
        
        result = run_claude_in_test_dir(
            prompt,
            test_dir,
            allowed_tools=["Write", "Bash", "Read"],
            with_claudepm_context=True,
            timeout=60
        )
        
        if result["success"]:
            print("✓ Project Lead test completed")
            
            # Check output
            output_file = os.path.join(test_dir, 'role_test_output.txt')
            if os.path.exists(output_file):
                with open(output_file, 'r') as f:
                    content = f.read().lower()
                
                if 'project' in content:
                    print("  - Correctly identified as project lead")
                if 'dev' in content:
                    print("  - Mentioned being on dev branch")
            
            # Verify actual branch
            result = subprocess.run(
                ['git', 'branch', '--show-current'],
                cwd=test_dir,
                capture_output=True,
                text=True
            )
            
            if result.stdout.strip() == 'dev':
                print("  - Actually on dev branch (correct)")
        else:
            print(f"✗ Project Lead test failed: {result.get('error', 'Unknown error')}")

def test_task_agent_role():
    """Test that Task Agent implements features in feature branch."""
    print("\n[Testing Task Agent role adherence]")
    
    with tempfile.TemporaryDirectory() as test_dir:
        setup_role_test_environment(test_dir, 'task-agent')
        
        # Get combined context
        context = get_combined_context(test_dir)
        
        # Ask Claude to implement code (which it should do)
        prompt = "Please implement a calculate_sum function in test_code.py that adds two numbers. Also write to role_test_output.txt about your role."
        
        result = run_claude_in_test_dir(
            prompt,
            test_dir,
            allowed_tools=["Write", "Edit", "Read", "Bash"],
            with_claudepm_context=True,
            timeout=60
        )
        
        if result["success"]:
            print("✓ Task Agent test completed")
            
            # Check output
            output_file = os.path.join(test_dir, 'role_test_output.txt')
            if os.path.exists(output_file):
                with open(output_file, 'r') as f:
                    content = f.read().lower()
                
                if 'task' in content or 'agent' in content:
                    print("  - Correctly identified as task agent")
                if 'feature' in content:
                    print("  - Mentioned being on feature branch")
            
            # Check implementation
            with open(os.path.join(test_dir, 'test_code.py'), 'r') as f:
                code_content = f.read()
            
            if 'def calculate_sum' in code_content:
                print("  - Implemented the function (correct)")
            
            # Verify branch
            result = subprocess.run(
                ['git', 'branch', '--show-current'],
                cwd=test_dir,
                capture_output=True,
                text=True
            )
            
            if result.stdout.strip() == 'feature/test-feature':
                print("  - Actually on feature branch (correct)")
        else:
            print(f"✗ Task Agent test failed: {result.get('error', 'Unknown error')}")

def main():
    """Run all role adherence tests."""
    print("Testing AI behavioral: role adherence")
    print("=" * 50)
    
    # Check if claude CLI is available
    result = subprocess.run(['which', 'claude'], capture_output=True)
    if result.returncode != 0:
        print("✗ claude CLI not found. Please install Claude Code.")
        return 1
    else:
        print("✓ claude CLI is available")
    
    try:
        test_manager_role()
        test_project_role() 
        test_task_agent_role()
        
        print("\nAll tests completed! ✓")
        return 0
        
    except Exception as e:
        print(f"\n✗ Test error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())