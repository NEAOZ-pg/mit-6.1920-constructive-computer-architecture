# 6.192[6.175] Lab 1_a Part 2

## Introduction
This part of the lab involves debugging and fixing a buggy version of a Vector [dot product](https://en.wikipedia.org/wiki/Dot_product). Given two vectors, the code should return $A\cdot B$, following a normal vector product method (i.e. $ A_1*B_1+A_2*B_2+\dots+A_n*B_n $).

[non-LaTeX: `A · B = a_1·b_1 + a_2·b_2 + ... + a_n·b_n` ; where A, B are vectors of length n, and a_i and b_i are scalars.]

The buggy code is stored in `VectorDot.bsv`, with a provided test bench in `TbVD.bsv`.

Please fix the code such that it passes all four (0->3) test cases in the test bench. Write a brief comment in the code `//` near each bug you find explaining the issue. Also please track how much time you spend on this component of the lab.

## Specifications

We have provided an interface for you
```verilog
interface VD;
    method Action start(Bit#(8) dim_in, Bit#(2) i);
    method ActionValue#(Bit#(32)) response();
endinterface
```
The test bench will call the method `start` with the starting dimension `dim_in`, e.g. 16 for a 16 length vector A and B and the vector index `i`.  (Ungraded: What is the largest length of vector this interface could compute for?)

Assume vector A and B are the same size. Vector A is stored in `v1.hex` and B is in `v2.hex`. Each contains a series of vectors, three 16-dimension vectors to be precise, in sequential order. The start of each vector is at `vector_id*dimension`. The expected dot product of each vector is stored in `v3.hex` for each corresponding pair of vectors. Note that all files are in hexadecimal even if not apparent.

Assume dimension is constant, but do not hard code any number that is given as an input. The index can vary.

Please keep the structure of the code as close as possible. This code is structured into three, generally mutually exclusive, rules.

```verilog
rule process_a (ready_start && !done_a && !req_a_ready);
rule process_b (ready_start && !done_b && !req_b_ready);
rule mult_inputs (req_a_ready && req_b_ready && !done_all);
```
These rules should read from BRAM for vectors A and B respectively, then merge results (i.e. multiply) after reading (third rule).

The method `response()` should give the result of the dot product when operations are finished.

## Running the code

```
make
./TbVD
```

It should not run to completion if you made no edits.

## Kinds of Bugs

There are 5 main bugs you are looking for. These can be initialization, logic, arithmetic, and/or similar bugs. Note that bugs in bluespec can prevent code from running at all. For instance, this code will just hang, unmodified. You should check when these issues arise and what is causing it to hang.

## Debug Tips

We recommend to use `$display()` commands to display variables to find bugs. Are the values what you expect?

Display works similar to python `print` and C [`printf`](https://en.wikipedia.org/wiki/Printf). It accepts formatting keywords like `printf` does, such as `%d` for decimal, `%x` for hex, etc.

Both of these will print the variable x in decimal.
```verilog
$display("testing variable %d", x);
$display("testing variable", x);
```

or if you have multiple variables you'd like to print,
```verilog
let c = a + b;
$display("%d + %d = %d", a, b, c);
```

You may also want to draw out a small example (e.g., maybe for a length 4 vector) and do a dot product by hand.

You may also want to sketch out a small [finite state machine](https://en.wikipedia.org/wiki/Finite-state_machine) that models the state transitions in the module, and where signals are written and read. How do these rules and methods interact with each other?

Make sure you understand the BRAM request-response interface.

## Submit

Once you have discovered, fixed, and annotated the bugs, refer back to the main README. Be sure to record time spent.

## Getting Help

As always post on piazza or come to office hours. This is a newly developed lab. While we hope we were thorough, there may be things we missed.
