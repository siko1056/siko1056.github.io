---
layout: post
title:  "Using directed rounding in Octave/Matlab"
date:   2021-12-23
image: /assets/blog/2021-12-23_mswin_octave_blas_small.png
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
Depending on the used library,
improper thread synchronization might lead to unreliable results
when switching the rounding mode using C/C++ functions.
This article investigates how to reliably switch the rounding mode in
GNU Octave using the performant [OpenBLAS](https://www.openblas.net/) library
and last resort problem mitigations for Matlab.


## Rounding modes: standards and implementations

Switching the rounding mode is an important tool
used by many verification methods based on floating-point arithmetic.
The latter being only of **finite precision**,
input data or results of numerical computations
with "too long" fractional part
have to be **rounded** to a
[floating-point number](https://en.wikipedia.org/wiki/Floating-point_arithmetic),
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

- since C99 [`fesetround` and `fegetround`](https://en.cppreference.com/w/c/numeric/fenv/feround)
- since C++11 [`std::fesetround` and `std::fegetround`](https://en.cppreference.com/w/cpp/numeric/fenv/feround).

Under the hood,
for example in the GNU C library (glibc 2.34) the functions
[fesetround.c](https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/fpu/fesetround.c;h=2d3f1ca3c6102d06cfec0b8e64b807b750289467;hb=refs/heads/release/2.34/master)
and
[fegetround.c](https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/fpu/fegetround.c;h=0039987696f335f289d163bc4412b5d97698ee70;hb=refs/heads/release/2.34/master)
modify or read the active rounding mode from the **global**
[x87 FPU Control Status Register](https://en.wikipedia.org/wiki/X87)
and
[SSE Control Status Register (MXCSR)](https://en.wikipedia.org/wiki/Streaming_SIMD_Extensions#Registers).
The state of those registers is part of a running process.
During a [process context switch](https://en.wikipedia.org/wiki/Context_switch)
the register state (and thus the active rounding mode)
is usually saved and restored properly.

With gaining popularity of multi-core processors,
using light-weight **threads** has become more popular in software design.
Context switches for threads are designed to be fast.
For the sake of performance and depending on the implementation,
some register states are not properly synchronized
or at worst (partially) reset or cleared.

To overcome implementation-dependency,
software libraries like BLAS/LAPACK have to manually take care of
synchronizing those register states when starting a new thread.
The situation for OpenBLAS is described below.

Further details about the specification and implementation
of floating-point arithmetic can be found in many excellent articles and books.
To name an exceptional all-encompassing source of information,
see section 2.2, sub-section 3.4.4, chapter 6, and sub-section 6.1.3
in Muller *et al.* "Handbook of Floating-Point Arithmetic" (2018,
[doi: 10.1007/978-3-319-76526-6](https://doi.org/10.1007/978-3-319-76526-6))
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
See `setround.c` for analogous calls for other rounding modes.

This approach of switching the rounding mode is most notably used by
[INTLAB](https://www.tuhh.de/ti3/rump/intlab/)
or the
[Interval package](https://gnu-octave.github.io/packages/interval).


## The issue: parallel matrix computation

For "small" (single-threaded) computations (thus mostly scalars)
the function `setround` works fine.

```matlab
e = eps () * eps ();  % smaller than machine precision
setround (+1);        % round to +inf
num2hex (1 + e)
ans = 3ff0000000000001

setround (-1);        % round to -inf
num2hex (1 + e)
ans = 3ff0000000000000
```

However,
the strength of Octave and Matlab is the ease and speed
of matrix and vector computations.
Therefore,
it is desirable to perform those calculations
using directed rounding modes as well.

```matlab
e = eps () * eps ();  % smaller than machine precision
setround (+1);        % round to +inf
a = ones(100) + e;
a_sup = a * a;        % use BLAS (multi-threaded)

setround (-1);        % round to -inf
a_inf = a * a;        % use BLAS (multi-threaded)

% The following value must be "0" (all values differ),
% if rounding mode switching works correctly.
sum (a_inf(:) == a_sup(:))
```

As outlined above,
Octave and Matlab use in general multi-threaded BLAS/LAPACK implementations
for matrix and vector computations.
The thread synchronization of the rounding mode
(in the global register state)
is often neglected by those BLAS/LAPACK implementations
for the sake of performance
and the code listing above returns a value larger than 0
(which means computing with `setround (+1)` or `setround (-1)`
makes no difference at all).

For example OpenBLAS offers an **optional** compile flag
[`CONSISTENT_FPCSR = 1`](https://github.com/xianyi/OpenBLAS/blob/253670383f15cd4d25c6be6b210dfa48a6dcc883/Makefile.rule#L210-L211)
for manual rounding mode synchronization.
See
[`driver/others/blas_server_omp.c`](https://github.com/xianyi/OpenBLAS/blob/253670383f15cd4d25c6be6b210dfa48a6dcc883/driver/others/blas_server_omp.c#L284-L287):

```c
static void exec_threads(blas_queue_t *queue, int buf_index){

// ...

#ifdef CONSISTENT_FPCSR
  __asm__ __volatile__ ("ldmxcsr %0" : : "m" (queue -> sse_mode));
  __asm__ __volatile__ ("fldcw %0"   : : "m" (queue -> x87_mode));
#endif
```

Using this compile flag has already been suggested by
[Masahide Kashiwagi](http://verifiedby.me/adiary/?q=CONSISTENT_FPCSR&all=1)
and by
[INTLAB](https://www.tuhh.de/ti3/rump/intlab/Octave/INTLAB_for_GNU_Octave.shtml).

However,
most Linux distributions provide OpenBLAS libraries
without this compile flag set.
And the situation seems similar for other
BLAS/LAPACK implementations like the
[Intel MKL](https://en.wikipedia.org/wiki/Math_Kernel_Library).

Therefore the remainder of this article deals with
how to replace the default OpenBLAS version with a custom one
compiled with the `CONSISTENT_FPCSR=1` flag set and,
alternatively,
how to ensure that only a single computation thread is used
in Octave and Matlab,
a slow and impractical last resort solution.


## Octave on Microsoft Windows

It is assumed,
that
[octave-6.4.0-w64-installer.exe](https://ftpmirror.gnu.org/octave/windows/octave-6.4.0-w64-installer.exe)
from <https://www.octave.org/download> has been successfully installed.


### Option 1 - Single computation thread (slow)

Go in the Windows Explorer to the GNU Octave installation folder,
for example:
```
C:\Octave\Octave-6.4.0\
```
and right-click on the `octave.vbs` ("edit"):

[![mswin_octave_blas](/assets/blog/2021-12-23_mswin_octave_omp_num_threads.png)](/assets/blog/2021-12-23_mswin_octave_omp_num_threads.png)

and add in the text editor the line:
```
wshSystemEnv("OMP_NUM_THREADS") = "1"
```
as shown in the screenshot above and start Octave as usual.


### Option 2 - Replace `libblas.dll`

Download the file compiled
[dynamic-link library (DLL)](https://en.wikipedia.org/wiki/Dynamic-link_library)
for OpenBLAS:

- [libopenblasFPCSR-0.3.18.dll](/assets/blog/2021/libopenblasFPCSR-0.3.18.dll)
  Below the DLL-file creation is described.

> For the next steps **administrator privileges** might be required.
> Click yes of you are prompted for confirmation.

Put the DLL-file in the directory
```
C:\Octave\Octave-6.4.0\mingw64\bin
```
like in the screenshot below:

[![mswin_octave_blas](/assets/blog/2021-12-23_mswin_octave_blas.png)](/assets/blog/2021-12-23_mswin_octave_blas.png)

Delete the file `libblas.dll`.

Copy `libopenblasFPCSR-0.3.18.dll` and rename the copy to `libblas.dll`.

> If you want to **undo this change**:
> Delete the file `libblas.dll` again.
>
> Copy `libopenblas.dll` and rename the copy to `libblas.dll`.

> **How to create `libopenblasFPCSR-0.3.18.dll`**
>
> One can make use of the
> [MXE Octave](https://wiki.octave.org/Windows_Installer)
> project to cross-compile Octave for MS Windows **on Linux**.
> ```
> hg clone https://hg.octave.org/mxe-octave
> cd mxe-octave
> ./bootstrap
> ./configure                        \
>   --enable-devel-tools             \
>   --enable-binary-packages         \
>   --with-ccache                    \
>   --enable-octave=release
> ```
> Edit the file
> [`mxe-octave/src/openblas.mk`](https://hg.octave.org/mxe-octave/file/6f8def83bcf7/src/openblas.mk#l27)
> and add about line 28 to `$(PKG)_MAKE_OPTS` the compile flag
> `CONSISTENT_FPCSR=1`.
>
> Then compile the project (this might take a few hours):
> ```
> make JOBS=8 all openblas
> ```
> Finally find the OpenBLAS DLL in:
> ```
> mxe-octave//usr/x86_64-w64-mingw32/bin/libopenblas.dll
> ```
> Rename and use it as described above.

## Octave on macOS

It is assumed,
that GNU Octave is installed via Homebrew <https://brew.sh/>:
```
brew install octave
```

### Option 1 - Single computation thread (slow)

Start Octave from the Terminal with this command:

```
OMP_NUM_THREADS=1 octave --gui
```

### Option 2 - Rebuild OpenBLAS

Edit the Homebrew Formula for OpenBLAS:
```
export EDITOR="open -a TextEdit"
brew edit openblas
```
and add the line
```
ENV["CONSISTENT_FPCSR"] = "1"
```
like in the screenshot below:

[![macos_openblas](/assets/blog/2021-12-23_macos_openblas.png)](/assets/blog/2021-12-23_macos_openblas.png)

Finally run from the Terminal:
```
brew uninstall --ignore-dependencies openblas
brew reinstall --build-from-source   openblas
```
The compilation and installation might take about 15-20 minutes.

> If you want to **undo this change**:
>
> ```
> cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
> git restore Formula/openblas.rb
> brew uninstall --ignore-dependencies openblas
> brew install openblas
> ```


## Octave on Linux

### Option 1 - Single computation thread (slow)

Start Octave from the Terminal with this command:

```
OMP_NUM_THREADS=1 octave --gui
```


### Option 2 - Rebuild OpenBLAS

> **Note:** This approach does not work with Snap, Flatpak, or Docker
> installations of GNU Octave.

Download and extract the OpenBLAS source code:
```
cd /tmp
wget https://github.com/xianyi/OpenBLAS/archive/refs/tags/v0.3.19.tar.gz
tar -xf v0.3.19.tar.gz
cd OpenBLAS-0.3.19
```
Build OpenBLAS (note: if you compiled Octave with
[ilp64](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models)
add the flags `BINARY=64 INTERFACE64=1` to the `make` command)
this should take about 5-10 minutes:
```
make -j8             \
  CONSISTENT_FPCSR=1 \
  USE_THREAD=1       \
  USE_OPENMP=1       \
  NUM_THREADS=256
```
Then locally install the library:
```
make install PREFIX=$HOME
```
Finally start Octave with this command
(the part `_haswell` might differ depending on the used CPU):
```
LD_PRELOAD=$HOME/lib/libopenblas_haswellp-r0.3.19.so octave --gui
>> version -blas
ans = OpenBLAS (config: OpenBLAS 0.3.19 NO_AFFINITY USE_OPENMP HASWELL MAX_THREADS=256)
```

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
works more of less reliable.
At the time of writing,
Matlab R2020b is known to work,
while Matlab R2021a is not.

A known reliable workaround is to force Matlab to only use a single
computations thread with the startup option `-singleCompThread`.
This works on
[MS Windows](https://www.mathworks.com/help/matlab/ref/matlabwindows.html),
[macOS](https://www.mathworks.com/help/matlab/ref/matlabmacos.html), and
[Linux](https://www.mathworks.com/help/matlab/ref/matlablinux.html).


## Summary

In this blog post the issue of reliably changing the rounding mode
for basic linear algebra operations
within multi-threaded BLAS/LAPACK libraries using C/C++ instructions
from Octave and Matlab was investigated.

While Octave can address this problem by using a customized OpenBLAS
or slower reference BLAS/LAPACK implementation,
each Matlab release must be evaluated for limitations of the underlying
Intel MKL.
A solution of last resort for both Octave and Matlab
is enforcing a single computation thread,
sacrificing all benefits of having multiple CPU cores available.

The proposed solutions do not apply for
[graphics processing units (GPUs)](https://en.wikipedia.org/wiki/Graphics_processing_unit),
and associated numerical libraries,
as the architecture and command set differs significantly from the CPU.



