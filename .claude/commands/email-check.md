# /email-check

Process emails as project updates via the apple-mcp email integration.

## Usage

```
/email-check
```

This command:
1. Reads emails using mcp_email_read
2. Analyzes them for project-relevant content
3. Suggests updates to project files (does NOT auto-update)
4. Maintains human control over what gets incorporated

## Manager Mode

When run at the manager level (~projects/), it:
- Scans all emails for project-related content
- Groups suggestions by project
- Proposes brain-dump style updates for routing

## Project Mode  

When run within a project directory, it:
- Filters emails for this project's context
- Suggests updates to ROADMAP.md
- Identifies action items and deadlines
- Extracts decisions and blockers

## Philosophy

This follows the MCP integration pattern:
- **Email is the primitive** - We read, not manage
- **Human decides** - All updates are suggestions
- **Project memory focused** - Extract what matters for CLAUDE_LOG and roadmap
- **No automation** - You review and approve each suggestion

## Example Output

```
## Email Check - 3 relevant emails found

### Project: auth-service
**From: client@example.com - "Re: Auth deployment timeline"**
Suggested roadmap update:
- Add to Active Work: "Deploy auth to staging [DUE: 2024-03-15]"
- Note: Client confirmed March 15th deadline

### Project: blog  
**From: team@company.com - "Blog post schedule"**
Suggested log entry:
- Marketing wants claudepm article by Friday
- Add to roadmap: "Write claudepm announcement post [DUE: 2024-03-10]"

### General
**From: manager@company.com - "Team standup time change"**
No specific project - for your awareness:
- Daily standup moving to 10am starting Monday
```

## Implementation

```bash
# Read emails from the last 24 hours
emails=$(mcp_email_read --since "24 hours ago")

# Analyze for project content
echo "$emails" | claude-code -p "Analyze these emails for project updates:
1. Identify which projects are mentioned
2. Extract deadlines, decisions, and action items  
3. Suggest specific updates to ROADMAP.md or CLAUDE_LOG.md
4. Group by project
5. Present as review-and-approve suggestions"
```

## Notes

- Emails are never deleted or marked as read
- Suggestions can be ignored if not relevant
- Works best with clear subject lines mentioning project names
- Run daily for best results