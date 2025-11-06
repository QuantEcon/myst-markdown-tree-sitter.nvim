# Visual Test for Code-Cell Configuration Fix

Open this file in Neovim with the myst-markdown plugin to verify syntax highlighting.

## ✅ Test 1: Python with concise config syntax

```{code-cell} python
:tags: [output_scroll]
# This Python code should be highlighted
import numpy as np
x = np.array([1, 2, 3])
print(x.mean())
```

## ✅ Test 2: IPython with YAML block config

```{code-cell} ipython
---
tags: [hide-input]
---
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
df.head()
```

## ✅ Test 3: Python3 with concise multi-option config

```{code-cell} python3
:tags: [output_scroll, hide-cell]
:linenos:
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
```

## ✅ Test 4: JavaScript with YAML block config

```{code-cell} javascript
---
tags: [remove-output]
---
// JavaScript code should be highlighted
const greeting = "Hello, World!";
console.log(greeting);
```

## ✅ Test 5: Bash with concise config

```{code-cell} bash
:tags: [output_scroll]
# Bash commands should be highlighted
echo "Testing highlighting"
ls -la | grep "test"
```

## ✅ Test 6: No config (baseline - should still work)

```{code-cell} python
# This should work as before
y = 5 + 3
print(f"Result: {y}")
```

## ✅ Test 7: Python with YAML block and multiple options

```{code-cell} python
---
tags: [hide-input, output_scroll]
linenos: true
emphasize-lines: [2, 3]
---
# Multiple config options
import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 2*np.pi, 100)
y = np.sin(x)

plt.plot(x, y)
plt.title("Sine Wave")
plt.show()
```

## 🔍 Expected Behavior

All code blocks above should have proper syntax highlighting according to their language:
- Python keywords (import, def, return, etc.) should be highlighted
- JavaScript keywords (const, console, etc.) should be highlighted  
- Bash commands (echo, ls, grep) should be highlighted
- Comments should be styled as comments
- Strings should be highlighted as strings

**MyST Configuration Formats:**
- **Concise format** (Tests 1, 3, 5): Use `:key:` with colons (e.g., `:tags: [value]`, `:linenos:`)
- **YAML block format** (Tests 2, 4, 7): Use `---` delimiters with `key:` without leading colon

Both formats should work without breaking syntax highlighting.

## 📊 How to Test

1. Save this file
2. Open in Neovim
3. Set filetype to myst: `:set filetype=myst`
4. Verify syntax highlighting appears in all code blocks
5. Compare with a regular markdown file to see the difference

## 🐛 What Was Fixed

**Before:** Code-cell directives with YAML configuration (`:tags:`, `:linenos:`, etc.) would not get syntax highlighting because the tree-sitter query used exact string matching.

**After:** Updated injection queries use regex patterns to match the language portion while ignoring configuration, so highlighting works regardless of config presence.

**Technical Details:**
- Changed from `(#eq? @_lang "{code-cell} python")` 
- To `(#match? @_lang "^\\{code-cell\\}\\s+(python|ipython|ipython3)")`
- This allows the `info_string` to contain additional content (config) after the language specifier

## ✅ Math Directives (LaTeX Support)

### Test 8: Simple {math} directive without config

```{math}
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
```

### Test 9: {math} directive with label

```{math}
---
label: my-equation
---
E = mc^2
```

### Test 10: {math} directive with multiple options

```{math}
---
label: quadratic-formula
nowrap: true
---
$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```

### Test 11: Matrix equation with label

```{math}
---
label: matrix-eq
---
\mathbf{A} = 
\begin{bmatrix}
    a_{11} & a_{12} & \cdots & a_{1n} \\
    a_{21} & a_{22} & \cdots & a_{2n} \\
    \vdots & \vdots & \ddots & \vdots \\
    a_{m1} & a_{m2} & \cdots & a_{mn}
\end{bmatrix}
```

### Test 12: Aligned equations

```{math}
---
label: system-of-equations
---
\begin{aligned}
    y_1 &= a_{11} x_1 + a_{12} x_2 + \cdots + a_{1k} x_k \\
    y_2 &= a_{21} x_1 + a_{22} x_2 + \cdots + a_{2k} x_k \\
    &\vdots \\
    y_n &= a_{n1} x_1 + a_{n2} x_2 + \cdots + a_{nk} x_k
\end{aligned}
```

### Test 13: Standard $$ delimiters (baseline - should already work)

$$
\nabla \times \mathbf{E} = -\frac{\partial \mathbf{B}}{\partial t}
$$

## 🔍 Expected Behavior for Math

All `{math}` blocks above should have proper LaTeX syntax highlighting:
- LaTeX commands (\int, \sqrt, \frac, etc.) should be highlighted
- Math environments (\begin{bmatrix}, \begin{aligned}, etc.) should be styled
- Greek letters (\pi, \nabla, etc.) should be highlighted
- The configuration lines (`label:`, `nowrap:`, etc.) are part of the YAML block

**Note:** LaTeX highlighting requires the tree-sitter latex parser to be installed.
