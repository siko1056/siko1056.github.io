---
layout: post
title:  "Seminar notes mathematical optimization"
date:   2022-01-11
image: /assets/blog/2022-01-11_gauss_hills.png
categories: blog
tags:
  - math
---

Today I completed my seminar notes about selected topics in
[mathematical optimization](https://en.wikipedia.org/wiki/Mathematical_optimization):
optimality conditions for finite-dimensional (un-)constrained continuous problems,
(un-)constrained optimization methods,
convex analysis,
and many [GNU Octave](https://octave.org/) /
[Matlab](https://www.mathworks.com/products/matlab.html) examples.
The material was created with [Jupyter Book](https://jupyterbook.org/)
and [JupyterLab](https://jupyter.org/) running the
[octave_kernel](https://github.com/Calysto/octave_kernel)
using the [Octave Docker image]({% post_url 2021-06-10-octave-docker %}).


### Seminar "Selected Topics in Mathematical Optimization"

- [Web version](https://siko1056.github.io/optim-2021)
- [PDF version](https://github.com/siko1056/optim-2021/blob/main/optim-2021.pdf)
- Repository: <https://github.com/siko1056/optim-2021>

[![mswin_octave_blas](/assets/blog/2022-01-11_gauss_hills.png)](/assets/blog/2022-01-11_gauss_hills.png)

```matlab
N = 3;
[X,Y] = meshgrid (linspace (-N, N, 40));

% Gaussian probability density function (PDF)
GAUSS = @(sigma, mu)  1 / (sigma * sqrt (2*pi)) * ...
                      exp (-0.5 * ((X - mu(1)).^2 + (Y - mu (2)).^2) / sigma^2);

Z = 9 * GAUSS (0.6, [ 0.0,  2.0]) + 5 * GAUSS (0.5, [ 1.0,  0.0]) ...
  + 3 * GAUSS (0.4, [-0.5,  0.0]) - 3 * GAUSS (0.3, [-1.5,  0.5]) ...
  - 7 * GAUSS (0.5, [ 0.0, -2.0]);

surf (X, Y, Z);
colormap ('jet');
view (-55, 21);
axis off;
```
