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
        # Ensure Tasks section exists
        if ! grep -q "^## Tasks" ROADMAP.md; then
            {
                echo ""
                echo "## Tasks"
                echo ""
                echo "### TODO"
            } >> ROADMAP.md
        fi
        
        if command -v rg >/dev/null 2>&1; then
            rg "TODO|FIXME" --no-heading | while read -r line; do
                echo "- [ ] $line" >> ROADMAP.md
                echo "  ID: $(generate_uuid)" >> ROADMAP.md
                echo "" >> ROADMAP.md
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
        # Count tasks in each section
        local todo_count=0
        local in_progress_count=0
        local blocked_count=0
        local in_section=""
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^###[[:space:]]+(TODO|IN\ PROGRESS|BLOCKED|DONE) ]]; then
                in_section="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^-[[:space:]]\[([[:space:]]|x)\] ]] && [[ -n "$in_section" ]]; then
                case "$in_section" in
                    TODO) ((todo_count++)) ;;
                    "IN PROGRESS") ((in_progress_count++)) ;;
                    BLOCKED) ((blocked_count++)) ;;
                esac
            fi
        done < ROADMAP.md
        
        local active_count=$((todo_count + in_progress_count))
        
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
                # Check for blocked tasks in new format
                if grep -q "^### BLOCKED" ROADMAP.md 2>/dev/null && grep -A20 "^### BLOCKED" ROADMAP.md | grep -q "^- \[[ x]\]"; then
                    status="🟠 Blocked"
                fi
                
                printf "%-20s v%-6s %s\n" "$name:" "$version" "$status"
                cd - >/dev/null
            done
        fi
    done
    
    echo -e "\nRun 'claudepm upgrade' in outdated projects"
}


# Ensure tasks section exists in ROADMAP.md
ensure_tasks_section() {
    if [[ ! -f "ROADMAP.md" ]]; then
        echo "No ROADMAP.md found"
        exit 1
    fi
    
    # Check if Tasks section exists
    if ! grep -q "^## Tasks" ROADMAP.md; then
        # Add Tasks section at the end
        {
            echo ""
            echo "## Tasks"
            echo ""
            echo "### TODO"
            echo ""
            echo "### IN PROGRESS"
            echo ""
            echo "### BLOCKED"
            echo ""
            echo "### DONE"
            echo ""
        } >> ROADMAP.md
    fi
}

