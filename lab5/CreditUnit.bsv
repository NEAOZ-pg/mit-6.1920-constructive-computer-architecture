import FIFO::*;
import FIFOF::*;
import Types::*;
import VirtualChannelTypes::*;
import CreditTypes::*;
import SpecialFIFOs::*;

interface ReverseCreditUnit;
  /* Credit */
  method Action putCredit(CreditSignal credit);
  `ifdef SMART
  method Action putCreditSMART(CreditSignal credit);
  `endif
  method ActionValue#(CreditSignal) getCredit;
endinterface

(* synthesize *)
module mkReverseCreditUnit(ReverseCreditUnit);
  FIFOF#(CreditSignal)     creditQueue <- mkPipelineFIFOF;
  FIFOF#(CreditSignal)     smartCreditQueue <- mkPipelineFIFOF;

  method Action putCredit(CreditSignal credit);
    if(isValid(credit)) begin
      creditQueue.enq(credit);
    end
  endmethod

`ifdef SMART
  method Action putCreditSMART(CreditSignal credit);
    if(isValid(credit)) begin
      smartCreditQueue.enq(credit);
    end
  endmethod
`endif

  method ActionValue#(CreditSignal) getCredit;
    CreditSignal credit = ?;

    if(creditQueue.notEmpty) begin
      creditQueue.deq;
      credit = creditQueue.first();
    end
    else if(smartCreditQueue.notEmpty) begin
      smartCreditQueue.deq;
      credit = smartCreditQueue.first();
    end
    else begin
      credit = Invalid;
    end

    return credit;
  endmethod

endmodule
