Update project templates to latest version

I'll update the claudepm templates in the specified project to the latest version.

Usage: /update [project-name]

1. **Parse the project name**:
   ```bash
   PROJECT="$ARGUMENTS"
   if [ -z "$PROJECT" ]; then
     echo "Please specify a project: /update [project-name]"
     exit 1
   fi
   ```

2. **Check if project exists and has claudepm**:
   ```bash
   if [ ! -f "$PROJECT/CLAUDE.md" ]; then
     echo "Error: $PROJECT doesn't appear to be a claudepm project"
     exit 1
   fi
   ```

3. **Back up existing files**:
   ```bash
   # Create backup with timestamp
   BACKUP_TIME=$(date +%Y%m%d_%H%M%S)
   cp "$PROJECT/CLAUDE.md" "$PROJECT/CLAUDE.md.backup_$BACKUP_TIME"
   ```

4. **Preserve project-specific content**:
   - Extract "Project Context" section from existing CLAUDE.md
   - Extract any custom sections added by user
   - Note discovered commands and project metadata

5. **Apply latest template**:
   - Start with latest CLAUDE.md template
   - Re-insert preserved project-specific content
   - Update template version in .claudepm
   - Keep all existing log entries and roadmap items

6. **Report what was updated**:
   ```
   ## Template Update Report - [Project Name]
   
   ### Updated Files
   ✅ CLAUDE.md updated to template v0.1.1
   ✅ Preserved project context and custom sections
   ✅ Backup saved as CLAUDE.md.backup_[timestamp]
   
   ### New Template Features
   - Added: Parallel work merge guidance
   - Added: PLANNED vs IMPLEMENTED patterns
   - Improved: Commit checklist
   
   ### Next Steps
   1. Review the updated CLAUDE.md
   2. Check if any new patterns apply to your project
   3. Update CLAUDE_LOG.md with update entry
   ```

7. **Update .claudepm marker**:
   ```json
   {
     "claudepm": {
       "version": "0.1",
       "template_version": "0.1.1",
       "last_template_update": "2025-06-29T21:15:00Z"
     }
   }
   ```

8. **Add log entry**:
   ```
   ### YYYY-MM-DD HH:MM - Updated claudepm templates
   Did: Updated CLAUDE.md to template v0.1.1
   Next: Review new template features and apply if relevant
   Notes: Backup saved. New features include parallel work guidance.
   ```

Example usage:
```
/update auth-service
> Updating auth-service to template v0.1.1...
> ✅ CLAUDE.md updated (backup saved)
> ✅ Project context preserved
> ✅ Added 3 new template sections
> Review changes and commit when ready
```