---
name: systematic-debugging
description: Four-phase structured debugging methodology. Use when (1) tests fail unexpectedly, (2) functions produce wrong values, (3) systems show anomalous results, (4) unexpected errors appear, (5) performance regresses, (6) multiple quick fixes have already failed. Enforces root cause investigation before any fix attempt.
---

# Systematic Debugging

Root cause first. No random fixes.

**Core principle:** Random fixes waste time and create new bugs. Quick patches mask underlying issues.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you're guessing, you're not debugging.

## When to Use

- Test failures
- Unexpected results
- Error values appearing in calculations
- Performance regressions
- Anomalous behavior

**Especially critical when:**
- Under time pressure (resist "quick fix" urge)
- After multiple failed attempts
- Lacking full understanding of the code path

## The Four Phases (Sequential)

### Phase 1: Root Cause Investigation

Complete before proposing ANY fix.

**1. Read Error Messages Carefully**
```python
# Don't skip past errors - they often contain exact solutions
# Note: line numbers, file paths, variable values, stack trace

# Example: "IndexError at line 45 in processor.py"
# → Go to processor.py:45, understand what index is out of bounds
```

**2. Reproduce Consistently**
```bash
# Create minimal reproduction
pytest tests/test_module.py::test_that_fails -v

# If intermittent, gather more data before guessing
```

**3. Check Recent Changes**
```bash
# What changed that could cause this?
git diff HEAD~5 -- src/
git log --oneline -10 -- <failing_file>
```

**4. Trace Data Flow**

For complex bugs, add diagnostic prints at boundaries:

```python
# Trace where bad values originate
def process_data(data, config):
    print(f"INPUT: data.shape={len(data)}, config={config}")
    print(f"INPUT: data[:5]={data[:5]}")

    result = _process(data, config)

    print(f"OUTPUT: result.shape={len(result)}")
    print(f"OUTPUT: result[:5]={result[:5]}")
    return result
```

**5. Check for Common Issues**

```python
# Off-by-one errors
# Null/None handling
# Type mismatches
# Race conditions
# Resource exhaustion
```

### Phase 2: Pattern Analysis

Find working examples before fixing.

**1. Find Working Similar Code**
```bash
# Look for similar functionality that works
grep -r "similar_pattern" src/ --include="*.py"
```

**2. Compare Against References**
```python
# Compare your output to known-good implementation
expected = reference_implementation(test_input)
actual = your_implementation(test_input)

# Find where they diverge
for i, (e, a) in enumerate(zip(expected, actual)):
    if e != a:
        print(f"First divergence at index {i}: expected {e}, got {a}")
        break
```

**3. Identify Differences**

List every difference between working and broken:
- Input data format?
- Parameter handling?
- Edge case handling (empty, null, single value)?
- Index alignment?

### Phase 3: Hypothesis and Testing

Scientific method only.

**1. Form Single Hypothesis**

Write it down explicitly:
```
HYPOTHESIS: Function returns empty because the input
validation rejects all items when config is None.

EVIDENCE: Output shows empty result when config=None.

TEST: Check if providing default config fixes it.
```

**2. Test Minimally**

One change at a time:
```python
# Change ONE thing
result = process_data(data, config=DEFAULT_CONFIG)  # Added default

# Run test
pytest tests/test_module.py::test_that_fails -v
```

**3. If Fix Doesn't Work**

- Do NOT add another fix on top
- Return to Phase 1 with new information
- Form new hypothesis

**4. After 3+ Failed Fixes: Question Architecture**

Pattern of each fix revealing new problems = architectural issue, not implementation bug.

```
STOP. This isn't a bug - it's a design problem.

Questions to ask:
- Is the interface correct?
- Are we solving the right problem?
- Should this be restructured?
```

### Phase 4: Implementation

Fix root cause, not symptoms.

**1. Create Failing Test First**
```python
def test_handles_none_config():
    """Function should use defaults when config is None."""
    result = process_data(test_data, config=None)
    assert len(result) > 0
    assert result == expected_with_defaults
```

**2. Implement Single Fix**
```python
# Address identified root cause only
def process_data(data, config=None):
    if config is None:
        config = DEFAULT_CONFIG
    # ... rest of implementation
```

**3. Verify Fix**
```bash
pytest tests/test_module.py -v
# ALL tests must pass, not just the new one
```

## Red Flags - STOP and Follow Process

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- Proposing solutions before tracing data flow
- Attempting another fix when 2+ already failed

## Common Debugging Patterns

### Null/None Propagation
```python
# Trace where None originates
def debug_none(obj, name=""):
    if obj is None:
        print(f"{name}: is None")
        return
    if hasattr(obj, '__iter__'):
        none_indices = [i for i, v in enumerate(obj) if v is None]
        if none_indices:
            print(f"{name}: None at indices {none_indices[:5]}...")
```

### Type Mismatch Issues
```python
# Check types at boundaries
def check_types(obj, name=""):
    print(f"{name}: type={type(obj).__name__}")
    if hasattr(obj, 'dtype'):
        print(f"{name}: dtype={obj.dtype}")
    if hasattr(obj, '__len__'):
        print(f"{name}: len={len(obj)}")
```

### Performance Debugging
```python
# Profile to find actual bottleneck
import time

def timed(func):
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__}: {elapsed:.4f}s")
        return result
    return wrapper
```

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|----------------|------------------|
| 1. Root Cause | Read errors, reproduce, trace data | Understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Identify differences |
| 3. Hypothesis | Form theory, test minimally | Confirmed or new hypothesis |
| 4. Implementation | Create test, fix, verify | Bug resolved, all tests pass |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too |
| "Emergency, no time for process" | Systematic is faster than thrashing |
| "Just try this first" | First fix sets the pattern—do it right |
| "Multiple fixes at once saves time" | Can't isolate what worked |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause |
| "One more fix attempt" (after 2+) | 3+ failures = architectural problem |
