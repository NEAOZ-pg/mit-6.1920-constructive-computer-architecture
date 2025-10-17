# Lab 3a -- Caches

Lab 3a is split into two problems that consist of designing realistic memory interfaces for a processor. The first problem is implementing an L1 cache that sits between your processor and the rest of the memory. The second problem is implementing an L2 cache that sits between your L1 cache and the rest of the memory.

Later in 3b (not in this repo), you will connect these caches to your processor. We expect most of the difficulty will be in 3a.

Some definitions:
* word = 32 bits
* line = 512 bits, or 16 words as a vector
* L1 cache = directly connected to processor and requests word response
* L2 cache = connected to the L1 cache and below main memory, stores lines just like main memory.

We are producing an L1 cache and L2 cache to create a system more reflective of real-life [memory hierarchy](https://en.wikipedia.org/wiki/Memory_hierarchy). As you recall from lecture, there is a tradeoff in memory systems between speed and size. In the previous lab, we assumed that memory would always be big and fast. We are starting to move away from that assumption.

## Part 1 -- L1 Cache

In the file `Cache32.bsv`, you should implement the `mkCache32` module. Your cache should have the following characteristics:
- It has 128 cache lines, each line is 512-bits long, made up of 32 bit words. (so how many words per line? what's the cache size in KB?)
- It uses a writeback miss-allocate policy
- You should use a BRAM to hold the content of the cache and the associated tags. We made two (different) placeholder BRAMs in the code for you. If you keep them, you should rename them to meaningful names.
- You are free to design either a k-way associative (k=2,4,8) or a direct-mapped cache. If you choose a k-way associative you can pick any replacement policy you want. Direct-mapped is probably easier to implement first.
- (Optional but recommended) It uses a store-buffer. This adds some complexity but would save you some cycles in performance. If you're implementing a store buffer, you will want to update the `Beveren.bsv` test bench to increase the chances of the test bench submitting a load right after a store to the same address. Otherwise, you may not be able to catch bugs in your store buffer implementation. Why?

We provide an example BE (byte enable) BRAM to store data. Byte enable is important for processor use since RISC-V specifications allow byte based (`lb, sb, etc.`) instructions. A byte enable string looks something like `1100` for a four byte write. This means only the upper two bytes will be written to the bram, ignoring the lower two bytes. This applies for lines as well. A 64 byte line (512 bits at 8 bits per byte) would consist of a series of 64 bits (one hot encoding) for the byte enable request. The data in value would be the same, but the zeroed bytes are ignored. Please see the Bluespec specifications for usage. `BramRequestBE` types include this byte enable value in the `writeen` field. We use the Bluespec BE BRAM for convenience. (Optional: You can use a non-BE BRAM as long as your cache handles the different `writeen` cases explicitly.)
```
typedef struct {Bit#(n) writeen;
    Bool responseOnWrite;
    addr address;
    data datain;
} BRAMRequestBE#(type addr, type data, numeric type n) deriving (Bits, Eq);
```
Please see the Bluespec Reference Guide for more details on usage. Note that reads are always `writeen=0`. You will still always want to return words for any read. Your processor will always give a `CacheReq` type with the fields `CacheReq{word_byte: req.byte_en, addr: req.addr, data: req.data}`. The `word_byte` field will be the associated byte enable field for a given word. You will need to modify that to write to lines in your cache. Hint: n-dim vectors of m-bits in bluespec are the same as `n*m` bits in bluespec (in bram or otherwise).

### Types
To make development and debugging easier, please make and use types with sensible names. Try getting started in the `MemTypes.bsv` file. A little bit of planning ahead of time can make implementation (and debugging) easier.

You may modify the structs for the requests if you find the need to add some data. Just make sure that each side using the interface agrees with it. You will likely not need to modify the requests for the purposes of this lab, but the freedom is there.

```verilog
interface Cache32;
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();  // returns a word
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);  // returns a full line
endinterface
```

Here we see four methods. Two of them interface with the processor (`putFromProc` and `getToProc`) and two of them interface with the next stage of memory (`getToMem` and `putFromMem`). A module that instantiates your cache would call these methods to use it.

`putFromProc` delivers a cache request from your processor to your cache. `getToProc` should return the associated data that is for that memory address that was requested. `getToMem` will deliver any requests from your cache to the next stage of memory. `putFromMem` will respond with the data you requested from the next stage. These are connected in the test bench for you already.

For testing Part 1, use `Beveren.bsv`. This will directly probe your L1 cache.

Tip: Don't forget to use your `$display` statements. They can be helpful in checking the behavior of your cache.

As a note for the later lab: we will instantiate two L1 caches: one for instructions, one for data.

## Part 2 -- L2 Cache

In the file `Cache512.bsv`, you should implement the `mkCache` module. Your cache should have the following characteristics:
- It has 256 cache lines, each line is 512-bits long, with all data requested and returned being 512 bits long (what's the cache size in KB?)
- It uses a writeback miss-allocate policy
- You are free to design either a k-way associative (k=2,4,8) or a direct-mapped cache. If you choose a k-way associative you can pick any replacement policy you want
- You should use a BRAM to hold the content of the cache and the associated tags. A placeholder bram is in the code for you with these specifications.
- (Optional) It uses a store-buffer.

In the file `MemTypes.bsv` we defined a few basic types.
You will also have to define new types for the tags and the indexes. Make sure these do not conflict with types defined in Cache32

Here, you do not need to worry about byte enable flags at all, so please feel free to store everything in a single bram as given. You are free to split it up instead if you so desire.

```verilog
interface Cache512;
    method Action putFromProc(MainMemReq e);
    method ActionValue#(MainMemResp) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface
```

Here we see four methods. `putFromProc` delivers a cache request from your L1 cache to your L2 cache. `getToProc` should return the associated data that is for that memory address that was requested from L1. `getToMem` will deliver any requests from your cache to main memory (or a higher level cache). `putFromMem` will respond with the data you requested from main memory. These are connected in the test bench for you already.

For testing Part 2, use `Beveren_nested.bsv`. This will test your L2 cache *indirectly*. We connect your L1 cache to the L2 cache and probe your L1. If you find it helpful, you can make your own test bench using the same structure as `Beveren.bsv` and probe your L2 cache directly.

As a note for the later lab, we will instantiate one L2 cache, which we will connect to both of your L1 caches.

## Suggestions

Use types! Use types! Use types!

Also use `$display` statements.

Note: you cannot use two port BRAMs in this lab.

# Running tests

To test the cache in isolation, we have made one randomized test. It only tests functional correctness. The test does not check the sizes/kind of cache chosen, etc... all those things will be discussed during checkoffs.

The test is simply sending random requests both to your design, and to an ideal memory. The test make sure that the response obtained from your system are the same as the one returned by the ideal memory.

To run the test, you can do:

```bash
make
./Beveren # tests only L1 cache
./Beveren_nested # tests L1 and L2 cache
```

# Submitting
Run `make submit` in the main folder.

Deadline: March 14, 2024 at 9:30am.

# Discussion

How big are our caches in terms of bytes or kilobytes? The L1? The L2? What about the main memory (32 bit addresses with byte addressing)?

Why do we want to use a cache?

Why does the cache store lines instead of words?
