---
name: dispatch-task
aliases: [dispatch, task]
description: Create a worktree and dispatch a Task Agent to implement a feature
---

# Task Agent Dispatcher

**Purpose**: Create an isolated environment for a Task Agent to work on a feature, ensuring clean git state and proper separation of concerns.

## Three-Level Hierarchy

This command operates within claudepm's three-level Claude hierarchy:

1. **Manager Claude** (lives at projects root, e.g., ~/projects)
   - Coordinates across multiple projects
   - Never implements features directly

2. **Project Lead Claude** (YOU - in project directory on dev branch)
   - Reviews PRs and manages merges
   - Dispatches Task Agents for features
   - Never leaves the dev branch

3. **Task Agent Claude** (in temporary worktrees)
   - Implements specific features in isolation
   - Creates PRs back to dev
   - Gets terminated after merge

## Process

1. You provide a branch name (e.g., 'add-tests', 'fix-typo', 'user-auth')
2. This command creates a worktree and generates Task Agent instructions
3. You spawn a Task Agent with those instructions
4. Task Agent implements, commits, and creates PR
5. You review, merge, and cleanup

## Benefits

- **Isolation**: Features developed in separate directories
- **Parallelism**: Multiple Task Agents can work simultaneously
- **Safety**: No accidental commits to main branches
- **Clarity**: Clear handoff points via PRs

## When to Use

- Features from /architect-feature command
- Items from ROADMAP.md
- Bug fixes requiring investigation
- Any change touching multiple files

## When NOT to Use

- Single-line fixes (just do them directly)
- Documentation typos (quick and safe)
- Changes you want to implement yourself

## Usage

1. Run: `/dispatch-task add-user-auth`
2. Follow the generated instructions to create worktree
3. Copy the Task Agent prompt and start a NEW conversation
4. Review the PR when Task Agent completes
5. Merge and run cleanup commands

The generated prompt will include:
- Clear role definition for the Task Agent
- Implementation instructions from your architecture
- PR creation guidelines
- Specific branch/worktree information

Remember: This pattern works for ANY project using claudepm, not just claudepm itself!