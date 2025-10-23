// This tests that your processor treats the word 0x00006023, which looks like
// a SW instruction but has an incorrect funct3, as an unimplemented
// instruction.
.text
start:
    // 0000000 00000 00000 110 00000 0100011
    .word 0x00006023 // SW with invalid funct3
    unimp
    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 