# Parse task metadata from a line
parse_task_metadata() {
    local line="$1"
    local metadata=""
    
    # Extract priority
    if [[ "$line" =~ \[high\] ]]; then
        metadata="${metadata}priority:high "
    elif [[ "$line" =~ \[medium\] ]]; then
        metadata="${metadata}priority:medium "
    elif [[ "$line" =~ \[low\] ]]; then
        metadata="${metadata}priority:low "
    fi
    
    # Extract tags
    if [[ "$line" =~ \[#([^]]+)\] ]]; then
        local tags="${BASH_REMATCH[1]}"
        metadata="${metadata}tags:${tags} "
    fi
    
    # Extract due date
    if [[ "$line" =~ \[due:([0-9-]+)\] ]]; then
        metadata="${metadata}due:${BASH_REMATCH[1]} "
    fi
    
    # Extract assignee
    if [[ "$line" =~ \[@([^]]+)\] ]]; then
        metadata="${metadata}assignee:@${BASH_REMATCH[1]} "
    fi
    
    # Extract estimate
    if [[ "$line" =~ \[([0-9]+[hd])\] ]]; then
        metadata="${metadata}estimate:${BASH_REMATCH[1]} "
    fi
    
    # Extract blocked reason
    if [[ "$line" =~ \[blocked:([^]]+)\] ]]; then
        metadata="${metadata}blocked:${BASH_REMATCH[1]} "
    fi
    
    echo "$metadata"
}

# Task management
task_command() {
    local subcommand="${1:-list}"
    shift
    
    case "$subcommand" in
        add)
            ensure_tasks_section
            parse_roadmap
            
            local description=""
            local priority=""
            local tags=()
            local due_date=""
            local assignee=""
            local estimate=""
            
            # Parse arguments
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -p|--priority)
                        priority="$2"
                        shift 2
                        ;;
                    -t|--tag)
                        tags+=("$2")
                        shift 2
                        ;;
                    -d|--due)
                        due_date="$2"
                        shift 2
                        ;;
                    -a|--assign)
                        assignee="$2"
                        shift 2
                        ;;
                    -e|--estimate)
                        estimate="$2"
                        shift 2
                        ;;
                    *)
                        # Collect remaining args as description
                        description="$description $1"
                        shift
                        ;;
                esac
            done
            
            description=$(echo "$description" | sed 's/^ *//')
            
            if [[ -z "$description" ]]; then
                echo "Error: Task description required"
                echo "Usage: claudepm task add <description> [options]"
                exit 1
            fi
            
            local uuid=$(generate_uuid)
            
            # Build task line
            local task_line="- [ ] $description"
            [[ -n "$priority" ]] && task_line="$task_line [$priority]"
            if [[ ${#tags[@]} -gt 0 ]]; then
                local tag_list=$(printf "#%s" "${tags[@]}" | sed 's/#/, #/g' | sed 's/^, //')
                task_line="$task_line [$tag_list]"
            fi
            [[ -n "$due_date" ]] && task_line="$task_line [due:$due_date]"
            [[ -n "$assignee" ]] && task_line="$task_line [$assignee]"
            [[ -n "$estimate" ]] && task_line="$task_line [$estimate]"
            
            # Add task to data structure
            TASK_UUIDS+=("$uuid")
            TASK_LINES+=("$task_line")
            TASK_SECTIONS+=("TODO")
            TASK_ORDER+=("$uuid")
            
            # Render updated roadmap
            render_roadmap
            
            echo "Added task: $uuid"
            ;;
            
        list)
            ensure_tasks_section
            parse_roadmap
            
            local filter_status=""
            local filter_priority=""
            local filter_tag=""
            local show_full=false
            local show_overdue=false
            
            # Parse list options
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --todo|--done|--blocked|--in-progress)
                        filter_status=$(echo "$1" | sed 's/--//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
                        [[ "$filter_status" == "IN_PROGRESS" ]] && filter_status="IN_PROGRESS"
                        shift
                        ;;
                    -p|--priority)
                        filter_priority="$2"
                        shift 2
                        ;;
                    -t|--tag)
                        filter_tag="$2"
                        shift 2
                        ;;
                    -f|--full)
                        show_full=true
                        shift
                        ;;
                    --overdue)
                        show_overdue=true
                        shift
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            # Display tasks by section
            local current_section=""
            local i
            for ((i=0; i<${#TASK_UUIDS[@]}; i++)); do
                local uuid="${TASK_UUIDS[$i]}"
                local task_line="${TASK_LINES[$i]}"
                local section="${TASK_SECTIONS[$i]}"
                
                # Apply status filter
                if [[ -n "$filter_status" ]] && [[ "$section" != "$filter_status" ]]; then
                    continue
                fi
                
                # Apply priority filter
                if [[ -n "$filter_priority" ]] && ! [[ "$task_line" =~ \[$filter_priority\] ]]; then
                    continue
                fi
                
                # Apply tag filter
                if [[ -n "$filter_tag" ]] && ! [[ "$task_line" =~ "#$filter_tag" ]]; then
                    continue
                fi
                
                # Apply overdue filter
                if [[ "$show_overdue" == true ]]; then
                    if [[ "$task_line" =~ \[due:([0-9-]+)\] ]]; then
                        local due_date="${BASH_REMATCH[1]}"
                        if ! command -v date >/dev/null 2>&1 || [[ $(date -d "$due_date" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$due_date" +%s 2>/dev/null) -ge $(date +%s) ]]; then
                            continue
                        fi
                    else
                        continue
                    fi
                fi
                
                # Print section header if changed
                if [[ "$section" != "$current_section" ]]; then
                    current_section="$section"
                    echo ""
                    local display_section="$section"
                    [[ "$display_section" == "IN_PROGRESS" ]] && display_section="IN PROGRESS"
                    echo "### $display_section"
                fi
                
                # Display task
                if [[ "$show_full" == true ]]; then
                    echo "$task_line"
                    echo "  ID: $uuid"
                else
                    # Extract just the description without metadata
                    local desc=$(echo "$task_line" | sed 's/^-[[:space:]]\[[[:space:]]x\][[:space:]]//' | sed 's/ \[[^]]*\]//g')
                    echo "[$uuid] $desc"
                fi
            done
            ;;
            
        start)
            local uuid="${1:-}"
            if [[ -z "$uuid" ]]; then
                echo "Error: UUID required"
                echo "Usage: claudepm task start <uuid>"
                exit 1
            fi
            
            ensure_tasks_section
            parse_roadmap
            
            # Check if task exists
            local idx=$(find_task_index "$uuid")
            if [[ -z "$idx" ]]; then
                echo "Error: Task $uuid not found"
                exit 1
            fi
            
            # Update task
            local task_line="${TASK_LINES[$idx]}"
            TASK_SECTIONS[$idx]="IN_PROGRESS"
            
            # Add started timestamp if not present
            if ! [[ "$task_line" =~ \[started: ]]; then
                task_line="$task_line [started:$(date +%Y-%m-%d)]"
                TASK_LINES[$idx]="$task_line"
            fi
            
            # Render updated roadmap
            render_roadmap
            
            echo "Started task $uuid"
            ;;
            
        done)
            local uuid="${1:-}"
            if [[ -z "$uuid" ]]; then
                echo "Error: UUID required"
                echo "Usage: claudepm task done <uuid>"
                exit 1
            fi
            
            ensure_tasks_section
            parse_roadmap
            
            # Check if task exists
            local idx=$(find_task_index "$uuid")
            if [[ -z "$idx" ]]; then
                echo "Error: Task $uuid not found"
                exit 1
            fi
            
            # Update task
            local task_line="${TASK_LINES[$idx]}"
            TASK_SECTIONS[$idx]="DONE"
            
            # Update checkbox to checked
            task_line=$(echo "$task_line" | sed 's/- \[ \]/- [x]/')
            
            # Add completed timestamp if not present
            if ! [[ "$task_line" =~ \[completed: ]]; then
                task_line="$task_line [completed:$(date +%Y-%m-%d)]"
            fi
            
            TASK_LINES[$idx]="$task_line"
            
            # Render updated roadmap
            render_roadmap
            
            echo "Completed task $uuid"
            ;;
            
        block)
            local uuid="${1:-}"
            local reason="${2:-}"
            if [[ -z "$uuid" ]] || [[ -z "$reason" ]]; then
                echo "Error: UUID and reason required"
                echo "Usage: claudepm task block <uuid> <reason>"
                exit 1
            fi
            
            ensure_tasks_section
            parse_roadmap
            
            # Check if task exists
            local idx=$(find_task_index "$uuid")
            if [[ -z "$idx" ]]; then
                echo "Error: Task $uuid not found"
                exit 1
            fi
            
            # Update task
            local task_line="${TASK_LINES[$idx]}"
            TASK_SECTIONS[$idx]="BLOCKED"
            
            # Add blocked reason if not present
            if ! [[ "$task_line" =~ \[blocked: ]]; then
                task_line="$task_line [blocked:$reason]"
                TASK_LINES[$idx]="$task_line"
            fi
            
            # Render updated roadmap
            render_roadmap
            
            echo "Blocked task $uuid: $reason"
            ;;
            
        update)
            local uuid="${1:-}"
            if [[ -z "$uuid" ]]; then
                echo "Error: UUID required"
                echo "Usage: claudepm task update <uuid> [options]"
                exit 1
            fi
            shift
            
            ensure_tasks_section
            parse_roadmap
            
            # Check if task exists
            local idx=$(find_task_index "$uuid")
            if [[ -z "$idx" ]]; then
                echo "Error: Task $uuid not found"
                exit 1
            fi
            
            # Parse update options
            local new_priority=""
            local new_tags=()
            local new_due=""
            local new_assignee=""
            local new_estimate=""
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -p|--priority)
                        new_priority="$2"
                        shift 2
                        ;;
                    -t|--tag)
                        new_tags+=("$2")
                        shift 2
                        ;;
                    -d|--due)
                        new_due="$2"
                        shift 2
                        ;;
                    -a|--assign)
                        new_assignee="$2"
                        shift 2
                        ;;
                    -e|--estimate)
                        new_estimate="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            # Get current task line
            local task_line="${TASK_LINES[$idx]}"
            
            # Parse current task to extract components
            local checkbox=" "
            if [[ "$task_line" =~ ^-[[:space:]]\[x\] ]]; then
                checkbox="x"
            fi
            
            # Remove existing metadata to get clean description
            local clean_desc=$(echo "$task_line" | sed 's/^-[[:space:]]\[[[:space:]x]\][[:space:]]//' | sed 's/ \[[^]]*\]//g')
            
            # Rebuild task line with updated metadata
            local updated_line="- [$checkbox] $clean_desc"
            
            # Priority
            if [[ -n "$new_priority" ]]; then
                updated_line="$updated_line [$new_priority]"
            elif [[ "$task_line" =~ \[(high|medium|low)\] ]]; then
                updated_line="$updated_line [${BASH_REMATCH[1]}]"
            fi
            
            # Tags
            if [[ ${#new_tags[@]} -gt 0 ]]; then
                local tag_list=$(printf "#%s" "${new_tags[@]}" | sed 's/#/, #/g' | sed 's/^, //')
                updated_line="$updated_line [$tag_list]"
            elif [[ "$task_line" =~ \[#([^]]+)\] ]]; then
                updated_line="$updated_line [#${BASH_REMATCH[1]}]"
            fi
            
            # Due date
            if [[ -n "$new_due" ]]; then
                updated_line="$updated_line [due:$new_due]"
            elif [[ "$task_line" =~ \[due:([^]]+)\] ]]; then
                updated_line="$updated_line [due:${BASH_REMATCH[1]}]"
            fi
            
            # Assignee
            if [[ -n "$new_assignee" ]]; then
                updated_line="$updated_line [@$new_assignee]"
            elif [[ "$task_line" =~ \[@([^]]+)\] ]]; then
                updated_line="$updated_line [@${BASH_REMATCH[1]}]"
            fi
            
            # Estimate
            if [[ -n "$new_estimate" ]]; then
                updated_line="$updated_line [$new_estimate]"
            elif [[ "$task_line" =~ \[([0-9]+[hd])\] ]]; then
                updated_line="$updated_line [${BASH_REMATCH[1]}]"
            fi
            
            # Preserve status-specific metadata
            if [[ "$task_line" =~ \[started:([^]]+)\] ]]; then
                updated_line="$updated_line [started:${BASH_REMATCH[1]}]"
            fi
            if [[ "$task_line" =~ \[completed:([^]]+)\] ]]; then
                updated_line="$updated_line [completed:${BASH_REMATCH[1]}]"
            fi
            if [[ "$task_line" =~ \[blocked:([^]]+)\] ]]; then
                updated_line="$updated_line [blocked:${BASH_REMATCH[1]}]"
            fi
            
            # Update task in data structure
            TASK_LINES[$idx]="$updated_line"
            
            # Render updated roadmap
            render_roadmap
            
            echo "Updated task $uuid"
            ;;
            
        *)
            echo "Unknown task subcommand: $subcommand"
            echo "Available: add, list, start, done, block, update"
            exit 1
            ;;
    esac
}

