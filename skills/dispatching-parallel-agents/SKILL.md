---
name: dispatching-parallel-agents
description: Dispatch multiple agents in parallel for independent problems. Use when (1) 3+ test files failing with different root causes, (2) multiple modules broken independently, (3) multiple components need separate fixes, (4) each problem can be understood without context from others. Do NOT use when failures are related (fixing one might fix others) or agents would edit the same files.
---

# Dispatching Parallel Agents

## Overview

When you have multiple unrelated failures (different test files, different modules, different components), investigating them sequentially wastes time. Each investigation is independent and can happen in parallel.

**Core principle:** Dispatch one agent per independent problem domain. Let them work concurrently.

## When to Use

**Use when:**
- 3+ test files failing with different root causes
- Multiple modules broken independently
- Multiple components need separate fixes
- Each problem can be understood without context from others
- No shared state between investigations

**Don't use when:**
- Failures are related (fix one might fix others)
- Need to understand full system state first
- Agents would interfere (editing same files)
- Exploratory debugging (don't know what's broken yet)

## Decision Tree

```
Multiple failures?
├── No → Single agent handles it
└── Yes → Are they independent?
    ├── No (related) → Single agent investigates all
    └── Yes → Can they work in parallel?
        ├── No (shared state) → Sequential agents
        └── Yes → How many agents needed?
            ├── 2-3 agents → Single wave parallel
            ├── 4-9 agents → Wave deployment (this skill)
            └── 10+ agents → Use orchestrator agent
```

## Wave Deployment Pattern

**Critical for 4+ agents:** Don't dispatch all at once. Use waves.

### Why Waves?

```
PROBLEM: 8 agents return simultaneously
→ 8 result summaries compete for context
→ Context overflow, can't synthesize
→ Miss conflicts between agents

SOLUTION: Wave deployment
→ 2-3 agents per wave
→ Synthesize results before next wave
→ Maintain context budget
```

### Wave Rules

| Agents | Waves | Pattern |
|--------|-------|---------|
| 2-3 | 1 | All parallel |
| 4-6 | 2 | 3 + 3 |
| 7-9 | 3 | 3 + 3 + 3 |
| 10+ | Consider orchestrator agent |

### Wave Execution

```
Wave 1: Deploy first batch (max 3)
  ├── Agent A: Task 1
  ├── Agent B: Task 2
  ├── Agent C: Task 3
  └── WAIT for all to complete

Synthesis Point:
  ├── Read all results
  ├── Check for conflicts
  ├── Extract interfaces for next wave
  └── Update TodoWrite

Wave 2: Deploy next batch
  ├── Agent D: Task 4 (may use Wave 1 outputs)
  ├── Agent E: Task 5
  └── WAIT for all to complete

Final Synthesis:
  └── Combine all results
```

### Wave Dispatch Example

```python
# Wave 1: Independent modules
Task("Fix auth tests", subagent_type="general-purpose")
Task("Fix API tests", subagent_type="general-purpose")
Task("Fix cache tests", subagent_type="general-purpose")
# Wait for results...

# Synthesis: Check no conflicts, all pass

# Wave 2: Remaining modules
Task("Fix DB tests", subagent_type="general-purpose")
Task("Fix queue tests", subagent_type="general-purpose")
# Wait for results...

# Final: Run full test suite
```

### Context Budget Awareness

Each agent result consumes ~500-2000 tokens. Budget accordingly:

```
Available context: ~100k tokens
Reserved for synthesis: ~20k tokens
Available for results: ~80k tokens

Max per wave: 80k / 3 agents = ~26k per agent result
→ Keep agent tasks focused to limit result size
```

---

## The Pattern

### 1. Identify Independent Domains

Group failures by what's broken:

```
# Example: Test failures across modules
- tests/test_auth.py: 3 failures (session handling)
- tests/test_api.py: 2 failures (response parsing)
- tests/test_cache.py: 1 failure (serialization)

Each module is independent - fixing auth doesn't affect API.
```

### 2. Create Focused Agent Tasks

Each agent gets:
- **Specific scope:** One module/component/service
- **Clear goal:** Make these tests pass
- **Constraints:** Don't change other code
- **Expected output:** Summary of findings and fixes

### 3. Dispatch in Parallel

