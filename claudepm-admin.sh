#!/bin/bash
#
# claudepm-admin.sh - Foolproof git worktree management for claudepm
#
# Provides safe, role-aware commands for the Project Lead to manage
# Task Agent worktrees. Enforces that the lead is on the 'dev' branch
# for all operations and prevents accidental operations on 'main'.

# --- Configuration ---
PROJECT_LEAD_BRANCH="dev"
TASK_AGENT_BRANCH_PREFIX="feature/"
WORKTREE_DIR="worktrees"
MAIN_BRANCH="main"
PROMPTS_ARCHIVE_DIR=".prompts_archive"
TEMPLATE_FILE="templates/project/TASK_PROMPT.template.md"
API_QUERIES_DIR=".api-queries"

# --- Colors for feedback ---
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # No Color

# --- Helper Functions ---

# Function to print error messages and exit
function error_exit {
    echo -e "${COLOR_RED}ERROR: $1${COLOR_NC}" >&2
    exit 1
}

# Function to verify the current git branch
function verify_branch {
    local expected_branch=$1
    local current_branch=$(git symbolic-ref --short HEAD)
    if [[ "$current_branch" != "$expected_branch" ]]; then
        error_exit "This command must be run from the '${COLOR_YELLOW}${expected_branch}${COLOR_RED}' branch. You are currently on '${COLOR_YELLOW}${current_branch}${COLOR_RED}'."
    fi
}

# Function to prevent operations on a specific branch
function prevent_branch {
    local forbidden_branch=$1
    local current_branch=$(git symbolic-ref --short HEAD)
    if [[ "$current_branch" == "$forbidden_branch" ]]; then
        error_exit "This script cannot be run on the '${COLOR_YELLOW}${forbidden_branch}${COLOR_RED}' branch for safety reasons."
    fi
}

# Function to generate TASK_PROMPT.md from template
function generate_task_prompt {
    local feature_name=$1
    local worktree_path=$2
    
    # Check if template exists
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo -e "${COLOR_YELLOW}Warning: TASK_PROMPT template not found at ${TEMPLATE_FILE}${COLOR_NC}"
        return 1
    fi
    
    # Look for architectural review
    local arch_review=""
    local arch_file="${API_QUERIES_DIR}/*-${feature_name}.md"
    for file in $arch_file; do
        if [[ -f "$file" ]]; then
            echo -e "${COLOR_BLUE}Found architectural review: ${file}${COLOR_NC}"
            arch_review=$'\n## Architectural Review\n\n'
            arch_review+=$(cat "$file")
            break
        fi
    done
    
    # Generate TASK_PROMPT.md by replacing placeholders
    # First create the file with feature name replaced
    sed "s/{{FEATURE_NAME}}/${feature_name}/g" "$TEMPLATE_FILE" > "${worktree_path}/TASK_PROMPT.md"
    
    # Now handle the architectural review placeholder
    if [[ -n "$arch_review" ]]; then
        # Create a temporary file with the content before the placeholder
        sed '/{{ARCHITECTURAL_REVIEW}}/q' "${worktree_path}/TASK_PROMPT.md" | sed '$d' > "${worktree_path}/TASK_PROMPT.md.tmp"
        # Add the architectural review
        echo "$arch_review" >> "${worktree_path}/TASK_PROMPT.md.tmp"
        # Add any content after the placeholder
        sed '1,/{{ARCHITECTURAL_REVIEW}}/d' "${worktree_path}/TASK_PROMPT.md" >> "${worktree_path}/TASK_PROMPT.md.tmp"
        # Replace the original file
        mv "${worktree_path}/TASK_PROMPT.md.tmp" "${worktree_path}/TASK_PROMPT.md"
    else
        # Just remove the placeholder
        sed -i.bak 's/{{ARCHITECTURAL_REVIEW}}//' "${worktree_path}/TASK_PROMPT.md"
        rm "${worktree_path}/TASK_PROMPT.md.bak"
    fi
    
    echo -e "${COLOR_GREEN}Generated TASK_PROMPT.md in ${worktree_path}${COLOR_NC}"
}

