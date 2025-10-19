import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;

// Note that this interface *is* symmetric.
interface Cache512;
    method Action putFromProc(MainMemReq e);
    method ActionValue#(MainMemResp) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

// delete when you're done with it
typedef Bit#(1) PLACEHOLDER;

(* synthesize *)
module mkCache(Cache512);
    BRAM_Configure cfgData = defaultValue;
    cfgData.memorySize = valueOf(L2CacheLineSize);
    cfgData.loadFormat = tagged Binary "zero512.vmh";  // zero out for you
    BRAM1Port#(L2LineIndex, LineBits) cacheData <- mkBRAM1Server(cfgData);

    BRAM_Configure cfgTag = defaultValue;
    cfgTag.memorySize = valueOf(L2CacheLineSize);
    cfgTag.loadFormat = tagged Binary "./zero.vmh";
    BRAM1Port#(L2LineIndex, L2LineTag) cacheTag <- mkBRAM1Server(cfgTag);

    BRAM_Configure cfgState = defaultValue;
    cfgState.memorySize = valueOf(L2CacheLineSize);
    cfgState.loadFormat = tagged Binary "./zero.vmh";
    BRAM1Port#(L2LineIndex, LineState) cacheState <- mkBRAM1Server(cfgState);

    FIFO#(MainMemReq) cacheReqQ <- mkFIFO;
    FIFO#(MainMemResp)  cacheRespQ <- mkBypassFIFO;
    FIFO#(MainMemReq)  memReqQ <- mkFIFO;
    FIFO#(MainMemResp)  memRespQ <- mkFIFO;

    Reg#(ReqStatus) mshr <- mkReg(Ready);

    Reg#(Bool) debug <- mkReg(False);

    Reg#(Word) ticks <- mkReg(0);
    Reg#(Word) cnt <- mkReg(0);

    rule tick;
        ticks <= ticks + 1;
        if (debug) $display("tick=%d mshr=%d\n", ticks, mshr);
    endrule

    // Remember the previous hints when applicable, especially defining useful types.

    rule startJudgeHit if (mshr == StartMiss);
        let data <- cacheData.portA.response.get();
        let tag <- cacheTag.portA.response.get();
        let state <- cacheState.portA.response.get();
        let e = cacheReqQ.first();
        let cacheParse = l2parseAddress(e.addr);

        if (state != Invalid && cacheParse.tag == tag) begin
            if (debug) $display("StartMiss:\taddr=0x%h\twrite=%b\tdata=0x%h\n--hit\tstate=%d\ttag=0x%h\tindex=0x%h\n", e.addr, e.write, e.data, state, cacheParse.tag, cacheParse.index);
            cacheReqQ.deq();
            if (e.write == 0) begin   // read
                cacheRespQ.enq(data);
            end
            else begin  // write
                BRAMRequest#(L2LineIndex, LineBits) reqCacheData = BRAMRequest {
                    write: True,
                    responseOnWrite: False,
                    address: cacheParse.index,
                    datain: e.data
                };
                cacheData.portA.request.put(reqCacheData);
                // cache state
                if (state == Clean) begin
                    BRAMRequest#(L2LineIndex, LineState) reqCacheState = BRAMRequest {
                        write: True,
                        responseOnWrite: False,
                        address: cacheParse.index,
                        datain: Dirty
                    };
                    cacheState.portA.request.put(reqCacheState);
                end
            end
            mshr <= Ready;
        end
        else begin
            if (debug) $display("StartMiss:\taddr=0x%h\twrite=%b\tdata=0x%h\n--miss\tstate=%d\ttag=0x%h\tindex=0x%h\n", e.addr, e.write, e.data, state, cacheParse.tag, cacheParse.index);
            // write back the dirty cache
            if (state == Dirty) begin
                if (debug) $display("dirty: write back\nline=\t0x%h\n", data);
                let memReq = MainMemReq {
                    write: 1,
                    addr: {tag, cacheParse.index},
                    data: data
                };
                memReqQ.enq(memReq);
                mshr<= SendFillReq;
            end
            else begin
                let memReq = MainMemReq {
                    write: 0,
                    addr: {cacheParse.tag, cacheParse.index},
                    data: ?
                };
                memReqQ.enq(memReq);
                mshr <= WaitFillResp;
            end
        end
    endrule

    rule sendMemFillReq if (mshr == SendFillReq);
        let e = cacheReqQ.first();
        let cacheParse = l2parseAddress(e.addr);
        let memReq = MainMemReq {
            write: 0,
            addr: {cacheParse.tag, cacheParse.index},
            data: ?
        };
        memReqQ.enq(memReq);
        mshr <= WaitFillResp;
    endrule

    rule waitMemFillResp if (mshr == WaitFillResp);
        let line = memRespQ.first();
        memRespQ.deq();
        let e = cacheReqQ.first();
        cacheReqQ.deq();
        let cacheParse = l2parseAddress(e.addr);
        if (e.write == 0) begin   // read
            cacheRespQ.enq(line);
            if (debug) $display("WaitFillResp:\taddr=0x%h\twrite=%b\tdata=0x%h\ntag=0x%h\tindex=0x%h\tline=\t0x%h\n", e.addr, e.write, e.data, cacheParse.tag, cacheParse.index, line);
            // update the bram
            BRAMRequest#(L2LineIndex, LineBits) reqCacheData = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: line
            };

            BRAMRequest#(L2LineIndex, L2LineTag) reqCacheTag = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: cacheParse.tag
            };

            BRAMRequest#(L2LineIndex, LineState) reqCacheState = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: Clean
            };

            cacheData.portA.request.put(reqCacheData);
            cacheTag.portA.request.put(reqCacheTag);
            cacheState.portA.request.put(reqCacheState);
        end
        else begin  // write
            if (debug) $display("WaitFillResp:\taddr=0x%h\twrite=%b\tdata=0x%h\nline=\t0x%h\nnew=\t0x%h\n\n", e.addr, e.write, e.data, line);
            BRAMRequest#(L2LineIndex, LineBits) reqCacheData = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: e.data
            };

            BRAMRequest#(L2LineIndex, L2LineTag) reqCacheTag = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: cacheParse.tag
            };

            BRAMRequest#(L2LineIndex, LineState) reqCacheState = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: Dirty
            };

            cacheData.portA.request.put(reqCacheData);
            cacheTag.portA.request.put(reqCacheTag);
            cacheState.portA.request.put(reqCacheState);
        end
        mshr <= Ready;
    endrule

    method Action putFromProc(MainMemReq e) if (mshr == Ready);
        cnt <= cnt + 1;
        let cacheParse = l2parseAddress(e.addr);
        if (debug) $display("-----cnt:%d------\nputFromProc:\taddr=0x%h\twrite=%b\tdata=0x%h\n", cnt, e.addr, e.write, e.data);

        cacheReqQ.enq(e);

        BRAMRequest#(L2LineIndex, LineBits) reqCacheData = BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: cacheParse.index,
            datain: ?
        };

        BRAMRequest#(L2LineIndex, L2LineTag) reqCacheTag = BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: cacheParse.index,
            datain: ?
        };

        BRAMRequest#(L2LineIndex, LineState) reqCacheState = BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: cacheParse.index,
            datain: ?
        };

        cacheData.portA.request.put(reqCacheData);
        cacheTag.portA.request.put(reqCacheTag);
        cacheState.portA.request.put(reqCacheState);

        mshr <= StartMiss;
    endmethod

    method ActionValue#(MainMemResp) getToProc();
        let re = cacheRespQ.first();
        cacheRespQ.deq();
        if (debug) $display("getToProc:\tdata=0x%h\n--------------\n", re);
        return re;
    endmethod

    method ActionValue#(MainMemReq) getToMem();
        let re = memReqQ.first();
        memReqQ.deq();
        return re;
    endmethod

    method Action putFromMem(MainMemResp e);
        memRespQ.enq(e);
    endmethod
endmodule