```python
# Use Task tool with multiple parallel invocations
Task("Fix auth test failures", subagent_type="general-purpose")
Task("Fix API test failures", subagent_type="general-purpose")
Task("Fix cache test failures", subagent_type="general-purpose")
# All three run concurrently
```

### 4. Review and Integrate

When agents return:
1. Read each summary
2. Verify fixes don't conflict
3. Run full test suite
4. Integrate all changes

## Agent Prompt Template

Good agent prompts are:
1. **Focused** - One clear problem domain
2. **Self-contained** - All context needed
3. **Specific about output** - What should agent return?

```markdown
Fix the 3 failing tests in tests/test_auth.py:

Failures:
1. test_session_handles_expired_token - 401 on refresh
2. test_session_concurrent_requests - Race condition
3. test_session_logout_clears_state - State not cleared

Location: src/auth/session.py

Your task:
1. Read the test file and module implementation
2. Identify root cause for each failure
3. Fix the module to handle edge cases
4. Run tests to verify fixes

Constraints:
- Only modify session.py and test_auth.py
- Follow existing patterns in other modules
- Use @systematic-debugging skill for investigation

Return: Summary of root cause and fix for each failure.
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| **Too broad:** "Fix all tests" | **Specific:** "Fix tests/test_auth.py" |
| **No context:** "Fix the timeout issue" | **Context:** Paste error messages and test names |
| **No constraints:** Agent refactors everything | **Constraints:** "Only modify session.py" |
| **Vague output:** "Fix it" | **Specific:** "Return summary of root cause and changes" |

## Examples

### Multiple Module Failures

```
Scenario: 8 test failures across 4 module files after library upgrade

Failures:
- test_auth.py: 2 failures (token handling)
- test_api.py: 3 failures (response parsing)
- test_cache.py: 2 failures (serialization)
- test_db.py: 1 failure (connection pooling)

Decision: Independent - each module has isolated logic

Dispatch:
Agent 1 → "Fix auth token handling in test_auth.py"
Agent 2 → "Fix API response parsing in test_api.py"
Agent 3 → "Fix cache serialization in test_cache.py"
Agent 4 → "Fix DB connection pooling in test_db.py"
```

### Multiple Service Issues

```
Scenario: 3 microservices failing health checks after config change

Failures:
- user-service: Connection refused on port 8080
- order-service: Timeout in database connection
- notification-service: Missing environment variable

Decision: Independent services, different failure modes

Dispatch:
Agent 1 → "Fix user-service port configuration"
Agent 2 → "Fix order-service database timeout"
Agent 3 → "Fix notification-service missing env var"
```

### Script Migration

```
Scenario: Multiple scripts broken after API change

Failures:
- data_export.py: AttributeError
- report_generator.py: TypeError
- sync_tool.py: ImportError

Decision: Independent scripts, can be fixed in parallel

Dispatch:
Agent 1 → "Update data_export.py for new API"
Agent 2 → "Update report_generator.py for new API"
Agent 3 → "Update sync_tool.py for new API"
```

## When NOT to Use

### Related Failures
```
# These 3 failures are likely related:
test_create.py: validation fails
test_update.py: validation fails
test_delete.py: permission check fails

# Investigate together - fixing validation may fix all three
```

### Shared State
```
# These would conflict:
Agent 1: "Refactor base_service.py"
Agent 2: "Update user_service.py which inherits from base_service"

# Run sequentially - Agent 2 depends on Agent 1's changes
```

### Exploratory Debugging
```
# Don't know what's broken yet:
"API returns wrong data but tests pass"

# Single agent explores first to identify domains
# THEN dispatch parallel agents for identified issues
```

## Verification After Parallel Dispatch

```bash
# After all agents complete:

# 1. Check for conflicts
git diff --name-only  # See all changed files
# Verify no file was edited by multiple agents

# 2. Run full test suite
pytest tests/ -v

# 3. Spot check agent work
# Review each agent's changes for quality
```

## Key Benefits

1. **Parallelization** - N problems solved in time of 1
2. **Focus** - Each agent has narrow scope, less confusion
3. **Independence** - No interference between agents
4. **Speed** - Critical for large refactoring efforts

## Integration with Other Skills

- Use **@systematic-debugging** within each agent for investigation
- Use **@verification-before-completion** before claiming agent task done
- Use **@test-driven-development** if agents need to write new tests
