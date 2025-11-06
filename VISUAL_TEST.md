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

## ✅ Test 4: Rust with YAML block config

```{code-cell} rust
---
tags: [remove-output]
---
// Rust code should be highlighted
fn main() {
    let greeting = "Hello, World!";
    println!("{}", greeting);
}
```

## ✅ Test 5: Python with concise config (numeric operations)

```{code-cell} python
:tags: [output_scroll]
# Numeric computations should be highlighted
import math
result = math.sqrt(16) + math.pi
print(f"Result: {result}")
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
- Rust keywords (fn, let, etc.) should be highlighted  
- Comments should be styled as comments
- Strings should be highlighted as strings

**MyST Configuration Formats:**
- **Concise format** (Tests 1, 3, 5): Use `:key:` with colons (e.g., `:tags: [value]`, `:linenos:`)
- **YAML block format** (Tests 2, 4, 7): Use `---` delimiters with `key:` without leading colon

Both formats should work without breaking syntax highlighting.

## 📦 Required Tree-sitter Parsers

Syntax highlighting requires the corresponding tree-sitter parsers to be installed:

- **Python** (Tests 1-3, 5-7): `:TSInstall python` ✅ (commonly pre-installed)
- **Rust** (Test 4): `:TSInstall rust` ✅ (used in this test file)
- **LaTeX** (Math tests 8-12): `:TSInstall latex` (required for math directives)

**Other Supported Languages** (install as needed):
```vim
:TSInstall javascript bash r julia c cpp go typescript
```

**Note:** The plugin supports these languages via injection queries, but highlighting only works if you've installed the corresponding parser. If you don't see highlighting for a code-cell, install its parser with `:TSInstall <language>`.

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

**Comparison - Regular latex code block (should have identical highlighting):**

```latex
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
```

**Comparison - Standard $$ delimiters (may have less highlighting):**

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$

**Expected:** The `{math}` block should match the ```` ```latex ```` block highlighting.

### Test 9: {math} directive with label

```{math}
---
label: my-equation
---
E = mc^2
```

**Comparison - Standard $$ delimiter:**

$$
E = mc^2
$$

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

**Comparison - Standard $$ delimiter:**

$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

**Note:** In the `{math}` directive with `nowrap: true`, you need to include `$$` delimiters inside the block.

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

**Comparison - Standard $$ delimiter:**

$$
\mathbf{A} = 
\begin{bmatrix}
    a_{11} & a_{12} & \cdots & a_{1n} \\
    a_{21} & a_{22} & \cdots & a_{2n} \\
    \vdots & \vdots & \ddots & \vdots \\
    a_{m1} & a_{m2} & \cdots & a_{mn}
\end{bmatrix}
$$

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

**Comparison - Standard $$ delimiter:**

$$
\begin{aligned}
    y_1 &= a_{11} x_1 + a_{12} x_2 + \cdots + a_{1k} x_k \\
    y_2 &= a_{21} x_1 + a_{22} x_2 + \cdots + a_{2k} x_k \\
    &\vdots \\
    y_n &= a_{n1} x_1 + a_{n2} x_2 + \cdots + a_{nk} x_k
\end{aligned}
$$

### Test 13: Standard $$ delimiters (baseline - should already work)

$$
\nabla \times \mathbf{E} = -\frac{\partial \mathbf{B}}{\partial t}
$$

**Note:** This is the baseline test - standard `$$` delimiters should work by default with markdown's built-in math support.

## 🔍 Expected Behavior for Math

**Both `{math}` directives AND standard `$$` delimiters should have LaTeX syntax highlighting:**

- LaTeX commands (`\int`, `\sqrt`, `\frac`, `\mathbf`, etc.) should be highlighted
- Math environments (`\begin{bmatrix}`, `\begin{aligned}`, etc.) should be styled
- Greek letters (`\pi`, `\nabla`, etc.) should be highlighted
- Subscripts and superscripts should be properly styled
- The configuration lines (`label:`, `nowrap:`, etc.) are part of the YAML block and won't be highlighted as LaTeX

**Comparison Test:** 
The `{math}` directive should inject LaTeX syntax highlighting similar to a standard ```` ```latex ```` code block.

**Important Note About `$$` Delimiters:**
Standard `$$` math blocks in markdown don't automatically get LaTeX syntax highlighting from tree-sitter - they're treated as inline math by the markdown parser. The comparison here shows the difference between MyST's `{math}` directive (which uses LaTeX injection) and standard markdown math delimiters.

**To verify LaTeX highlighting is working:**
1. Check if a regular ```` ```latex ```` code block shows LaTeX highlighting
2. The `{math}` directive should show similar highlighting to ```` ```latex ````
3. Standard `$$` blocks may show less/different highlighting (this is expected)

**Note:** LaTeX highlighting requires the tree-sitter latex parser to be installed: `:TSInstall latex`
