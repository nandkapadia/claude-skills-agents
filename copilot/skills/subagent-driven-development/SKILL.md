---
name: subagent-driven-development
description: Orchestrate implementation through fresh subagents per task with two-stage review (spec compliance then code quality). Use when (1) executing a plan with multiple independent tasks, (2) staying in current session to complete all tasks, (3) tasks don't tightly couple together. Each task gets: fresh implementer agent → spec reviewer → quality reviewer → mark complete.
---

# Subagent-Driven Development

Fresh subagent per task. Two-stage review after each.

**Core principle:** Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration.

## When to Use

Use when you have:
- An implementation plan with independent tasks
- Intent to stay in the current session
- Tasks that don't tightly couple together

```
Plan exists? → Tasks independent? → Same session? → Use this skill
```

**vs. Sequential execution:**
- Fresh subagent per task (no context pollution)
- Two-stage review after each task
- Faster iteration (no human-in-loop between tasks)

## Relationship to Agents

This skill is a **coordination pattern** - it describes HOW to dispatch agents, not WHAT they do.

| Role | Agent to Dispatch | Agent's Skills |
|------|-------------------|----------------|
| Implementer | `general-purpose` subagent | Uses @test-driven-development, @verification-before-completion |
| Spec Reviewer | `review` agent (Stage 1) | Built into reviewer agent |
| Quality Reviewer | `review` agent (Stage 2) | Uses @code-reviewer |

**This skill does NOT contain agent prompts.** It tells the orchestrator the dispatch pattern. The agents define their own behavior and use their own skills.

## The Process

### Setup Phase

1. Read plan file once
2. Extract all tasks with full text and context
3. Create TodoWrite tracking all tasks

### Per-Task Cycle

For each task:

```
┌─────────────────────────────────────────────────────────────┐
│  1. IMPLEMENTER (use .claude/developer.md)                  │
│     ├─ Dispatch with full task context                      │
│     ├─ Answer any clarifying questions                      │
│     ├─ Developer: implement → test → commit → self-review   │
│     └─ Returns: implementation report with verification     │
│                                                             │
│  2. SPEC REVIEWER (use .claude/reviewer.md Stage 1)         │
│     ├─ "Did we build what was specified?"                   │
│     ├─ Compare implementation against spec line-by-line     │
│     ├─ If issues → implementer fixes → re-review            │
│     └─ Returns: ✅ Spec compliant OR ❌ Issues (with refs)   │
│                                                             │
│  3. CODE QUALITY REVIEWER (use .claude/reviewer.md Stage 2) │
│     ├─ "Is it well-built?"                                  │
│     ├─ Review for quality, performance, maintainability     │
│     ├─ If issues → implementer fixes → re-review            │
│     └─ Returns: ✅ Approved OR ❌ Issues (with refs)         │
│                                                             │
│  4. Mark task complete in TodoWrite                         │
└─────────────────────────────────────────────────────────────┘
```

### Dispatching Agents

**For Implementer:**
```
Task(
  subagent_type="general-purpose",
  description="Implement [task name]",
  prompt="""
Use @test-driven-development and @verification-before-completion skills.

TASK CONTEXT:
- Task: [task name and description from plan]
- Files: [relevant files]
- Dependencies: [what this depends on]

IMPLEMENT THIS TASK with TDD: write failing test, implement, verify pass.
"""
)
```

**For Spec Review:**
```
Task(
  subagent_type="review",
  description="Spec review [task name]",
  prompt="""
Perform STAGE 1 (Spec Compliance) review only.

SPECIFICATION:
[Original task spec from plan]

IMPLEMENTATION:
[Implementer's report]

Check: Did we build what was specified? No more, no less.
"""
)
```

**For Quality Review:**
```
Task(
  subagent_type="review",
  description="Quality review [task name]",
  prompt="""
Perform STAGE 2 (Code Quality) review.

IMPLEMENTATION:
[Files changed, code to review]

PREVIOUS REVIEW:
[Spec review passed]

Check: Is it well-built? Readability, error handling, tests.
"""
)
```

### Completion Phase

After all tasks:
1. Dispatch final code reviewer for entire implementation
2. Run full test suite
3. Mark implementation complete

## Two-Stage Review: Why This Order?

```
WRONG ORDER:
  Code quality first → "This is well-written"
  Spec review later  → "But it's not what we asked for"
  Result: Wasted quality review on wrong code

RIGHT ORDER:
  Spec review first  → "This matches the specification"
  Code quality after → "And it's well-written"
  Result: Quality review only on correct code
```

**Spec reviewer catches:**
- "You added unrequested parameters" (YAGNI)
- "You skipped the edge case in the spec"
- "Output format doesn't match requirements"

**Code quality reviewer catches:**
- "This loop should be optimized"
- "Error handling is incomplete"
- "This pattern doesn't match codebase conventions"

## Example Workflow

### Initial Setup
```
You: Using Subagent-Driven Development for this plan.
[Read plan, extract 5 tasks, create TodoWrite]
```

### Task Execution
```
Task 1: Add input validation to user service

[Dispatch general-purpose agent with task context]

Implementer: "Should validation raise exception or return error object?"
You: "Raise ValueError for invalid input."

Implementer: [Implements with TDD, tests 3/3 pass, self-reviews, commits]

[Dispatch review agent for Stage 1 - Spec Compliance]
Reviewer: ✅ Spec compliant
  - Input validation implemented
  - ValueError raised for invalid input
  - Tests cover edge cases

[Dispatch review agent for Stage 2 - Code Quality]
Reviewer: ✅ Approved
  - Clean implementation
  - Good error messages
  - No issues found

[Mark Task 1 complete]
```

### With Review Iterations
```
Task 2: Add rate limiting to API endpoints

[Implementer implements, tests 5/5 pass, commits]

[Dispatch review agent Stage 1]
Reviewer: ❌ Issues:
  - Missing: per-user rate limiting
  - Extra: added caching parameter (not in spec)

[Implementer fixes - removes caching, adds per-user limits]
[Reviewer re-reviews Stage 1]
Reviewer: ✅ Compliant now

[Dispatch review agent Stage 2]
Reviewer: ❌ Issue: Magic number (100) should be constant

[Implementer extracts DEFAULT_RATE_LIMIT constant]
[Reviewer re-reviews Stage 2]
Reviewer: ✅ Approved

[Mark Task 2 complete]
```

## Red Flags

**Never:**
- Skip spec review (even if "obviously correct")
- Skip code quality review
- Proceed with unfixed issues
- Let implementer self-review replace actual review
- Start code quality review before spec passes
- Move to next task with open review issues

**If subagent asks questions:**
- Answer clearly and completely
- Provide additional context if needed
- Don't rush into implementation

**If reviewer finds issues:**
- Same implementer fixes them
- Reviewer reviews again
- Repeat until approved

## Integration with Other Skills

**Implementer agent uses:**
- `@test-driven-development` — For implementing each task
- `@systematic-debugging` — If tests fail during implementation
- `@verification-before-completion` — Before claiming task done

**Review agent uses:**
- `@code-reviewer` — For domain-specific quality checks (if available)

**When receiving review feedback:**
- `@receiving-code-review` — For responding to findings
