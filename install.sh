#!/bin/bash
#
# Install Claude Code skills and agents to global directory
# Usage: ./install.sh
#
# Paths:
#   Skills: ~/.claude/skills/<skill-name>/SKILL.md
#   Agents: ~/.claude/agents/<agent-name>.md
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Claude Code Skills & Agents Installer"
echo "======================================"
echo ""

# Create directories if they don't exist
echo "Creating directories..."
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

# Install skills
echo ""
echo "Installing skills to $SKILLS_DIR..."
for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        target_dir="$SKILLS_DIR/$skill_name"

        if [ -d "$target_dir" ]; then
            echo -e "  ${YELLOW}[UPDATE]${NC} $skill_name"
            rm -rf "$target_dir"
        else
            echo -e "  ${GREEN}[NEW]${NC} $skill_name"
        fi

        cp -r "$skill_dir" "$target_dir"
    fi
done

# Install agents
echo ""
echo "Installing agents to $AGENTS_DIR..."
for agent_file in "$SCRIPT_DIR/agents/"*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file")
        target_file="$AGENTS_DIR/$agent_name"

        if [ -f "$target_file" ]; then
            echo -e "  ${YELLOW}[UPDATE]${NC} $agent_name"
        else
            echo -e "  ${GREEN}[NEW]${NC} $agent_name"
        fi

        cp "$agent_file" "$target_file"
    fi
done

# Summary
echo ""
echo "======================================"
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Installed locations:"
echo "  Skills: $SKILLS_DIR"
echo "  Agents: $AGENTS_DIR"
echo ""
echo "Skills installed:"
ls -1 "$SKILLS_DIR" | sed 's/^/  - /'
echo ""
echo "Agents installed:"
ls -1 "$AGENTS_DIR" | sed 's/^/  - /'
echo ""
echo "Restart Claude Code to use the new skills and agents."
