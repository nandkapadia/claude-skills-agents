---
name: python-documentation
description: Review and update Python documentation to match project standards. Use when (1) writing new code that needs documentation, (2) reviewing existing code for documentation gaps, (3) updating docstrings after code changes, (4) adding inline comments to complex logic, (5) organizing imports. Enforces Google-style docstrings, beginner-friendly inline comments, and proper import structure.
---

# Python Documentation Standards

Review and update Python documentation to match project standards: Google-style docstrings, beginner-friendly inline comments, and organized imports.

## When to Use

- Writing new modules, classes, or functions
- Reviewing code for documentation completeness
- After modifying code (docstrings may be stale)
- Making complex code understandable
- Organizing imports in a messy file

## Documentation Checklist

### 1. Module-Level Docstring

Every Python file needs a module docstring at the top:

```python
"""Short description of module purpose.

Longer description explaining:
- What this module provides
- Key classes/functions
- Usage context

Example:
    Basic usage example if helpful.
"""
```

### 2. Class Docstrings

```python
class DataProcessor:
    """One-line summary of class purpose.

    Longer description explaining behavior, usage patterns,
    and any important notes.

    Attributes:
        threshold: float
            The threshold value for processing.
        window: int
            Lookback window size.

    Example:
        >>> processor = DataProcessor(threshold=0.5)
        >>> processor.run(data)
    """
```

### 3. Function/Method Docstrings (Google Style)

```python
def process_data(
    data: list,
    threshold: float = 0.0,
    window: int = 14,
) -> list:
    """Process input data with configurable parameters.

    Applies processing logic to input data, filtering based on
    threshold and using a rolling window for calculations.

    Args:
        data: List of numeric values to process.
            Must not be empty.
        threshold: Minimum value to include in output.
            Positive values filter more aggressively. Defaults to 0.0.
        window: Number of items for rolling calculation.
            Larger windows create smoother but laggier results.
            Defaults to 14.

    Returns:
        List of processed values with same length as input.
        Values below threshold are set to None.

    Raises:
        ValueError: If data is empty or window is less than 1.
        TypeError: If data contains non-numeric values.

    Example:
        >>> results = process_data([1, 2, 3, 4, 5], threshold=2.0)
        >>> filtered = [r for r in results if r is not None]
    """
```

### 4. Inline Comments

**DO: Explain the "why" and complex logic**

```python
# Calculate rolling average using expanding window
# We use expanding() instead of rolling() to handle the warmup period
# without introducing NaN values at the start
average = values.expanding(min_periods=1).mean()

# Shift results forward to avoid using current value in calculation
# Without this, we'd be using today's data to compute today's result
shifted = results[:-1]

# Use parallel execution for independent iterations
# This provides ~4x speedup on multi-core systems
for i in range(n_workers):
```

**DON'T: State the obvious**

```python
# BAD: States what code does, not why
i = 0  # Set i to 0
data = df['value']  # Get value column

# GOOD: Explains purpose or gotcha
i = 0  # Start from first valid item after warmup period
data = df['value']  # Use raw values (not normalized) for this calculation
```

### 5. Import Organization

```python
# Standard Library
import os
from datetime import datetime
from typing import Dict, List, Optional

# Third Party
import numpy as np
import pandas as pd
import requests
from sqlalchemy import create_engine

# First Party
from myproject.core import DataManager
from myproject.utils import helpers
from myproject.config import settings
```

**Rules:**
- Absolute imports only (no `from . import`)
- Alphabetize within each section
- One blank line between sections
- Use `isort` to maintain structure

## Review Process

### Step 1: Scan for Missing Documentation

```bash
# Find functions without docstrings
grep -n "def " file.py | while read line; do
    # Check if next non-empty line is a docstring
done
```

Or manually check:
- [ ] Module has docstring
- [ ] All classes have docstrings with Attributes section
- [ ] All public methods have Args/Returns/Raises
- [ ] All private methods have at least a one-liner
- [ ] Complex logic has inline comments

### Step 2: Verify Docstring Accuracy

