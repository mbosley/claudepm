Process unstructured updates and route to relevant projects

Parse this brain dump and intelligently route items to appropriate project roadmaps:

$ARGUMENTS

## Instructions:
1. Parse the brain dump to identify which projects are mentioned
2. Look for project names by checking */ directories in ~/projects
3. Extract from the brain dump:
   - Deadlines: "by July 1st", "due Friday", "needs to ship this week" → [DUE: YYYY-MM-DD]
   - Blockers: "blocked on", "waiting for", "can't proceed until" → Move to Blocked section
   - Priorities: "focus on", "urgent", "prioritize" → Reorder in roadmap
   - Bugs: "bug in", "broken", "not working" → Add to Active Work
   - Context: "client said", "team decided" → Add to Notes section

4. **Route updates to ALL projects IN PARALLEL**:
   ```python
   # CRITICAL: Spawn all updates simultaneously!
   # After parsing brain dump and identifying which projects need updates:
   
   Task: "Update auth roadmap",
     prompt: "In auth-service/, update ROADMAP.md: Add 'JWT implementation [DUE: 2025-07-01]' to Active Work"
   
   Task: "Update payment roadmap", 
     prompt: "In payment-api/, update ROADMAP.md: Move 'Stripe integration' to Blocked section with note 'Waiting for API keys'"
   
   Task: "Update blog roadmap",
     prompt: "In blog/, update ROADMAP.md: Add 'Publish claudepm article [DUE: this week]' to Active Work"
   
   # ALL tasks launch together - don't wait between them!
   ```

5. Create a summary report showing:
   - Which items were routed to which projects
   - Any items that couldn't be matched to a project
   - What changes were made to each roadmap

## Example Input:
"Client wants auth system live by July 1st. Payment integration blocked on Stripe keys. 
Blog post about claudepm should go out this week. Found bug in CSV export."

## Example Output:
```
Processed 4 items from brain dump:
- auth-system: Added deadline [DUE: 2025-07-01] to Active Work
- payment-app: Moved Stripe integration to Blocked section
- blog: Added "Publish claudepm post" [DUE: this week]
- Unmatched: "bug in CSV export" - no clear project context
```

**REMINDER**: After processing a brain dump, log to ~/projects/CLAUDE_LOG.md:
- Which projects were affected
- What updates were routed
- Any items that couldn't be matched
