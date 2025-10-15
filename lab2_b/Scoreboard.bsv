import Vector::*;
import Ehr::*;
import RVUtil::*;


interface ScoreboardIfc;
    method Bool search1(RIdx rs1_idx);
    method Bool search2(RIdx rs2_idx);
    method Bool searchd(RIdx rd_idx);

    method Action insert(RIdx rd_idx);

    method Action eRemove(RIdx rd_idx); // remove scoreboard entry at EX stage
    method Action wRemove(RIdx rd_idx); // remove scoreboard entry at WB stage
endinterface

// TODO: non-stalling scoreboard upon WAW
(* synthesize *)
module mkScoreboard(ScoreboardIfc);
    Vector#(32, Ehr#(4, Bool)) scoreboard <- replicateM(mkEhr(False)); // FALSE: no hazard

    method Bool search1(RIdx rs1_idx);
        return scoreboard[rs1_idx][2];
    endmethod

    method Bool search2(RIdx rs2_idx);
        return scoreboard[rs2_idx][2];
    endmethod

    // method Bool searchd(RIdx rd_idx);
    //     return scoreboard[rd_idx][2];
    // endmethod

    method Action insert(RIdx rd_idx);
        scoreboard[rd_idx][3] <= True; // TRUE: hazard exist
    endmethod
    // Why is `eRemove` < `wRemove`?    FIFO has its own priority and need be consistent with passby net
    method Action eRemove(RIdx rd_idx);
        scoreboard[rd_idx][0] <= False;
    endmethod

    method Action wRemove(RIdx rd_idx);
        scoreboard[rd_idx][1] <= False;
    endmethod
endmodule
