# /scope-feature

Start a structured feature scoping session that outputs a ready-to-execute TASK_PROMPT.

## Usage

```
/scope-feature [feature-name]
```

## Initial Context
!`git branch --show-current`
!`git status --short`
!`ls -la .scoping/ 2>/dev/null || echo "No scoping directory yet"`

## Process

I'll guide you through a structured feature scoping session for: $ARGUMENTS

1. **Problem Statement & Requirements**
   - What problem does this solve?
   - Who benefits from this feature?
   - Key functional requirements?
   - Technical constraints?

2. **Architectural Review** (if needed)
   - Consult Gemini for architectural guidance
   - Review existing patterns in codebase
   - Identify potential challenges

3. **Implementation Plan**
   - Specific implementation steps
   - Files to modify
   - Testing approach
   - Success criteria

4. **Output Generation**
   After we complete scoping, I'll:
   - Save our conversation to `.scoping/[feature-name].md`
   - Generate a complete TASK_PROMPT.md
   - Create the worktree with: !`./lib/scope.sh create-worktree $ARGUMENTS`

The Task Agent will run with `--dangerously-skip-permission` flag for autonomous execution.

## Example

```
/scope-feature human-readable-tasks

> What problem does this feature solve?
The current CPM::TASK format is not human-readable...

> Key requirements?
1. Replace delimiter format with markdown
2. Maintain parseability
3. Provide migration path

> [Architectural consultation if needed]

Output:
- Scoping saved to .scoping/human-readable-tasks.md
- Worktree created at worktrees/human-readable-tasks
- TASK_PROMPT populated with scoped requirements
- Ready to run: cd worktrees/human-readable-tasks && claude --dangerously-skip-permission
```

This workflow reduces friction from idea to implementation-ready Task Agent.