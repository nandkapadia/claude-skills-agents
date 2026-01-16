# Claude Code Skills & Agents

Reusable skills and agents for [Claude Code](https://claude.ai/claude-code) - general-purpose process workflows that work across any project.

## Installation

### Quick Install (Recommended)

**macOS / Linux:**
```bash
git clone https://github.com/nandkapadia/claude-skills-agents.git
cd claude-skills-agents
./install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/nandkapadia/claude-skills-agents.git
cd claude-skills-agents
.\install.ps1
```

### Manual Install

Copy contents to your global Claude Code directory:

**macOS / Linux:**
```bash
cp -r skills/* ~/.claude/skills/
cp -r agents/* ~/.claude/agents/
```

**Windows:**
```powershell
Copy-Item -Recurse skills\* $env:USERPROFILE\.claude\skills\
Copy-Item -Recurse agents\* $env:USERPROFILE\.claude\agents\
```

### Installation Paths

| Platform | Skills | Agents |
|----------|--------|--------|
| macOS/Linux | `~/.claude/skills/` | `~/.claude/agents/` |
| Windows | `%USERPROFILE%\.claude\skills\` | `%USERPROFILE%\.claude\agents\` |

## Skills

Skills teach Claude specialized knowledge and workflows. Place in `~/.claude/skills/<name>/SKILL.md`.

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

Agents are specialized sub-agents with custom prompts and tool access. Place in `~/.claude/agents/<name>.md`.

| Agent | Description | Tools |
|-------|-------------|-------|
| **orchestrator** | Pure coordination for multi-agent workflows. Never writes code. | Read, Glob, Grep, Task, TodoWrite |
| **plan** | Requirements analysis, architecture design, task breakdown. | Read, Glob, Grep, Bash, WebSearch |
| **review** | Two-stage code review: spec compliance first, then code quality. | Read, Glob, Grep, Bash |
| **multi-review** | Multi-model review using Claude, Codex, and Gemini for comprehensive bug-catching. | Read, Glob, Grep, Bash |
| **doc-refresh** | Audit and update project documentation. | Read, Write, Edit, Glob, Grep, Bash |

## Usage

### Skills

Skills are automatically discovered by Claude Code. Reference them with `@skill-name`:

```
Use @test-driven-development for this implementation.
```

### Agents

Dispatch agents using the Task tool:

```python
Task(
    subagent_type="orchestrator",
    description="Coordinate multi-file implementation",
    prompt="..."
)
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

## Contributing

1. Skills should be under 500 lines (use progressive disclosure for complex skills)
2. Follow the frontmatter format with `name` and `description`
3. Include clear "When to Use" and "When NOT to Use" sections
4. Test skills across different project types

## License

MIT
