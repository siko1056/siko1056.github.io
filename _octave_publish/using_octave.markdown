---
layout: post
title: Using Octave
date: 2016-11-11
---


First, follow the
[installation guide](https://www.gnu.org/software/octave/doc/interpreter/Installation.html)
to install GNU Octave on your system.  Then, launch the interactive prompt by
typing `octave` in a terminal or by clicking the icon in the programs menu.
For further guidance, see the manual page on
[Running Octave](https://www.gnu.org/software/octave/doc/interpreter/Running-Octave.html).

* TOC
{:toc}


# Variable Assignment

Assign values to variables with `=` (Note: assignment is *pass-by-value*).
Read more
[about variables](https://www.gnu.org/software/octave/doc/interpreter/Variables.html).

{% highlight octave %}
a = 1;
{% endhighlight %}

{% highlight text %}

{% endhighlight %}

# Comments

`#` or `%` start a comment line, that continues to the end of the line.
Read more
[about comments](https://www.gnu.org/software/octave/doc/interpreter/Comments.html).

# Command evaluation

The output of every command is printed to the console unless terminated with
a semicolon `;`.  The [disp](https://www.gnu.org/software/octave/doc/interpreter/XREFdisp.html) command can be used to print output
anywhere.  Use [exit](https://www.gnu.org/software/octave/doc/interpreter/XREFquit.html) or [quit](https://www.gnu.org/software/octave/doc/interpreter/XREFquit.html) to quit the console.
Read more
[about command evaluation](https://www.gnu.org/software/octave/doc/interpreter/Simple-Examples.html).

{% highlight octave %}
t = 99 + 1  # prints 't = 100'
{% endhighlight %}

{% highlight text %}
t =  100

{% endhighlight %}

{% highlight octave %}
t = 99 + 1; # nothing is printed
disp(t);
{% endhighlight %}

{% highlight text %}
 100

{% endhighlight %}

# Elementary math

Many mathematical operators are available in addition to the standard
arithmetic.  Operations are floating-point.  Read more
[about elementary math](https://www.gnu.org/software/octave/doc/interpreter/Arithmetic.html).

{% highlight octave %}
x = 3/4 * pi;
y = sin (x)
{% endhighlight %}

{% highlight text %}
y =  0.70711

{% endhighlight %}

# Matrices

Arrays in Octave are called matrices.  One-dimensional matrices are referred
to as vectors.  Use a space or a comma `,` to separate elements in a row and
semicolon `;` to start a new row.  Read more
[about matrices](https://www.gnu.org/software/octave/doc/interpreter/Linear-Algebra.html).

{% highlight octave %}
rowVec = [8 6 4]
{% endhighlight %}

{% highlight text %}
rowVec =
   8   6   4

{% endhighlight %}

{% highlight octave %}
columnVec = [8; 6; 4]
{% endhighlight %}

{% highlight text %}
columnVec =
   8
   6
   4

{% endhighlight %}

{% highlight octave %}
mat = [8 6 4; 2 0 -2]
{% endhighlight %}

{% highlight text %}
mat =
   8   6   4
   2   0  -2

{% endhighlight %}

{% highlight octave %}
size(mat)
{% endhighlight %}

{% highlight text %}
ans =
   2   3

{% endhighlight %}

{% highlight octave %}
length(rowVec)
{% endhighlight %}

{% highlight text %}
ans =  3

{% endhighlight %}

# Linear Algebra

Many common linear algebra operations are simple to program using Octave’s
matrix syntax.  Read more
[about linear algebra](https://www.gnu.org/software/octave/doc/interpreter/Linear-Algebra.html).

{% highlight octave %}
columnVec * rowVec
{% endhighlight %}

{% highlight text %}
ans =
   64   48   32
   48   36   24
   32   24   16

{% endhighlight %}

{% highlight octave %}
rowVec * columnVec
{% endhighlight %}

{% highlight text %}
ans =  116

{% endhighlight %}

{% highlight octave %}
columnVec'
{% endhighlight %}

{% highlight text %}
ans =
   8   6   4

{% endhighlight %}

# Accessing Elements

Octave is 1-indexed.  Matrix elements are accessed as
`matrix(rowNum, columnNum)`.  Read more
[about accessing elements](https://www.gnu.org/software/octave/doc/interpreter/Index-Expressions.html).

{% highlight octave %}
mat(2,3)
{% endhighlight %}

{% highlight text %}
ans = -2

{% endhighlight %}

# Control flow wih loops

Octave supports `for` and `while` loops, as well as other control flow
structures.  Read more
[about control flow](https://www.gnu.org/software/octave/doc/interpreter/Statements.html).

{% highlight octave %}
x = zeros (50,1);
for i = 1:2:100 # iterate from 1 to 100 with step size 2
  x(i) = i^2;
endfor

y = zeros (50,1);
k = 1;
step = 2;
while (k <= (100-step))
  y(i) = k^2;
  k = k + step;
endwhile
{% endhighlight %}

{% highlight text %}

{% endhighlight %}

# Vectorization

For-loops can often be replaced or simplified using vector syntax.  The
operators `*`, `/`, and `^` all support element-wise operations writing
a dot `.` before the operators.  Many other functions operate element-wise
by default ([sin](https://www.gnu.org/software/octave/doc/interpreter/XREFsin.html), `+`, `-`, etc.).  Read more
[about vectorization](https://www.gnu.org/software/octave/doc/interpreter/Vectorization-and-Faster-Code-Execution.html).

{% highlight octave %}
i = 1:2:100;      # create an array with 50-elements
x = i.^2;         # each element is squared
y = x + 9;        # add 9 to each element
z = y./i;         # divide each element in y by the corresponding value in i
w = sin (i / 10); # take the sine of each element divided by 10
{% endhighlight %}

{% highlight text %}

{% endhighlight %}

# Plotting

The function [plot](https://www.gnu.org/software/octave/doc/interpreter/XREFplot.html) can be called with vector arguments to
create 2D line and scatter plots.  Read more
[about plotting](https://www.gnu.org/software/octave/doc/interpreter/Two_002dDimensional-Plots.html).

{% highlight octave %}
plot (i / 10, w);
title ('w = sin (i / 10)');
xlabel ('i / 10');
ylabel ('w');
{% endhighlight %}

{% highlight text %}

{% endhighlight %}
![/src/octave/html/using_octave-1.png](/src/octave/html/using_octave-1.png)
# Strings

Strings are simply arrays of characters.  Strings can be composed using
C-style formatting with [sprintf](https://www.gnu.org/software/octave/doc/interpreter/XREFsprintf.html) or
[fprintf](https://www.gnu.org/software/octave/doc/interpreter/XREFfprintf.html).  Read more
[about strings](https://www.gnu.org/software/octave/doc/interpreter/Strings.html).

{% highlight octave %}
firstString = "hello world";
secondString = "!";
[firstString, secondString] # concatenate both strings
{% endhighlight %}

{% highlight text %}
ans = hello world!

{% endhighlight %}

{% highlight octave %}
fprintf ("%s %.10f \n", "The number is:", 10)
{% endhighlight %}

{% highlight text %}
The number is: 10.0000000000 

{% endhighlight %}

# If-else

Conditional statements can be used to create branching logic in your code.
Read more
[in the manual](https://www.gnu.org/software/octave/doc/interpreter/The-if-Statement.html).

{% highlight octave %}
# Print 'Foo'      if divisible by 7,
#       'Fizz'     if divisible by 3,
#       'Buzz'     if divisible by 5,
#       'FizzBuzz' if divisible by 3 and 5
for i = 1:1:20
  outputString = "";
  if (rem (i, 3) == 0)  # rem is the remainder function
    outputString = [outputString, "Fizz"];
  endif
  if (rem (i, 5) == 0)
    outputString = [outputString, "Buzz"];
  elseif (rem(i,7) == 0)
    outputString = "Foo";
  else
    outputString = outputString;
  endif
  fprintf("i=%g: %s \n", i, outputString);
endfor
{% endhighlight %}

{% highlight text %}
i=1:  
i=2:  
i=3: Fizz 
i=4:  
i=5: Buzz 
i=6: Fizz 
i=7: Foo 
i=8:  
i=9: Fizz 
i=10: Buzz 
i=11:  
i=12: Fizz 
i=13:  
i=14: Foo 
i=15: FizzBuzz 
i=16:  
i=17:  
i=18: Fizz 
i=19:  
i=20: Buzz 

{% endhighlight %}

# Getting Help

The [help](https://www.gnu.org/software/octave/doc/interpreter/XREFhelp.html) and [doc](https://www.gnu.org/software/octave/doc/interpreter/XREFdoc.html) commands can be invoked at the
Octave prompt to print documentation for any function.

{% highlight octave %}
help plot
doc plot
{% endhighlight %}

# Octave forge packages

Community-developed packages can be added from the
[Octave Forge](http://octave.sourceforge.net/index.html) website to extend
the functionality of Octave’s core library.  (Matlab users: Forge packages
act similarly to Matlab’s toolboxes.)  The [pkg](https://www.gnu.org/software/octave/doc/interpreter/XREFpkg.html) command is used
to manage these packages.  For example, to use the image processing library
from the Forge, use:

{% highlight octave %}
pkg install -forge image # install package
pkg load image           # load new functions into workspace
{% endhighlight %}

[Read more about packages](https://www.gnu.org/software/octave/doc/interpreter/Packages.html).


Published with GNU Octave 4.2.0-rc4