// PIPELINED SINGLE CORE PROCESSOR WITH 2 LEVEL CACHE
import RVUtil::*;
import BRAM::*;
import pipelined::*;
import FIFO::*;
import SpecialFIFOs::*;
import MemTypes::*;
import CacheInterface::*;
// typedef Bit#(32) Word;

module mktop_pipelined(Empty);
    // Instantiate the dual ported memory
    // BRAM_Configure cfg = defaultValue();
    // cfg.loadFormat = tagged Hex "mem.vmh";
    // BRAM2PortBE#(Bit#(30), Word, 4) bram <- mkBRAM2ServerBE(cfg);


    CacheInterface cache <- mkCacheInterface();

    RVIfc rv_core <- mkpipelined;
    Reg#(Mem) ireq <- mkRegU;
    FIFO#(Mem) dreq <- mkPipelineFIFO;
    FIFO#(Mem) mmioreq <- mkFIFO;
    let debug = False;
    Reg#(Bit#(32)) cycle_count <- mkReg(0);
    Reg#(Bit#(32)) count_arrived <- mkReg(0);

    rule tic;
	    cycle_count <= cycle_count + 1;
    endrule

    rule requestI;
        let req <- rv_core.getIReq;
        if (debug) $display("Get IReq", fshow(req));
        ireq <= req;

        cache.sendReqInstr(CacheReq{word_byte: req.byte_en, addr: req.addr, data: req.data});

            // bram.portB.request.put(BRAMRequestBE{
            //         writeen: req.byte_en,
            //         responseOnWrite: True,
            //         address: truncate(req.addr >> 2),
            //         datain: req.data});
    endrule

    rule responseI;
        let x <- cache.getRespInstr();
        // let x <- bram.portB.response.get();
        let req = ireq;
        if (debug) $display("Get IResp ", fshow(req), fshow(x));
        req.data = x;
        rv_core.getIResp(req);
    endrule

    rule requestD;
        let req <- rv_core.getDReq;
        dreq.enq(req);
        if (debug) $display("Get DReq", fshow(req));
        // $display("DATA ",fshow(CacheReq{word_byte: req.byte_en, addr: req.addr, data: req.data}));
        cache.sendReqData(CacheReq{word_byte: req.byte_en, addr: req.addr, data: req.data});

        // bram.portA.request.put(BRAMRequestBE{
        //   writeen: req.byte_en,
        //   responseOnWrite: True,
        //   address: truncate(req.addr >> 2),
        //   datain: req.data});
    endrule

    rule responseD;
        // let x <- bram.portA.response.get();
        let x <- cache.getRespData();

        let req = dreq.first;
        dreq.deq();
        if (debug) $display("Get DResp ", fshow(req), fshow(x));
        req.data = x;
            rv_core.getDResp(req);
    endrule

    rule requestMMIO;
        let req <- rv_core.getMMIOReq;
        if (debug) $display("Get MMIOReq", fshow(req));
        if (req.byte_en == 'hf) begin
            if (req.addr == 'hf000_fff4) begin
                // Write integer to STDERR
                        $fwrite(stderr, "%0d", req.data);
                        $fflush(stderr);
            end
        end
        if (req.addr ==  'hf000_fff0) begin
                // Writing to STDERR
                $fwrite(stderr, "%c", req.data[7:0]);
                $fflush(stderr);
        end else
            if (req.addr == 'hf000_fff8) begin
                $display("RAN CYCLES", cycle_count);

            // Exiting Simulation
                if (req.data == 0) begin

                    if (count_arrived == 0 ) $fdisplay(stderr, "  [0;32mPASS first thread [0m");
                    if (count_arrived == 1 ) $fdisplay(stderr, "  [0;32mPASS second thread [0m");
                end
                else
                    begin
                         if (count_arrived == 0) $fdisplay(stderr, "  [0;31mFAIL first thread[0m (%0d)", req.data);
                         if (count_arrived == 1) $fdisplay(stderr, "  [0;31mFAIL second thread[0m (%0d)", req.data);
                    end
                $fflush(stderr);
                count_arrived <= count_arrived + 1;
                if (count_arrived == 1) $finish;
            end

        mmioreq.enq(req);
    endrule

    rule responseMMIO;
        let req = mmioreq.first();
        mmioreq.deq();
        if (debug) $display("Put MMIOResp", fshow(req));
        rv_core.getMMIOResp(req);
    endrule

endmodule
