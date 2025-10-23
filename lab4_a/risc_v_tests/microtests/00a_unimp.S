// This tests that your processor terminates on an unimplemented instruction.
.text
start:
    unimp

    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 