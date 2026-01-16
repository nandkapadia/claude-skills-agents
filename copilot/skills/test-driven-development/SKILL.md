---
name: test-driven-development
description: Enforce test-first development with Red-Green-Refactor cycle. Use when (1) implementing new features in production code, (2) fixing bugs (write test that reproduces bug first), (3) refactoring code (ensure tests exist before changing behavior). Skip for exploratory research scripts or throwaway prototypes.
---

# Test-Driven Development (TDD)

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

## When to Use

**Always use for:**
- New features in production code
- Bug fixes (write test that reproduces the bug first)
- Refactoring (ensure tests exist before changing behavior)
- Any code that will be committed to main branch

**Skip for (use standard workflow instead):**
- Exploratory research scripts
- One-off analysis notebooks
- Throwaway prototypes (ask user to confirm)
- Configuration files

## Step-by-Step Execution (One Test at a Time)

**This is the exact sequence to follow for each feature:**

```
┌─────────────────────────────────────────────────────────────────┐
│  FEATURE: "Add input validation with bounds checking"           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Behavior 1: "rejects negative input"                           │
│  ├─ Write test_rejects_negative_input()                         │
│  ├─ Run pytest → FAIL (function doesn't exist)                  │
│  ├─ Write minimal code: raise ValueError if input < 0           │
│  ├─ Run pytest → PASS                                           │
│  └─ Refactor if needed                                          │
│                                                                 │
│  Behavior 2: "returns correct output type"                      │
│  ├─ Write test_returns_correct_type()                           │
│  ├─ Run pytest → FAIL (returns wrong type)                      │
│  ├─ Fix implementation to return correct type                   │
│  ├─ Run pytest → PASS (both tests)                              │
│  └─ Refactor if needed                                          │
│                                                                 │
│  Behavior 3: "handles edge cases"                               │
│  ├─ Write test_handles_edge_cases()                             │
│  ├─ Run pytest → FAIL (edge case not handled)                   │
│  ├─ Fix edge case logic                                         │
│  ├─ Run pytest → PASS (all 3 tests)                             │
│  └─ Refactor if needed                                          │
│                                                                 │
│  ... continue for each behavior ...                             │
│                                                                 │
│  DONE: All behaviors tested, all tests green                    │
└─────────────────────────────────────────────────────────────────┘
```

### Execution Template

For each behavior you need to implement:

```
## Behavior: [describe what should happen]

### 1. Write Test
```python
def test_<behavior_description>():
    """[What this test verifies]."""
    # Arrange
    # Act
    # Assert
```

### 2. Run Test - Verify FAIL
```bash
pytest tests/test_<module>.py::test_<name> -v
# Expected: FAIL because [reason]
```

### 3. Write Minimal Code
```python
# Only enough to make this test pass
```

### 4. Run Test - Verify PASS
```bash
pytest tests/test_<module>.py -v
# Expected: ALL tests pass
```

### 5. Refactor (if needed)
- Clean up duplication
- Improve names
- Keep tests green

### 6. Next Behavior
Repeat from step 1 for next behavior.
```

**Critical:** Do NOT write the next test until the current one passes. Do NOT write code for behaviors you haven't tested yet.

## The Red-Green-Refactor Cycle

```
┌─────────────────────────────────────────────────────────┐
│  RED → Verify Fail → GREEN → Verify Pass → REFACTOR    │
│   ↑                                              │      │
│   └──────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

### 1. RED - Write Failing Test

Write one minimal test showing what should happen.

```python
# Good - clear name, tests real behavior, one thing
def test_validator_rejects_negative_input():
    """Validator should raise ValueError for input < 0."""
    with pytest.raises(ValueError, match="input must be >= 0"):
        validate_input(-1)
```

```python
# Bad - vague name, tests mock not code
def test_works():
    mock = MagicMock()
    mock.return_value = True
    assert validate_input(mock) == True  # Tests nothing
