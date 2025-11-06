# YAML Syntax Format Compatibility Test

This file tests both supported YAML configuration formats in MyST directives.

## Format 1: Inline YAML (Legacy/Short Syntax)

```{code-cell} python
:tags: [hide-input]
print("This uses inline YAML config")
x = [1, 2, 3]
```

## Format 2: Full YAML Block (Recommended/Proper Syntax)

```{code-cell} python
---
:tags: [hide-input]
---
print("This uses proper YAML block config")
x = [1, 2, 3]
```

## Format 3: Multiple Options (Inline)

```{code-cell} ipython
:tags: [hide-output, remove-input]
:linenos:
import numpy as np
data = np.random.rand(100)
```

## Format 4: Multiple Options (YAML Block)

```{code-cell} ipython
---
:tags: [hide-output, remove-input]
:linenos:
---
import numpy as np
data = np.random.rand(100)
```

## Math Directive Format 1: No Config

```{math}
\int_0^1 x^2 dx = \frac{1}{3}
```

## Math Directive Format 2: YAML Block Config

```{math}
---
:label: my-integral
:nowrap: true
---
$$
\int_0^1 x^2 dx = \frac{1}{3}
$$
```

## Expected Behavior

All code blocks above should have proper syntax highlighting regardless of YAML format:
- Python/IPython code should be highlighted
- LaTeX math should be highlighted
- Both inline and YAML block configurations should work

**Technical Note:** Our regex-based injection queries match on the `info_string` 
(first line) only, so both formats work. The YAML configuration (whether inline 
or in a block) becomes part of the `code_fence_content` which doesn't affect 
language detection.
