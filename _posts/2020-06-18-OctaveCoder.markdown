---
layout: post
title:  "Testing the OctaveCoder"
date: 2020-06-18
categories: blog
tags:
  - octave
---

On June 4th there arrived an
[extraordinary mail by *Hossein*](https://lists.gnu.org/archive/html/octave-maintainers/2020-06/msg00027.html)
on the Octave maintainers mailing-list.
To my knowledge he has not been involved into Octave development so far.
He introduced shortly and convincingly
[OctaveCoder](https://github.com/shsajjadi/OctaveCoder):

> - Octave instructions, are translated to the intermediate Coder C++ API.
> - The Coder C++ API uses the Octave C++ API
>   and links against Octave core libraries.
> - Names and symbols are resolved at translation time
>   - no symbol table lookup at runtime
>   - no AST traversal at runtime
> - Speed-up is usually 3X - 4X relative to the interpreter.

OctaveCoder can be installed as usual Octave package:
```
pkg install https://github.com/shsajjadi/OctaveCoder/archive/coder-1.0.0-octave-5.2.0.tar.gz
```

## The test setup

To test the speed-up there is severe crime in the Octave language:
**"ijk Matrix multiplication"** using triply nested loops
```matlab
function C = matrix_mult (A, B)
  [m, r] = size (A);
  [R, n] = size (B);
  if (r != R)
    error ("matrix_mult: Bad arguments");
  endif

  C = zeros (m, n);
  for i = 1:m
    for j = 1:n
      for k = 1:r
        C(i,j) += A(i,k) * B(k,j);
      endfor
    endfor
  endfor
endfunction
```

As can be seen from a short test run,
even for rather small dimensions `matrix_mult.m` is by a factor of about
10,000 slower than Octave's builtin matrix multiplication.
```matlab
n = 30;
A = rand (2*n, n);
B = rand (n, 3*n);

tic; C1 = A * B; toc
Elapsed time is 0.000144958 seconds.

tic; C2 = matrix_mult (A, B); toc
Elapsed time is 1.72018 seconds.
```

The interpretation of Octave code as in `matrix_mult.m` is rather slow,
as many checks for index bounds, existing symbols, correct syntax, etc.
and lots of memory operations have to be performed.

If there is no builtin routine available in Octave,
as in the example above,
one can study the
[vectorization chapter](https://octave.org/doc/v5.2.0/Vectorization-and-Faster-Code-Execution.html)
in the Octave manual.

## The test result

OctaveCoder claims to speed-up things by factor three to four
and indeed succeeds:
```matlab
pkg load coder
octave2oct ("matrix_mult")

which matrix_mult
'matrix_mult' is a function from the file matrix_mult.oct

tic; C3 = matrix_mult (A, B); toc
Elapsed time is 0.54394 seconds.
```

What happens under the hood?
There is an option to keep intermediate files during the compilation
to an oct-file.
```matlab
octave2oct ("matrix_mult", "KeepSource", true)
```
The output is an about 5000 lines C++-file containing many class definitions
and strongly reminds of Octave's interpreter implementation.
According to the description by Hossein,
he implemented a "lightweight interpreter",
that does all symbol look-ups at compile time,
but still there is interpretation work left to be done.
The compiled file reacts dynamically on bad input, for example.

## Summary

- OctaveCoder keeps it's promise and speeds up ordinary Octave m-code
  by factor three to four.
- It seems like a viable solution,
  if vectorization is not applicable or translation to C/C++ too tedious.
- Until Octave finally gets a proper working
  [JIT compiler](https://wiki.octave.org/JIT)
  this solution can be really recommended.