# Migrate old CPM::TASK format to new human-readable format
migrate_tasks() {
    if [[ ! -f "ROADMAP.md" ]]; then
        return 0
    fi
    
    # Check if migration is needed
    if ! grep -q "CPM::TASK::" ROADMAP.md; then
        return 0
    fi
    
    echo "Migrating tasks to new human-readable format..."
    
    # Create temp file
    local temp_file=$(mktemp)
    local migrated_count=0
    
    # Read and categorize old tasks
    local todo_tasks=()
    local in_progress_tasks=()
    local blocked_tasks=()
    local done_tasks=()
    
    while IFS= read -r line; do
        if [[ "$line" =~ CPM::TASK::([^:]+)::([^:]+)::([^:]+)::(.+) ]]; then
            local uuid="${BASH_REMATCH[1]}"
            local status="${BASH_REMATCH[2]}"
            local date="${BASH_REMATCH[3]}"
            local desc="${BASH_REMATCH[4]}"
            
            # Parse additional metadata from description
            local priority=""
            local tags=""
            local due=""
            local assignee=""
            local estimate=""
            local blocked_reason=""
            
            # Extract metadata patterns from description
            if [[ "$desc" =~ \|\|priority:([^|]+)\|\| ]]; then
                priority="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed "s/||priority:[^|]*||//g")
            fi
            
            if [[ "$desc" =~ \|\|tags:([^|]+)\|\| ]]; then
                tags="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed "s/||tags:[^|]*||//g")
            fi
            
            if [[ "$desc" =~ \|\|due:([^|]+)\|\| ]]; then
                due="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed "s/||due:[^|]*||//g")
            fi
            
            if [[ "$desc" =~ \|\|assignee:([^|]+)\|\| ]]; then
                assignee="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed "s/||assignee:[^|]*||//g")
            fi
            
            if [[ "$desc" =~ \|\|estimate:([^|]+)\|\| ]]; then
                estimate="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed "s/||estimate:[^|]*||//g")
            fi
            
            if [[ "$desc" =~ \(Blocked:[[:space:]]([^\)]+)\) ]]; then
                blocked_reason="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed "s/ (Blocked: [^)]*)//g")
            fi
            
            # Build new format task line
            local checkbox="[ ]"
            [[ "$status" == "DONE" ]] && checkbox="[x]"
            
            local task_line="- $checkbox $desc"
            [[ -n "$priority" ]] && task_line="$task_line [$priority]"
            [[ -n "$tags" ]] && task_line="$task_line [#$tags]"
            [[ -n "$due" ]] && task_line="$task_line [due:$due]"
            [[ -n "$assignee" ]] && task_line="$task_line [$assignee]"
            [[ -n "$estimate" ]] && task_line="$task_line [$estimate]"
            
            # Add status-specific metadata
            case "$status" in
                TODO)
                    todo_tasks+=("$task_line\n  ID: $uuid\n")
                    ;;
                IN_PROGRESS)
                    task_line="$task_line [started:$date]"
                    in_progress_tasks+=("$task_line\n  ID: $uuid\n")
                    ;;
                BLOCKED)
                    [[ -n "$blocked_reason" ]] && task_line="$task_line [blocked:$blocked_reason]"
                    blocked_tasks+=("$task_line\n  ID: $uuid\n")
                    ;;
                DONE)
                    task_line="$task_line [completed:$date]"
                    done_tasks+=("$task_line\n  ID: $uuid\n")
                    ;;
            esac
            
            ((migrated_count++))
        fi
    done < ROADMAP.md
    
    # Write non-task content and new task sections
    local in_old_tasks=false
    while IFS= read -r line; do
        # Skip old task lines
        if [[ "$line" =~ CPM::TASK:: ]]; then
            in_old_tasks=true
            continue
        fi
        
        # Check if we're leaving the old tasks section
        if [[ "$in_old_tasks" == true ]] && ! [[ "$line" =~ CPM::TASK:: ]] && [[ -n "$line" ]]; then
            in_old_tasks=false
        fi
        
        if [[ "$in_old_tasks" == false ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < ROADMAP.md
    
    # Add new Tasks section
    {
        echo ""
        echo "## Tasks"
        echo ""
        echo "### TODO"
        for task in "${todo_tasks[@]}"; do
            echo -e "$task"
        done
        echo ""
        echo "### IN PROGRESS"
        for task in "${in_progress_tasks[@]}"; do
            echo -e "$task"
        done
        echo ""
        echo "### BLOCKED"
        for task in "${blocked_tasks[@]}"; do
            echo -e "$task"
        done
        echo ""
        echo "### DONE"
        for task in "${done_tasks[@]}"; do
            echo -e "$task"
        done
    } >> "$temp_file"
    
    # Backup and replace
    cp ROADMAP.md ROADMAP.md.backup_$(date +%Y%m%d_%H%M%S)
    mv "$temp_file" ROADMAP.md
    
    echo "Migrated $migrated_count tasks to new format"
    echo "Backup saved as ROADMAP.md.backup_*"
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
    
    # Migrate tasks if needed
    migrate_tasks
    
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
    
    local in_blocked=false
    while IFS= read -r line; do
        if [[ "$line" == "### BLOCKED" ]]; then
            in_blocked=true
        elif [[ "$line" =~ ^### ]]; then
            in_blocked=false
        elif [[ "$in_blocked" == true ]] && [[ "$line" =~ ^-[[:space:]]\[([[:space:]]x)\][[:space:]](.+) ]]; then
            local task="${BASH_REMATCH[2]}"
            # Extract just the description without metadata
            task=$(echo "$task" | sed 's/ \[[^]]*\]//g')
            echo "  - $task"
        fi
    done < ROADMAP.md 2>/dev/null
    
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
        # Count tasks in each section
        local todo_count=0
        local progress_count=0
        local blocked_count=0
        local in_section=""
        local in_progress_tasks=()
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^###[[:space:]]+(TODO|IN\ PROGRESS|BLOCKED|DONE) ]]; then
                in_section="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^-[[:space:]]\[([[:space:]]x)\][[:space:]](.+) ]] && [[ -n "$in_section" ]]; then
                case "$in_section" in
                    TODO) ((todo_count++)) ;;
                    "IN PROGRESS") 
                        ((progress_count++))
                        local task="${BASH_REMATCH[1]}"
                        # Extract just the description without metadata
                        task=$(echo "$task" | sed 's/ \[[^]]*\]//g')
                        in_progress_tasks+=("$task")
                        ;;
                    BLOCKED) ((blocked_count++)) ;;
                esac
            fi
        done < ROADMAP.md
        
        echo "  TODO: $todo_count tasks"
        echo "  IN_PROGRESS: $progress_count tasks"
        echo "  BLOCKED: $blocked_count tasks"
        
        # Show in-progress tasks
        if [[ "$progress_count" -gt 0 ]]; then
            echo ""
            echo "  Currently in progress:"
            for task in "${in_progress_tasks[@]}"; do
                echo "    - $task"
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

# Log work with consistent format - simplified for v0.2.5.2
log_work() {
    local title="${1:-}"
    shift
    
    if [[ -z "$title" ]]; then
        echo "Error: Log title required"
        echo "Usage: claudepm log \"title\" [content]"
        echo ""
        echo "Examples:"
        echo '  claudepm log "Fixed auth bug"'
        echo '  claudepm log "Fixed auth bug" "Found race condition. Applied mutex lock."'
        echo ""
        echo "Claude can structure content as needed:"
        echo '  claudepm log "Debug session" "Did: Found memory leak'
        echo '  Error: MaxListenersExceeded in WebSocket'
        echo '  Next: Add cleanup in unmount"'
        exit 1
    fi
    
    # Collect any additional content as free-form text
    local content="$*"
    
    # Append to LOG.md with minimal structure
    {
        echo ""
        echo ""
        echo "### $(date '+%Y-%m-%d %H:%M') - $title"
        if [[ -n "$content" ]]; then
            echo "$content"
        else
            echo "Did: $title"
        fi
        echo ""
        echo "---"
    } >> LOG.md
    
    echo "Logged: $title"
}

# Suggest next task - new command for v0.2.5.1
suggest_next() {
    echo "SUGGESTED_TASKS:"
    echo ""
    
    # Check for in-progress tasks first
    if [[ -f "ROADMAP.md" ]]; then
        local in_section=""
        local task_count=0
        
        # First check IN PROGRESS section
        echo "Continue in-progress work:"
        while IFS= read -r line; do
            if [[ "$line" =~ ^###[[:space:]]+(TODO|IN\ PROGRESS|BLOCKED|DONE) ]]; then
                in_section="${BASH_REMATCH[1]}"
            elif [[ "$in_section" == "IN PROGRESS" ]] && [[ "$line" =~ ^-[[:space:]]\[([[:space:]]x)\][[:space:]](.+) ]]; then
                local task="${BASH_REMATCH[2]}"
            elif [[ "$in_section" == "IN PROGRESS" ]] && [[ "$line" =~ ^[[:space:]]+ID:[[:space:]](.+) ]]; then
                local uuid="${BASH_REMATCH[1]}"
                if [[ -n "$task" ]]; then
                    # Extract just the description without metadata
                    local desc=$(echo "$task" | sed 's/ \[[^]]*\]//g')
                    echo "  [$uuid] $desc"
                    ((task_count++))
                    task=""
                fi
            fi
        done < ROADMAP.md
        
        if [[ $task_count -eq 0 ]]; then
            echo "  No tasks in progress"
        fi
        echo ""
        
        # Then show TODO tasks
        echo "Available TODO tasks:"
        task_count=0
        while IFS= read -r line; do
            if [[ "$line" =~ ^###[[:space:]]+(TODO|IN\ PROGRESS|BLOCKED|DONE) ]]; then
                in_section="${BASH_REMATCH[1]}"
            elif [[ "$in_section" == "TODO" ]] && [[ "$line" =~ ^-[[:space:]]\[([[:space:]]x)\][[:space:]](.+) ]]; then
                local task="${BASH_REMATCH[2]}"
            elif [[ "$in_section" == "TODO" ]] && [[ "$line" =~ ^[[:space:]]+ID:[[:space:]](.+) ]]; then
                local uuid="${BASH_REMATCH[1]}"
                if [[ -n "$task" ]] && [[ $task_count -lt 5 ]]; then
                    # Extract just the description without metadata
                    local desc=$(echo "$task" | sed 's/ \[[^]]*\]//g')
                    echo "  [$uuid] $desc"
                    ((task_count++))
                    task=""
                fi
            fi
        done < ROADMAP.md
        
        if [[ $task_count -eq 0 ]]; then
            echo "  No TODO tasks"
        fi
        
        # Show blocked tasks
        echo ""
        echo "Blocked tasks (resolve blockers first):"
        task_count=0
        while IFS= read -r line; do
            if [[ "$line" =~ ^###[[:space:]]+(TODO|IN\ PROGRESS|BLOCKED|DONE) ]]; then
                in_section="${BASH_REMATCH[1]}"
            elif [[ "$in_section" == "BLOCKED" ]] && [[ "$line" =~ ^-[[:space:]]\[([[:space:]]x)\][[:space:]](.+) ]]; then
                local task="${BASH_REMATCH[2]}"
                # Extract just the description without metadata
                local desc=$(echo "$task" | sed 's/ \[[^]]*\]//g')
                echo "  - $desc"
                ((task_count++))
            fi
        done < ROADMAP.md
        
        if [[ $task_count -eq 0 ]]; then
            echo "  No blocked tasks"
        fi
    else
        echo "No ROADMAP.md found"
    fi
}

# Parse-Mutate-Render Architecture for task management
# Global arrays to hold parsed data
declare -a TASK_UUIDS
declare -a TASK_LINES
declare -a TASK_SECTIONS
declare -a TASK_ORDER
declare -a PRE_TASK_LINES
declare -a POST_TASK_LINES

# Parse ROADMAP.md into structured data
parse_roadmap() {
    # Clear previous state
    PRE_TASK_LINES=()
    POST_TASK_LINES=()
    TASK_UUIDS=()
    TASK_LINES=()
    TASK_SECTIONS=()
    TASK_ORDER=()
    
    local state="pre" # states: pre, tasks, post
    local current_section=""
    local current_task=""
    local current_uuid=""
    local line_num=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        if [[ "$line" =~ ^##[[:space:]]+Tasks ]]; then
            state="tasks"
            PRE_TASK_LINES+=("$line")
            continue
        elif [[ "$state" == "tasks" ]] && [[ "$line" =~ ^##[[:space:]] ]] && ! [[ "$line" =~ ^##[[:space:]]+Tasks ]]; then
            # Found a section after Tasks
            state="post"
        fi
        
        if [[ "$state" == "pre" ]]; then
            PRE_TASK_LINES+=("$line")
        elif [[ "$state" == "post" ]]; then
            POST_TASK_LINES+=("$line")
        elif [[ "$state" == "tasks" ]]; then
            # Parse task sections
            if [[ "$line" =~ ^###[[:space:]]+(TODO|IN[[:space:]]PROGRESS|BLOCKED|DONE) ]]; then
                current_section="${BASH_REMATCH[1]}"
                # Normalize section name
                [[ "$current_section" == "IN PROGRESS" ]] && current_section="IN_PROGRESS"
            elif [[ "$line" =~ ^-[[:space:]]\[([[:space:]]|x)\][[:space:]](.+) ]]; then
                # Task line
                current_task="$line"
                local checkbox="${BASH_REMATCH[1]}"
                local content="${BASH_REMATCH[2]}"
            elif [[ "$line" =~ ^[[:space:]]+ID:[[:space:]](.+) ]] && [[ -n "$current_task" ]]; then
                # ID line for previous task
                current_uuid="${BASH_REMATCH[1]}"
                # Store task data in parallel arrays
                TASK_UUIDS+=("$current_uuid")
                TASK_LINES+=("$current_task")
                TASK_SECTIONS+=("$current_section")
                TASK_ORDER+=("$current_uuid")
                current_task=""
                current_uuid=""
            fi
        fi
    done < ROADMAP.md
    
    # Always return success
    return 0
}

# Find task index by UUID
find_task_index() {
    local uuid="$1"
    local i
    for ((i=0; i<${#TASK_UUIDS[@]}; i++)); do
        if [[ "${TASK_UUIDS[$i]}" == "$uuid" ]]; then
            echo "$i"
            return 0
        fi
    done
    return 1
}

# Render the roadmap from structured data
render_roadmap() {
    local temp_file=$(mktemp)
    
    # Write pre-task content
    if [[ ${#PRE_TASK_LINES[@]} -gt 0 ]]; then
        for line in "${PRE_TASK_LINES[@]}"; do
            echo "$line" >> "$temp_file"
        done
    fi
    
    # Write task sections
    echo "" >> "$temp_file"
    echo "### TODO" >> "$temp_file"
    local i
    for ((i=0; i<${#TASK_UUIDS[@]}; i++)); do
        if [[ "${TASK_SECTIONS[$i]}" == "TODO" ]]; then
            echo "${TASK_LINES[$i]}" >> "$temp_file"
            echo "  ID: ${TASK_UUIDS[$i]}" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    done
    
    echo "### IN PROGRESS" >> "$temp_file"
    for ((i=0; i<${#TASK_UUIDS[@]}; i++)); do
        if [[ "${TASK_SECTIONS[$i]}" == "IN_PROGRESS" ]]; then
            echo "${TASK_LINES[$i]}" >> "$temp_file"
            echo "  ID: ${TASK_UUIDS[$i]}" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    done
    
    echo "### BLOCKED" >> "$temp_file"
    for ((i=0; i<${#TASK_UUIDS[@]}; i++)); do
        if [[ "${TASK_SECTIONS[$i]}" == "BLOCKED" ]]; then
            echo "${TASK_LINES[$i]}" >> "$temp_file"
            echo "  ID: ${TASK_UUIDS[$i]}" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    done
    
    echo "### DONE" >> "$temp_file"
    for ((i=0; i<${#TASK_UUIDS[@]}; i++)); do
        if [[ "${TASK_SECTIONS[$i]}" == "DONE" ]]; then
            echo "${TASK_LINES[$i]}" >> "$temp_file"
            echo "  ID: ${TASK_UUIDS[$i]}" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    done
    
    # Write post-task content
    if [[ ${#POST_TASK_LINES[@]} -gt 0 ]]; then
        for line in "${POST_TASK_LINES[@]}"; do
            echo "$line" >> "$temp_file"
        done
    fi
    
    # Atomic replacement
    mv "$temp_file" ROADMAP.md
}