// This tests that your processor treats the all-0 word as an unimplemented
// instruction.
.text
start:
    .word 0
    unimp

    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 