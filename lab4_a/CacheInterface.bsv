// SINGLE CORE CACHE INTERFACE WITH NO PPP
import MainMem::*;
import MemTypes::*;
import Cache32::*;
import Cache512::*;
// import FIFOF::*;
import MemTypes::*;
import Ehr::*;


interface CacheInterface;
    method Action sendReqData(CacheReq req);
    method ActionValue#(Word) getRespData();
    method Action sendReqInstr(CacheReq req);
    method ActionValue#(Word) getRespInstr();
endinterface


module mkCacheInterface(CacheInterface);
    let verbose = True;
    MainMem mainMem <- mkMainMem();
    Cache512 cacheL2 <- mkCache;
    Cache32 cacheI <- mkCache32;
    Cache32 cacheD <- mkCache32;

    // FIFO#(MainMemReq)  mainReq <- mkBypassFIFO;
    // FIFO#(MainMemResp)  mainResp <- mkBypassFIFO;

    // assume l1I has higher priority
    Ehr#(2, Bool) l1IReql2 <- mkEhr(False);
    Ehr#(2, Bool) l1DReql2 <- mkEhr(False);


    Ehr#(2, Bool) isDW <- mkEhr(False);
    // You need to add rules and/or state elements.

    Reg#(Bool) debug <- mkReg(False);

    rule l1IReqL2Mem if (l1DReql2[0] == False && l1IReql2[0] == False);
        if (debug) $display("cacheI req mem, %d\n", l1IReql2[0]);
        MainMemReq l1req <- cacheI.getToMem();
        cacheL2.putFromProc(l1req);
        l1IReql2[0] <= True;
    endrule

    rule l2MemResp;
        let l2Resp <- cacheL2.getToProc();
        if (l1IReql2[0] == True) begin
            if (debug) $display("cacheI resp mem, %d\n", l1IReql2[0]);
            cacheI.putFromMem(l2Resp);
            l1IReql2[1] <= False;
        end
        else begin
            if (debug) $display("cacheD resp mem, %d\n", l1DReql2[0]);
            cacheD.putFromMem(l2Resp);
            l1DReql2[1] <= False;
        end
    endrule

    rule l1DReqL2Mem if (l1IReql2[1] == False && l1DReql2[0] == False);
        if (debug) $display("cacheD req mem, %d\n", l1DReql2[0]);
        MainMemReq l1req <- cacheD.getToMem();
        cacheL2.putFromProc(l1req);
        l1DReql2[0] <= (l1req.write == 0);
    endrule

    rule reqMainMen;
        MainMemReq req <- cacheL2.getToMem();
        mainMem.put(req);
    endrule

    rule respMainMen;
        MainMemResp resp <- mainMem.get();
        cacheL2.putFromMem(resp);
    endrule

    method Action sendReqData(CacheReq req);
        if (debug) $display("cacheD req, %d, %d\n", l1DReql2[0], req.word_byte != 0);
        cacheD.putFromProc(req);
        isDW[0] <= (req.word_byte != 0);
    endmethod

    method ActionValue#(Word) getRespData() ;
        if (debug) $display("cacheD resp, %d\n", l1DReql2[0]);
        if (isDW[0]) begin
            isDW[1] <= False;
            return 0;
        end
        else begin
            let re <- cacheD.getToProc();
            return re;
        end
    endmethod

    method Action sendReqInstr(CacheReq req);
        if (debug) $display("cacheI req, %d\n", l1IReql2[0]);
        cacheI.putFromProc(req);
    endmethod

    method ActionValue#(Word) getRespInstr();
        if (debug) $display("cacheI resp, %d\n", l1IReql2[0]);
        let re <- cacheI.getToProc();
        return re;
    endmethod
endmodule
