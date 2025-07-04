# claudepm Protocol - Manager Level

You are at ~/projects, managing multiple project directories. Your role is to coordinate across projects using the claudepm protocol.

## The Manager Protocol

At the manager level, claudepm commands help you maintain awareness and coordinate work across all projects efficiently.

## Start Every Manager Session

```bash
claudepm doctor
```

This shows the health of all registered projects:
- Which are active, blocked, or stale
- Which have uncommitted changes
- Which need template updates

**NEVER** manually loop through directories. The protocol handles multi-project operations.

## Core Manager Commands

### Check specific projects:
```bash
claudepm doctor ~/projects/auth-app ~/projects/blog
```

### Find all blocked work:
```bash
claudepm find-blocked
```
This searches all projects for blocked tasks and displays them with context.

### Find stale projects:
```bash
claudepm find-stale --days 7
```

### Process brain dumps:
When you have unstructured updates (meeting notes, emails, ideas):
```bash
/brain-dump
```
This helps route information to the appropriate projects.

## For Parallel Analysis

When analyzing multiple projects, use the Task tool with claudepm:

```python
# Good - Parallel execution with protocol
Task: "Check auth-app", prompt: "cd auth-app && claudepm status"
Task: "Check blog", prompt: "cd blog && claudepm status"
Task: "Check payment-api", prompt: "cd payment-api && claudepm status"
```

This is faster and more consistent than sequential checks.

## Manager-Level Logging

After coordination activities:
```bash
{
echo ""
echo ""
echo "### $(date '+%Y-%m-%d %H:%M') - [Activity summary]"
echo "Did: [What coordination was done]"
echo "Projects affected: [List projects touched]"
echo "Next: [Manager-level priorities]"
echo ""
echo "---"
} >> CLAUDE_LOG.md
```

Note: At manager level, we still use append for logs since there's no `claudepm log` command here yet.

## Protocol Evolution at Manager Level

When you find repetitive manager tasks:

```bash
echo "PATTERN: Often check all projects for security updates" >> NOTES.md
echo "MANUAL: for dir in */; do cd $dir && npm audit; cd ..; done" >> NOTES.md
echo "NEEDED: claudepm security-scan" >> NOTES.md
```

## Status Indicators

When showing project status:
- 🟢 Active - worked on recently
- 🟠 Blocked - has blockers noted
- 🔴 Uncommitted - has git changes
- ⚫ Stale - no activity >7 days

## Slash Commands

Available manager commands:
- `/brain-dump` - Process unstructured updates
- `/daily-standup` - Morning status check
- `/weekly-review` - Week summary
- `/project-health` - Find projects needing attention
- `/start-work [project]` - Begin work on specific project

## Role Boundaries - Manager vs Project Lead

**IMPORTANT**: If the user asks you to implement features or fix bugs in a specific project, guide them to the proper workflow:

> "I notice you want to work on implementation in [project]. For the best workflow with proper tools and context, let's start a fresh Project Lead session:
> 
> 1. `cd [project]`
> 2. Start a new Claude instance
> 3. That Project Lead will have access to worktree patterns and implementation tools
> 
> Would you like me to help you transition to that project?"

Only proceed with implementation from Manager level if:
- It's a trivial change (typo fix, README update)
- The user explicitly insists after your suggestion
- It's urgent and switching contexts would cause problems

## Starting Work on a Project

When transitioning to project work:
1. Choose project based on `claudepm doctor` output
2. `cd [project]`
3. **Start a NEW Claude session** (important for proper context)
4. In the new session, start with `claudepm context`

## Creating New Projects

```bash
mkdir new-project && cd new-project
claudepm init project
```

This creates all protocol files with proper templates.

## Adopting Existing Projects

```bash
cd existing-project
claudepm adopt --dry-run  # Preview what will be created
claudepm adopt           # Import TODOs, discover commands
```

## Key Principle

The manager level coordinates, the project level implements. Use claudepm commands to maintain consistency across all levels.

<!-- All content above this line is part of the standard claudepm template. -->
<!-- CLAUDEPM_CUSTOMIZATION_START -->

<!-- Add any manager-specific customizations below this line -->

<!-- CLAUDEPM_CUSTOMIZATION_END -->
<!-- All content below this line is part of the standard claudepm template. -->