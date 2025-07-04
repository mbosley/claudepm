# Project Roadmap - [Project Name]

## Current Status
[One paragraph summary of where the project stands right now]

## Active Work
- [ ] Current task being worked on [high] [#feature]
- [ ] Next immediate priority [medium] [@alice]
- [ ] Task with deadline [high] [due:2025-07-01]

## Upcoming

### v0.2 - [Theme Name]
- [ ] Specific actionable feature
- [ ] Another clear deliverable
- [ ] Include rationale in description

### v0.3 - [Next Theme]
- [ ] Group related features
- [ ] Think "what could be one PR?"
- [ ] Enable future branching

### Future Versions
- [ ] Less detailed but captured
- [ ] Can be refined when closer

## Completed
- [x] Initial setup
- [x] Basic functionality
- [x] Move completed items here with date

## Blocked
- [ ] Items waiting on external dependencies
- [ ] Decisions needed
- [ ] Include what would unblock

## Notes
<!-- 
ROADMAP.md is for WHAT & WHY - context, plans, decisions
Put project philosophy, design rationale, and architecture decisions here
Keep behavioral instructions (HOW to work) in CLAUDE.md

Task Format:
- Use markdown checkboxes with inline metadata
- Each task must have a UUID on the line below (ID: <uuid>)
- Example: - [ ] Fix auth bug [high] [#auth] [due:2025-01-15]
           ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

This template version: See CHANGELOG.md for version history
-->

### Design Decisions
- Key technical choices and rationale
- Important constraints and trade-offs
- Architecture principles

### Project Context  
- Why this project exists
- Problem it solves
- Links to relevant resources

### Development Notes
- This roadmap drives development - each version can become a git branch
- Structure enables future automation: "work on v0.2 features"
- Use rich metadata for tasks: [priority] [#tags] [due:date] [@assignee] [estimate]
- Manager Claude can scan all projects for upcoming deadlines
- Tasks are managed with: `claudepm task add/list/done/block/start/update`

---
Last updated: YYYY-MM-DD HH:MM