# Function to archive TASK_PROMPT.md when removing worktree
function archive_task_prompt {
    local feature_name=$1
    local worktree_path=$2
    
    # Create archive directory if it doesn't exist
    [[ ! -d "$PROMPTS_ARCHIVE_DIR" ]] && mkdir -p "$PROMPTS_ARCHIVE_DIR"
    
    # Archive TASK_PROMPT.md if it exists
    if [[ -f "${worktree_path}/TASK_PROMPT.md" ]]; then
        local archive_name="${PROMPTS_ARCHIVE_DIR}/$(date '+%Y-%m-%d')-${feature_name}.md"
        cp "${worktree_path}/TASK_PROMPT.md" "$archive_name"
        echo -e "${COLOR_GREEN}Archived TASK_PROMPT.md to ${archive_name}${COLOR_NC}"
    fi
}
# --- Main Script Logic ---

# Global safety check: never run on main
prevent_branch "$MAIN_BRANCH"

COMMAND=$1
FEATURE_NAME=$2

case "$COMMAND" in
    create-worktree)
        verify_branch "$PROJECT_LEAD_BRANCH"
        [[ -z "$FEATURE_NAME" ]] && error_exit "Usage: $0 create-worktree <feature-name>"

        branch_name="${TASK_AGENT_BRANCH_PREFIX}${FEATURE_NAME}"
        worktree_path="${WORKTREE_DIR}/${FEATURE_NAME}"

        if [[ -d "$worktree_path" ]]; then
            error_exit "Worktree path '${COLOR_YELLOW}${worktree_path}${COLOR_RED}' already exists."
        fi
        if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
            error_exit "Branch '${COLOR_YELLOW}${branch_name}${COLOR_RED}' already exists."
        fi

        echo -e "${COLOR_BLUE}Creating branch '${COLOR_YELLOW}${branch_name}${COLOR_BLUE}' and worktree at '${COLOR_YELLOW}${worktree_path}${COLOR_BLUE}'...${COLOR_NC}"
        git worktree add -b "$branch_name" "$worktree_path"
        
        # Generate TASK_PROMPT.md
        generate_task_prompt "$FEATURE_NAME" "$worktree_path"
        
        echo -e "${COLOR_GREEN}Success! Task Agent can now start in '${COLOR_YELLOW}${worktree_path}${COLOR_GREEN}'.${COLOR_NC}"
        ;;

    remove-worktree)
        verify_branch "$PROJECT_LEAD_BRANCH"
        [[ -z "$FEATURE_NAME" ]] && error_exit "Usage: $0 remove-worktree <feature-name>"

        branch_name="${TASK_AGENT_BRANCH_PREFIX}${FEATURE_NAME}"
        worktree_path="${WORKTREE_DIR}/${FEATURE_NAME}"

        if [[ ! -d "$worktree_path" ]]; then
            error_exit "Worktree path '${COLOR_YELLOW}${worktree_path}${COLOR_RED}' does not exist."
        fi

        echo -e "${COLOR_YELLOW}This will permanently delete the worktree and branch '${branch_name}'. Are you sure? (y/n) ${COLOR_NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${COLOR_BLUE}Removing worktree and branch...${COLOR_NC}"
            
            # Archive TASK_PROMPT.md before removing worktree
            archive_task_prompt "$FEATURE_NAME" "$worktree_path"
            
            git worktree remove "$worktree_path"
            git branch -D "$branch_name"
            echo -e "${COLOR_GREEN}Cleanup complete.${COLOR_NC}"
        else
            echo -e "${COLOR_YELLOW}Operation cancelled.${COLOR_NC}"
        fi
        ;;

    list-worktrees)
        echo -e "${COLOR_BLUE}Active worktrees:${NC}"
        git worktree list
        ;;

    *)
        echo "claudepm-admin - Git Safety Tool"
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo -e "  ${COLOR_GREEN}create-worktree <feature-name>${NC}   - Creates a new worktree and feature branch."
        echo -e "  ${COLOR_GREEN}remove-worktree <feature-name>${NC}   - Removes a worktree and its associated branch."
        echo -e "  ${COLOR_GREEN}list-worktrees${NC}                   - Lists all active worktrees."
        exit 1
        ;;
esac