# claudepm Modular Structure (v0.3 Planning)

This directory will contain the split modules for v0.3:

## Planned Modules

### core.sh (~50 lines)
- generate_uuid()
- safe_copy_template()
- Common variables and setup

### init.sh (~250 lines)
- init_project()
- adopt_project()
- upgrade_project()

### health.sh (~150 lines)
- health_check()
- doctor_check()
- find_blocked()

### tasks.sh (~100 lines)
- task_command() with simplified subcommands
- Future: Rich task metadata support

### protocol.sh (~150 lines)
- get_context()
- log_work()
- suggest_next()

## Benefits
1. Each module focused on one aspect
2. Easier to test and maintain
3. Can load only what's needed
4. Prevents file corruption during edits

## Migration Plan
1. Create modules in v0.3
2. Main script sources all modules
3. Maintain backward compatibility
4. Deprecate monolithic utils.sh in v0.4