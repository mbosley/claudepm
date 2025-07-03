---
name: migrate-project
aliases: [migrate]
description: Migrate a project from v0.1.x single-file to v0.2.0 two-file architecture
---

I'll help you migrate a project from the legacy single-file CLAUDE.md to the new two-file architecture (CLAUDE.md + CLAUDEPM-*.md).

Usage: /migrate-project [project-name]

1. **Parse the project name**:
   ```bash
   PROJECT="$ARGUMENTS"
   if [ -z "$PROJECT" ]; then
     echo "Please specify a project: /migrate-project [project-name]"
     exit 1
   fi
   ```

2. **Check if project exists and needs migration**:
   ```bash
   if [ ! -f "$PROJECT/CLAUDE.md" ]; then
     echo "Error: $PROJECT doesn't have a CLAUDE.md file"
     exit 1
   fi
   
   # Check if already migrated
   if [ -f "$PROJECT/.claudepm" ]; then
     CORE_VERSION=$(grep -o '"core_version"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT/.claudepm" | sed 's/.*"core_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
     if [ -n "$CORE_VERSION" ]; then
       echo "✓ Project already migrated to v0.2.0 architecture"
       exit 0
     fi
   fi
   
   # Check for migration markers
   if ! grep -q "<!-- CLAUDEPM_CUSTOMIZATION_START -->" "$PROJECT/CLAUDE.md"; then
     echo "⚠️  Warning: Project has pre-v0.1.9 template without migration markers"
     echo "Manual migration required. Please:"
     echo "1. Backup your CLAUDE.md"
     echo "2. Identify custom content (Project Context, commands, etc.)"
     echo "3. Create new minimal CLAUDE.md with just custom content"
     echo "4. Update .claudepm with role and core_version"
     exit 1
   fi
   ```

3. **Create backup**:
   ```bash
   BACKUP_TIME=$(date +%Y%m%d_%H%M%S)
   cp "$PROJECT/CLAUDE.md" "$PROJECT/CLAUDE.md.backup_$BACKUP_TIME"
   echo "✓ Created backup: CLAUDE.md.backup_$BACKUP_TIME"
   ```

4. **Extract custom content**:
   ```bash
   # Extract content between markers
   awk '
     /<!-- CLAUDEPM_CUSTOMIZATION_START -->/ { capture = 1; next }
     /<!-- CLAUDEPM_CUSTOMIZATION_END -->/ { capture = 0; next }
     capture { print }
   ' "$PROJECT/CLAUDE.md" > "$PROJECT/custom_content.tmp"
   ```

5. **Create new minimal CLAUDE.md**:
   ```bash
   # Get project name from first line if available
   PROJECT_NAME=$(head -1 "$PROJECT/CLAUDE.md" | grep "^# Project:" | sed 's/# Project: //')
   if [ -z "$PROJECT_NAME" ]; then
     PROJECT_NAME="[Project Name]"
   fi
   
   cat > "$PROJECT/CLAUDE.md" << 'EOF'
# Project: $PROJECT_NAME

<!-- This file contains your project-specific customizations -->
<!-- Core claudepm instructions are automatically loaded from CLAUDEPM-PROJECT.md -->

EOF
   
   # Append the extracted custom content
   cat "$PROJECT/custom_content.tmp" >> "$PROJECT/CLAUDE.md"
   rm "$PROJECT/custom_content.tmp"
   ```

6. **Update or create .claudepm**:
   ```bash
   if [ -f "$PROJECT/.claudepm" ]; then
     # Update existing file with jq if available, otherwise use sed
     if command -v jq >/dev/null 2>&1; then
       jq '.claudepm.core_version = "0.2.0" | .claudepm.role = "project"' "$PROJECT/.claudepm" > "$PROJECT/.claudepm.tmp"
       mv "$PROJECT/.claudepm.tmp" "$PROJECT/.claudepm"
     else
       # Manual update
       cp "$PROJECT/.claudepm" "$PROJECT/.claudepm.backup"
       # Add core_version and role fields
     fi
   else
     # Create new .claudepm
     cat > "$PROJECT/.claudepm" << 'EOF'
{
  "claudepm": {
    "version": "0.2.0",
    "core_version": "0.2.0",
    "role": "project",
    "template_version": "0.1.9",
    "initialized": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
   fi
   ```

7. **Add log entry**:
   ```bash
   {
   echo ""
   echo ""
   echo "### $(date '+%Y-%m-%d %H:%M') - Migrated to v0.2.0 two-file architecture"
   echo "Did:"
   echo "- MIGRATED: Split CLAUDE.md into custom + core files"
   echo "- BACKED UP: Original saved as CLAUDE.md.backup_$BACKUP_TIME"
   echo "- UPDATED: .claudepm with core_version and role"
   echo "Next: Verify custom content preserved correctly"
   echo "Notes: Core instructions now loaded from ~/.claude/core/CLAUDEPM-PROJECT.md"
   echo ""
   echo "---"
   } >> "$PROJECT/CLAUDE_LOG.md"
   ```

8. **Report success**:
   ```
   ## Migration Complete! ✅
   
   Project: $PROJECT
   Backup: CLAUDE.md.backup_$BACKUP_TIME
   
   ### What changed:
   - Your custom content is preserved in the minimal CLAUDE.md
   - Generic claudepm instructions moved to core files
   - Updates now just replace core files (no AI needed!)
   
   ### Verify the migration:
   1. Check CLAUDE.md has your custom content
   2. Run a command to test everything works
   3. Compare with backup if needed
   
   ### Next steps:
   - The project will now use the two-file architecture
   - Future updates will preserve your customizations
   - Core updates via: install.sh (updates ~/.claude/core/)
   ```

Example usage:
```
/migrate-project auth-service
> Migrating auth-service to v0.2.0 architecture...
> ✓ Created backup: CLAUDE.md.backup_20250102_143022  
> ✓ Extracted custom content (Project Context, commands)
> ✓ Created minimal CLAUDE.md
> ✓ Updated .claudepm with core_version
> ✅ Migration complete!
```