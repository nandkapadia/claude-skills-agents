---
name: codebase-cleanup
description: Use when preparing codebase for production commit, removing dead code, cleaning debug artifacts, auditing security, or performing pre-merge cleanup passes
---

# Codebase Cleanup

## Overview

Remove clutter while preserving all functional behavior. **Cleanup only** - no refactoring or redesign.

## When to Use

- Preparing code for production commit
- Pre-merge cleanup passes
- Removing accumulated debug artifacts
- Dead code audits
- Security and configuration reviews before release

**When NOT to use:** Refactoring, redesign, or functional improvements.

## Core Principles

- **Be conservative.** If unsure whether code is used, **flag it** instead of deleting.
- **Preserve git history readability.** Group related changes logically.
- **Do not refactor working logic.** Cleanup only.

## Quick Reference

| Category | Remove | Keep/Convert | Flag for Review |
|----------|--------|--------------|-----------------|
| Dead code | No references, commented-out blocks, unreachable | - | Reflection/dynamic calls, test-only refs |
| Debug | `print()`, `console.log()`, `debugger`, hardcoded test values | Useful debug → structured logging | - |
| Imports | Unused | - | - |
| Comments | Restates obvious, outdated, inline changelogs | Explains "why", warnings, external refs | - |
| Temp names | `temp`, `test`, `debug`, `foo`, `xxx` | - | - |

## 1. Dead Code Removal

### Delete
- Functions, classes, methods with **no references**
- Commented-out code blocks *(except those marked `NOTE:` or `KEEP:`)*
- Unused imports and dependencies
- Unreachable code (after `return`, in impossible branches)

### Flag for Review (Do Not Delete)
- Code possibly invoked via decorators, reflection, or dynamic calls
- Functions referenced only in tests
- Any code you are **<90% confident** is safe to remove

## 2. Debug Artifact Cleanup

### Remove
- `print()`, `console.log()`, `debugger` statements
- Hardcoded test values (e.g., `user_id = 12345`)
- Temporary variable names: `temp`, `test`, `debug`, `foo`, `xxx`
- Completed `TODO` / `FIXME` comments

### Convert (Do Not Remove)
- Useful debug output → structured logging with appropriate log levels

## 3. Code Organization

### Import Order
1. Standard library
2. Third-party packages
3. Local/project imports

(Separate groups with a blank line)

### Remove
- Duplicate code blocks *(Flag if behavior differs slightly)*
- Redundant type annotations that add no clarity
- Excessive blank lines (max two consecutive)

## 4. Documentation Audit

### Remove
- Comments that restate obvious code behavior
- Outdated or misleading comments
- Inline changelog notes (git handles history)

### Keep
- Explanations of **why**, not **what**
- Warnings about non-obvious behavior
- Links to issues, specs, or external references

### Generate/Update
- Add or update docstrings for public modules, classes, and functions
- Follow project documentation standards

## 5. Security & Configuration Check

### Verify Absence Of
- Hardcoded credentials, API keys, tokens, or passwords
- Internal URLs, IPs, or hostnames
- Personal data or PII in fixtures

### Confirm Presence Of
- Environment variable usage for secrets
- Proper `.gitignore` entries (logs, env files, caches, secrets)

## 6. Linting & Formatting Pass

After cleanup, run project-configured linters and formatters. Fix violations introduced by cleanup, but do not refactor functional logic.

### General Approach
- Run linters with project configuration
- Apply safe auto-fixes
- Flag any new rule suppressions added during cleanup
- Fix violations **caused by cleanup**
- Do not perform large-scale rewrites to satisfy linters

### Python Example
```bash
ruff check --fix .          # Lint + auto-fix
ruff format .               # Format
isort .                     # Import sorting
pylint <modified_modules>   # Additional checks
```

### JavaScript/TypeScript Example
```bash
eslint --fix .
prettier --write .
```

### Linting Rules of Engagement
- No new ignore comments (`# noqa`, `// eslint-disable`) without justification
- If a lint rule conflicts with project style, **flag rather than override**

## 7. Execution Order

1. Read and understand codebase structure
2. Identify removal and modification candidates
3. Apply changes file-by-file
4. Update documentation (docstrings)
5. Run linters and formatters
6. Final verification: check references and run CI if available

## 8. Output Requirements

After completing cleanup, provide:

### Summary
- Total files reviewed
- Files modified (brief description of changes)
- Approximate lines removed

### Flagged Items

| File | Line(s) | Concern |
|------|---------|---------|

### Recommended Follow-ups
Improvements noticed but outside cleanup scope.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Deleting code called via reflection | Flag instead of delete; search for string references |
| Removing "unused" test utilities | Check test files before removing |
| Over-cleaning comments | Keep "why" explanations, warnings, and caveats |
| Refactoring while cleaning | Separate concerns - cleanup only |
| Batch-committing all changes | Group related changes for readable git history |
