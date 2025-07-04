#!/bin/bash
# Feature scoping workflow for claudepm
# Called from /scope-feature slash command to create worktree

set -euo pipefail

# Create worktree with scoped content
create_worktree() {
    local feature_name="${1:-}"
    local scoped_content="${2:-}"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required"
        return 1
    fi
    
    # Validate feature name (alphanumeric and hyphens only)
    if ! [[ "$feature_name" =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo "Error: Feature name must be alphanumeric with hyphens only"
        return 1
    fi
    
    # Check if admin script exists
    if [[ ! -f "./tools/claudepm-admin.sh" ]]; then
        echo "Error: claudepm-admin.sh not found"
        return 1
    fi
    
    # Create worktree using admin script
    if ! ./tools/claudepm-admin.sh create-worktree "$feature_name"; then
        echo "Error: Failed to create worktree"
        return 1
    fi
    
    # If we have scoped content, update the TASK_PROMPT
    if [[ -n "$scoped_content" ]] && [[ -f "worktrees/$feature_name/TASK_PROMPT.md" ]]; then
        # Save scoping artifacts
        local scoping_dir=".scoping"
        mkdir -p "$scoping_dir"
        
        # Save the scoped content with timestamp
        local timestamp=$(date '+%Y-%m-%d-%H%M')
        echo "$scoped_content" > "$scoping_dir/${feature_name}-${timestamp}.md"
        
        # Replace the task prompt with our scoped content
        echo "$scoped_content" > "worktrees/$feature_name/TASK_PROMPT.md"
        echo "✓ Updated TASK_PROMPT with scoped requirements"
        echo "✓ Saved scoping artifact to $scoping_dir/${feature_name}-${timestamp}.md"
    fi
    
    echo ""
    echo "✓ Worktree created at: worktrees/$feature_name"
    echo "✓ Ready to execute:"
    echo ""
    echo "  cd worktrees/$feature_name && claude --dangerously-skip-permission"
    echo ""
    
    return 0
}

# Main entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly
    command="${1:-}"
    
    case "$command" in
        "create-worktree")
            # Called from slash command to create worktree
            create_worktree "${2:-}" "${3:-}"
            ;;
        *)
            echo "Usage: $0 create-worktree <feature-name> [scoped-content]"
            exit 1
            ;;
    esac
fi