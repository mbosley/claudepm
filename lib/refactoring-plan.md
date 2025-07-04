# Utils.sh Refactoring Plan

## Current State
- 820 lines, 12 functions
- Monolithic file handling all claudepm functionality
- Difficult to maintain and edit safely

## Proposed Structure

### lib/core.sh (Keep in utils.sh)
- generate_uuid()
- safe_copy_template()

### lib/init.sh
- init_project()
- adopt_project()  
- upgrade_project()

### lib/health.sh
- health_check()
- doctor_check()
- find_blocked()

### lib/tasks.sh
- task_command() and all task subcommands

### lib/protocol.sh (New v0.2.5.1 commands)
- get_context()
- log_work()
- suggest_next()

## Benefits
1. Each file ~200-300 lines max
2. Easier to edit without corruption
3. Clear separation of concerns
4. Can source only what's needed
5. Easier to test individual components

## Implementation
The main claudepm script would source all needed files:
```bash
source "$CLAUDEPM_HOME/lib/core.sh"
source "$CLAUDEPM_HOME/lib/init.sh"
source "$CLAUDEPM_HOME/lib/health.sh"
source "$CLAUDEPM_HOME/lib/tasks.sh"
source "$CLAUDEPM_HOME/lib/protocol.sh"
```

## Migration Path
1. Keep utils.sh working as-is for now
2. In v0.3, split into modules
3. Maintain backward compatibility