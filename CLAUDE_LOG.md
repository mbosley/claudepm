# claudepm Development Log

## Project Overview
A simple memory system for maintaining context across Claude Code sessions. Just two markdown files per project create persistent memory.

---

### 2024-06-29 17:25 - Made CLAUDE_LOG.md append-only principle explicit
Did:
- Added "append-only" principle to all templates
- Updated CLAUDE_MANAGER.md, CLAUDE_PROJECT_TEMPLATE.md, and our own CLAUDE.md
- Emphasized never editing past entries, only adding new ones
Next: Commit these changes as v0.1
Notes: This prevents rewriting history and maintains trust in the log. Mistakes become learning opportunities when preserved.

---

### 2024-06-29 17:17 - Moved from sandbox to proper project
Did: 
- Created /Users/mitchellbosley/projects/claudepm directory
- Copied core files from pm-system-sandbox
- Created own CLAUDE.md using our template (meta!)
- Set up as a real project that uses itself
Next: Initialize git repository and test the install process
Notes: This is very meta - claudepm will track its own development using the claudepm system. Good test case.

---

### 2024-06-29 17:25 - Made CLAUDE_LOG.md append-only principle explicit
Did:
- Added "append-only" principle to all templates
- Updated CLAUDE_MANAGER.md, CLAUDE_PROJECT_TEMPLATE.md, and our own CLAUDE.md
- Emphasized never editing past entries, only adding new ones
Next: Commit these changes as v0.1
Notes: This prevents rewriting history and maintains trust in the log. Mistakes become learning opportunities when preserved.

---

### 2024-06-29 17:20 - Tested our own installer
Did:
- Successfully ran install.sh
- Verified CLAUDE.md installed to ~/projects
- Verified templates installed to ~/.claude/templates/
- Confirmed claudepm can manage itself
Next: Create initial git commit and tag as v0.1
Notes: The meta aspect works - we're using claudepm to develop claudepm. This will help us feel any friction points directly.

---

### 2024-06-29 17:25 - Made CLAUDE_LOG.md append-only principle explicit
Did:
- Added "append-only" principle to all templates
- Updated CLAUDE_MANAGER.md, CLAUDE_PROJECT_TEMPLATE.md, and our own CLAUDE.md
- Emphasized never editing past entries, only adding new ones
Next: Commit these changes as v0.1
Notes: This prevents rewriting history and maintains trust in the log. Mistakes become learning opportunities when preserved.

---
### 2024-06-29 17:35 - Added PROJECT_ROADMAP.md as third core document
Did:
- Created PROJECT_ROADMAP_TEMPLATE.md for living project state
- Updated all templates to read roadmap first, then logs
- Added roadmap update step to work block instructions
- Created claudepm's own PROJECT_ROADMAP.md
- Updated install.sh to copy roadmap template
Next: Test the three-document system with a real project
Notes: This completes the three-document system: CLAUDE.md (process), CLAUDE_LOG.md (history), PROJECT_ROADMAP.md (current state). Manager Claude can now quickly scan roadmaps instead of parsing logs.

---

### 2025-01-29 17:40 - Fixed year in timestamps
Did:
- Noticed I was using 2024 instead of 2025 in all timestamps
- This highlights importance of accuracy in logging
- Previous entries preserved (append-only principle)
Next: Add date format guidance to templates
Notes: User caught this error. Good reminder that Claude's sense of time can be unreliable. Should add explicit date format examples to templates.

---

### 2025-06-29 17:41 - Corrected month too
Did:
- Previous entry had wrong month (01 instead of 06)
- It's June 29, 2025, not January
- Shows how easy it is to make timestamp errors
Next: Really should add date format examples to templates
Notes: Multiple timestamp errors in a row\! This emphasizes need for clear date formatting guidance.

---

### 2025-06-29 17:45 - Added explicit date format to templates
Did:
- Updated all templates to show YYYY-MM-DD HH:MM format
- Fixed example dates to use 2025
- Added consistent timestamp format across all templates
Next: Commit v0.1 and create GitHub repository
Notes: This prevents ambiguity and helps Claude (and humans) use consistent timestamps. ISO-style format is unambiguous.

---

### 2025-06-29 17:52 - Created timestamp helper
Did:
- Created get-timestamp.sh for accurate timestamps
- Updated all templates to show the date command
- Tested timestamp generation (it works\!)
Next: Create initial git commit and tag v0.1
Notes: This solves Claude's unreliable time perception. Now every log entry can have an accurate timestamp by running date command.

---

### 2025-06-29 17:56 - Added git vs log guidance
Did:
- Added section to template about commit vs log frequency
- Recommended logging every 30-90 min, committing 2-4 times daily
- Emphasized logs show journey, commits show destinations
Next: Create first git commit with all v0.1 features
Notes: This guidance helps prevent over-committing WIP while maintaining rich context in logs.

---

### 2025-06-29 17:58 - Updated guidelines for Claude work patterns
Did:
- Replaced human-centric time-based guidance with task-based triggers
- Listed specific Claude scenarios for logging (session end, discoveries, blocks)
- Clarified commit triggers (user request, tests pass, working state)
Next: Create initial git commit for v0.1
Notes: Claude doesn't work in time blocks like humans - might do 10 tasks in 5 minutes or spend an hour on one bug. Task-based triggers make more sense.

---

### 2025-06-29 18:01 - Caught myself creating new file instead of editing
Did:
- Initially created BETA_FEATURES.md (wrong\!)
- User pointed out this should go in PROJECT_ROADMAP.md
- Moved all content to roadmap's Upcoming section
- Deleted unnecessary file
Next: Test the three-document system with a real project
Notes: Perfect example of default behavior overriding principles. Even after documenting 'Edit, don't create', I still created a new file out of habit. This is why we need these reminders in CLAUDE.md.

---

### 2025-06-29 18:03 - Encoded file creation lesson into all templates
Did:
- Added explicit 'Where Things Go' sections to all templates
- Listed common wrong files (BETA_FEATURES.md, TODO.md, etc.)
- Made it crystal clear that features go in roadmap, not new files
- Added quick reference to three-document system
Next: Commit v0.1 and test with real project
Notes: This lesson came from real experience - I created BETA_FEATURES.md even after documenting the principle. Now future Claudes have explicit guidance to prevent this.

---
