#!/bin/bash
# utils.sh - Shared functions for claudepm
set -euo pipefail

# Generate UUID (portable)
generate_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    else
        # Fallback: timestamp with nanoseconds
        date +%s%N
    fi
}

# Safe template copy (never overwrites)
safe_copy_template() {
    local template="$1"
    local destination="$2"
    
    if [[ -f "$destination" ]]; then
        echo "File exists: $destination (skipping)"
        return 0
    fi
    
    # Check user templates first
    if [[ -f "$CLAUDEPM_CONFIG/templates/$template" ]]; then
        cp "$CLAUDEPM_CONFIG/templates/$template" "$destination"
        echo "Created: $destination (from user template)"
    elif [[ -f "$CLAUDEPM_HOME/templates/$template" ]]; then
        cp "$CLAUDEPM_HOME/templates/$template" "$destination"
        echo "Created: $destination"
    else
        echo "Error: Template not found: $template" >&2
        return 1
    fi
}

# Initialize project or manager
init_project() {
    local type="${1:-project}"
    
    echo "Initializing claudepm $type..."
    
    # Create marker file
    if [[ ! -f ".claudepm" ]]; then
        cat > .claudepm << EOF
template_version=$CLAUDEPM_VERSION
adopted_date=$(date +%Y-%m-%d)
last_update_check=$(date +%Y-%m-%d)
type=$type
EOF
        echo "Created: .claudepm"
    fi
    
    # Copy templates based on type
    case "$type" in
        project)
            safe_copy_template "project/CLAUDE.md" "CLAUDE.md"
            safe_copy_template "project/LOG.md" "LOG.md"
            safe_copy_template "project/ROADMAP.md" "ROADMAP.md"
            safe_copy_template "project/NOTES.md" "NOTES.md"
            
            # Add initial log entry if LOG.md was just created
            if [[ -f "LOG.md" ]] && grep -q "<!-- Initial entry will be added by claudepm init -->" LOG.md 2>/dev/null; then
                # Replace the placeholder with actual log entry
                {
                    echo "# Work Log"
                    echo ""
                    echo "### $(date '+%Y-%m-%d %H:%M') - Project initialized with claudepm"
                    echo "Did: Set up claudepm for project memory management"
                    echo "Next: Update ROADMAP.md with initial goals and tasks"
                    echo "Notes: Remember to log after each work session"
                    echo ""
                    echo "---"
                } > LOG.md
            fi
            ;;
        manager)
            safe_copy_template "manager/CLAUDE.md" "CLAUDE.md"
            safe_copy_template "manager/LOG.md" "LOG.md"
            safe_copy_template "manager/ROADMAP.md" "ROADMAP.md"
            safe_copy_template "manager/NOTES.md" "NOTES.md"
            
            # Add initial log entry if LOG.md was just created
            if [[ -f "LOG.md" ]] && grep -q "<!-- Initial entry will be added by claudepm init -->" LOG.md 2>/dev/null; then
                # Replace the placeholder with actual log entry
                {
                    echo "# Manager Activity Log"
                    echo ""
                    echo "### $(date '+%Y-%m-%d %H:%M') - Manager workspace initialized"
                    echo "Did: Set up claudepm manager-level coordination"
                    echo "Projects affected: All future projects"
                    echo "Next: Use 'claudepm doctor' to scan for existing projects"
                    echo ""
                    echo "---"
                } > LOG.md
            fi
            ;;
        *)
            echo "Error: Unknown type '$type'. Use 'project' or 'manager'"
            exit 1
            ;;
    esac
    
    # Update .gitignore
    if ! grep -q "^\.claudepm$" .gitignore 2>/dev/null; then
        echo ".claudepm" >> .gitignore
        echo "Added .claudepm to .gitignore"
    fi
    
    # Register project
    if [[ "$type" == "project" ]] && [[ ! -f "$CLAUDEPM_HOME/projects.list" ]] || ! grep -q "^$PWD$" "$CLAUDEPM_HOME/projects.list" 2>/dev/null; then
        echo "$PWD" >> "$CLAUDEPM_HOME/projects.list"
        echo "Registered project in ~/.claudepm/projects.list"
    fi
    
    echo -e "\n${GREEN}✓ Initialization complete!${NC}"
    echo "Next steps:"
    echo "1. Edit ROADMAP.md with your project goals"
    echo "2. Start working and update LOG.md"
    echo "3. Capture insights in NOTES.md"
}

