// Types used in L1 interface
typedef struct { Bit#(1) write; Bit#(26) addr; Bit#(512) data; } MainMemReq deriving (Eq, FShow, Bits, Bounded);
typedef struct { Bit#(4) word_byte; Bit#(32) addr; Bit#(32) data; } CacheReq deriving (Eq, FShow, Bits, Bounded);
typedef Bit#(512) MainMemResp;
typedef Bit#(32) Word;

// (Curiosity Question: CacheReq address doesn't actually need to be 32 bits. Why?)

// Helper types for implementation (L1 cache):

typedef 128 CacheLineSize;
typedef 512 LineBitsSize;
typedef 32  WordSize;
typedef 8   ByteSize;

typedef TDiv#(LineBitsSize, ByteSize) LineBytes;  // 512 / 8 = 64


typedef enum {
    Invalid,
    Clean,
    Dirty
} LineState deriving (Eq, Bits, FShow);

typedef enum {
    Ready,
    StartMiss,
    SendFillReq,
    WaitFillResp
} ReqStatus deriving (Eq, Bits, FShow);

// You should also define a type for LineTag, LineIndex. Calculate the appropriate number of bits for your design.
typedef Bit#(19) LineTag;
typedef Bit#(7) LineIndex;
typedef Bit#(4) WordIndex;
typedef Bit#(2) WordOffset;

typedef Bit#(LineBitsSize) LineBits;
typedef Bit#(TLog#(LineBitsSize)) LineBitsAddrSize;

typedef 256 L2CacheLineSize;
typedef Bit#(18) L2LineTag;
typedef Bit#(8) L2LineIndex;
// You may also want to define a type for WordOffset, since multiple Words can live in a line.

// You can translate between Vector#(16, Word) and Bit#(512) using the pack/unpack builtin functions.
// typedef Vector#(16, Word) LineData  (optional)

// Optional: You may find it helpful to make a function to parse an address into its parts.
// e.g.,
typedef struct {
        LineTag tag;
        LineIndex index;
        WordIndex l;
        WordOffset offset;
    } ParsedAddress deriving (Bits, Eq);

function ParsedAddress parseAddress(Bit#(32) address);
    return ParsedAddress {
        tag: address[31: 13],
        index: address[12: 6],
        l: address[5: 2],
        offset: address[1: 0]
    };
endfunction

// and define whatever other types you may find helpful.

typedef struct {
        L2LineTag tag;
        L2LineIndex index;
    } L2ParsedAddress deriving (Bits, Eq);

function L2ParsedAddress l2parseAddress(Bit#(26) address);
    return L2ParsedAddress {
        tag: address[25: 8],
        index: address[7: 0]
    };
endfunction


// Helper types for implementation (L2 cache):