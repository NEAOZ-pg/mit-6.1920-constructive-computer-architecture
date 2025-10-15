# 6.192[6.175] Lab 1_a Part 1

Complete the exercises below, answering the questions in the answers.txt file provided. Please also track how much time you spend on these exercises.

## Warmup: Arithmetic and Logic Unit

Write a little 4 operations ALU in `Alu.bsv`. You can use the Bluespec primitives operators (+, << , &, ~).

The operations are:

Add: Add v1, v2
ShiftL: Shift v1 left by the amount specified by v2
And: Bitwise AND v1, v2
Not: Bitwise NOT v1

You can test your ALU by doing: 
```
make
./AluTest
``` 

## Arbiter 

### General motivation 
Implement an arbiter in `CombArbiter.bsv`.
A typical recurring problem in computer architecture is having multiple machines that produce results at different rate in parallel, and we want to merge the multiple streams of result into a single stream of result.
For example 16 machines each take ~16 cycles to produce a result. Conceptually, we should be able to produce a single stream that would have an average of ~1 result per cycle.

### Implementation
In this small exercise, we tackle a small subproblem of this generic problem: given two sets of values (ready and data, which would correspond to when the machines are ready to produce a result, and the corresponding result produced), generate a circuit that extracts an index (if any exists) that currently has a valid result, and extract its result. The circuit should also identify when no value is ready.

It's good to think about tradeoffs in performance, but in this exercise we are checking only for correctness.

Fill out the code within `CombArbiter.bsv`:

```
function ResultArbiter arbitrate(Vector#(16, Bit#(1)) ready, Vector#(16, Bit#(31)) data);
	return ResultArbiter{valid: False, data : 0, index: 0};
	// TODO
endfunction
```

To test your code you can do:
```
make
./ArbiterTest
```

## Shifters

### Barrel shifter
In `Shifter.bsv` we gave a reference implementation of a naive left-shifter for vectors:

```
function Vector#(16, Word) naiveShfl(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) resultVector = in; 
    for (Integer i = 0; i < 16; i = i + 1) begin
        Bit#(4) idx = fromInteger(i);
        resultVector[i] = in[shftAmnt+idx];
    end
    return resultVector;
endfunction
```

_Question:_ If `shftAmnt` is dynamic (nonconstant), count the number of selectors (and their size) of `naiveShfl(in, shftAmnt)`.

_Question:_ If `shftAmnt` is constant (for example 0b0100), count the number of selectors (and their size) of `naiveShfl(in, shftAmnt)`.

_Implementation_: Recall from 6.191 the concept of a [barrel shifter](https://en.wikipedia.org/wiki/Barrel_shifter), which contains several constant shifters and uses them based on `shftAmnt`. Implement a barrel shifter that shifts to the left in the body of `barrelLeft` in `Shift.bsv`.

Note: For Vectors, indices increase to the right, as opposed to Bits where indices increase to the left.

Note: You may be accustomed to parametric functions in Minispec, which are used to reduce repetition in your code (e.g., so you can write one function that you can turn into 8-bit version, 16-bit version, etc.). Unfortunately, parametric functions in that syntax are a Minispec exclusive. The similar feature in Bluespec (polymorphism) is more complicated, so we ask that you not worry about repeating yourself for this exercise.

_Question:_ Count the number of selectors (and their size) of your barrel shifter

```
make
./ShifterTest    # This last command should print "Left barrel shifter test passed" if it works
```

_Curiosity question (not graded)_:
You learned about modules in the second lecture when we covered sequential circuits. How do we decide when to use a module versus when to use a function?

---

Once you have finished this part, remember to move onto the second part. And be sure to record how much time you spent on this part.