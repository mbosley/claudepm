# ClaudePM Conventions

## Task Format (CPM::TASK)

Tasks in ROADMAP.md follow a structured format for machine readability:

```
CPM::TASK::<uuid>::<status>::<date>::<description>
```

### Fields:
- **uuid**: Unique identifier (generated automatically)
- **status**: TODO, DOING, DONE, or BLOCKED
- **date**: Creation date in YYYY-MM-DD format
- **description**: Human-readable task description

### Examples:
```
CPM::TASK::a1b2c3d4-e5f6-7890-abcd-ef1234567890::TODO::2025-07-03::Implement user authentication
CPM::TASK::b2c3d4e5-f6a7-8901-bcde-f23456789012::DOING::2025-07-02::Refactor database layer
CPM::TASK::c3d4e5f6-a7b8-9012-cdef-345678901234::BLOCKED::2025-07-01::Deploy to production (waiting for approval)
```

## File Naming Conventions

- **CLAUDE.md** - Project-specific instructions (never LOG.md or Claude.md)
- **LOG.md** - Append-only work log (never CLAUDE_LOG.md)
- **ROADMAP.md** - Project roadmap and tasks (never PROJECT_ROADMAP.md)
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