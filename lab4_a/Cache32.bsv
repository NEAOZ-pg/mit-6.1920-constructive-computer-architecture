// SINGLE CORE ASSOIATED CACHE -- stores words

import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import Vector :: * ;

// The types live in MemTypes.bsv

// Notice the asymmetry in this interface, as mentioned in lecture.
// The processor thinks in 32 bits, but the other side thinks in 512 bits.
interface Cache32;
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

// delete when you're done with it

(* synthesize *)
module mkCache32(Cache32);
    BRAM_Configure cfgData = defaultValue;
    cfgData.memorySize = valueOf(CacheLineSize);
    cfgData.loadFormat = tagged Binary "./zero512.vmh";
    BRAM1Port#(LineIndex, LineBits) cacheData <- mkBRAM1Server(cfgData);

    BRAM_Configure cfgTag = defaultValue;
    cfgTag.memorySize = valueOf(CacheLineSize);
    cfgTag.loadFormat = tagged Binary "./zero.vmh";
    BRAM1Port#(LineIndex, LineTag) cacheTag <- mkBRAM1Server(cfgTag);

    BRAM_Configure cfgState = defaultValue;
    cfgState.memorySize = valueOf(CacheLineSize);
    cfgState.loadFormat = tagged Binary "./zero.vmh";
    BRAM1Port#(LineIndex, LineState) cacheState <- mkBRAM1Server(cfgState);

    // the second argument is the type being held, and the first argument is the address type (3rd would be byte enable specifics)
    FIFO#(CacheReq) cacheReqQ <- mkFIFO;
    FIFO#(Word)  cacheRespQ <- mkBypassFIFO;
    FIFO#(MainMemReq)  memReqQ <- mkFIFO;
    FIFO#(MainMemResp)  memRespQ <- mkFIFO;
    // You may instead find it useful to use the CacheArrayUnit abstraction presented
    // in lecture. In that case, most of your logic would be in that module, which you
    // can instantiate within this one.

    // Hint: Refer back to the slides for implementation details.
    // Hint: You may find it helpful to outline the necessary states and rules you'll need for your cache
    // Hint: Don't forget about $display
    // Hint: If you want to add in a store buffer, do it after getting it working without one.
    Reg#(ReqStatus) mshr <- mkReg(Ready);

    Reg#(Bool) debug <- mkReg(False);

    Reg#(Word) ticks <- mkReg(0);
    Reg#(Word) cnt <- mkReg(0);

    rule tick;
        ticks <= ticks + 1;
        if (debug) $display("tick=%d mshr=%d\n", ticks, mshr);
    endrule

    rule startJudgeHit if (mshr == StartMiss);
        let data <- cacheData.portA.response.get();
        let tag <- cacheTag.portA.response.get();
        let state <- cacheState.portA.response.get();
        let e = cacheReqQ.first();
        let cacheParse = parseAddress(e.addr);

        if (state != Invalid && cacheParse.tag == tag) begin
            if (debug) $display("StartMiss:\taddr=0x%h\twrite=%b\tdata=0x%h\n--hit\tstate=%d\ttag=0x%h\tindex=0x%h\n", e.addr, e.word_byte, e.data, state, cacheParse.tag, cacheParse.index);
            cacheReqQ.deq();
            LineBitsAddrSize daddr = zeroExtend(cacheParse.l) << 5;
            if (e.word_byte == 0) begin   // read
                cacheRespQ.enq((data >> daddr)[valueOf(WordSize)-1:0]);
            end
            else begin  // write
                Bit#(WordSize) mask = {
                    (e.word_byte[3] == 1) ? 8'hFF : 8'h00,
                    (e.word_byte[2] == 1) ? 8'hFF : 8'h00,
                    (e.word_byte[1] == 1) ? 8'hFF : 8'h00,
                    (e.word_byte[0] == 1) ? 8'hFF : 8'h00
                };
                Bit#(LineBitsSize) new_line = (data & (~(zeroExtend(mask) << daddr))) | (zeroExtend(e.data & mask) << daddr);
                BRAMRequest#(LineIndex, LineBits) reqCacheData = BRAMRequest {
                    write: True,
                    responseOnWrite: False,
                    address: cacheParse.index,
                    datain: new_line
                };
                cacheData.portA.request.put(reqCacheData);
                // cache state
                if (state == Clean) begin
                    BRAMRequest#(LineIndex, LineState) reqCacheState = BRAMRequest {
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
            if (debug) $display("StartMiss:\taddr=0x%h\twrite=%b\tdata=0x%h\n--miss\tstate=%d\ttag=0x%h\tindex=0x%h\n", e.addr, e.word_byte, e.data, state, cacheParse.tag, cacheParse.index);
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
        let cacheParse = parseAddress(e.addr);
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
        let cacheParse = parseAddress(e.addr);
        if (e.word_byte == 0) begin   // read
            LineBitsAddrSize daddr = zeroExtend(cacheParse.l) << 5;
            Word readData = (line >> daddr)[valueOf(WordSize)-1:0];
            cacheRespQ.enq(readData);
            if (debug) $display("WaitFillResp:\taddr=0x%h\twrite=%b\tdata=0x%h\ntag=0x%h\tindex=0x%h\tdaddr=%d\nline=\t0x%h\nread=\t0x%h\t\n", e.addr, e.word_byte, e.data, cacheParse.tag, cacheParse.index, daddr, line, readData);
            // update the bram
            BRAMRequest#(LineIndex, LineBits) reqCacheData = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: line
            };

            BRAMRequest#(LineIndex, LineTag) reqCacheTag = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: cacheParse.tag
            };

            BRAMRequest#(LineIndex, LineState) reqCacheState = BRAMRequest {
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
            LineBitsAddrSize daddr = zeroExtend(cacheParse.l) << 5;
            // update the bram
            Bit#(WordSize) mask = {
                (e.word_byte[3] == 1) ? 8'hFF : 8'h00,
                (e.word_byte[2] == 1) ? 8'hFF : 8'h00,
                (e.word_byte[1] == 1) ? 8'hFF : 8'h00,
                (e.word_byte[0] == 1) ? 8'hFF : 8'h00
            };
            Bit#(LineBitsSize) new_line = (line & (~(zeroExtend(mask) << daddr))) | (zeroExtend(e.data & mask) << daddr);
            if (debug) $display("WaitFillResp:\taddr=0x%h\twrite=%b\tdata=0x%h\nline=\t0x%h\nnew=\t0x%h\n\n", e.addr, e.word_byte, e.data, line, new_line);
            BRAMRequest#(LineIndex, LineBits) reqCacheData = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: new_line
            };

            BRAMRequest#(LineIndex, LineTag) reqCacheTag = BRAMRequest {
                write: True,
                responseOnWrite: False,
                address: cacheParse.index,
                datain: cacheParse.tag
            };

            BRAMRequest#(LineIndex, LineState) reqCacheState = BRAMRequest {
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

    method Action putFromProc(CacheReq e) if (mshr == Ready);
        cnt <= cnt + 1;
        let cacheParse = parseAddress(e.addr);
        if (debug) $display("-----cnt:%d------\nputFromProc:\taddr=0x%h\twrite=%b\tdata=0x%h\n", cnt, e.addr, e.word_byte, e.data);

        cacheReqQ.enq(e);

        BRAMRequest#(LineIndex, LineBits) reqCacheData = BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: cacheParse.index,
            datain: ?
        };

        BRAMRequest#(LineIndex, LineTag) reqCacheTag = BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: cacheParse.index,
            datain: ?
        };

        BRAMRequest#(LineIndex, LineState) reqCacheState = BRAMRequest {
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

    method ActionValue#(Word) getToProc();
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
