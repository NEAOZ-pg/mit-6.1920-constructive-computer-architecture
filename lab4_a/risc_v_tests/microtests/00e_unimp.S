// This tests that your processor treats the word 0x00002063, which looks like
// a BRANCH instruction but has an illegal funct3, as an unimplemented
// instruction.
.text
start:
    .word 0x00002063 // BRANCH opcode but illegal funct3
    unimp
    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 