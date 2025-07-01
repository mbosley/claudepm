Analyze and adopt existing project into claudepm: $ARGUMENTS

Set up claudepm for an existing project by analyzing its structure and generating appropriate initial files.

## Instructions:

1. **Check if already initialized**:
   ```bash
   if [ -f "$ARGUMENTS/.claudepm" ]; then
     echo "Project already initialized with claudepm"
     cat "$ARGUMENTS/.claudepm"
     exit
   fi
   ```

2. **Analyze the project thoroughly**:
   - Project type: Check for package.json, requirements.txt, Cargo.toml, go.mod, etc.
   - Language: Identify primary language from file extensions
   - Documentation: Read README.md for project description and setup
   - Build system: Look for Makefile, package.json scripts, etc.
   - Tests: Identify test commands and framework
   - TODOs: Search for TODO/FIXME comments in code
   - Recent work: Check git log for activity patterns

3. **Generate CLAUDE.md** using the full template:
   - If CLAUDE.md already exists, back it up and extract Project Context
   - Start with the complete content from ~/.claude/templates/CLAUDE.md
   - Replace `[Project Name]` with the discovered project name
   - In the "Project Context" section, either preserve existing or add:
     ```markdown
     ## Project Context
     Type: [Discovered type - Web app, CLI tool, library, etc.]
     Language: [Primary language from files]
     Purpose: [From README or package.json description]
     
     ## Discovered Commands
     - Test: [npm test, pytest, cargo test, etc. if found]
     - Build: [npm run build, make, etc. if found]
     - Run: [npm start, python main.py, etc. if found]
     - Lint: [npm run lint, flake8, etc. if found]
     ```
   - Keep ALL other template content including:
     - Core Principles
     - PLANNED vs IMPLEMENTED guidance
     - Where Things Go section
     - Git commit guidance
     - claudepm Files listing

4. **Generate PROJECT_ROADMAP.md** using the template:
   - Start with ~/.claude/templates/PROJECT_ROADMAP.md
   - Fill in sections based on analysis:
   
   ```markdown
   ## Current Status
   [Summarize from README and recent git activity. Note when adopted, last commit date, general state]
   
   ## Active Work
   - [ ] Review and organize imported TODOs
   - [ ] [Any TODO/FIXME comments found in code]
   - [ ] [Infer from recent commit messages]
   
   ## Upcoming
   [Import content from any TODO.md or ROADMAP files found]
   
   ## Completed
   - [x] Project adopted into claudepm - [today's date]
   [Any completed items inferred from git history]
   
   ## Notes
   - Adopted from existing project on [date]
   - [Any important context from README]
   - [Key technical decisions found]
   ```

5. **Create initial CLAUDE_LOG.md** with proper header and first entry:
   ```markdown
   # [Project Name] Development Log
   
   ## Project Overview
   [Brief description from README or package.json]
   
   ---
   
   ### [Date using: date '+%Y-%m-%d %H:%M'] - Adopted project into claudepm
   Did:
   - ANALYZED: [Project type] project with [language]
   - IMPORTED: [X] TODOs from code comments and existing TODO files
   - DISCOVERED: Test command: [cmd], Build: [cmd], Run: [cmd]
   - CREATED: claudepm files based on project analysis
   - PRESERVED: Existing documentation and roadmap items
   Next: Review imported TODOs in PROJECT_ROADMAP.md and prioritize
   Blocked: [Check if any missing dependencies or credentials noted]
   Notes: [Any interesting findings during adoption - architecture, patterns, concerns]
   ```
   
   Important: Remind that future log entries should:
   - Use `date '+%Y-%m-%d %H:%M'` for accurate timestamps
   - Follow the Did/Next/Blocked format
   - Use PLANNED/IMPLEMENTED/FIXED prefixes
   - Be added after each work session

6. **Create .claudepm marker**:
   ```json
   {
     "claudepm": {
       "version": "0.1",
       "template_version": "0.1.1",
       "initialized": "[timestamp]"
     },
     "adoption": {
       "adopted_from_existing": true,
       "discovered_type": "[type]",
       "language": "[language]",
       "imported_todos": [count],
       "found_commands": [list]
     }
   }
   ```

7. **Update .gitignore**:
   Add `.claudepm` if not already present

8. **Apply append-only protection** (macOS only):
   ```bash
   if [[ "$OSTYPE" == "darwin"* ]]; then
       chflags uappnd "$ARGUMENTS/CLAUDE_LOG.md" 2>/dev/null && \
           echo "✓ Protected CLAUDE_LOG.md (append-only)" || \
           echo "⚠ Could not protect CLAUDE_LOG.md (non-macOS system)"
   fi
   ```

## Example Usage:
```
/adopt-project auth-service
```

## Report Format:
```
=== Adoption Report: auth-service ===

Discovered:
- Type: Node.js Express API
- Test command: npm test
- Build command: npm run build
- 7 TODO comments imported
- Last activity: 2 days ago

Created:
✓ CLAUDE.md with project-specific commands
✓ PROJECT_ROADMAP.md with 7 imported TODOs
✓ CLAUDE_LOG.md with adoption entry
✓ .claudepm marker file
✓ Updated .gitignore

Ready to use! Next: Review PROJECT_ROADMAP.md and organize imported items.
```