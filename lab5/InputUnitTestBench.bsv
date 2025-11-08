import Vector::*;
import FIFO::*;
import SpecialFIFOs::*;
import Ehr::*;

import Types::*;
import MessageTypes::*;
import VirtualChannelTypes::*;

import InputUnit::*;

typedef 100 TestCount;



(* synthesize *)
module mkInputUnitTestBench();

  Reg#(Data) count <- mkReg(0);
  InputUnit inputUnit <- mkInputUnit;
  FIFO#(VCIdx) vcLog <- mkBypassFIFO;

  rule doCount;
    if(count < fromInteger(valueOf(TestCount))) begin
      $display("Cycle: %d ---------------------------------------", count);
      count <= count + 1;
    end
    else begin
      $finish;
    end
  endrule

  rule rl_putFlit(count < fromInteger(valueOf(TestCount)));// && (count % 8 < 4));
    Flit flit = ?;
    VCIdx vc = truncate(count % 4);
    flit.vc = vc;
    flit.flitType = HeadTail;
    inputUnit.putFlit(flit);
    $display("[PutFlit]: vc=%d", vc);
  endrule

  rule rl_doOthers(count < fromInteger(valueOf(TestCount)));// && (count % 4 < 2));
    let mFlit = inputUnit.peekFlit;
    let header = inputUnit.peekHeader;
    inputUnit.deqFlit;//(truncate(count % 4)-1); 
    $display("[DeqFlit]: vc=%d",count % 4-1);
  endrule 

  rule rl_printVC(count < fromInteger(valueOf(TestCount)));
    let currVC = inputUnit.getNextVC;
    $display("Current Active VC: %d", currVC);
  endrule

endmodule
