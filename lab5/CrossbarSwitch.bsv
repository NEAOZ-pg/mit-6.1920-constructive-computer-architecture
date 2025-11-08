import Vector::*;
import Ehr::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import Types::*;
import MessageTypes::*;
import SwitchAllocTypes::*;
import RoutingTypes::*;

import CrossbarBuffer::*;

interface CrossbarPort;
  method Action putFlit(Flit traverseFlit, DirIdx destDirn);
  method ActionValue#(Flit) getFlit;
endinterface

interface CrossbarSwitch;
  interface Vector#(NumPorts, CrossbarPort) crossbarPorts;
endinterface

(* synthesize *)
module mkCrossbarSwitch(CrossbarSwitch);
  /*
    lab 5a
    @student, please implement the crossbar logic
  */

  // just switch, no arbitrate to consider

  Vector#(NumPorts, CrossbarPort) portsVec;

  Vector#(NumPorts, Ehr#(TAdd#(NumPorts, 1), Flit)) crossbar <- replicateM(mkEhr(Flit{nextDir: null_, flitData: 0}));
  Vector#(NumPorts, Ehr#(TAdd#(NumPorts, 1), Bool)) valid <- replicateM(mkEhr(False));

  for (Integer ports = 0; ports < valueOf(NumPorts); ports = ports + 1) begin
    portsVec[ports] = interface CrossbarPort
      method Action putFlit(Flit traverseFlit, DirIdx destDirn);
        crossbar[destDirn][ports] <= traverseFlit;
        valid[destDirn][ports] <= True;
      endmethod
      method ActionValue#(Flit) getFlit if (valid[ports][valueOf(NumPorts)]);
        // using read and write the same ports of valid in rule will error, but in action won't
        valid[ports][valueOf(NumPorts)] <= False;
        return crossbar[ports][valueOf(NumPorts)];
      endmethod
    endinterface;
  end

  interface crossbarPorts = portsVec;
endmodule
