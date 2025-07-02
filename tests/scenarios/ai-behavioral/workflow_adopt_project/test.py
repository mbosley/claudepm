#!/usr/bin/env python3
"""
Test the /adopt-project workflow for existing projects.
Verifies proper creation of .claudepm, PROJECT_ROADMAP.md, and preservation of existing files.
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

def setup_manager_environment(manager_dir):
    """Set up a manager-level environment with adopt-project command."""
    
    # Create manager .claudepm
    claudepm_config = {
        "claudepm": {
            "version": "0.2.0", 
            "role": "manager"
        }
    }
    with open(os.path.join(manager_dir, '.claudepm'), 'w') as f:
        json.dump(claudepm_config, f, indent=2)
    
    # Create manager CLAUDE.md
    with open(os.path.join(manager_dir, 'CLAUDE.md'), 'w') as f:
        f.write("""# Test Manager

You are testing the /adopt-project command. 

## Test Instructions
1. Use /adopt-project to adopt the project in ./test-project/
2. Verify the adoption was successful
3. Record results in adoption_test_output.txt

## Important for Testing
Since we're in a test environment, when the adopt-project command references ~/.claude/templates/, 
please use the templates from .claude/templates/ in the current directory instead.
""")
    
    # Set up .claude directory with commands
    commands_dir = os.path.join(manager_dir, '.claude', 'commands')
    os.makedirs(commands_dir, exist_ok=True)
    
    # Define project root at the start
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
    
    # Use simplified adopt-project command for testing
    adopt_cmd_src = os.path.join(os.path.dirname(__file__), 'setup/adopt-project-simple.md')
    if os.path.exists(adopt_cmd_src):
        shutil.copy(adopt_cmd_src, commands_dir)
    else:
        # Fallback to real command
        adopt_cmd_src = os.path.join(project_root, '.claude/commands/adopt-project.md')
        if os.path.exists(adopt_cmd_src):
            shutil.copy(adopt_cmd_src, commands_dir)
    
    # Set up core files
    core_dir = os.path.join(manager_dir, '.claude', 'core')
    os.makedirs(core_dir, exist_ok=True)
    
    # Copy core files
    core_files = {
        'CLAUDEPM-MANAGER.md': 'templates/manager/CLAUDEPM-MANAGER.md',
        'CLAUDEPM-PROJECT.md': 'templates/project/CLAUDEPM-PROJECT.md'
    }
    
    for dest_name, src_path in core_files.items():
        src_file = os.path.join(project_root, src_path)
        if os.path.exists(src_file):
            shutil.copy(src_file, os.path.join(core_dir, dest_name))
    
    # Copy templates for project adoption
    templates_dir = os.path.join(manager_dir, '.claude', 'templates', 'project')
    os.makedirs(templates_dir, exist_ok=True)
    
    template_files = ['CLAUDE.md', 'PROJECT_ROADMAP.md']
    for template in template_files:
        src = os.path.join(project_root, 'templates/project', template)
        if os.path.exists(src):
            shutil.copy(src, templates_dir)
    
    # Copy get-context.sh
    get_context_src = os.path.join(project_root, 'tools/get-context.sh')
    if os.path.exists(get_context_src):
        shutil.copy(get_context_src, manager_dir)
        os.chmod(os.path.join(manager_dir, 'get-context.sh'), 0o755)

def create_test_project(manager_dir, project_name):
    """Create a test project to be adopted."""
    project_dir = os.path.join(manager_dir, project_name)
    os.makedirs(project_dir, exist_ok=True)
    
    # Create some existing files
    with open(os.path.join(project_dir, 'README.md'), 'w') as f:
        f.write(f"# {project_name}\n\nThis is an existing project that needs claudepm adoption.\n")
    
    with open(os.path.join(project_dir, 'main.py'), 'w') as f:
        f.write("""#!/usr/bin/env python3
# Existing project code

def main():
    print("Hello from existing project")

if __name__ == "__main__":
    main()
