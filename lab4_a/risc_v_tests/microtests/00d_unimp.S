// This tests that your processor treats the word 0x80000033, which looks like
// an ADD instruction but has an incorrect funct7, as an unimplemented
// instruction.
.text
start:
    .word 0x80000033 // looks like an add instruction, but really isn't
    unimp

    //lui a1, 0xf000f
    //addi a1, a1, SEXT_IMM(0xff8)

    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 