# Task Agent Mission: {{FEATURE_NAME}}

You are a Task Agent for the `claudepm` project, working in the `worktrees/{{FEATURE_NAME}}` worktree.

## Your Mission
Implement the feature: **{{FEATURE_NAME}}**

## Requirements
- [Primary requirement 1 for {{FEATURE_NAME}}]
- [Primary requirement 2 for {{FEATURE_NAME}}]
- Review the architectural plan below if provided.

## Process
1. You are already in the correct worktree: `worktrees/{{FEATURE_NAME}}`.
2. Start by reading `CLAUDE.md` and `PROJECT_ROADMAP.md` for context.
3. Implement the feature as described in requirements.
4. Update all relevant documentation and tests.
5. Test your changes thoroughly.
6. Log your work to `CLAUDE_LOG.md` with prefix `[feature/{{FEATURE_NAME}}]`.

## Git Workflow (CRITICAL - DO NOT SKIP)
After implementation is complete, you MUST:
1. Stage and commit all changes:
   ```bash
   git add -A
   git commit -m "feat: {{FEATURE_NAME}}

   - Implemented [main thing]
   - Added [other thing]
   - Updated [documentation/tests]"
   ```
2. Push the feature branch:
   ```bash
   git push -u origin feature/{{FEATURE_NAME}}
   ```
3. Create a Pull Request:
   ```bash
   gh pr create --base dev --title "feat: {{FEATURE_NAME}}" --body "## Summary
   [Brief description of what was implemented]
   
   ## Changes
   - [List key changes]
   
   ## Testing
   - [How you tested]
   
   Closes #[issue-number-if-applicable]"
   ```
4. Report back with: "✅ PR #[number] created: [url]"

Remember: You work in isolation. Focus only on this feature. Complete the ENTIRE workflow including PR creation.

---
{{ARCHITECTURAL_REVIEW}}