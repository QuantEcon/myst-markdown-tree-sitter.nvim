# MyST Code Cell with Configuration - Test Fixture

## Test Case 1: Python with YAML config block

```{code-cell} python
:tags: [output_scroll]
---
x = 1 + 2
print(x)
```

## Test Case 2: IPython with concise config

```{code-cell} ipython
:tags: [hide-input]
import numpy as np
arr = np.array([1, 2, 3])
print(arr)
```

## Test Case 3: Python3 with YAML config

```{code-cell} python3
:tags: [output_scroll, hide-cell]
---
def hello():
    return "world"
```

## Test Case 4: JavaScript with config

```{code-cell} javascript
:tags: [remove-output]
console.log("Hello from JS");
```

## Test Case 5: Bash with config

```{code-cell} bash
:tags: [output_scroll]
echo "Testing bash highlighting"
ls -la
```

## Test Case 6: No config (baseline)

```{code-cell} python
# This should still work
y = 5 + 3
print(y)
```

## Test Case 7: Multiple config options

```{code-cell} python
:tags: [hide-input, output_scroll]
:linenos:
:emphasize-lines: 2,3
---
import matplotlib.pyplot as plt
x = [1, 2, 3]
y = [2, 4, 6]
plt.plot(x, y)
```
