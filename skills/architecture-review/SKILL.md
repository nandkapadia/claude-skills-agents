---
name: architecture-review
description: Steenberg-style architecture review for maintainability and replaceability. Use when (1) planning major refactors, (2) designing new modules or systems, (3) reviewing existing architecture, (4) before significant dependency additions, (5) when "it works but feels wrong". Enforces primitive identification, black box boundaries, and dependency wrapping.
---

# Architecture Review

Identify primitives. Draw black boxes. Wrap dependencies.

**Core principle:** "It's faster to write five lines of code today than to write one line today and then have to edit it in the future." - Eskil Steenberg

## When to Use

**Always use for:**
- Planning new modules or subsystems
- Major refactors affecting 3+ files
- Adding external dependencies
- Code that "works but feels tangled"
- Pre-review of architectural decisions

**Skip for:**
- Bug fixes within existing architecture
- Adding features to well-defined modules
- Configuration changes

## The Four-Phase Review

### Phase 1: Primitive Identification

Find the fundamental data types that flow through the system.

**Questions to answer:**
1. What is the basic unit of information?
2. What operations are performed on this data?
3. Can this primitive handle future requirements without change?

**Examples by domain:**
```
Web service:
- Request (method + path + headers + body)
- Response (status + headers + body)
- User (id + credentials + permissions)

Data pipeline:
- Record (schema + values + metadata)
- Transform (input_type → output_type)
- Batch (records + timestamp + source)
```

**Checklist:**
- [ ] List all data types that cross module boundaries
- [ ] Each primitive has clear, minimal definition
- [ ] Primitives are stable (won't need frequent changes)
- [ ] Operations on primitives are well-defined

### Phase 2: Black Box Boundaries

Every module should be replaceable using only its interface.

**The test:** Can you describe this module to a new developer using ONLY:
- What goes in (inputs)
- What comes out (outputs)
- What guarantees it provides

**Checklist:**
- [ ] Each module has explicit input/output types
- [ ] Internal implementation details are hidden
- [ ] Interface is documented without reference to internals
- [ ] Module can be rewritten without touching callers

**Red flags:**
```python
# BAD: Leaky abstraction
class DataProcessor:
    def process(self, data):
        self._internal_buffer.append(data)  # Caller knows about buffer
        return self._cached_results[-1]  # Caller knows about caching

# GOOD: Clean interface
class DataProcessor:
    def process(self, data: InputType) -> OutputType:
        """Processes data and returns result."""
        ...  # Implementation hidden
```

### Phase 3: Dependency Audit

Never depend directly on what you don't control.

**External dependencies to wrap:**
- Third-party libraries (pandas, requests, boto3)
- Platform APIs (file system, network)
- Data sources (databases, APIs, message queues)
- Configuration systems

**Checklist:**
- [ ] External libraries accessed through wrapper layer
- [ ] No direct imports of external APIs in business logic
- [ ] Wrappers have stable interfaces even if underlying changes
- [ ] Dependencies can be swapped without touching core code

**Example wrapper pattern:**
```python
# platform/storage.py - Wrapper layer
from typing import Protocol

class StorageProtocol(Protocol):
    """Our interface - stable even if S3/GCS/local changes."""
    def read(self, key: str) -> bytes: ...
    def write(self, key: str, data: bytes) -> None: ...

# Business logic imports from wrapper, not boto3 directly
from platform.storage import StorageProtocol
```

### Phase 4: Replaceability Test

For each component, answer:

| Question | Good Answer | Bad Answer |
|----------|-------------|------------|
| Can one developer understand this? | "Yes, it does X" | "Well, you need to understand Y and Z first..." |
| Can this be rewritten from scratch? | "Yes, given the interface" | "No, too many implicit dependencies" |
| What breaks if this fails? | "Just this feature" | "Half the system" |
| Can we add 10x features here? | "Yes, same interface" | "We'd need to restructure" |

**Checklist:**
- [ ] Single developer can own each module
- [ ] Failure in one module doesn't cascade
- [ ] Clear boundaries enable parallel development
- [ ] Future features fit existing structure

## Architecture Patterns

### Good Architecture
```
┌─────────────────────────────────────────────────────────┐
│  External Layer (wrapped)                               │
│  └─ APIs, databases, file systems, third-party libs    │
├─────────────────────────────────────────────────────────┤
│  Service Layer (primitives: request → response)         │
│  └─ Each service is independent black box              │
├─────────────────────────────────────────────────────────┤
│  Domain Layer (primitives: input → output)              │
│  └─ Business logic, pure functions where possible      │
├─────────────────────────────────────────────────────────┤
│  Infrastructure Layer (wrapped)                         │
│  └─ Logging, metrics, configuration                    │
└─────────────────────────────────────────────────────────┘
```

### Bad Architecture Signs
- Lower layers import from upper layers
- Business logic depends on specific infrastructure
- Business logic scattered across layers
- "Utility" modules used everywhere
- Circular imports

## Quick Reference

| Phase | Key Question | Success Criteria |
|-------|--------------|------------------|
| 1. Primitives | What data flows through? | Minimal, stable types defined |
| 2. Black Boxes | Can I describe the interface without internals? | Yes, input/output only |
| 3. Dependencies | Do I control this? | If not, wrapped |
| 4. Replaceability | Can one person rewrite this? | Yes, using only interface |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Wrapper adds overhead" | Wrapper prevents rewrite-everything-later |
| "Only I work on this" | You in 6 months won't remember |
| "Dependencies are stable" | Until they're not |
| "Too small to modularize" | Small modules grow; boundaries don't |
| "Flexibility for later" | Over-abstraction is as bad as under-abstraction |

## Integration with Plan Agent

When using `plan` agent for architecture design:

1. Run architecture review FIRST
2. Identify primitives and boundaries
3. Let plan agent design within those constraints
4. Review plan output against this checklist

## Output Format

After review, document:

```markdown
## Architecture Review: [Component/System Name]

### Primitives
- [List with definitions]

### Module Boundaries
| Module | Input | Output | Responsibility |
|--------|-------|--------|----------------|

### Dependency Map
- External: [wrapped/unwrapped status]
- Internal: [dependency direction]

### Risks
- [Identified architectural risks]

### Recommendations
- [Concrete changes needed]
```
