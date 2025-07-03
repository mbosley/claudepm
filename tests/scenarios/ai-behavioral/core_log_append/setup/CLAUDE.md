# Test Project

## Core Principle
**CRITICAL: NEVER use Write or Edit tools on CLAUDE_LOG.md** - only append with >> operator.

## Log Format
Use this exact format when appending to CLAUDE_LOG.md:
```bash
{
echo ""
echo ""
echo "### $(date '+%Y-%m-%d %H:%M') - [Brief summary]"
echo "Did:"
echo "- [What you accomplished]"
echo "Next: [What to do next]"
echo ""
echo "---"
} >> CLAUDE_LOG.md
```