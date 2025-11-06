---
title: Basic MyST Test
---

# Basic MyST File

This is a simple MyST markdown file for testing.

## Python Code Cell

```{code-cell} python
import numpy as np
import pandas as pd

data = np.random.randn(10)
print(f"Mean: {data.mean()}")
```

## Regular Markdown Code Block

```python
# This is regular markdown, not a code-cell
print("Hello, World!")
```

## JavaScript Code Cell

```{code-cell} javascript
const numbers = [1, 2, 3, 4, 5];
const sum = numbers.reduce((a, b) => a + b, 0);
console.log(`Sum: ${sum}`);
```
