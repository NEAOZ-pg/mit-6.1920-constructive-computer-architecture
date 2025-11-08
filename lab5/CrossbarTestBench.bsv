import Vector::*;
import Ehr::*;

import Types::*;
import MessageTypes::*;
import SwitchAllocTypes::*;
import RoutingTypes::*;

import CrossbarSwitch::*;
import CrossbarBuffer::*;

typedef 100 TestCount;

(* synthesize *)
module mkCrossbarTestBench();
  Reg#(Data) count <- mkReg(0);
  CrossbarSwitch cb <- mkCrossbarSwitch;

  rule doCount;
    if(count < fromInteger(valueOf(TestCount))) begin
      count <= count + 1;
    end
    else begin
      $finish;
    end
  endrule

  rule rl_insertFlits(count < fromInteger(valueOf(TestCount)));
    Flit flit1 = ?, flit2 = ?, flit3 = ?, flit4 = ?, flit5 = ?;
    flit1.flitData = 1;
    flit2.flitData = 2;
    flit3.flitData = 3;
    flit4.flitData = 4;
    flit5.flitData = 5;

    if(count == 10) begin
      cb.crossbarPorts[0].putFlit(flit1, 1); //N->E 2
      cb.crossbarPorts[1].putFlit(flit2, 0); //E->N 1
      cb.crossbarPorts[2].putFlit(flit3, 4); //S->L 4
      cb.crossbarPorts[3].putFlit(flit4, 2); //W->S 5
      cb.crossbarPorts[4].putFlit(flit5, 3); //L->W 3
    end
    else if(count == 11) begin
      cb.crossbarPorts[0].putFlit(flit1, 4); //N->L 0 2 0 0 1
      cb.crossbarPorts[4].putFlit(flit2, 1); //L->E
    end
    else if(count == 12) begin
      cb.crossbarPorts[0].putFlit(flit1, 2); //N->S 4
      cb.crossbarPorts[1].putFlit(flit2, 3); //E->W 5
      cb.crossbarPorts[2].putFlit(flit3, 4); //S->L 1
      cb.crossbarPorts[3].putFlit(flit4, 0); //W->N 2
      cb.crossbarPorts[4].putFlit(flit5, 1); //L->E 3
    end

  endrule

  rule rl_getFlits(count < fromInteger(valueOf(TestCount)));
    if(count == 10) begin
      let flit_rec_1 <- cb.crossbarPorts[0].getFlit;
      let flit_rec_2 <- cb.crossbarPorts[1].getFlit;
      let flit_rec_3 <- cb.crossbarPorts[2].getFlit;
      let flit_rec_4 <- cb.crossbarPorts[3].getFlit;
      let flit_rec_5 <- cb.crossbarPorts[4].getFlit;
      if (flit_rec_1.flitData != 2) begin
        $fdisplay(stderr, "  [0;31mFAIL[0m (port 0 receives %0d, expected 2)", count, flit_rec_1.flitData);
        $finish;
        end
      if (flit_rec_2.flitData != 1) begin
        $fdisplay(stderr, "  [0;31mFAIL[0m (port 0 receives %0d, expected 1)", count, flit_rec_2.flitData);
        $finish;
        end
      if (flit_rec_3.flitData != 4) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 0 receives %0d, expected 4)", count, flit_rec_3.flitData);
        $finish;
        end
      if (flit_rec_4.flitData != 5) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 0 receives %0d, expected 5)", count, flit_rec_4.flitData);
        $finish;
        end
      if (flit_rec_5.flitData != 3) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 0 receives %0d, expected 3)", count, flit_rec_5.flitData);
        $finish;
        end
    end
    else if(count == 11) begin
      let flit_rec_1 <- cb.crossbarPorts[1].getFlit;
      let flit_rec_2 <- cb.crossbarPorts[4].getFlit;
      if (flit_rec_1.flitData != 2) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 1 receives %0d, expected 2)", count, flit_rec_1.flitData);
        $finish;
        end
      if (flit_rec_2.flitData != 1) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 4 receives %0d, expected 1)", count, flit_rec_2.flitData);
        $finish;
        end
    end
    else if(count == 12) begin
      let flit_rec_1 <- cb.crossbarPorts[0].getFlit;
      let flit_rec_2 <- cb.crossbarPorts[1].getFlit;
      let flit_rec_3 <- cb.crossbarPorts[2].getFlit;
      let flit_rec_4 <- cb.crossbarPorts[3].getFlit;
      let flit_rec_5 <- cb.crossbarPorts[4].getFlit;
      if (flit_rec_1.flitData != 4) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 0 receives %0d, expected 4)", count, flit_rec_1.flitData);
        $finish;
      end
      if (flit_rec_2.flitData != 5) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 1 receives %0d, expected 5)", count, flit_rec_2.flitData);
        $finish;
        end
      if (flit_rec_3.flitData != 1) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 2 receives %0d, expected 1)", count, flit_rec_3.flitData);
        $finish;
        end
      if (flit_rec_4.flitData != 2) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 3 receives %0d, expected 2)", count, flit_rec_4.flitData);
        $finish;
        end
      if (flit_rec_5.flitData != 3) begin
        $fdisplay(stderr, "[cycle: %d]  [0;31mFAIL[0m (port 4 receives %0d, expected 3)", count, flit_rec_5.flitData);
        $finish;
        end
    end
    else if (count == 13) begin
      $fdisplay(stderr, "  [0;32mPASS[0m");
    end

  endrule

  // for(DirIdx i = 0; i<5; i=i+1) begin
  //   rule rl_getFlits(count < fromInteger(valueOf(TestCount)));
  //     let flit <- cb.crossbarPorts[i].getFlit;
  //     $display("[Count:%d] port %d got a flit with value %d", i, count, flit.flitData);
  //   endrule
  // end

endmodule
