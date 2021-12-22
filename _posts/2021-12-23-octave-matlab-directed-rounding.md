---
layout: post
title:  "Using directed rounding in Octave/Matlab"
date:   2021-12-23
image: /assets/blog/2021-12-23_title_slide.png
categories: blog
tags:
  - octave
---

The current
[IEEE Standard for Floating-Point Arithmetic](https://en.wikipedia.org/wiki/IEEE_754)
specifies several rounding modes,
which have become accessible to the C/C++ programming languages
as part of the [C99](https://en.wikipedia.org/wiki/C99),
[C++11](https://en.wikipedia.org/wiki/C%2B%2B11), and following standards.
GNU Octave and Matlab use in general multi-threaded
[BLAS](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms)/
[LAPACK](https://en.wikipedia.org/wiki/LAPACK)
library functions for fast matrix-vector-computations.
Depending on the underlying library,
improper thread synchronization might lead to unreliable results,
when switching the rounding mode using C/C++ functions.
This article investigates how to reliably switch the rounding mode in
GNU Octave using the [OpenBLAS](https://www.openblas.net/) library
and problem mitigations for Matlab.


## Rounding modes: standards and implementations

Switching the rounding mode is an important tool in the design
of verification methods based on floating-point arithmetic.
The latter being only of **finite precision**,
numbers or computation results with "too long" fractional part
have to be **rounded** to a floating-point number,
i.e. a number that fits "nicely" into the computers memory.

The rules for rounding are defined by the
IEEE Standard for Floating-Point Arithmetic (IEEE-754 2019,
[doi: 10.1109/IEEESTD.2019.8766229](https://doi.org/10.1109/IEEESTD.2019.8766229)),
which the [C99](https://en.wikipedia.org/wiki/C99),
[C++11](https://en.wikipedia.org/wiki/C%2B%2B11),
and later C/C++ standards refer to in an older version.
Those rounding modes with respective C/C++ macros are:

- Roundings to nearest
  - `FE_TONEAREST` ("ties to even")
  - ("ties away from zero" is not available in C/C++)
- Directed roundings
  - `FE_TOWARDZERO` = towards zero
  - `FE_UPWARD`     = towards +infinity
  - `FE_DOWNWARD`   = towards -infinity

C/C++ functions using the macros above are:

- [`fesetround` and `fegetround`](https://en.cppreference.com/w/c/numeric/fenv/feround)
  for C99 and for C++11
- [`std::fesetround` and `std::fegetround`](https://en.cppreference.com/w/cpp/numeric/fenv/feround).

More details can be found in many excellent articles and books.
For example,
section 2.2, chapter 6, and sub-section 6.1.3
in Muller *et al.* "Handbook of Floating-Point Arithmetic" (2018,
([doi: 10.1007/978-3-319-76526-6](https://doi.org/10.1007/978-3-319-76526-6))
or the respective
[Wikipedia article](https://en.wikipedia.org/wiki/IEEE_754#Rounding_rules).


## Changing the rounding mode from Octave/Matlab

Finally,
the C function `fesetround` can be called from Octave/Matlab through the
[mex-file interface](https://octave.org/doc/v6.4.0/Getting-Started-with-Mex_002dFiles.html)
using the following code `setround.c`:

```c
#include <mex.h>
#include <fenv.h>
#include <float.h>

#pragma STDC FENV_ACCESS ON

void mexFunction ( int nlhs, mxArray *plhs[],
                   int nrhs, const mxArray *prhs[] ) {

  int rnd = (int) mxGetScalar (prhs[0]);
  int mode = FE_TONEAREST;

  switch (rnd)
    {
      case -1:
        mode = FE_DOWNWARD;
        break;
      case 0:
        mode = FE_TONEAREST;
        break;
      case 1:
        mode = FE_UPWARD;
        break;
      case 2:
        mode = FE_TOWARDZERO;
        break;
      default:
        mode = FE_TONEAREST;
        break;
    }

  fesetround (mode);
}

```
which can be compiled with:
```
mex --std=c11 setround.c                          % Octave
mex ('CFLAGS="$CFLAGS --std=c11"', 'setround.c')  % Matlab
```
Switching the rounding mode to +infinity would be done with the call:
```
setround (+1);
```
Other rounding modes are apparent form the mex-file.

This approach is most notably used by
[INTLAB](https://www.tuhh.de/ti3/rump/intlab/)
or the
[Interval package](https://gnu-octave.github.io/packages/interval).


## The issue: of scalars and parallel computed matrices

The function `setround` works fine for "small" computations,
that involve mostly scalars and are performed using a single computation thread.
However


https://www.tuhh.de/ti3/rump/intlab/Octave/INTLAB_for_GNU_Octave.shtml


http://verifiedby.me/adiary/?q=CONSISTENT_FPCSR&all=1


## Octave

### Microsoft Windows

It is assumed,
that
[octave-6.4.0-w64-installer.exe](https://ftpmirror.gnu.org/octave/windows/octave-6.4.0-w64-installer.exe)
from <https://www.octave.org/download> has been successfully installed.


#### Option 1 - Single computation thread (slow)

Go in the Windows Explorer to the GNU Octave installation folder,
for example:
```
C:\Octave\Octave-6.4.0\
```
and right-click on the `octave.vbs` ("edit")

[![mswin_octave_blas](/assets/blog/2021-12-23_mswin_octave_omp_num_threads.png)](/assets/blog/2021-12-23_mswin_octave_omp_num_threads.png)

and add in the text editor the line
```
wshSystemEnv("OMP_NUM_THREADS") = "1"
```
as shown in the screenshot above.


#### Option 2 - Replace `libblas.dll`

Download the file compiled
[dynamic-link library (DLL)](https://en.wikipedia.org/wiki/Dynamic-link_library)
for OpenBLAS:

- [libopenblasFPCSR-0.3.18.dll]()

Read the box below, how it can be created yourself.

Put this file in the directory
```
C:\Octave\Octave-6.4.0\mingw64\bin
```
like in the screenshot below:

[![mswin_octave_blas](/assets/blog/2021-12-23_mswin_octave_blas.png)](/assets/blog/2021-12-23_mswin_octave_blas.png)

> For the next two steps **administrator privileges** might be required.
> Click yes of you are prompted for confirmation.

Finally:
1. Delete the file `libblas.dll`.
2. Copy `libopenblasFPCSR-0.3.18.dll` and rename the copy to `libblas.dll`.

**Finished.**

> If you want to **undo this change**:
> 1. Deleting the file `libblas.dll` again.
> 2. copy `libopenblas.dll` and rename the copy to `libblas.dll`.

> **Some background**
>
>

### macOS

It is assumed,
that GNU Octave is installed via Homebrew <https://brew.sh/>:
```
brew install octave
```

#### Option 1 - Single computation thread (slow)

```
OMP_NUM_THREADS=1 octave --gui
```

#### Option 2 - Rebuild OpenBLAS

```
brew rm   openblas
brew edit openblas
```

```
brew reinstall --build-from-source openblas
```


### Linux

#### Option 1 - Single computation thread (slow)

```
OMP_NUM_THREADS=1 octave --gui
```


#### Option 2 - Rebuild OpenBLAS

`CONSISTENT_FPCSR=1`


## Matlab

In an
[undocumented `feature`-function](https://undocumentedmatlab.com/articles/undocumented-feature-function)
Matlab offers an implementation,
similar to `setround` above:
```
feature ('setround', mode);  % mode = 0, 0.5, +Inf, or -Inf
```

However,
this function has the same limitations as `setround`
and as it is no official function,
it is not expected to work reliably.
With every new Matlab release the thread synchronization
of the underlying
[Intel MKL](https://en.wikipedia.org/wiki/Math_Kernel_Library)

A known reliable workaround is to force Matlab to only use a single
computations thread with the startup option `-singleCompThread`.
This works on
[MS Windows](https://www.mathworks.com/help/matlab/ref/matlabwindows.html),
[macOS](https://www.mathworks.com/help/matlab/ref/matlabmacos.html), and
[Linux](https://www.mathworks.com/help/matlab/ref/matlablinux.html).


## Summary

TODO




