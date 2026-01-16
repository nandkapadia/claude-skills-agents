#!/bin/bash
#
# Install git hooks for claude-skills-agents
# Usage: ./scripts/install-hooks.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$REPO_DIR/.git/hooks"

GREEN='\033[0;32m'
NC='\033[0m'

echo "Installing git hooks..."

# Create pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
#
# Pre-commit hook: Sync Claude skills to GitHub Copilot format
#

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Check if any Claude skills/agents changed
CLAUDE_CHANGED=$(git diff --cached --name-only | grep -E '^(skills|agents)/' || true)

if [ -n "$CLAUDE_CHANGED" ]; then
    echo "Claude skills/agents changed - syncing to Copilot format..."
    "$REPO_ROOT/scripts/sync-copilot.sh"

    # Stage the synced files
    git add "$REPO_ROOT/copilot/"

    echo "Copilot files staged for commit."
fi

exit 0
EOF

chmod +x "$HOOKS_DIR/pre-commit"

echo -e "${GREEN}Pre-commit hook installed!${NC}"
echo ""
echo "The hook will automatically sync skills to Copilot format when you commit changes."
