# claudepm Testing Roadmap

## Overview
This document outlines the phased approach to building comprehensive test coverage for claudepm.

## Testing Philosophy
- **Test deterministic parts traditionally** (bash scripts, file operations)
- **Test AI behavior with actual AI** (Claude Code SDK in controlled environments)
- **Start simple, expand systematically**
- **Prioritize high-value tests first**

## Phase 1: Foundation (Current)
**Goal:** Establish testing infrastructure and core safety tests

### Traditional Tests
- [x] `installer` - Test install.sh creates correct structure
- [x] `get-context` - Test context assembly from two-file architecture
- [x] `admin-worktree` - Test worktree creation/removal

### AI Behavioral Tests
- [x] `core_log_append` - Verify append-only behavior
- [ ] `core_role_adherence` - Ensure agents respect their roles
- [ ] `workflow_adopt_project` - Test project adoption

### Infrastructure
- [x] Test runner framework
- [x] GitHub Actions CI setup
- [x] Test documentation

## Phase 2: Core Workflows (Weeks 3-4)
**Goal:** Verify main user workflows work end-to-end

### Traditional Tests
- [ ] `migration-v1-v2` - Test v0.1.x → v0.2.0 migration
- [ ] `slash-commands` - Test command discovery and loading

### AI Behavioral Tests
- [ ] `task_agent_lifecycle` - Full worktree → implementation → PR flow
- [ ] `brain_dump_processing` - Manager-level update routing
- [ ] `doctor_update_flow` - Template version detection and updates
- [ ] `multi_project_coordination` - Manager handling multiple projects

## Phase 3: Advanced Features (Week 5+)
**Goal:** Test complex features and edge cases

### AI Behavioral Tests
- [ ] `architect_feature` - Test Gemini integration (mocked)
- [ ] `merge_conflicts` - Handling CLAUDE_LOG.md conflicts
- [ ] `missing_files` - Graceful handling of missing templates
- [ ] `permission_errors` - Handling file permission issues
- [ ] `large_projects` - Performance with many files/projects

### Integration Tests
- [ ] `full_project_lifecycle` - Create → develop → archive
- [ ] `template_evolution` - Upgrading through multiple versions

## Test Patterns

### Adding a New Feature Test
1. Create scenario directory: `tests/scenarios/[type]/feature_name/`
2. Add minimal setup files in `setup/`
3. Write test script (`test.bats` or `test.py`)
4. Add to appropriate phase in this roadmap
5. Update CI configuration if needed

### Test Structure Example
```
tests/scenarios/ai-behavioral/new_feature/
├── setup/
│   ├── CLAUDE.md         # Minimal instructions
│   ├── .claudepm         # Role configuration
│   └── test_data/        # Any test files
└── test.py               # Test implementation
```

## Cost Management
- Use Haiku model for most tests (~$0.00025 per test)
- Mock expensive operations (Gemini API)
- Run full suite weekly, not on every commit
- Budget alert at $10/month

## CI Strategy
- **Every commit:** Traditional tests only (fast, free)
- **Every PR:** Traditional + Phase 1 AI tests (Haiku)
- **Weekly/Release:** Full test suite

## Success Metrics
- [ ] 100% coverage of installation workflows
- [ ] All slash commands have tests
- [ ] Core AI behaviors validated
- [ ] New features include tests
- [ ] CI prevents regressions

## Notes
- Prioritize tests that catch real bugs we've seen
- Keep tests simple and focused
- Document patterns as we discover them
- Adjust roadmap based on actual usage