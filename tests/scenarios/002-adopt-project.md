# Test Scenario 002: Adopt Existing Project

## Objective
Verify claudepm can successfully adopt an existing project and extract relevant information.

## Test Steps

1. **Create Legacy Project**
   ```bash
   mkdir -p /tmp/claudepm-test-002-[timestamp]/legacy-app
   cd legacy-app
   ```

2. **Populate with Typical Project Files**
   - Create package.json with scripts:
     ```json
     {
       "name": "legacy-app",
       "version": "1.0.0",
       "scripts": {
         "test": "jest",
         "build": "webpack",
         "dev": "nodemon"
       }
     }
     ```
   - Create README.md with TODOs:
     ```markdown
     # Legacy App
     TODO: Add authentication
     TODO: Improve performance
     FIXME: Memory leak in worker
     ```
   - Add source files with inline TODOs:
     ```javascript
     // TODO: Refactor this function
     // FIXME: Handle edge case
     ```

3. **Run Adopt Command**
   - Execute: `claudepm adopt`
   - Capture output

4. **Verify Generated Files**
   - Check CLAUDE.md contains:
     - Discovered project type (Node.js)
     - Extracted npm scripts
     - Project context
   - Check ROADMAP.md contains:
     - Imported TODOs from README
     - Imported inline TODOs from source
     - Proper categorization
   - Check NOTES.md exists
   - Check LOG.md has adoption entry

5. **Test Adopted Project**
   - Run: `claudepm health`
   - Run: `claudepm task list`
   - Verify imported tasks appear

## Expected Results
- Adoption completes successfully
- All TODOs/FIXMEs extracted
- npm scripts documented
- Project type identified
- No existing content destroyed

## Edge Cases to Test
- Project with existing CLAUDE.md (should preserve)
- Project with no package.json
- Project with malformed JSON
- Empty project directory
- Project with 50+ TODOs