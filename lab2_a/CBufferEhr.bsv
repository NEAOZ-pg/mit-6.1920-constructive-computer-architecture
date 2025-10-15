import Ehr::*;
import StmtFSM::*;
import Vector::*;
import FIFO::*;

typedef Bit#(3) Token;
typedef Bit#(32) Response;

// Time Spent:

interface CBuffer;
    method ActionValue#(Token) getToken();
    method Action put(Token t, Response r);
    method ActionValue#(Response) getResponse();
endinterface

(* synthesize *)
module mkCBufferEhr(CBuffer);
    Reg#(Token) tokenHead <- mkReg(0);
    Reg#(Token) tokenTail <- mkReg(0);
    Reg#(Bool) isFull <- mkReg(False);

    Vector#(8, Ehr#(2, Bool)) tokenInUse <- replicateM(mkEhr(False));
    Vector#(8, Ehr#(2, Bool)) repInUse <- replicateM(mkEhr(False));
    Vector#(8, Ehr#(2, Response)) resp <- replicateM(mkEhrU);

    method ActionValue#(Token) getToken() if (!isFull);
        tokenTail <= tokenTail + 1;
        if (tokenTail + 1 == tokenHead) begin
            isFull <= True;
        end
        tokenInUse[tokenTail][0] <= True;
        return tokenTail;
    endmethod

    method Action put(Token t, Response r);
        if (tokenInUse[t][1] && !repInUse[t][0]) begin
            repInUse[t][0] <= True;
            resp[t][0] <= r;
        end
    endmethod

    method ActionValue#(Response) getResponse() if (tokenInUse[tokenHead][1] && repInUse[tokenHead][1]);
        isFull <= False;
        tokenHead <= tokenHead + 1;
        return resp[tokenHead][1];
    endmethod
endmodule

/////// Testing infrastructure below
module mkCBufferEhrTb(Empty);
    CBuffer dut1 <- mkCBufferEhr;
    FIFO#(Token) tok <- mkSizedFIFO(8);
    Reg#(Bit#(32)) req <- mkReg(18);
    Reg#(Bit#(32)) resp <- mkReg(18);
    Reg#(Bit#(32)) tic <- mkReg(0);

    rule do_tic;
        if (tic == 0)
            $display("Start testing the register-based CBuffer");
        $display("Cycle %d", tic);
        tic <= tic + 1;
        if (tic == 100)
            $finish(1);
    endrule

    rule emit_request if (req > 0);
        let x <- dut1.getToken();
        req <= req - 1;
        $display("Emit request with token: %d", x);
        tok.enq(x);
        emitRequest(x);
    endrule

    rule emit_response if (tic > 4);
        let y <- response();
        if ( y != -1) begin
            Bit#(3) ty = truncate(y);
            $display("Completion buffer received response corresponding to token: %d", ty);
            dut1.put(ty, y);
        end
    endrule

    rule get_resp;
        let x <- dut1.getResponse();
        let y = tok.first();
        tok.deq();
        if (truncate(x) != y) begin
            $display("The completion buffer produced a result that did not respect FIFO: it produced the result for token %d while the next expected in FIFO order was %d", x, y);
            $finish(1);
        end else begin
            $display("The completion buffer CORRECTLY produced the result %d, which was the one expected in FIFO order.", x);
        end
        resp <= resp - 1;
        if (resp == 1) begin
                $display("CBufferEhrTest passed in %d cycles",tic);
                $finish(0);
        end
    endrule
endmodule

import "BDPI" function Action emitRequest(Bit#(3) x);
import "BDPI" function ActionValue#(Bit#(32)) response();