```

**Requirements:**
- One behavior per test
- Clear name describing expected behavior
- Real code, not mocks (unless external dependencies)

### 2. Verify RED - Watch It Fail

**MANDATORY. Never skip.**

```bash
pytest tests/test_<module>.py::test_<name> -v
```

Confirm:
- Test **fails** (not errors due to typos)
- Failure message matches expectation
- Fails because feature is missing, not because of test bugs

**Test passes immediately?** You're testing existing behavior. Revise the test.

### 3. GREEN - Minimal Code

Write the simplest code to pass the test.

```python
# Good - just enough to pass
def validate_input(value: int) -> bool:
    if value < 0:
        raise ValueError("input must be >= 0")
    return True
```

```python
# Bad - over-engineered beyond what test requires
def validate_input(
    value: int,
    strict: bool = False,      # YAGNI - no test for this yet
    allow_none: bool = True,   # YAGNI
) -> bool:
    ...
```

**Don't:**
- Add features not required by current test
- Refactor other code
- "Improve" beyond test scope

### 4. Verify GREEN - Watch It Pass

**MANDATORY.**

```bash
pytest tests/test_<module>.py -v
```

Confirm:
- Current test passes
- All other tests still pass
- No warnings or errors

### 5. REFACTOR - Clean Up

After green only:
- Remove duplication
- Improve names
- Extract helpers

**Keep tests green throughout.** Don't add behavior.

## What If You Wrote Code First?

**Pragmatic recovery (don't delete everything):**

1. Write tests for the implementation
2. **Verify tests are meaningful** by temporarily breaking the code
3. Confirm tests fail for the right reason
4. Restore the code, confirm tests pass

This isn't true TDD, but it's better than untested code.

## Good Test Patterns

| Quality | Example |
|---------|---------|
| **Clear name** | test_rejects_empty_input, test_returns_list_of_strings |
| **Edge cases** | Empty input, null/None, single value, boundary values |
| **Error conditions** | Invalid input types, out of range values |
| **Performance** | Test with realistic data sizes when relevant |

### Example: Testing a Function

```python
class TestValidator:
    """Tests for input validator."""

    def test_validator_accepts_positive_integers(self):
        """Validator should return True for positive integers."""
        assert validate_input(42) == True

    def test_validator_rejects_negative_integers(self):
        """Validator should raise ValueError for negative input."""
        with pytest.raises(ValueError, match="must be >= 0"):
            validate_input(-1)

    def test_validator_handles_zero(self):
        """Validator should accept zero as valid input."""
        assert validate_input(0) == True

    def test_validator_rejects_non_integer_types(self):
        """Validator should raise TypeError for non-integer input."""
        with pytest.raises(TypeError):
            validate_input("not an int")
```

## Common Rationalizations (and Responses)

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing about catching bugs. |
| "Already manually tested" | Manual tests can't be re-run, aren't documented. |
| "Test is hard to write" | Hard to test = hard to use. Simplify the design. |
| "Exploring first" | Fine. But mark it as research, not production code. |

## Verification Checklist

Before marking implementation complete:

- [ ] Every new function has at least one test
- [ ] Each test failed before implementation (or you verified via breaking)
- [ ] Tests fail for expected reason (feature missing, not typo)
- [ ] Minimal code written to pass each test
- [ ] All tests pass
- [ ] Edge cases covered (empty, null, single value)

## Bug Fix Process

1. Write a failing test that reproduces the bug
2. Verify it fails for the right reason
3. Fix the bug with minimal code
4. Verify test passes
5. The test now prevents regression

**Never fix bugs without a test.**

## Red Flags - Pause and Reassess

- Test passes immediately (not testing new behavior)
- Can't explain why test should fail
- Writing lots of code between test runs
- "Just this once" rationalization
- Skipping verify steps

## Example: TDD Bug Fix Session

**Bug:** Empty input causes crash

```python
# 1. RED - Write failing test
def test_handles_empty_input():
    """Function should return empty result for empty input."""
    result = process_data([])
    assert len(result) == 0
    assert isinstance(result, list)

# 2. Verify RED
# $ pytest tests/test_processor.py::test_handles_empty_input -v
# FAILED - IndexError: list index out of bounds

# 3. GREEN - Minimal fix
def process_data(data: list) -> list:
    if len(data) == 0:
        return []
    # ... rest of implementation

# 4. Verify GREEN
# $ pytest tests/test_processor.py -v
# PASSED (all tests)

# 5. REFACTOR - None needed for this fix
```
