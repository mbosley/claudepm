# claudepm Development Notes

## 2025-07-03 - Simplification Insights

### Why Remove Time Tracking
- Claude isn't good at estimating time
- Humans are notoriously bad at it too  
- Adds complexity without value
- Creates false precision

### Protocol Philosophy: Structure + Freedom
The protocol should:
1. **Enforce minimal structure** (timestamp, title, consistent format)
2. **Allow creative freedom** (Claude decides what details to include)
3. **Avoid prescriptive fields** (no forced categories)

### Simplified Commands

**Before (prescriptive):**
```bash
claudepm log "Fixed bug" --did "Found issue" --did "Applied fix" --time 2h --tag bug
```

**After (flexible):**
```bash
claudepm log "Fixed bug" "Found race condition in auth flow. Applied mutex lock."
```

Claude can still structure the content however makes sense:
```
### 2025-07-03 15:30 - Fixed authentication race condition
Did:
- Found race condition in session handler
- Applied mutex lock to critical section
- Added tests for concurrent access
Next: Monitor for similar patterns in other handlers
Tags: #bug #security #concurrency
```

But this structure comes from Claude's judgment, not rigid command flags.

### Benefits
1. **Simpler implementation** - Less code to maintain
2. **More flexible** - Claude adapts format to context
3. **Natural writing** - Like taking notes, not filling forms
4. **Easier to remember** - Fewer options to learn

### Task Simplification
Same principle for tasks:
```bash
# Old way
claudepm task add "Fix memory leak" -p high -t bug -d 2025-07-10

# New way  
claudepm task add "Fix memory leak" "HIGH PRIORITY - Due Friday - Bug in WebSocket handler"
```

The UUID and date are structural. Everything else is content.