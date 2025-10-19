# Lab 3b -- Caches + Processor

This section of the lab will involve connecting your caches into your processor from labs 2b and 3a.

Start by copying `pipelined.bsv` from lab2_b into this lab. Then copy `Cache32.bsv`, `Cache512.bsv`, and your updated `MemTypes.bsv` from lab3_a into this lab.

Note: if you did not finish lab2_b, you can copy the contents of `multicycle.bsv` into `pipelined.bsv` instead (albeit renaming appropriate things). You will want to eventually finish `lab2_b` since the rest of the semester builds upon it (and this!).

## Your goal

You will need to populate `CacheInterface.bsv` with proper instruction and data L1 caches that connect to a shared L2 cache, which in turn connects to main memory. Almost all your changes will be to this file.

This should look like:
```
      MAIN MEM
          |
         L2
     -----|-----
    |           |
  IMEM L1    DMEM L1
    |           |
    -----||------
         ||    
      Processor
```

You want two L1 (32 bit) caches -- one for data and one for instructions. A single L2 (512 bit) is shared and main memory is connected to L2. We instantiate the main pieces of state in `CacheInterface`, but you will need to add some bookkeeping state elements and rules. These state elements will mostly be FIFOs and registers/EHRs. We expect to see no BRAMs other than the ones that already exist in your caches and main memory.

```verilog
module mkCacheInterface(CacheInterface);
    MainMem mainMem <- mkMainMem(); 
    Cache512 cacheL2 <- mkCache;
    Cache32 cacheI <- mkCache32;
    Cache32 cacheD <- mkCache32;
    // ...
```

The interface you must implement in `mkCacheInterface` is this:

```verilog
interface CacheInterface;
    method Action sendReqData(CacheReq req);
    method ActionValue#(Word) getRespData();
    method Action sendReqInstr(CacheReq req);
    method ActionValue#(Word) getRespInstr();
endinterface
```

The two L1 caches, the L2 cache, and the main memory live inside our `CacheInterface`. All four methods talk to the processor. We have one pair for data (`sendReqData` and `getRespData`) and one pair for instructions (`sendReqInstr` and `getRespInstr`). Our infrastructure in `top_pipelined` will drive the communication between the memory and the processor.

Hint: You may want to use `BypassFIFO`s to support your methods in a similar way as your processor uses its `getIReq`, `getDReq`, etc. methods. Then you can do most of your logic inside your rules.

In lab2_b, your processor spoke to a really big two-ported BRAM. Now it speaks to the `CacheInterface`. You need to build the plumbing:
- between the processor and the two L1 caches. (easy)
- between the two L1 caches and the L2 cache. (less easy)
- between the L2 cache and the main memory. (easy)

You will not need to modify much, if any, of your L1 and L2 caches or your processor to complete this lab.

Be aware that you have two L1 caches that share an L2 cache. Fortunately, all the addresses have always been in the same address space, even in lab2_b. If you look inside the old `top_pipelined.bsv`, and you will see your processor had been talking to a big BRAM for both instructions and data.

The main challenge is that you must design logic to manage the flow of requests and responses between the L2 cache and the two L1 caches. It can be difficult to debug such logic, so be sure to use a healthy system of `$display` statements and to approach the problem systematically.

Hint: You may want to maintain a FIFO queue that will keep track of the order in which your L1 caches request from L2. The responses from L2 should return to their respective L1 cache depending on what order value you put in the FIFO.

L2 cache should connect directly to main memory, which uses the following interface:

```verilog
interface MainMem;
    method Action put(MainMemReq req);
    method ActionValue#(MainMemResp) get();
endinterface
```
`put` sends a request (address) to memory, `get` returns the resulting line of data. See the `MemTypes.bsv` for information on the types. Connecting the L2 cache to the main memory should be significantly easier than connecting the L1 caches to L2.

## Running tests

We test your system in a very similar way to lab2_b.

Run `make all` first. then....

We have a collection of a few tests:
  add32, and32, or32, hello32, thelie32, mul32, ... (see the full list in test/build/)

To run one of those tests specifically you can do:

```
./run_pipelined add32
```

Those will generate a trace `pipelined.log` that can be opened in Konata (see below).

You can also run all the tests with:
```
./test_all_pipelined.sh
```

All tests but `matmul32` typically take less than 2s to finish. `matmul32` is much slower (30s to 1mn).

Note: The testbench `top_pipelined` has been modified from lab2_b to use the `CacheInterface` instead of the old BRAM. Please do not overwrite it with the version from lab2_b.

You will also need `python3` installed and in your path (i.e. can run `python3` in terminal/command prompt) to run the tests. (For enrichment: we use an `arrange_mem.py` script to transfrom our previous `mem.vmh` files, which were used to populate 32-bit BRAM entries, into `memlines.vmh` files that are used to populate 512-bit entries in our main memory.)

### How does testing work?
(For enrichment)

Your processor gets its instructions from its memory, and its memory is loaded from the `mem.vmh` file. Our test script moves a prebuilt RISC-V hex file from the `test/build` directory into `mem.vmh` and then calls the simulator that runs the `top` file that corresponds with whichever processor you're testing. If you're using the `run_<something>.sh` scripts, they also convert the intermediate Konata logs into a human-readable Konata log, which is how you see things like `li a0 0` in the Konata visualization.

If you want to produce your own tests, you can do two things:
- Write your own RISC-V assembly and compile it into an `elf`
- Write your own C code and compile it into RISC-V `elf`

then convert that `elf` into a `hex` file, hence the `elf2hex` tool we have in the directory.  (Note: run `make clean; make` in the `elf2hex` directory before use if not on Linux amd64). We don't expect you'll need to produce any tests yourself, but they are here if you want them.

If you *do* make your own tests, feel free to share the `hex` files on the Piazza. We have a rather boring and minimal set of tests, and I'm sure your peers would be delighted to see whatever fun tests you cook up! But it is not necessary for the lab.

# Submitting
`make submit` will do it all for you :)

Deadline: March 14, 2024 at 9:30am.

# Discussion

In what ways do your Konata log look different, e.g., for a test like `thelie32`? Do you see any room for improvement?

Why do we use a separate L1 caches for instructions and data? Why not just a single cache?

Why do we use both an L1 and L2 cache? Which would be faster on a real processor?

The L2 cache has only a single port for requests and a single port for responses. How significant would you expect this to be for performance since both L1 caches must share these ports? And in practice?

What might happen in our current implementation if a program tries to modify the instructions? What if we try to execute instructions held in data?

We use the same cache structure for Imem and Dmem. How might you simplify the Imem cache to make it more efficient in terms of hardware usage? Hint: think about how instruction accesses differ from data accesses.
