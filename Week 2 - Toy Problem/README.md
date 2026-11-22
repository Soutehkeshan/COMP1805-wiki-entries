# Toy Problem
## Sphere Function

```math
f(\mathbf{x}) = \sum_{i=1}^{D} x_i^2, \qquad -5.12 \le x_i \le 5.12, \quad D = 30
```

The optimum is $0$ at the origin. Fitness improved as the sample size grew, but with diminishing returns, since random sampling rarely lands near the optimum in 30 dimensions. I then evolved the 50 solutions with Differential Evolution: mutation $\mathbf{v}_i = \mathbf{x}_a + F(\mathbf{x}_b - \mathbf{x}_c)$ shares information between solutions, crossover mixes variables, and greedy selection keeps improvements. Best fitness fell from $\sim 180$ (best of 50 random) to $\sim 10^{-9}$.
