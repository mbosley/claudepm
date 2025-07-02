# Task Agent Mission: task-prompt-management

You are a Task Agent for the `claudepm` project, working in the `worktrees/task-prompt-management` worktree.

## Your Mission
Implement the feature: **TASK_PROMPT Management System**

## Requirements
- Create a system that automatically generates TASK_PROMPT.md when creating worktrees
- Archive TASK_PROMPTs when worktrees are removed
- Include Gemini architectural reviews in TASK_PROMPTs when available
- Make it easy to review past TASK_PROMPTs for learning

## Process
1. You are already in the correct worktree: `worktrees/task-prompt-management`.
2. Read this project's `CLAUDE.md` and `PROJECT_ROADMAP.md` for full context.
3. Implement the feature as described in the architectural review below.
4. Update all relevant documentation, templates, and version files as per the Feature Development Checklist in `CLAUDE.md`.
5. Test your changes thoroughly.
6. Commit your work with clear, atomic messages.
7. Create a Pull Request back to the `dev` branch.
8. Report your completion and the PR number.

Remember: You work in isolation. Focus only on this feature. Do not modify files outside your worktree.

---
## Architectural Review

### Summary of Feature Impact

This feature formalizes a critical part of the Task Agent workflow: defining the mission. By automating the creation and archiving of `TASK_PROMPT.md` files, we gain several key benefits:

- **Consistency:** Every Task Agent receives a standardized, well-structured prompt.
- **Traceability:** A permanent archive of all dispatched tasks is created, providing a historical record of feature goals and architectural decisions.
- **Automation:** It removes the manual, error-prone step of creating and populating the prompt, streamlining the Project Lead's workflow.
- **Integration:** It directly links architectural planning (`.api-queries/`) with the implementation task, ensuring Gemini's recommendations are part of the initial context for the Task Agent.

### Implementation Steps

1. **Create `templates/project/TASK_PROMPT.template.md`** with the template content:
   ```markdown
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
   2. Read this project's `CLAUDE.md` and `PROJECT_ROADMAP.md` for full context.
   3. Implement the feature as described.
   4. Update all relevant documentation, templates, and version files as per the Feature Development Checklist in `CLAUDE.md`.
   5. Test your changes thoroughly.
   6. Commit your work with clear, atomic messages.
   7. Create a Pull Request back to the `dev` branch.
   8. Report your completion and the PR number.

   Remember: You work in isolation. Focus only on this feature. Do not modify files outside your worktree.

   ---
   {{ARCHITECTURAL_REVIEW}}
   ```

2. **Update `.gitignore`** to add `.prompts_archive/`

3. **Modify `claudepm-admin.sh`** to:
   - In `create-worktree`: Generate TASK_PROMPT.md from template, including architectural review if found
   - In `remove-worktree`: Archive TASK_PROMPT.md to `.prompts_archive/YYYY-MM-DD-<feature-name>.md`

4. **Update `CLAUDE.md`** documentation to reflect automated TASK_PROMPT generation

### Testing Plan

1. Test with architectural review present
2. Test without architectural review
3. Test archiving on worktree removal
4. Verify archive naming convention works correctly

### Key Implementation Details

The claudepm-admin.sh modifications should:
- Search for architectural reviews in `.api-queries/*-<feature-name>.md`
- Use sed to replace {{FEATURE_NAME}} and {{ARCHITECTURAL_REVIEW}} in template
- Create `.prompts_archive/` directory if it doesn't exist
- Use date format `YYYY-MM-DD` for archive files