# Adopt existing project
adopt_project() {
    local dry_run="${1:-}"
    
    if [[ -f ".claudepm" ]]; then
        echo "Project already adopted. Run 'claudepm upgrade' to update."
        exit 0
    fi
    
    echo "Analyzing existing project..."
    
    # Detect project type
    local project_type="unknown"
    local project_name="$(basename "$PWD")"
    local test_command=""
    local build_command=""
    local run_command=""
    
    # Node.js detection
    if [[ -f "package.json" ]]; then
        project_type="node"
        # Better JSON parsing - look for the value after the key
        project_name=$(grep '"name"' package.json | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "$project_name")
        test_command=$(grep '"test"' package.json | head -1 | sed 's/.*"test"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
        build_command=$(grep '"build"' package.json | head -1 | sed 's/.*"build"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
        run_command=$(grep '"start"' package.json | head -1 | sed 's/.*"start"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
    fi
    
    # Python detection
    if [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]]; then
        project_type="python"
        test_command="pytest"
        run_command="python main.py"
    fi
    
    # Find TODOs
    local todo_count=0
    if command -v rg >/dev/null 2>&1; then
        todo_count=$(rg -c "TODO|FIXME" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
    else
        todo_count=$(grep -r "TODO\|FIXME" . 2>/dev/null | wc -l | tr -d ' ' || echo 0)
    fi
    
    if [[ "$dry_run" == "--dry-run" ]]; then
        echo -e "\n${YELLOW}DRY RUN - Would create:${NC}"
        echo "- CLAUDE.md (with discovered commands)"
        echo "- LOG.md (with adoption entry)"
        echo "- ROADMAP.md (importing $todo_count TODOs)"
        echo "- NOTES.md (project wisdom template)"
        echo "- .claudepm (version marker)"
        echo -e "\nProject type: $project_type"
        echo "Commands found:"
        [[ -n "$test_command" ]] && echo "  Test: $test_command"
        [[ -n "$build_command" ]] && echo "  Build: $build_command"
        [[ -n "$run_command" ]] && echo "  Run: $run_command"
        exit 0
    fi
    
    # Create CLAUDE.md
    if [[ ! -f "CLAUDE.md" ]]; then
        cat > CLAUDE.md << EOF
# Project: $project_name

## Start Every Session
1. Read LOG.md - understand where we left off
2. Run git status - see uncommitted work  
3. Look for "Next:" in recent logs

## After Each Work Block
Add to LOG.md (use \`date '+%Y-%m-%d %H:%M'\` for timestamp):
\`\`\`
### YYYY-MM-DD HH:MM - [What you did]
Did: [Specific accomplishments]
Next: [Immediate next task]
Blocked: [Any blockers, if none, omit this line]
\`\`\`

## Project Context
Type: $project_type project
Language: $(echo "$project_type" | sed 's/node/JavaScript/')
Purpose: [Update with project purpose]

## Discovered Commands
EOF
        [[ -n "$test_command" ]] && echo "- Test: \`$test_command\`" >> CLAUDE.md
        [[ -n "$build_command" ]] && echo "- Build: \`$build_command\`" >> CLAUDE.md
        [[ -n "$run_command" ]] && echo "- Run: \`$run_command\`" >> CLAUDE.md
        echo -e "\nRemember: The log is our shared memory. Keep it updated." >> CLAUDE.md
        echo "Created: CLAUDE.md"
    fi
    
    # Create LOG.md with adoption entry
    if [[ ! -f "LOG.md" ]]; then
        cat > LOG.md << EOF
# Work Log

### $(date '+%Y-%m-%d %H:%M') - Adopted project into claudepm
Did:
- ANALYZED: Project structure and discovered $project_type project
- FOUND: $todo_count existing TODOs to import
- DISCOVERED: Test command: $test_command
- CREATED: Initial claudepm files based on analysis
Next: Review imported items and update ROADMAP.md
Notes: Run 'claudepm task list' to see imported TODOs

---
EOF
        echo "Created: LOG.md"
    fi
    
    # Create other files
    safe_copy_template "project/ROADMAP.md" "ROADMAP.md"
    safe_copy_template "project/NOTES.md" "NOTES.md"
    
    # Import TODOs if found
    if [[ $todo_count -gt 0 ]]; then
        echo -e "\n## Imported TODOs\n" >> ROADMAP.md
        if command -v rg >/dev/null 2>&1; then
            rg "TODO|FIXME" --no-heading | while read -r line; do
                echo "CPM::TASK::$(generate_uuid)::TODO::$(date +%Y-%m-%d)::$line" >> ROADMAP.md
            done
        fi
    fi
    
    # Complete adoption
    init_project "project"
    
    echo -e "\n${GREEN}✓ Project adopted!${NC}"
    echo "Found and imported $todo_count TODOs"
    echo "Run 'claudepm health' to check status"
}

# Check project health
health_check() {
    if [[ ! -f ".claudepm" ]]; then
        echo -e "${RED}✗ Not a claudepm project${NC}"
        echo "Run 'claudepm adopt' to initialize"
        exit 1
    fi
    
    local project_name=$(basename "$PWD")
    local version=$(grep "template_version" .claudepm | cut -d'=' -f2)
    
    echo "Project: $project_name"
    
    # Check version
    if [[ "$version" == "$CLAUDEPM_VERSION" ]]; then
        echo -e "${GREEN}✓ Templates: v$version (current)${NC}"
    else
        echo -e "${YELLOW}⚠ Templates: v$version (outdated, current: v$CLAUDEPM_VERSION)${NC}"
    fi
    
    # Check last activity
    if [[ -f "LOG.md" ]]; then
        local last_log=$(grep "^### " LOG.md | tail -1 | cut -d' ' -f2)
        local days_ago=$(( ($(date +%s) - $(date -d "$last_log" +%s 2>/dev/null || echo $(date +%s))) / 86400 ))
        if [[ $days_ago -lt 7 ]]; then
            echo -e "${GREEN}✓ Last activity: $days_ago days ago${NC}"
        else
            echo -e "${YELLOW}⚠ Last activity: $days_ago days ago${NC}"
        fi
    fi
    
    # Check git status
    if git status --porcelain 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}⚠ Git status: Uncommitted changes${NC}"
    else
        echo -e "${GREEN}✓ Git status: Clean${NC}"
    fi
    
    # Check blocked tasks
    if [[ -f "ROADMAP.md" ]]; then
        local blocked_count=$(grep -c "::BLOCKED::" ROADMAP.md 2>/dev/null | tr -d ' \n' || echo 0)
        local active_count=$(grep -E "::TODO::|::IN_PROGRESS::" ROADMAP.md 2>/dev/null | wc -l | tr -d ' \n' || echo 0)
        
        # Ensure we have valid numbers
        blocked_count=${blocked_count:-0}
        active_count=${active_count:-0}
        
        if [[ "$blocked_count" -gt 0 ]]; then
            echo -e "${YELLOW}⚠ Blocked tasks: $blocked_count${NC}"
        else
            echo -e "${GREEN}✓ Blocked tasks: 0${NC}"
        fi
        echo -e "${GREEN}✓ Active work items: $active_count${NC}"
    fi
}

# Doctor - system-wide health check
doctor_check() {
    echo "Checking claudepm installation..."
    echo -e "${GREEN}✓ Version: $CLAUDEPM_VERSION${NC}"
    echo -e "${GREEN}✓ Templates: Current${NC}"
    
    if command -v claudepm >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Path: Configured${NC}"
    else
        echo -e "${YELLOW}⚠ Path: Not in PATH${NC}"
        echo "  Add to PATH: export PATH=\"\$HOME/.claudepm/bin:\$PATH\""
    fi
    
    echo -e "\nScanning for projects..."
    
    local paths=("$@")
    if [[ ${#paths[@]} -eq 0 ]]; then
        # Use projects.list if no paths provided
        if [[ -f "$CLAUDEPM_HOME/projects.list" ]]; then
            # Read file into array (bash 3 compatible)
            paths=()
            while IFS= read -r line; do
                [[ -n "$line" ]] && paths+=("$line")
            done < "$CLAUDEPM_HOME/projects.list"
        else
            paths=(".")
        fi
    fi
    
    for path in "${paths[@]}"; do
        if [[ -d "$path" ]]; then
            find "$path" -name ".claudepm" -type f 2>/dev/null | while read -r marker; do
                local dir=$(dirname "$marker")
                local name=$(basename "$dir")
                local version=$(grep "template_version" "$marker" 2>/dev/null | cut -d'=' -f2 || echo "unknown")
                
                # Quick status check
                cd "$dir" 2>/dev/null || continue
                local status="🟢 Active"
                
                if [[ -f "LOG.md" ]]; then
                    local last_log=$(grep "^### " LOG.md 2>/dev/null | tail -1 | cut -d' ' -f2)
                    if [[ -n "$last_log" ]]; then
                        local days_ago=$(( ($(date +%s) - $(date -d "$last_log" +%s 2>/dev/null || echo $(date +%s))) / 86400 ))
                        [[ $days_ago -gt 7 ]] && status="⚫ Stale"
                    fi
                fi
                
                [[ "$version" != "$CLAUDEPM_VERSION" ]] && status="🟠 Outdated"
                grep -q "::BLOCKED::" ROADMAP.md 2>/dev/null && status="🟠 Blocked"
                
                printf "%-20s v%-6s %s\n" "$name:" "$version" "$status"
                cd - >/dev/null
            done
        fi
    done
    
    echo -e "\nRun 'claudepm upgrade' in outdated projects"
}

# Task management
task_command() {
    local subcommand="${1:-list}"
    shift
    
    case "$subcommand" in
        add)
            local description="$*"
            if [[ -z "$description" ]]; then
                echo "Error: Task description required"
                echo "Usage: claudepm task add <description>"
                exit 1
            fi
            local uuid=$(generate_uuid)
            echo "CPM::TASK::$uuid::TODO::$(date +%Y-%m-%d)::$description" >> ROADMAP.md
            echo "Added task: $uuid"
            ;;
            
        list)
            if [[ ! -f "ROADMAP.md" ]]; then
                echo "No ROADMAP.md found"
                exit 1
            fi
            
            local filter="${1:-}"
            echo "Tasks:"
            if [[ "$filter" == "--blocked" ]]; then
                grep "CPM::TASK::.*::BLOCKED::" ROADMAP.md | while IFS= read -r line; do
                    # Split by :: using sed
                    local parts=$(echo "$line" | sed 's/::/|/g')
                    local uuid=$(echo "$parts" | cut -d'|' -f3)
                    local status=$(echo "$parts" | cut -d'|' -f4)
                    local date=$(echo "$parts" | cut -d'|' -f5)
                    local desc=$(echo "$parts" | cut -d'|' -f6-)
                    printf "[%s] %s - %s\n" "$status" "$date" "$desc"
                done
            else
                grep "CPM::TASK::" ROADMAP.md | while IFS= read -r line; do
                    # Split by :: using sed
                    local parts=$(echo "$line" | sed 's/::/|/g')
                    local uuid=$(echo "$parts" | cut -d'|' -f3)
                    local status=$(echo "$parts" | cut -d'|' -f4)
                    local date=$(echo "$parts" | cut -d'|' -f5)
                    local desc=$(echo "$parts" | cut -d'|' -f6-)
                    printf "[%s] %s - %s\n" "$status" "$date" "$desc"
                done
            fi
            ;;
            
        done)
            local uuid="${1:-}"
            if [[ -z "$uuid" ]]; then
                echo "Error: UUID required"
                echo "Usage: claudepm task done <uuid>"
                exit 1
            fi
            # Update task status to DONE
            sed -i.bak "s/CPM::TASK::$uuid::[^:]*::/CPM::TASK::$uuid::DONE::/" ROADMAP.md
            echo "Marked task $uuid as DONE"
            ;;
            
        block)
            local uuid="${1:-}"
            local reason="${2:-}"
            if [[ -z "$uuid" ]] || [[ -z "$reason" ]]; then
                echo "Error: UUID and reason required"
                echo "Usage: claudepm task block <uuid> <reason>"
                exit 1
            fi
            # Update task status to BLOCKED and append reason
            sed -i.bak "s/CPM::TASK::$uuid::[^:]*::\(.*\)/CPM::TASK::$uuid::BLOCKED::\1 (Blocked: $reason)/" ROADMAP.md
            echo "Marked task $uuid as BLOCKED"
            ;;
            
        *)
            echo "Unknown task subcommand: $subcommand"
            echo "Available: add, list, done, block"
            exit 1
            ;;
    esac
}

# Upgrade project templates
upgrade_project() {
    if [[ ! -f ".claudepm" ]]; then
        echo "Error: Not a claudepm project"
        echo "Run 'claudepm adopt' first"
        exit 1
    fi
    
    local current_version=$(grep "template_version" .claudepm | cut -d'=' -f2)
    
    if [[ "$current_version" == "$CLAUDEPM_VERSION" ]]; then
        echo "Already at latest version: v$CLAUDEPM_VERSION"
        exit 0
    fi
    
    echo "Upgrading from v$current_version to v$CLAUDEPM_VERSION..."
    
    # Update version marker
    sed -i.bak "s/template_version=.*/template_version=$CLAUDEPM_VERSION/" .claudepm
    sed -i.bak "s/last_update_check=.*/last_update_check=$(date +%Y-%m-%d)/" .claudepm
    
    # Add any missing files (like NOTES.md for older versions)
    local type=$(grep "type=" .claudepm | cut -d'=' -f2 || echo "project")
    [[ ! -f "NOTES.md" ]] && safe_copy_template "$type/NOTES.md" "NOTES.md"
    
    echo -e "${GREEN}✓ Upgrade complete!${NC}"
    echo "Version updated to v$CLAUDEPM_VERSION"
}

# Find blocked items
find_blocked() {
    echo "=== Blocked Tasks ==="
    grep "CPM::TASK::.*::BLOCKED" ROADMAP.md 2>/dev/null | \
        cut -d'::' -f6- | \
        sed 's/^/  - /'
    
    echo -e "\n=== Blocked in Logs ==="
    grep -A2 "^Blocked:" LOG.md 2>/dev/null | tail -20
}

# Get session context - new command for v0.2.5.1
get_context() {
    echo "PROJECT: $(basename "$PWD")"
    echo ""
    
    # Git status summary
    echo "GIT_STATUS:"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$changes" -gt 0 ]]; then
            echo "  Uncommitted changes: $changes files"
            echo "  Modified files:"
            git status --porcelain | head -5 | sed 's/^/    /'
            [[ "$changes" -gt 5 ]] && echo "    ... and $((changes - 5)) more"
        else
            echo "  Clean (no uncommitted changes)"
        fi
    else
        echo "  Not a git repository"
    fi
    echo ""
    
    # Recent log entries
    echo "RECENT_WORK:"
    if [[ -f "LOG.md" ]]; then
        # Get last 3 log entries
        local entries=$(grep -n "^### " LOG.md | tail -3)
        if [[ -n "$entries" ]]; then
            while IFS= read -r line; do
                local line_num=$(echo "$line" | cut -d':' -f1)
                local header=$(echo "$line" | cut -d':' -f2-)
                echo "  $header"
                # Get the "Did:" line
                local did_line=$((line_num + 1))
                sed -n "${did_line}p" LOG.md | sed 's/^/    /'
                # Get the "Next:" line if it exists
                local next_line=$((line_num + 2))
                while IFS= read -r content; do
                    if [[ "$content" =~ ^Next: ]]; then
                        echo "    $content"
                        break
                    fi
                    next_line=$((next_line + 1))
                done < <(tail -n +$next_line LOG.md | head -5)
                echo ""
            done <<< "$entries"
        else
            echo "  No log entries found"
        fi
    else
        echo "  LOG.md not found"
    fi
    
    # Active tasks
    echo "ACTIVE_TASKS:"
    if [[ -f "ROADMAP.md" ]]; then
        local todo_count=$(grep -c "CPM::TASK::.*::TODO::" ROADMAP.md 2>/dev/null | tr -d ' \n' || echo 0)
        local progress_count=$(grep -c "CPM::TASK::.*::IN_PROGRESS::" ROADMAP.md 2>/dev/null | tr -d ' \n' || echo 0)
        local blocked_count=$(grep -c "CPM::TASK::.*::BLOCKED::" ROADMAP.md 2>/dev/null | tr -d ' \n' || echo 0)
        
        echo "  TODO: $todo_count tasks"
        echo "  IN_PROGRESS: $progress_count tasks"
        echo "  BLOCKED: $blocked_count tasks"
        
        # Show in-progress tasks
        if [[ "$progress_count" -gt 0 ]]; then
            echo ""
            echo "  Currently in progress:"
            grep "CPM::TASK::.*::IN_PROGRESS::" ROADMAP.md | while IFS= read -r line; do
                local parts=$(echo "$line" | sed 's/::/|/g')
                local desc=$(echo "$parts" | cut -d'|' -f6-)
                echo "    - $desc"
            done
        fi
    else
        echo "  ROADMAP.md not found"
    fi
    echo ""
    
    # What to work on next
    echo "NEXT_SUGGESTED:"
    # First check for explicit "Next:" in last log
    if [[ -f "LOG.md" ]]; then
        local last_next=$(grep "^Next:" LOG.md | tail -1 | sed 's/^Next: *//')
        if [[ -n "$last_next" ]]; then
            echo "  From last log: $last_next"
        fi
    fi
    # Then check for in-progress tasks
    if [[ "$progress_count" -gt 0 ]]; then
        echo "  Continue in-progress work (see above)"
    elif [[ "$todo_count" -gt 0 ]]; then
        echo "  Start a TODO task (run: claudepm next)"
    else
        echo "  No tasks found - check ROADMAP.md"
    fi
}

# Log work with consistent format - new command for v0.2.5.1
log_work() {
    local title="$1"
    local did_items=()
    local next_task=""
    local blocked_reason=""
    local notes=""
    local tags=()
    local commits=()
    local people=()
    local time_spent=""
    local pr=""
    local error=""
    local decided=""
    
    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --did)
                did_items+=("$2")
                shift 2
                ;;
            --next)
                next_task="$2"
                shift 2
                ;;
            --blocked)
                blocked_reason="$2"
                shift 2
                ;;
            --notes)
                notes="$2"
                shift 2
                ;;
            --tag)
                tags+=("$2")
                shift 2
                ;;
            --commit)
                commits+=("$2")
                shift 2
                ;;
            --with)
                people+=("$2")
                shift 2
                ;;
            --time)
                time_spent="$2"
                shift 2
                ;;
            --pr)
                pr="$2"
                shift 2
                ;;
            --error)
                error="$2"
                shift 2
                ;;
            --decided)
                decided="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: claudepm log \"title\" [options]"
                echo ""
                echo "Options:"
                echo "  --did \"item\"        What was accomplished (repeatable)"
                echo "  --next \"task\"       What to work on next"
                echo "  --blocked \"reason\"  Why work is blocked"
                echo "  --notes \"text\"      Additional context"
                echo "  --tag \"keyword\"     Tags for searching (repeatable)"
                echo "  --commit \"sha\"      Related git commits (repeatable)"
                echo "  --with \"@person\"    People involved (repeatable)"
                echo "  --time \"duration\"   Time spent (e.g., \"2h\", \"30m\")"
                echo "  --pr \"#123\"         Related PR number"
                echo "  --error \"message\"   Error encountered"
                echo "  --decided \"choice\"  Decision made"
                echo ""
                echo "Examples:"
                echo "  claudepm log \"Fixed auth bug\" --commit abc123 --time 2h --tag security"
                echo "  claudepm log \"Team meeting\" --with @alice --with @bob --decided \"Use PostgreSQL\""
                echo "  claudepm log \"Debug session\" --error \"Memory leak in auth module\" --tag bug"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$title" ]]; then
        echo "Error: Log title required"
        echo "Usage: claudepm log \"title\" [options]"
        exit 1
    fi
    
    # Append to LOG.md
    {
        echo ""
        echo ""
        # Include tags in header if present
        if [[ ${#tags[@]} -gt 0 ]]; then
            local tag_string=""
            for tag in "${tags[@]}"; do
                tag_string="$tag_string #$tag"
            done
            echo "### $(date '+%Y-%m-%d %H:%M') - $title$tag_string"
        else
            echo "### $(date '+%Y-%m-%d %H:%M') - $title"
        fi
        
        # Handle Did section
        if [[ ${#did_items[@]} -gt 0 ]]; then
            echo "Did:"
            for item in "${did_items[@]}"; do
                echo "- $item"
            done
        else
            echo "Did: $title"
        fi
        
        # Add Error if provided
        if [[ -n "$error" ]]; then
            echo "Error: $error"
        fi
        
        # Add Decided if provided
        if [[ -n "$decided" ]]; then
            echo "Decided: $decided"
        fi
        
        # Add Next if provided
        if [[ -n "$next_task" ]]; then
            echo "Next: $next_task"
        fi
        
        # Add Blocked if provided
        if [[ -n "$blocked_reason" ]]; then
            echo "Blocked: $blocked_reason"
        fi
        
        # Add Time if provided
        if [[ -n "$time_spent" ]]; then
            echo "Time: $time_spent"
        fi
        
        # Add People if provided
        if [[ ${#people[@]} -gt 0 ]]; then
            echo -n "With:"
            for person in "${people[@]}"; do
                echo -n " $person"
            done
            echo ""
        fi
        
        # Add Commits if provided
        if [[ ${#commits[@]} -gt 0 ]]; then
            echo -n "Commits:"
            for commit in "${commits[@]}"; do
                echo -n " $commit"
            done
            echo ""
        fi
        
        # Add PR if provided
        if [[ -n "$pr" ]]; then
            echo "PR: $pr"
        fi
        
        # Add Notes if provided
        if [[ -n "$notes" ]]; then
            echo "Notes: $notes"
        fi
        
        echo ""
        echo "---"
    } >> LOG.md
    
    echo "Logged: $title"
    [[ ${#did_items[@]} -gt 0 ]] && echo "Items: ${#did_items[@]} completed"
    [[ -n "$next_task" ]] && echo "Next: $next_task"
    [[ -n "$blocked_reason" ]] && echo "Blocked: $blocked_reason"
    [[ ${#tags[@]} -gt 0 ]] && echo "Tags: ${tags[*]}"
}

# Suggest next task - new command for v0.2.5.1
suggest_next() {
    echo "SUGGESTED_TASKS:"
    echo ""
    
    # Check for in-progress tasks first
    if [[ -f "ROADMAP.md" ]]; then
        local in_progress=$(grep "CPM::TASK::.*::IN_PROGRESS::" ROADMAP.md)
        if [[ -n "$in_progress" ]]; then
            echo "Continue in-progress work:"
            echo "$in_progress" | while IFS= read -r line; do
                local parts=$(echo "$line" | sed 's/::/|/g')
                local uuid=$(echo "$parts" | cut -d'|' -f3)
                local desc=$(echo "$parts" | cut -d'|' -f6-)
                echo "  [$uuid] $desc"
            done
            echo ""
        fi
        
        # Then show TODO tasks
        local todos=$(grep "CPM::TASK::.*::TODO::" ROADMAP.md | head -5)
        if [[ -n "$todos" ]]; then
            echo "Available TODO tasks:"
            echo "$todos" | while IFS= read -r line; do
                local parts=$(echo "$line" | sed 's/::/|/g')
                local uuid=$(echo "$parts" | cut -d'|' -f3)
                local desc=$(echo "$parts" | cut -d'|' -f6-)
                echo "  [$uuid] $desc"
            done
        fi
        
        # Show blocked tasks
        local blocked=$(grep "CPM::TASK::.*::BLOCKED::" ROADMAP.md)
        if [[ -n "$blocked" ]]; then
            echo ""
            echo "Blocked tasks (resolve blockers first):"
            echo "$blocked" | while IFS= read -r line; do
                local parts=$(echo "$line" | sed 's/::/|/g')
                local desc=$(echo "$parts" | cut -d'|' -f6-)
                echo "  - $desc"
            done
        fi
    else
        echo "No ROADMAP.md found"
    fi
}