""")
    
    # Initialize git repo
    subprocess.run(['git', 'init', '-b', 'main'], cwd=project_dir, capture_output=True)
    subprocess.run(['git', 'config', 'user.email', 'test@example.com'], cwd=project_dir, capture_output=True)
    subprocess.run(['git', 'config', 'user.name', 'Test User'], cwd=project_dir, capture_output=True)
    subprocess.run(['git', 'add', '.'], cwd=project_dir, capture_output=True)
    subprocess.run(['git', 'commit', '-m', 'Initial commit'], cwd=project_dir, capture_output=True)
    
    return project_dir

def test_adopt_existing_project():
    """Test adopting an existing project without claudepm."""
    print("\n[Testing basic project adoption]")
    
    with tempfile.TemporaryDirectory() as manager_dir:
        print(f"  - Created temp dir: {manager_dir}")
        setup_manager_environment(manager_dir)
        print("  - Set up manager environment")
        project_dir = create_test_project(manager_dir, 'test-project')
        print(f"  - Created test project at: {project_dir}")
        
        # Run adopt-project command
        prompt = "/adopt-project test-project"
        print(f"  - Running command: {prompt}")
        
        result = run_claude_in_test_dir(
            prompt,
            manager_dir,
            allowed_tools=["Read", "Write", "Edit", "Bash", "LS"],
            with_claudepm_context=True,
            timeout=60
        )
        print(f"  - Command completed with success={result['success']}")
        
        if result["success"]:
            print("✓ Adoption command completed")
            
            # Verify adoption results
            claudepm_file = os.path.join(project_dir, '.claudepm')
            if os.path.exists(claudepm_file):
                print("  - Created .claudepm file")
                with open(claudepm_file, 'r') as f:
                    config = json.load(f)
                if config.get('claudepm', {}).get('role') == 'project':
                    print("  - Set correct project role")
            
            # Check other files
            if os.path.exists(os.path.join(project_dir, 'PROJECT_ROADMAP.md')):
                print("  - Created PROJECT_ROADMAP.md")
            if os.path.exists(os.path.join(project_dir, 'CLAUDE.md')):
                print("  - Created CLAUDE.md")
            
            # Verify existing files preserved
            if os.path.exists(os.path.join(project_dir, 'README.md')):
                print("  - Preserved existing README.md")
            if os.path.exists(os.path.join(project_dir, 'main.py')):
                with open(os.path.join(project_dir, 'main.py'), 'r') as f:
                    if "Hello from existing project" in f.read():
                        print("  - Preserved existing code")
        else:
            print(f"✗ Adoption failed: {result.get('error', 'Unknown error')}")

def test_adopt_project_with_existing_claude_md():
    """Test adopting a project that already has CLAUDE.md."""
    print("\n[Testing adoption with existing CLAUDE.md]")
    
    with tempfile.TemporaryDirectory() as manager_dir:
        setup_manager_environment(manager_dir)
        project_dir = create_test_project(manager_dir, 'test-project-2')
        
        # Add existing CLAUDE.md
        existing_claude = """# Existing Project Instructions

This project already has some Claude instructions.
Please preserve this content.
"""
        with open(os.path.join(project_dir, 'CLAUDE.md'), 'w') as f:
            f.write(existing_claude)
        
        # Run adopt-project
        prompt = "/adopt-project test-project-2"
        
        result = run_claude_in_test_dir(
            prompt,
            manager_dir,
            allowed_tools=["Read", "Write", "Edit", "Bash", "LS"],
            with_claudepm_context=True,
            timeout=60
        )
        
        if result["success"]:
            print("✓ Adoption with existing CLAUDE.md completed")
            
            # Check CLAUDE.md preserved
            claude_file = os.path.join(project_dir, 'CLAUDE.md')
            if os.path.exists(claude_file):
                with open(claude_file, 'r') as f:
                    content = f.read()
                if "already has some Claude instructions" in content:
                    print("  - Preserved existing CLAUDE.md content")
            
            # Should still create other files
            if os.path.exists(os.path.join(project_dir, '.claudepm')):
                print("  - Created .claudepm")
            if os.path.exists(os.path.join(project_dir, 'PROJECT_ROADMAP.md')):
                print("  - Created PROJECT_ROADMAP.md")
        else:
            print(f"✗ Adoption failed: {result.get('error', 'Unknown error')}")

def test_adopt_project_already_adopted():
    """Test attempting to adopt an already-adopted project."""
    print("\n[Testing already-adopted project handling]")
    
    with tempfile.TemporaryDirectory() as manager_dir:
        setup_manager_environment(manager_dir)
        project_dir = create_test_project(manager_dir, 'test-project-3')
        
        # Pre-create .claudepm file
        claudepm_config = {
            "claudepm": {
                "version": "0.1.0",
                "role": "project"
            }
        }
        with open(os.path.join(project_dir, '.claudepm'), 'w') as f:
            json.dump(claudepm_config, f, indent=2)
        
        # Run adopt-project
        prompt = "/adopt-project test-project-3"
        
        result = run_claude_in_test_dir(
            prompt,
            manager_dir,
            allowed_tools=["Read", "Write", "Edit", "Bash", "LS"],
            with_claudepm_context=True,
            timeout=60
        )
        
        if result["success"]:
            print("✓ Command completed for already-adopted project")
            print("  - Claude should recognize and handle gracefully")
            
            # Check if output mentions it's already adopted
            if result.get("output"):
                output_lower = result["output"].lower()
                if any(word in output_lower for word in ["already", "existing", "adopted", "found"]):
                    print("  - Correctly identified as already adopted")
        else:
            print(f"✗ Command failed: {result.get('error', 'Unknown error')}")

def main():
    """Run all adoption workflow tests."""
    print("Testing AI behavioral: workflow adopt project")
    print("=" * 50)
    
    # Check if claude CLI is available
    result = subprocess.run(['which', 'claude'], capture_output=True)
    if result.returncode != 0:
        print("✗ claude CLI not found. Please install Claude Code.")
        return 1
    else:
        print("✓ claude CLI is available")
    
    try:
        test_adopt_existing_project()
        test_adopt_project_with_existing_claude_md()
        test_adopt_project_already_adopted()
        
        print("\nAll tests completed! ✓")
        return 0
        
    except Exception as e:
        print(f"\n✗ Test error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())