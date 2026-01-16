---
name: verification-before-completion
description: Enforce evidence-based completion claims with actual command output. Use before (1) claiming tests pass, (2) claiming a bug is fixed, (3) claiming a task completed successfully, (4) claiming performance improved, (5) saying "ready for review". Prevents phrases like "should pass" or "that should fix it" - requires fresh verification evidence.
---

# Verification Before Completion

Evidence before claims. Always.

**Core principle:** Claiming work is complete without verification is dishonesty, not efficiency.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in THIS session, you cannot claim it passes.

## The Gate Function

Before ANY status claim, follow this sequence:

```
1. IDENTIFY → What command proves your claim?
2. RUN      → Execute it (fresh, in full)
3. READ     → Examine full output, check exit codes
4. VERIFY   → Does output confirm your claim?
              NO  → State actual status with evidence
              YES → State claim WITH evidence
5. CLAIM    → Only now make the claim
```

Skipping steps = dishonesty.

## Common Claims and Requirements

| Claim | Requires | NOT Sufficient |
|-------|----------|----------------|
| "Tests pass" | `pytest` output: 0 failures | Previous run, "should pass" |
| "Function works" | Test output + sample run | "Code looks correct" |
| "Task complete" | Verification command succeeds | "Started the process" |
| "Bug fixed" | Failing test now passes | "Changed the code" |
| "Performance improved" | Before/after benchmarks | "Removed the loop" |
| "Build succeeds" | Build command exit 0 | Linter passing |

## Verification Commands

### Tests
```bash
# Single module
pytest tests/test_<module>.py -v

# Full suite
pytest tests/ -v

# Specific test
pytest tests/test_module.py::test_specific -v
```

**Evidence format:**
```
Tests: 47 passed, 0 failed
```

### Build/Compile
```bash
# Check build succeeds
npm run build  # or make, cargo build, etc.
echo "Exit code: $?"
```

**Evidence format:**
```
Build complete: exit code 0
```

### Correctness
```python
# Compare against reference
assert result == expected
print("Verification: MATCH")
```

## Red Flags - STOP Immediately

Watch for these danger signals:

- Using "should", "probably", "seems to"
- Feeling satisfied before verification ("Done!", "Fixed!")
- About to commit without running tests
- Trusting previous test run from earlier in session
- Thinking "just this once"
- Fatigue making you want work to be finished
- **ANY wording implying success without running verification**

### Forbidden Phrases

```
❌ "Tests should pass now"
❌ "That should fix it"
❌ "The build will succeed"
❌ "I've implemented the feature"  (without test evidence)
❌ "Bug is fixed"  (without test evidence)
❌ "Ready for review"  (without full test run)
```

### Required Phrases

```
✅ "Tests pass (47/47, 0 failures)"
✅ "Task complete: verification output shows success"
✅ "Bug fixed - test_handles_empty now passes"
✅ "Function matches reference (verified with test data)"
```

## Verification Patterns

### For Bug Fixes (Red-Green Cycle)

```
1. Write failing test     → Run → See FAIL
2. Implement fix          → Run → See PASS
3. (Optional) Revert fix  → Run → See FAIL again
4. Restore fix            → Run → See PASS
5. Run full suite         → All green
```

The revert step proves the test actually tests the fix.

### For New Features

```
1. Write tests first      → Run → See FAIL (feature missing)
2. Implement feature      → Run → See PASS
3. Run full suite         → No regressions
```

### For Refactoring

```
1. Run tests before       → Record: X passed
2. Refactor code          → (no test changes)
3. Run tests after        → Same X passed
4. Verify behavior identical
```

## Performance Claims

Before claiming "X is faster":

```python
import timeit

# Before
before = timeit.timeit(old_function, number=100)

# After
after = timeit.timeit(new_function, number=100)

print(f"Before: {before:.3f}s")
print(f"After: {after:.3f}s")
print(f"Speedup: {before/after:.1f}x")
```

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Tests passed earlier" | Run them again |
| "Code looks correct" | Tests prove correctness |
| "I'm tired" | Exhaustion ≠ excuse |
| "Takes too long" | Run shorter verification to confirm |

## Example Session

**Bad:**
```
Assistant: I've fixed the validation issue. The function should now
handle edge cases correctly.
```

**Good:**
```
Assistant: Validation edge case fix implemented. Verification:

$ pytest tests/test_validator.py -v
tests/test_validator.py::test_handles_empty PASSED
tests/test_validator.py::test_handles_single_value PASSED
tests/test_validator.py::test_handles_null PASSED
tests/test_validator.py::test_normal_input PASSED
tests/test_validator.py::test_boundary_values PASSED

5 passed, 0 failed

All validator tests pass. Edge cases now handled correctly.
```

## The Bottom Line

```
No shortcuts for verification.
Run the command.
Read the output.
THEN claim the result.

This is non-negotiable.
```
