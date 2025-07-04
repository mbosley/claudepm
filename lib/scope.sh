#!/bin/bash
# Feature scoping workflow for claudepm
# Supports both interactive CLI usage and slash command integration

# Create worktree with scoped content
create_worktree() {
    local feature_name="${1:-}"
    local scoped_content="${2:-}"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required"
        return 1
    fi
    
    # Create worktree using admin script
    ./tools/claudepm-admin.sh create-worktree "$feature_name"
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create worktree"
        return 1
    fi
    
    # If we have scoped content, update the TASK_PROMPT
    if [[ -n "$scoped_content" ]] && [[ -f "worktrees/$feature_name/TASK_PROMPT.md" ]]; then
        # Replace the task prompt with our scoped content
        echo "$scoped_content" > "worktrees/$feature_name/TASK_PROMPT.md"
        echo "✓ Updated TASK_PROMPT with scoped requirements"
    fi
    
    echo ""
    echo "✓ Worktree created at: worktrees/$feature_name"
    echo "✓ Ready to execute:"
    echo ""
    echo "  cd worktrees/$feature_name && claude --dangerously-skip-permission"
    echo ""
    
    return 0
}

# Interactive scoping session (for CLI usage)
scope_feature() {
    local feature_name="${1:-}"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required"
        echo "Usage: claudepm scope <feature-name>"
        exit 1
    fi
    
    # Validate feature name (alphanumeric and hyphens only)
    if ! [[ "$feature_name" =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo "Error: Feature name must be alphanumeric with hyphens only"
        exit 1
    fi
    
    local scoping_dir=".scoping"
    local scoping_file="$scoping_dir/${feature_name}.md"
    local temp_prompt="/tmp/claudepm-scope-${feature_name}.md"
    
    # Create scoping directory if needed
    mkdir -p "$scoping_dir"
    
    # Create the scoping prompt
    cat > "$temp_prompt" << 'EOF'
# Feature Scoping Session

You are helping scope a new feature. Guide the user through a structured planning process.

## Feature Name: {{FEATURE_NAME}}

Please help me scope this feature by discussing:

1. **Problem Statement**
   - What problem does this solve?
   - Who benefits from this feature?

2. **Requirements**
   - What are the key functional requirements?
   - Any technical constraints?
   - Expected behavior and edge cases?

3. **Implementation Approach**
   - How should this be implemented?
   - What files need to be modified?
   - Any architectural considerations?

4. **Testing & Validation**
   - How will we test this?
   - What are the success criteria?

After gathering all information, output a complete TASK_PROMPT.md that includes:

# Task: {{FEATURE_NAME}}

## Overview
[Problem statement and why this feature is needed]

## Requirements
[Numbered list of specific requirements]

## Implementation Steps
[Ordered list of implementation steps]

## Testing Approach
[How to verify the implementation works]

## Git Workflow (CRITICAL - DO NOT SKIP)
After implementation is complete, you MUST:
1. Stage and commit all changes
2. Push the feature branch
3. Create a Pull Request to dev branch

Remember: The Task Agent will run with --dangerously-skip-permission flag.
EOF

    # Replace placeholder
    sed -i.bak "s/{{FEATURE_NAME}}/$feature_name/g" "$temp_prompt"
    rm "${temp_prompt}.bak"
    
    echo "Starting feature scoping session for: $feature_name"
    echo "This will launch Claude to help you plan the feature."
    echo ""
    echo "Press Enter to continue..."
    read -r
    
    # Launch Claude with the scoping prompt
    # Save the entire session to scoping file
    echo "# Feature Scoping: $feature_name" > "$scoping_file"
    echo "Date: $(date '+%Y-%m-%d %H:%M')" >> "$scoping_file"
    echo "" >> "$scoping_file"
    
    # Use Claude to run the scoping session
    # Note: This captures the structured output
    claude --system-prompt "$(cat "$temp_prompt")" \
           --print "Let's scope the feature: $feature_name" \
           > "$scoping_dir/${feature_name}-output.md"
    
    # After scoping is complete
    echo ""
    echo "Scoping session complete!"
    echo ""
    echo "Files created:"
    echo "  - $scoping_file (full session)"
    echo "  - $scoping_dir/${feature_name}-output.md (structured output)"
    echo ""
    
    # Offer to create worktree
    echo "Would you like to create the worktree now? (y/n)"
    read -r response
    
    if [[ "$response" == "y" ]]; then
        # Read the scoped output
        local scoped_content=""
        if [[ -f "$scoping_dir/${feature_name}-output.md" ]]; then
            scoped_content=$(cat "$scoping_dir/${feature_name}-output.md")
        fi
        
        create_worktree "$feature_name" "$scoped_content"
    else
        echo ""
        echo "You can create the worktree later with:"
        echo "  ./tools/claudepm-admin.sh create-worktree $feature_name"
    fi
    
    # Clean up
    rm "$temp_prompt"
}

# Main entry point - detect how we're being called
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly
    command="${1:-}"
    
    case "$command" in
        "create-worktree")
            # Called from slash command to create worktree
            create_worktree "${2:-}" "${3:-}"
            ;;
        *)
            # Default to interactive scoping
            scope_feature "${1:-}"
            ;;
    esac
fi