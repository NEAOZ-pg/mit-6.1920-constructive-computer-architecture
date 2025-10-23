# RISC-V 32 bit tests

Enclosed is a collection of small tests designed for RISC-V 32bit processors. These are from the 6.004 test bench and are modified for use in the 6.1920/6.175 testbenches. These will test various parts of the RISC-V ISA in small tests which might be helpful for debugging.

There are three types of tests: `microtests`, `fullasmtests`, and `quicksort`. 

To run these tests with your processor, copy `run_6004.sh` to your processor folder (e.g. `cp run_6004.sh <../lab2b_dir>; cd <../lab2b_dir>`). Then run 
```
./run_6004.sh <path_to_RISC_V_tests>/build/<test_type>/<test>.vmh
```
The konata output should still go to `pipelined.log`.

You can use `git clone https://github.com/6192-sp24/risc_v_tests.git`.

# Notes

For the microtests, most of them will show `PASS` if they just complete. You should look at the microtests folder and see the `.expected` file. You can make your processor print out the final register file state and compare to check accuracy. Note that in 6.175, we use `a1` and `a2` (`x11` and `x12`) to handle the proceessor end state -- these should be `0xf000fff8` and `0` respectively, regardless of the expected file.

All other tests should print PASS and FAIL as expected. However, these tests are still in a preliminary state and provided only for personal use. They are in no way used for final grading -- those tests are provided in the labs.

Let us know if you have any questions :)