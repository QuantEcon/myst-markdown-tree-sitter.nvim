# Edge Cases

## Code-cell without language (should default to Python based on MyST spec)

```{code-cell}
print("This should be treated as Python")
x = [1, 2, 3]
```

## Code-cell with ipython alias

```{code-cell} ipython
import matplotlib.pyplot as plt
plt.plot([1, 2, 3])
```

## Empty code-cell

```{code-cell} python
```

## Code-cell with complex code

```{code-cell} python
class DataProcessor:
    def __init__(self, data):
        self.data = data
    
    def process(self):
        """Process the data."""
        return [x * 2 for x in self.data]

processor = DataProcessor([1, 2, 3, 4, 5])
result = processor.process()
print(result)
```

## Multiple code-cells in succession

```{code-cell} python
import numpy as np
data = np.array([1, 2, 3])
```

```{code-cell} python
print(data.sum())
```

```{code-cell} python
print(data.mean())
```
