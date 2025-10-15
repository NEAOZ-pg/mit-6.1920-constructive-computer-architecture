# Concurrency Lab

## Setup

Clone your private repo by clicking on the green button that says "code". Next, click on SSH. Copy the ssh address. Now call `git clone git@github.com:6192-sp24/<lab>-<your github account name>.git`. You can paste the latter part of the command instead of typing it out, but it should be the same. Now move into the cloned directory to start working on the lab.

# Part 1: Step Counter

## Scenario

A certain professor claims to have discovered a particularly fast hedgehog, but is struggling to capture it. In hopes of finally catching it, they have designed a plan to calculate its speed and activity levels by placing a low-power
step counter on it. You have been contracted by this professor to develop this low-power step counter to suit their needs. Due to the speed they believe this hedgehog can reach,
they require that the design can set, read, and increment the value of the step counter simultaneously, within the same cycle. To achieve this, you start by designing a simple counter in hardware.

## Task

In `StepCounter.bsv`, we have provided a simple implementation of a counter module that only uses simple registers (`mkCounter`). This implementation fails to meet the requirement of setting, reading, and incrementing the current value simultaneously. **Why does it fail the requirement and how do the methods relate with regards to concurrency? Do any methods conflict? For the methods that don't conflict, what order do they execute within the same cycle? Include your answers in `StepCounter.bsv`.** To be able to meet the researchers requirement, we need to be able to call all three methods within a single cycle. We are tasking you with updating the provided implementation using Ehr registers to accomplish this. Fill in the module `mkCounterEhr` with your updated implementation.

## Design Specifications 

The interface StepCounter has three methods: `inc`, `cur`, and `set`.
- `inc`: Increment the current value by 1.
- `cur`: Return the current value.
- `set`: Set the current value.

These methods must be able to execute within the same cycle with the following concurrency relations:
```
set < inc
inc < cur
set < cur
```

In other words, `set` executes before `inc` and `inc` before `cur` (`set`<`inc`<`cur`). Use as many Ehr ports and registers as needed.

## Ehr Register Syntax

`Ehr#(3, Bit#(32)) example <- mkEhr(0);`

The above line instantiates a 3 port Ehr register of size 32 bits. The default value of this register is 0. When using the ports, the Ehr port `0` will be used before port `1` and port `1` before port `2`.

An example of this can be seen below:

```
Ehr#(3, Bit#(2)) cnt <- mkEhr(1);

method one:
    $display(cnt[0]);
    cnt[0] <= cnt[0] + 1;

method two:
    $display(cnt[1]);
    cnt[1] <= cnt[1] + 1;

method three:
    $display(cnt[2]);
    cnt[2] <= 1;

```

This example code will print `1 2 3` when all three methods are executed within a single cycle. Here, the concurrency relation is:

```
one < two
one < three
two < three
```

## Design Verification

To verify your design call `make StepCounterTest` on your command line. It should automatically re-compile your design if there are updates and
save the testbench output to the file `output.log`. It will also create a `mkCounterEhr.sched` file that you can inspect for the scheduling
information.

# Part 2: Completion Buffer

## Scenario A

With the help of your device, the professor has manged to finally capture the hedgehog he's been after. He then decides to take you out to eat to celebrate. While waiting on your food, you notice that people who arrived later than you have been served first. After a few more minutes, the owner of the restaurant finally comes out with your food. He apologizes to you about the wait and explains that his servers
and cooks are still trying to figure out a way to keep track of the orders once they are completed. Recalling the topics we cover in class, you explain the concept of a completion buffer to him as a way to solve his problem. The owner is delighted with your idea and contracts you to design for him a new system that implements a completion buffer.

## Completion Buffer Review

A completion buffer is used to keep track of multiple processes' identifiers and results. First, the completion buffer issues a unique identifier, or token, to a user. This reserves them a slot in the buffer 
or queue. Next, the user with the oldest token, or identifier, can request a result/response from the buffer. This action also releases the unique identifier for a new user to use. This type of system is described
as being First-In-First-Out (FIFO).

**With respect to the scenario, why is a completion buffer a well-suited solution? How might this system organize the waiters (the users) and the cooks (those who are responsible for creating and distributing the results/responses)?**

## Design Specification A

You begin by designing a simple completion buffer, without worrying about concurrency, in `CBuffer.bsv`. You decide on the following interface:

```
typedef Bit#(3) Token;
typedef Bit#(32) Response;

interface CBuffer;
    method ActionValue#(Token) getToken();
    method Action put(Token t, Response r);
    method ActionValue#(Response) getResponse();
endinterface

```

- `getToken`: This method should return a unique token to the user.
- `put`: This method should save `r` and associate it with the token, or user identifier, `t`.
- `getResponse`: This method should return the response, or result, associated with the oldest user, or token.

## Design Notes A

- You should use a single Vector to hold the responses for the tokens/users in your design. **What size should this Vector be to hold a response for every token/user?**
- Remember that the testbench will call the methods as soon as their guards are true. This means that you are responsible for making sure that the response/result associated with a token/user is valid/ready.
- Do not worry about `put` being called with an invalid token/user.
- Again, do NOT worry about concurrency for this design. Only use simple registers for this design.

## Design Verification A

You can test your code by running `make CBufferTest`. It should automatically re-compile your design if there are updates and
save the testbench output to the file `output.log`. It will also create a `mkCBufferReg.sched` file that you can inspect for the scheduling
information.

## Scenario B

After implementing your design, the restaurant's efficiency has dramatically increased. However, they are now running into issues doing multiple actions at once and would like to contract you again to improve the design. You decide to update your design to allow each method to occur simultaneously in the same cycle.

## Design Specification B

You begin by copying over your previous design into `CBufferEhr.bsv` (**Do this**). Without changing the logic of the methods, update them to no longer conflict.

**What are the current concurrency relations of your methods?**

Using only 2 port Ehr registers, create the following concurrency relations:

```
getToken < put 
getToken < getResponse
put < getResponse
```  

In other words, `getToken` executes before `put` and `put` before `getResponse` (`getToken`<`put`<`getResponse`). Again, you are limited to only 2 port EHRs.

## Design Verification B

You can test your code by running `make CBufferEhrTest`. It should automatically re-compile your design if there are updates and
save the testbench output to the file `output.log`. It will also create a `mkCBufferEhr.sched` file that you can inspect for the scheduling
information.

## Submission

To submit your completed lab we ask that you stage, commit, and push your changes to your repo. **Please include your entire working directory, including the output files, in your submission.**

To do this you should only need to call `make submit`. After doing so, your entire directory should be uploaded to your private git-repo on Github Classroom. Upon submission,
Github will automatically test & verify that your design runs correctly. You should see a green checkmark next to the commit titled "Save Changes & Submit" if your design passes Github's testcase. A yellow circle means the test is still pending and a red cross means the test failed. If your design passes locally, but not on Github, let the course staff know as this should not happen.

Please take some time to fill out the [feedback form](https://docs.google.com/forms/d/e/1FAIpQLSebf57zYacBZSh-ObykR0GLBqj8uJ6pKoKlmODVMXdS_aj3JA/viewform?usp=sf_link). We really appreciate it!

Should you need more guidance with git, please contact the course staff or see our piazza post: https://piazza.com/class/lrgt0dgrtpz590/post/27.

