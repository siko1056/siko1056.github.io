## Using Octave
#
# First, follow the
# <https://www.gnu.org/software/octave/doc/interpreter/Installation.html installation guide>
# to install GNU Octave on your system.  Then, launch the interactive prompt by
# typing |octave| in a terminal or by clicking the icon in the programs menu.
# For further guidance, see the manual page on
# <https://www.gnu.org/software/octave/doc/interpreter/Running-Octave.html Running Octave>.
#
##

## Variable Assignment
#
# Assign values to variables with |=| (Note: assignment is _pass-by-value_).
# Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Variables.html about variables>.
#

a = 1;

## Comments
#
# |#| or |%| start a comment line, that continues to the end of the line.
# Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Comments.html about comments>.
#

## Command evaluation
#
# The output of every command is printed to the console unless terminated with
# a semicolon |;|.  The <octave:disp disp> command can be used to print output
# anywhere.  Use <octave:quit exit> or <octave:quit quit> to quit the console.
# Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Simple-Examples.html about command evaluation>.
#

t = 99 + 1  # prints 't = 100'

##

t = 99 + 1; # nothing is printed
disp(t);

## Elementary math
#
# Many mathematical operators are available in addition to the standard
# arithmetic.  Operations are floating-point.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Arithmetic.html about elementary math>.
#

x = 3/4 * pi;
y = sin (x)

## Matrices
#
# Arrays in Octave are called matrices.  One-dimensional matrices are referred
# to as vectors.  Use a space or a comma |,| to separate elements in a row and
# semicolon |;| to start a new row.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Linear-Algebra.html about matrices>.
#

rowVec = [8 6 4]

##

columnVec = [8; 6; 4]

##

mat = [8 6 4; 2 0 -2]

##

size(mat)

##

length(rowVec)

## Linear Algebra
#
# Many common linear algebra operations are simple to program using Octave’s
# matrix syntax.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Linear-Algebra.html about linear algebra>.
#

columnVec * rowVec

##

rowVec * columnVec

##

columnVec'

## Accessing Elements
#
# Octave is 1-indexed.  Matrix elements are accessed as
# |matrix(rowNum, columnNum)|.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Index-Expressions.html about accessing elements>.
#

mat(2,3)

## Control flow wih loops
#
# Octave supports |for| and |while| loops, as well as other control flow
# structures.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Statements.html about control flow>.
#

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

## Vectorization
#
# For-loops can often be replaced or simplified using vector syntax.  The
# operators |*|, |/|, and |^| all support element-wise operations writing
# a dot |.| before the operators.  Many other functions operate element-wise
# by default (<octave:sin sin>, |+|, |-|, etc.).  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Vectorization-and-Faster-Code-Execution.html about vectorization>.
#

i = 1:2:100;      # create an array with 50-elements
x = i.^2;         # each element is squared
y = x + 9;        # add 9 to each element
z = y./i;         # divide each element in y by the corresponding value in i
w = sin (i / 10); # take the sine of each element divided by 10

## Plotting
#
# The function <octave:plot plot> can be called with vector arguments to
# create 2D line and scatter plots.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Two_002dDimensional-Plots.html about plotting>.
#

plot (i / 10, w);
title ('w = sin (i / 10)');
xlabel ('i / 10');
ylabel ('w');

## Strings
#
# Strings are simply arrays of characters.  Strings can be composed using
# C-style formatting with <octave:sprintf sprintf> or
# <octave:fprintf fprintf>.  Read more
# <https://www.gnu.org/software/octave/doc/interpreter/Strings.html about strings>.
#

firstString = "hello world";
secondString = "!";
[firstString, secondString] # concatenate both strings

##

fprintf ("%s %.10f \n", "The number is:", 10)

## If-else
#
# Conditional statements can be used to create branching logic in your code.
# Read more
# <https://www.gnu.org/software/octave/doc/interpreter/The-if-Statement.html in the manual>.
#

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

## Getting Help
#
# The <octave:help help> and <octave:doc doc> commands can be invoked at the
# Octave prompt to print documentation for any function.
#
#   help plot
#   doc plot
#

## Octave forge packages
#
# Community-developed packages can be added from the
# <http://octave.sourceforge.net/index.html Octave Forge> website to extend
# the functionality of Octave’s core library.  (Matlab users: Forge packages
# act similarly to Matlab’s toolboxes.)  The <octave:pkg pkg> command is used
# to manage these packages.  For example, to use the image processing library
# from the Forge, use:
#
#   pkg install -forge image # install package
#   pkg load image           # load new functions into workspace
#
# <https://www.gnu.org/software/octave/doc/interpreter/Packages.html Read more about packages>.
#
