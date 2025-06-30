# Brain Dump Processing

Process this unstructured update and route items to relevant projects:

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

4. For each identified project, spawn a sub-agent:
   ```bash
   claude -p "You are in [project]/ directory.
   Update PROJECT_ROADMAP.md based on these items:
   - [Extracted items for this project]
   Add [DUE: YYYY-MM-DD] for any deadlines.
   Move items to Blocked section if blockers identified.
   Add context to Notes if important background provided."
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