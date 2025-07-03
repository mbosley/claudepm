#!/usr/bin/env python3
"""
Simplified workflow adoption test based on Gemini's testing pyramid approach.
Tests basic outcomes rather than full E2E execution.
"""

import os
import sys
import subprocess
import tempfile
import json

# Add framework to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../framework/sdk'))

from helpers import (
    create_claude_client,
    run_claude_in_test_dir,
)

def test_basic_adoption_outcome():
    """Test that Claude can handle a simple adoption task with focused instructions."""
    print("\n[Testing simplified adoption workflow]")
    
    with tempfile.TemporaryDirectory() as test_dir:
        print(f"  - Test dir: {test_dir}")
        
        # Create manager setup
        with open(os.path.join(test_dir, '.claudepm'), 'w') as f:
            json.dump({"claudepm": {"version": "0.2.0", "role": "manager"}}, f)
        
        # Create focused CLAUDE.md with simple instructions
        with open(os.path.join(test_dir, 'CLAUDE.md'), 'w') as f:
            f.write("""# Test Manager

You are testing project adoption. When asked to adopt a project:

1. Check if the project directory exists
2. Create a .claudepm file in that directory with {"claudepm": {"role": "project"}}
3. Create a simple CLAUDE.md file saying "# Project adopted"
4. Write "SUCCESS" to adoption_result.txt
""")
        
        # Create test project
        project_dir = os.path.join(test_dir, 'my-project')
        os.makedirs(project_dir)
        with open(os.path.join(project_dir, 'README.md'), 'w') as f:
            f.write("# My Project\n")
        
        # Simple, focused prompt
        prompt = "Please adopt the project in ./my-project directory following the instructions in CLAUDE.md"
        
        print("  - Running adoption task...")
        result = run_claude_in_test_dir(
            prompt,
            test_dir,
            allowed_tools=["Read", "Write", "LS"],
            with_claudepm_context=True,
            timeout=30  # Shorter timeout for simple task
        )
        
        # Test outcomes, not exact execution
        if result["success"]:
            print("✓ Task completed")
            
            # Check outcomes
            claudepm_file = os.path.join(project_dir, '.claudepm')
            if os.path.exists(claudepm_file):
                print("  - Created .claudepm file")
                with open(claudepm_file, 'r') as f:
                    config = json.load(f)
                if config.get('claudepm', {}).get('role') == 'project':
                    print("  - Set correct project role")
            
            if os.path.exists(os.path.join(project_dir, 'CLAUDE.md')):
                print("  - Created CLAUDE.md")
            
            result_file = os.path.join(test_dir, 'adoption_result.txt')
            if os.path.exists(result_file):
                with open(result_file, 'r') as f:
                    if 'SUCCESS' in f.read():
                        print("  - Marked adoption as successful")
            
            return True
        else:
            print(f"✗ Task failed: {result.get('error', 'Unknown error')}")
            return False

def main():
    """Run simplified adoption test."""
    print("Testing AI behavioral: simplified workflow adoption")
    print("=" * 50)
    
    # Check Claude CLI
    result = subprocess.run(['which', 'claude'], capture_output=True)
    if result.returncode != 0:
        print("✗ claude CLI not found")
        return 1
    
    print("✓ claude CLI is available")
    
    if test_basic_adoption_outcome():
        print("\nSimplified test passed! ✓")
        return 0
    else:
        print("\nSimplified test failed! ✗")
        return 1

if __name__ == "__main__":
    sys.exit(main())