import Ehr::*;
import StmtFSM::*;

// Time Spent:

interface StepCounter;
    method Action inc();
    method Bit#(32) cur();
    method Action set(Bit#(32) newVal);
endinterface

// (* synthesize *)
// module mkCounterEhr(StepCounter);
//     Ehr#(2, Bit#(32)) cntSet <- mkEhr(0);
//     Ehr#(2, Bit#(32)) cntInc <- mkEhr(0);

//     method Action inc();
//         cntInc[0] <= cntSet[1] + 1;
//     endmethod

//     method Bit#(32) cur();
//         return cntInc[1];
//     endmethod

//     method Action set(Bit#(32) newVal);
//         cntSet[0] <= newVal;
//     endmethod

// endmodule

(* synthesize *)
module mkCounterEhr(StepCounter);
    Ehr#(3, Bit#(32)) cnt <- mkEhr(0);

    method Action inc();
        cnt[1] <= cnt[1] + 1;
    endmethod

    method Bit#(32) cur();
        return cnt[2];
    endmethod

    method Action set(Bit#(32) newVal);
        cnt[0] <= newVal;
    endmethod

endmodule

// Reference implementation using only simple registers.
(* synthesize *)
module mkCounter(StepCounter);
    Reg#(Bit#(32)) curVal <- mkReg(0);
    // cur < inc C set
    method Action inc();
        curVal <= curVal + 1;
    endmethod

    method Bit#(32) cur();
        return curVal;
    endmethod

    method Action set(Bit#(32) newVal);
        curVal <= newVal;
    endmethod
endmodule

/*
 Q: Why does the reference implementation fail to meet the requirement?

 A: TODO

 Q: How do  the methods relate with regards to concurrency? Fill in
 the following list. Replace ? with C, <, or >. Use C to indicate which
 methods conflict and cannot execute in the same cycle. Use < and > to
 indicate the order the methods execute in the same cycle.

 A: inc ? cur
    inc ? set
    cur ? set

*/

// Testbench (do not modify)
module mkStepCounterTb(Empty);
    StepCounter ehrized <- mkCounterEhr;
    Stmt test =
        (seq
            action
                $display("Starting with the counter being 0");
                $display("m.inc() and x=m.cur() called in the same cycle:");
                ehrized.inc();
                let x = ehrized.cur();
                if (x != 1) begin
                    $display("x was expected to be 1, but was %d", x);
                    $finish(1);
                end
            endaction
            action
                $display("Next cycle\nm.inc() and m.set(42) and m.cur() in the same cycle:");
                ehrized.set(42);
                ehrized.inc();
                let x = ehrized.cur();
                if (x != 43) begin
                    $display("x was expected to be 43, but was %d", x);
                    $finish(1);
                end
            endaction
            action
                $display("Next cycle\nm.cur() called alone");
                let x = ehrized.cur();
                if (x != 43) begin
                    $display("x was expected to be 43, but was %d", x);
                    $finish(1);
                end
            endaction
            action
                $display("StepCounterTest passed");
                $finish(0);
            endaction
        endseq);

    FSM test_fsm <- mkFSM(test);

    Reg#(Bool) going <- mkReg(False);

    rule start (!going);
        going <= True;
        test_fsm.start;
    endrule
endmodule
