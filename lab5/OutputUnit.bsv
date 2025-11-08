import Vector::*;
import SpecialFIFOs::*;
import FIFO::*;

import Types::*;
import MessageTypes::*;

interface OutputUnit;
  method Action putFlit(Flit flit);
  method ActionValue#(Flit) getFlit;
endinterface

(* synthesize *)
module mkOutputUnit(OutputUnit);

  FIFO#(Flit) outBuffer <- mkPipelineFIFO;

  method Action putFlit(Flit flit);
    outBuffer.enq(flit);
  endmethod

  method ActionValue#(Flit) getFlit;
    outBuffer.deq;
    return outBuffer.first;
  endmethod

endmodule
