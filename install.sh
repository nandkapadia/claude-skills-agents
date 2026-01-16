#!/bin/bash
#
# Install Claude Code skills and agents
# Usage: ./install.sh [OPTIONS]
#
# Options:
#   --claude-only    Install only to Claude Code (~/.claude/)
#   --copilot-only   Install only to GitHub Copilot (~/.copilot/)
#   --all            Install to both Claude and Copilot (default)
#   --help           Show this help message
#
# Paths:
#   Claude:  ~/.claude/skills/ and ~/.claude/agents/
#   Copilot: ~/.copilot/skills/ and ~/.copilot/agents/
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default: install to both
INSTALL_CLAUDE=true
INSTALL_COPILOT=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --claude-only)
            INSTALL_COPILOT=false
            shift
            ;;
        --copilot-only)
            INSTALL_CLAUDE=false
            shift
            ;;
        --all)
            INSTALL_CLAUDE=true
            INSTALL_COPILOT=true
            shift
            ;;
        --help|-h)
            head -20 "$0" | tail -15
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "Skills & Agents Installer"
echo "========================="

# Function to install skills to a target directory
install_skills() {
    local source_dir="$1"
    local target_dir="$2"
    local platform="$3"

    echo ""
    echo -e "${BLUE}Installing skills to $target_dir${NC}"
    mkdir -p "$target_dir"

    for skill_dir in "$source_dir/"*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            dest_dir="$target_dir/$skill_name"

            if [ -d "$dest_dir" ]; then
                echo -e "  ${YELLOW}[UPDATE]${NC} $skill_name"
                rm -rf "$dest_dir"
            else
                echo -e "  ${GREEN}[NEW]${NC} $skill_name"
            fi

            cp -r "$skill_dir" "$dest_dir"
        fi
    done
}

# Function to install agents to a target directory
install_agents() {
    local source_dir="$1"
    local target_dir="$2"
    local platform="$3"

    echo ""
    echo -e "${BLUE}Installing agents to $target_dir${NC}"
    mkdir -p "$target_dir"

    for agent_file in "$source_dir/"*.md; do
        if [ -f "$agent_file" ]; then
            agent_name=$(basename "$agent_file")
            dest_file="$target_dir/$agent_name"

            if [ -f "$dest_file" ]; then
                echo -e "  ${YELLOW}[UPDATE]${NC} $agent_name"
            else
                echo -e "  ${GREEN}[NEW]${NC} $agent_name"
            fi

            cp "$agent_file" "$dest_file"
        fi
    done
}

# Install to Claude Code
if [ "$INSTALL_CLAUDE" = true ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Claude Code${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    install_skills "$SCRIPT_DIR/skills" "$HOME/.claude/skills" "Claude"
    install_agents "$SCRIPT_DIR/agents" "$HOME/.claude/agents" "Claude"
fi

# Install to GitHub Copilot
if [ "$INSTALL_COPILOT" = true ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}GitHub Copilot${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    # Use copilot/ subdirectory as source if it exists, otherwise use same source
    if [ -d "$SCRIPT_DIR/copilot/skills" ]; then
        install_skills "$SCRIPT_DIR/copilot/skills" "$HOME/.copilot/skills" "Copilot"
    else
        install_skills "$SCRIPT_DIR/skills" "$HOME/.copilot/skills" "Copilot"
    fi
    if [ -d "$SCRIPT_DIR/copilot/agents" ]; then
        install_agents "$SCRIPT_DIR/copilot/agents" "$HOME/.copilot/agents" "Copilot"
    else
        install_agents "$SCRIPT_DIR/agents" "$HOME/.copilot/agents" "Copilot"
    fi
fi

# Summary
echo ""
echo "========================="
echo -e "${GREEN}Installation complete!${NC}"
echo ""

if [ "$INSTALL_CLAUDE" = true ]; then
    echo "Claude Code:"
    echo "  Skills: ~/.claude/skills/"
    echo "  Agents: ~/.claude/agents/"
fi

if [ "$INSTALL_COPILOT" = true ]; then
    echo "GitHub Copilot:"
    echo "  Skills: ~/.copilot/skills/"
    echo "  Agents: ~/.copilot/agents/"
fi

echo ""
echo "Skills installed:"
ls -1 "$SCRIPT_DIR/skills" 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
echo ""
echo "Agents installed:"
ls -1 "$SCRIPT_DIR/agents" 2>/dev/null | sed 's/.md$//' | sed 's/^/  - /' || echo "  (none)"
echo ""
echo "Restart your AI coding assistant to use the new skills and agents."
