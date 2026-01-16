#!/bin/bash
#
# Sync Claude Code skills to GitHub Copilot format
# Usage: ./scripts/sync-copilot.sh
#
# This script copies skills from skills/ to copilot/skills/ (same format)
# and agents from agents/ to copilot/agents/
#
# GitHub Copilot supports these paths:
#   Project: .github/skills/<skill-name>/SKILL.md
#   Personal: ~/.copilot/skills/<skill-name>/SKILL.md
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

CLAUDE_SKILLS_DIR="$REPO_DIR/skills"
CLAUDE_AGENTS_DIR="$REPO_DIR/agents"
COPILOT_SKILLS_DIR="$REPO_DIR/copilot/skills"
COPILOT_AGENTS_DIR="$REPO_DIR/copilot/agents"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Syncing Claude Code → GitHub Copilot${NC}"
echo "======================================"

# Create copilot directories
mkdir -p "$COPILOT_SKILLS_DIR"
mkdir -p "$COPILOT_AGENTS_DIR"

# Track changes for git
CHANGES=0

# Sync skills
echo ""
echo "Syncing skills..."
for skill_dir in "$CLAUDE_SKILLS_DIR/"*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        target_dir="$COPILOT_SKILLS_DIR/$skill_name"

        # Check if sync needed
        if [ -d "$target_dir" ]; then
            # Compare directories
            if diff -rq "$skill_dir" "$target_dir" > /dev/null 2>&1; then
                echo -e "  ${GREEN}[OK]${NC} $skill_name"
            else
                echo -e "  ${YELLOW}[SYNC]${NC} $skill_name"
                rm -rf "$target_dir"
                cp -r "$skill_dir" "$target_dir"
                CHANGES=$((CHANGES + 1))
            fi
        else
            echo -e "  ${BLUE}[NEW]${NC} $skill_name"
            cp -r "$skill_dir" "$target_dir"
            CHANGES=$((CHANGES + 1))
        fi
    fi
done

# Remove orphaned skills in copilot that don't exist in claude
for copilot_skill in "$COPILOT_SKILLS_DIR/"*/; do
    if [ -d "$copilot_skill" ]; then
        skill_name=$(basename "$copilot_skill")
        if [ ! -d "$CLAUDE_SKILLS_DIR/$skill_name" ]; then
            echo -e "  ${RED}[REMOVE]${NC} $skill_name (orphaned)"
            rm -rf "$copilot_skill"
            CHANGES=$((CHANGES + 1))
        fi
    fi
done

# Sync agents
echo ""
echo "Syncing agents..."
for agent_file in "$CLAUDE_AGENTS_DIR/"*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file")
        target_file="$COPILOT_AGENTS_DIR/$agent_name"

        if [ -f "$target_file" ]; then
            if diff -q "$agent_file" "$target_file" > /dev/null 2>&1; then
                echo -e "  ${GREEN}[OK]${NC} $agent_name"
            else
                echo -e "  ${YELLOW}[SYNC]${NC} $agent_name"
                cp "$agent_file" "$target_file"
                CHANGES=$((CHANGES + 1))
            fi
        else
            echo -e "  ${BLUE}[NEW]${NC} $agent_name"
            cp "$agent_file" "$target_file"
            CHANGES=$((CHANGES + 1))
        fi
    fi
done

# Remove orphaned agents
for copilot_agent in "$COPILOT_AGENTS_DIR/"*.md; do
    if [ -f "$copilot_agent" ]; then
        agent_name=$(basename "$copilot_agent")
        if [ ! -f "$CLAUDE_AGENTS_DIR/$agent_name" ]; then
            echo -e "  ${RED}[REMOVE]${NC} $agent_name (orphaned)"
            rm -f "$copilot_agent"
            CHANGES=$((CHANGES + 1))
        fi
    fi
done

# Summary
echo ""
echo "======================================"
if [ $CHANGES -gt 0 ]; then
    echo -e "${YELLOW}$CHANGES file(s) synced${NC}"
    echo ""
    echo "Don't forget to stage the changes:"
    echo "  git add copilot/"
else
    echo -e "${GREEN}Everything in sync${NC}"
fi
