# Task Enhancement Notes

The ultra-rich task system was too complex and caused the utils.sh file to become corrupted.
Here's what we tried to add:

## Rich Task Features
- Priority levels (high/medium/low)
- Tags for categorization
- Due dates
- Assignees (@mentions)
- Time estimates
- PR/commit links
- Dependencies

## Rich List Features
- Filter by status, priority, tag, assignee
- Show overdue tasks
- Full detail view
- Smart prioritization in suggest_next

## Issues Encountered
1. File became too large (1200+ lines)
2. Complex bash regex patterns may have performance issues
3. File corruption during editing
4. Install script hanging

## Recommendation
Keep the task system simple for now. The rich logging is working well.
Consider implementing rich tasks in a future version with:
- Separate task management functions in their own file
- Simpler metadata format
- JSON output for complex parsing