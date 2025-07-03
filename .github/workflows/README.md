# GitHub Actions Workflows

## test.yml - Test Suite

Runs the claudepm test suite with smart cost management.

### Triggers
- **Every push**: Traditional tests only (free)
- **Pull requests**: Traditional + core AI tests (low cost)
- **Manual dispatch**: Option to run full suite
- **Weekly** (optional): Full test suite

### Configuration

1. **Set up API key** (for AI tests):
   - Go to repository Settings → Secrets → Actions
   - Add secret: `ANTHROPIC_API_KEY`
   - Get key from: https://console.anthropic.com/settings/keys

2. **Cost estimates**:
   - Traditional tests: Free
   - AI tests (Haiku): ~$0.01 per run
   - Full suite: ~$0.05 per run

### Jobs

1. **traditional-tests**: Always runs, tests bash scripts
2. **ai-behavioral-tests**: Runs on PRs, tests AI behavior
3. **test-summary**: Aggregates results
4. **weekly-full-tests**: Optional comprehensive testing

### Artifacts
Test results are uploaded as artifacts for debugging failed tests.

### Security
- API keys stored as GitHub secrets
- No keys in code or logs
- Tests run in isolated environments