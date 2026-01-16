# Claude Code & GitHub Copilot Skills & Agents

Reusable skills and agents for AI coding assistants - general-purpose process workflows that work across any project.

**Supported Platforms:**
- [Claude Code](https://claude.ai/claude-code)
- [GitHub Copilot](https://github.com/features/copilot) (CLI, VS Code agent mode)

## Installation

### Quick Install (Recommended)

**macOS / Linux:**
```bash
git clone https://github.com/nandkapadia/claude-skills-agents.git
cd claude-skills-agents
./install.sh          # Installs to both Claude and Copilot
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/nandkapadia/claude-skills-agents.git
cd claude-skills-agents
.\install.ps1
```

### Installation Options

```bash
./install.sh              # Install to both Claude and Copilot (default)
./install.sh --claude-only    # Install only to Claude Code
./install.sh --copilot-only   # Install only to GitHub Copilot
./install.sh --help           # Show help
```

### Manual Install

**Claude Code:**
```bash
cp -r skills/* ~/.claude/skills/
cp -r agents/* ~/.claude/agents/
```

**GitHub Copilot:**
```bash
cp -r copilot/skills/* ~/.copilot/skills/
cp -r copilot/agents/* ~/.copilot/agents/
```

### Installation Paths

| Platform | Skills | Agents |
|----------|--------|--------|
| Claude Code | `~/.claude/skills/` | `~/.claude/agents/` |
| GitHub Copilot | `~/.copilot/skills/` | `~/.copilot/agents/` |

## Skills

Skills teach your AI coding assistant specialized knowledge and workflows.

### Process Skills

| Skill | Description |
|-------|-------------|
| **test-driven-development** | Red-Green-Refactor cycle. Write failing test first, implement minimally, refactor. |
| **systematic-debugging** | Four-phase debugging: Root Cause → Pattern → Hypothesis → Fix. No random fixes. |
| **verification-before-completion** | Evidence-based claims. Run verification commands before claiming success. |
| **receiving-code-review** | Respond to feedback with rigor. Verify claims, push back when warranted, no performative agreement. |
| **dispatching-parallel-agents** | Wave deployment for parallel agent coordination. Max 3 agents per wave. |
| **subagent-driven-development** | Fresh subagent per task with two-stage review (spec compliance → code quality). |
| **architecture-review** | Steenberg-style review: identify primitives, define black boxes, wrap dependencies. |
| **python-documentation** | Google-style docstrings, beginner-friendly inline comments, organized imports. |

### Domain Skills

| Skill | Description |
|-------|-------------|
| **quant-plan-reviewer** | Review implementation plans for quantitative trading systems. Catches lookahead bias, data leakage. |

## Agents

Agents are specialized sub-agents with custom prompts and tool access.

| Agent | Description | Tools |
|-------|-------------|-------|
| **orchestrator** | Pure coordination for multi-agent workflows. Never writes code. | Read, Glob, Grep, Task, TodoWrite |
| **plan** | Requirements analysis, architecture design, task breakdown. | Read, Glob, Grep, Bash, WebSearch |
| **review** | Two-stage code review: spec compliance first, then code quality. | Read, Glob, Grep, Bash |
| **multi-review** | Multi-model review using Claude, Codex, and Gemini for comprehensive bug-catching. | Read, Glob, Grep, Bash |
| **doc-refresh** | Audit and update project documentation. | Read, Write, Edit, Glob, Grep, Bash |

## Usage

### Claude Code

Skills are automatically discovered. Reference them with `@skill-name`:

```
Use @test-driven-development for this implementation.
```

Dispatch agents using the Task tool:

```python
Task(
    subagent_type="orchestrator",
    description="Coordinate multi-file implementation",
    prompt="..."
)
```

### GitHub Copilot

In Copilot CLI or VS Code agent mode, skills are loaded automatically when relevant to your prompt. You can also invoke explicitly:

```
$test-driven-development
```

Or reference in your prompt:

```
Use the test-driven-development skill for this implementation.
```

## Workflow Integration

Recommended flow for complex implementations:

```
plan → orchestrator → specialists → review
```

1. **plan** - Analyze requirements, design approach, break down tasks
2. **orchestrator** - Coordinate parallel agent deployment
3. **specialists** - Execute tasks using process skills (TDD, debugging, etc.)
4. **review** - Two-stage review before merging

## Directory Structure

```
claude-skills-agents/
├── skills/                 # Claude Code skills (source of truth)
│   ├── test-driven-development/
│   │   └── SKILL.md
│   ├── systematic-debugging/
│   │   └── SKILL.md
│   └── ...
├── agents/                 # Claude Code agents
│   ├── orchestrator.md
│   ├── plan.md
│   └── ...
├── copilot/               # GitHub Copilot (auto-synced)
│   ├── skills/
│   └── agents/
├── scripts/
│   ├── sync-copilot.sh    # Sync Claude → Copilot
│   └── install-hooks.sh   # Install pre-commit hook
├── install.sh             # Install to ~/.claude/ and ~/.copilot/
├── install.ps1            # Windows installer
└── README.md
```

## Development

### Keeping Formats in Sync

The `skills/` directory is the source of truth. The `copilot/` directory is auto-synced.

**For contributors:**

1. Install the pre-commit hook:
   ```bash
   ./scripts/install-hooks.sh
   ```

2. Edit skills in `skills/` directory

3. On commit, the hook automatically syncs to `copilot/`

**Manual sync:**
```bash
./scripts/sync-copilot.sh
```

### Adding New Skills

1. Create directory: `skills/<skill-name>/SKILL.md`
2. Use YAML frontmatter with `name` and `description`
3. Follow the existing skill format
4. Test with both Claude Code and Copilot

## Contributing

1. Skills should be under 500 lines (use progressive disclosure for complex skills)
2. Follow the frontmatter format with `name` and `description`
3. Include clear "When to Use" and "When NOT to Use" sections
4. Test skills across different project types

## License

MIT
