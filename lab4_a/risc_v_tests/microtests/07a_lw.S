// This is a minimal test that tests that your processor handles LW (and AUIPC
// and ADDI) correctly.
.text
start:
    la x1, label
    lw x2, 0(x1)
    unimp
    li a1, 0xf000fff8;
    li a2, 0; 
    sw a2, 0(a1); 
.data
label:  .word 0x12345678
