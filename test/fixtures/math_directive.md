# MyST Math Directive Test

## Test 1: Simple {math} directive without config

```{math}
\gamma x := 
\begin{bmatrix}
    \gamma x_1 \\
    \gamma x_2 \\
    \vdots \\
    \gamma x_n
\end{bmatrix}
```

## Test 2: {math} directive with label (YAML config)

```{math}
:label: la_se

\begin{aligned}
    y_1 = a_{11} x_1 + a_{12} x_2 + \cdots + a_{1k} x_k \\
    \vdots  \\
    y_n = a_{n1} x_1 + a_{n2} x_2 + \cdots + a_{nk} x_k
\end{aligned}
```

## Test 3: {math} directive with multiple options

```{math}
:label: eq_matrix
:nowrap: true

$$
\gamma x := 
\begin{bmatrix}
    \gamma x_1 \\
    \gamma x_2 \\
    \vdots \\
    \gamma x_n
\end{bmatrix}
$$
```

## Test 4: Standard inline math (should already work)

This is inline math: $x = y^2 + z^2$ in the text.

## Test 5: Standard display math (should already work)

$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$

## Test 6: Complex equation with label

```{math}
:label: bellman

v(x) = \max_{0 \le y \le x} \left\{
    u(x - y) + \beta \int v(f(y) z) \phi(dz)
\right\}
```

## Test 7: Multiple equations in one block

```{math}
\begin{align}
    E[X] &= \mu \\
    \text{Var}(X) &= \sigma^2 \\
    P(X = x) &= \frac{\lambda^x e^{-\lambda}}{x!}
\end{align}
```
