# ClaudePM Conventions

## Task Format (Human-Readable Markdown)

Tasks in ROADMAP.md use a human-readable markdown checkbox format with inline metadata:

```markdown
- [ ] Task description [priority] [#tag1, #tag2] [due:YYYY-MM-DD] [@assignee] [estimate]
  ID: <uuid>
```

### Core Metadata:
- **[priority]** - high, medium, or low (optional)
- **[#tags]** - Comma-separated tags for categorization (optional)
- **[due:date]** - Due date in YYYY-MM-DD format (optional)
- **[@assignee]** - Person responsible (optional)
- **[estimate]** - Time estimate like 2h, 1d, 1w (optional)

### Status-Specific Metadata:
- **[started:date]** - Date work began (IN PROGRESS tasks)
- **[completed:date]** - Date completed (DONE tasks)
- **[blocked:reason]** - Blocker description (BLOCKED tasks)

### Task Sections:
Tasks are organized by status under these headers:
- **TODO** - Not yet started
- **IN PROGRESS** - Currently being worked on
- **BLOCKED** - Waiting on external dependencies
- **DONE** - Completed tasks (marked with [x])

### Examples:
```markdown
## Tasks

### TODO
- [ ] Implement user authentication [high] [#auth, #security] [due:2025-01-15] [@alice] [3d]
  ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

### IN PROGRESS
- [ ] Refactor database layer [medium] [#backend] [started:2025-01-02]
  ID: b2c3d4e5-f6a7-8901-bcde-f23456789012

### BLOCKED
- [ ] Deploy to production [high] [blocked:Waiting for AWS credentials]
  ID: c3d4e5f6-a7b8-9012-cdef-345678901234

### DONE
- [x] Set up CI/CD pipeline [completed:2025-01-01]
  ID: d4e5f6a7-b8c9-0123-defg-456789012345
```

### Migration from Old Format:
The old `CPM::TASK::<uuid>::<status>::<date>::<description>` format is automatically migrated to the new format when running `claudepm upgrade`.

## File Naming Conventions

- **CLAUDE.md** - Project-specific instructions (never LOG.md or Claude.md)
- **LOG.md** - Append-only work log (never CLAUDE_LOG.md)
- **ROADMAP.md** - Project roadmap and tasks (never ROADMAP.md)
- **NOTES.md** - Project insights and notes

## Git Conventions

- Commit completed work promptly
- Update ROADMAP.md before committing
- Use descriptive commit messages
- Include task UUIDs in commits when applicable

## Log Entry Format

```
### YYYY-MM-DD HH:MM - Brief description
Did: What was accomplished
Next: Immediate next steps
Blocked: Any blockers (optional)
Notes: Additional context (optional)
```

## Version Management

- Template versions follow semantic versioning (e.g., 0.2.5)
- Projects track their template version in .claudepm
- Use `claudepm upgrade` to update templates