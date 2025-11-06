# Edge Cases Test File

This file contains various edge cases for MyST detection.

## Nested Directives

```{note}
This is a note directive.

```{code-cell} python
# Code inside a note
print("nested code")
```
```

## Malformed Syntax

```{code-cell python
# Missing closing brace
print("test")
```

```{code-cell}
# No language specified
print("should still be detected")
```

```{ code-cell } python
# Extra spaces
print("test")
```

## Unicode Content

```{code-cell} python
# Unicode characters: 你好世界 مرحبا العالم
message = "Hello, 世界! 🌍"
print(message)
```

## Empty Code Cells

```{code-cell} python
```

```{code-cell} javascript

```

## Multiple Languages

```{code-cell} python
import numpy as np
```

```{code-cell} javascript
const data = [1, 2, 3];
```

```{code-cell} julia
using DataFrames
```

```{code-cell} r
library(ggplot2)
```

## Comments and Metadata

```{code-cell} ipython
:tags: [hide-cell, remove-output]
:name: my-cell

import pandas as pd
```

## Very Long Lines

```{code-cell} python
very_long_variable_name = "This is a very long string that goes on and on and on and on and on and on and on and on and on and on and on and on and on and on and on"
```

## Special Characters in Code

```{code-cell} python
# Test special characters: !@#$%^&*()
regex = r"^\d{3}-\d{2}-\d{4}$"
escaped = "Test\\nNewline\\tTab"
```

## Mixed Indentation

```{code-cell} python
def test():
    if True:
        print("four spaces")
	print("tab character")
```
