# Visual Test for Code-Cell Configuration Fix

Open this file in Neovim with the myst-markdown plugin to verify syntax highlighting.

## ✅ Test 1: Python with :tags: (YAML-style config)

```{code-cell} python
:tags: [output_scroll]
---
# This Python code should be highlighted
import numpy as np
x = np.array([1, 2, 3])
print(x.mean())
```

## ✅ Test 2: IPython with concise config

```{code-cell} ipython
:tags: [hide-input]
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
df.head()
```

## ✅ Test 3: Python3 with multiple config options

```{code-cell} python3
:tags: [output_scroll, hide-cell]
:linenos:
---
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
```

## ✅ Test 4: JavaScript with config

```{code-cell} javascript
:tags: [remove-output]
// JavaScript code should be highlighted
const greeting = "Hello, World!";
console.log(greeting);
```

## ✅ Test 5: Bash with config

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

## ✅ Test 7: Multiple config options with emphasized lines

```{code-cell} python
:tags: [hide-input, output_scroll]
:linenos:
:emphasize-lines: 2,3
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

The configuration lines (`:tags:`, `:linenos:`, etc.) should NOT break the highlighting.

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
