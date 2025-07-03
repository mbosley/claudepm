#!/bin/bash
# install.sh - Install claudepm v0.2.5
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing claudepm v0.2.5..."
echo "=============================="

# 1. Create directory structure
echo -e "\n1. Creating directory structure..."
mkdir -p ~/.claudepm/{bin,templates/{manager,project,task-agent},lib,commands}
mkdir -p ~/.config/claudepm/templates
echo -e "${GREEN}✓ Directories created${NC}"

# 2. Copy core files
echo -e "\n2. Copying core files..."

# Copy templates if we're in the claudepm repo
if [[ -d "templates" ]]; then
    cp -r templates/* ~/.claudepm/templates/
    echo -e "${GREEN}✓ Templates copied${NC}"
else
    echo -e "${YELLOW}⚠ Templates directory not found${NC}"
fi

# Copy commands if available
if [[ -d "commands" ]]; then
    cp -r commands/* ~/.claudepm/commands/
    echo -e "${GREEN}✓ Commands copied${NC}"
else
    echo -e "${YELLOW}⚠ Commands directory not found - will create later${NC}"
fi

# Copy the claudepm script
if [[ -f "bin/claudepm" ]]; then
    cp bin/claudepm ~/.claudepm/bin/
    chmod +x ~/.claudepm/bin/claudepm
    echo -e "${GREEN}✓ claudepm script installed${NC}"
else
    # Use the one we already created
    echo -e "${GREEN}✓ claudepm script already in place${NC}"
fi

# Copy utils.sh
if [[ -f "lib/utils.sh" ]]; then
    cp lib/utils.sh ~/.claudepm/lib/
    echo -e "${GREEN}✓ Utils library copied${NC}"
else
    # Use the one we already created
    echo -e "${GREEN}✓ Utils library already in place${NC}"
fi

# 3. Create VERSION and other files
echo "0.2.5" > ~/.claudepm/VERSION
touch ~/.claudepm/projects.list

# Copy CONVENTIONS.md
if [[ -f "CONVENTIONS.md" ]]; then
    cp CONVENTIONS.md ~/.claudepm/
elif [[ -f "$HOME/.claudepm/CONVENTIONS.md" ]]; then
    echo -e "${GREEN}✓ CONVENTIONS.md already in place${NC}"
else
    echo -e "${YELLOW}⚠ CONVENTIONS.md not found${NC}"
fi

echo -e "${GREEN}✓ Core files created${NC}"

# 4. Add to PATH
echo -e "\n3. Checking PATH configuration..."
shell_rc=""
if [[ -f "$HOME/.bashrc" ]]; then
    shell_rc="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    shell_rc="$HOME/.zshrc"
fi

if [[ -n "$shell_rc" ]]; then
    if ! grep -q "claudepm/bin" "$shell_rc"; then
        echo "" >> "$shell_rc"
        echo "# claudepm" >> "$shell_rc"
        echo 'export PATH="$HOME/.claudepm/bin:$PATH"' >> "$shell_rc"
        echo -e "${GREEN}✓ Added claudepm to PATH in $shell_rc${NC}"
        echo "  Run: source $shell_rc"
    else
        echo -e "${GREEN}✓ PATH already configured${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Could not find .bashrc or .zshrc${NC}"
    echo "  Add to your shell config: export PATH=\"\$HOME/.claudepm/bin:\$PATH\""
fi

# 5. Link slash commands for Claude Code
echo -e "\n4. Checking for Claude Code installation..."
if [[ -d "$HOME/.claude/commands" ]]; then
    echo -e "${GREEN}✓ Claude Code detected${NC}"
    read -p "Link claudepm slash commands? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create symlinks for any command files that exist
        for cmd in ~/.claudepm/commands/*.md; do
            if [[ -f "$cmd" ]]; then
                ln -sf "$cmd" ~/.claude/commands/ 2>/dev/null || true
            fi
        done
        echo -e "${GREEN}✓ Linked claudepm slash commands${NC}"
    fi
else
    echo "  Claude Code not detected (slash commands not linked)"
fi

# 6. Final instructions
echo -e "\n${GREEN}✓ Installation complete!${NC}"
echo -e "\nNext steps:"
echo "1. Run: source ${shell_rc:-~/.bashrc}"
echo "2. Verify: claudepm version"
echo "3. Initialize a project: claudepm init project"
echo "4. Or adopt existing: claudepm adopt"

# Check if we're in the claudepm repo
if [[ -f "VERSION" ]] && [[ -d "templates" ]]; then
    echo -e "\n${YELLOW}Note: You're in the claudepm repo.${NC}"
    echo "To test installation:"
    echo "  claudepm version  # Should show 0.2.5"
    echo "  claudepm doctor   # Check system health"
fi