After code changes, docstrings often become stale:

```python
# BAD: Docstring doesn't match signature
def calculate(data: list, window: int = 14) -> list:
    """Calculate result.

    Args:
        data: Input data.
        period: Lookback period.  # WRONG: param is 'window', not 'period'
    """
```

**Check:**
- [ ] All Args match function signature
- [ ] Default values in docstring match actual defaults
- [ ] Return type description matches actual return
- [ ] Raises section lists all possible exceptions

### Step 3: Add Missing Inline Comments

Focus on:
1. **Algorithm specifics** - Explain optimization choices
2. **Library patterns** - Explain non-obvious API usage
3. **Domain logic** - Explain business rules for readers unfamiliar with domain
4. **Performance decisions** - Why this algorithm over alternatives
5. **Edge cases** - Why certain checks exist

### Step 4: Organize Imports

Run isort or manually organize:
```bash
isort --profile black --sections STDLIB,THIRDPARTY,FIRSTPARTY file.py
```

## Common Issues

### Issue 1: Missing Args Documentation

```python
# BAD
def run(self, data_manager, config, **kwargs):
    """Run the processor."""

# GOOD
def run(self, data_manager, config, **kwargs):
    """Run the processor with given configuration.

    Args:
        data_manager: DataManager instance providing input data.
        config: Configuration dict with processing parameters.
        **kwargs: Additional parameters passed to process function.
            Common kwargs include 'window', 'threshold'.

    Returns:
        Processor instance with results accessible as properties.
    """
```

### Issue 2: Stale Default Values

```python
# BAD: Docstring says default is 14, but code uses 20
def calculate(window: int = 20) -> list:
    """Calculate result.

    Args:
        window: Lookback period. Defaults to 14.  # WRONG!
    """

# GOOD
def calculate(window: int = 20) -> list:
    """Calculate result.

    Args:
        window: Lookback period. Defaults to 20.
    """
```

### Issue 3: Missing Raises Section

```python
# BAD: Function raises but doesn't document it
def validate(data):
    """Validate input data."""
    if data is None:
        raise ValueError("Data cannot be None")

# GOOD
def validate(data):
    """Validate input data.

    Args:
        data: Input data to validate.

    Raises:
        ValueError: If data is None or empty.
    """
    if data is None:
        raise ValueError("Data cannot be None")
```

### Issue 4: No Explanation for Complex Logic

```python
# BAD: No explanation
result = [
    v for i, v in enumerate(data)
    if i > window and data[i-1] > threshold and flags[i]
]

# GOOD: Step-by-step explanation
# Filter values based on multiple conditions:
# 1. Skip warmup period (first 'window' items)
# 2. Previous value must exceed threshold (trend confirmation)
# 3. Flag must be set (external validation passed)
result = [
    v for i, v in enumerate(data)
    if i > window           # Skip warmup period
    and data[i-1] > threshold  # Trend confirmation
    and flags[i]            # External validation
]
```

## Output Format

When reviewing documentation, report:

```
## Documentation Review: [filename]

### Summary
- Functions: X total, Y missing docstrings
- Classes: X total, Y missing docstrings
- Inline comments: [Adequate/Sparse/Missing]
- Import organization: [Correct/Needs fixing]

### Issues Found

#### Missing Docstrings
1. `function_name()` at line X - needs Args/Returns/Raises

#### Stale Documentation
1. `function_name()` at line X - default value mismatch

#### Missing Inline Comments
1. Lines X-Y: Complex operation needs explanation

### Suggested Fixes
[Provide specific docstring/comment text to add]
```

## Quick Reference

| Element | Required Sections |
|---------|------------------|
| Module | Summary, description |
| Class | Summary, Attributes |
| Public function | Summary, Args, Returns, Raises (if applicable) |
| Private function | At least one-line summary |
| Complex logic | Inline comment explaining why |

## Integration with Other Skills

- **code-reviewer**: Checks documentation as part of review
- **verification-before-completion**: Verifies docstrings updated after changes
