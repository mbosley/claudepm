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

# --- Main Script Logic ---

# Global safety check: never run on main
prevent_branch "$MAIN_BRANCH"

COMMAND=$1
FEATURE_NAME=$2

case "$COMMAND" in
    create-worktree)
        verify_branch "$PROJECT_LEAD_BRANCH"
        [[ -z "$FEATURE_NAME" ]] && error_exit "Usage: $0 create-worktree <feature-name>"

        local branch_name="${TASK_AGENT_BRANCH_PREFIX}${FEATURE_NAME}"
        local worktree_path="${WORKTREE_DIR}/${FEATURE_NAME}"

        if [[ -d "$worktree_path" ]]; then
            error_exit "Worktree path '${COLOR_YELLOW}${worktree_path}${COLOR_RED}' already exists."
        fi
        if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
            error_exit "Branch '${COLOR_YELLOW}${branch_name}${COLOR_RED}' already exists."
        fi

        echo -e "${COLOR_BLUE}Creating branch '${COLOR_YELLOW}${branch_name}${COLOR_BLUE}' and worktree at '${COLOR_YELLOW}${worktree_path}${COLOR_BLUE}'...${COLOR_NC}"
        git worktree add -b "$branch_name" "$worktree_path"
        echo -e "${COLOR_GREEN}Success! Task Agent can now start in '${COLOR_YELLOW}${worktree_path}${COLOR_GREEN}'.${COLOR_NC}"
        ;;

    remove-worktree)
        verify_branch "$PROJECT_LEAD_BRANCH"
        [[ -z "$FEATURE_NAME" ]] && error_exit "Usage: $0 remove-worktree <feature-name>"

        local branch_name="${TASK_AGENT_BRANCH_PREFIX}${FEATURE_NAME}"
        local worktree_path="${WORKTREE_DIR}/${FEATURE_NAME}"

        if [[ ! -d "$worktree_path" ]]; then
            error_exit "Worktree path '${COLOR_YELLOW}${worktree_path}${COLOR_RED}' does not exist."
        fi

        read -p "$(echo -e ${COLOR_YELLOW}This will permanently delete the worktree and branch '${branch_name}'. Are you sure? (y/n) ${COLOR_NC})" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${COLOR_BLUE}Removing worktree and branch...${COLOR_NC}"
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