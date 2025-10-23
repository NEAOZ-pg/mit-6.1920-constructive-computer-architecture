// This tests that your processor handles BNE (and ADDI and ADD) correctly.
.text
start:
    addi x1, x0, 10
    addi x2, x0, 1
loop_start:
    addi x1, x1, -1
    add x2, x2, x2
    bne x1, x0, loop_start
    unimp
    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 