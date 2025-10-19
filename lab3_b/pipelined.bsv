import FIFO::*;
import SpecialFIFOs::*;
import RegFile::*;
import RVUtil::*;
import Vector::*;
import KonataHelper::*;
import Printf::*;
import Ehr::*;
import Scoreboard::*;

typedef struct { Bit#(4) byte_en; Bit#(32) addr; Bit#(32) data; } Mem deriving (Eq, FShow, Bits);

interface RVIfc;
    method ActionValue#(Mem) getIReq();
    method Action getIResp(Mem a);
    method ActionValue#(Mem) getDReq();
    method Action getDResp(Mem a);
    method ActionValue#(Mem) getMMIOReq();
    method Action getMMIOResp(Mem a);
endinterface
typedef struct { Bool isUnsigned; Bit#(2) size; Bit#(2) offset; Bool mmio; } MemBusiness deriving (Eq, FShow, Bits);

function Bool isMMIO(Bit#(32) addr);
    Bool x = case (addr)
        32'hf000fff0: True;
        32'hf000fff4: True;
        32'hf000fff8: True;
        default: False;
    endcase;
    return x;
endfunction

typedef struct { Bit#(32) pc;
                 Bit#(32) ppc;
                 Bit#(1) epoch;
                 KonataId k_id; // <- This is a unique identifier per instructions, for logging purposes
             } F2D deriving (Eq, FShow, Bits);

typedef struct {
    DecodedInst dinst;
    Bit#(32) pc;
    Bit#(32) ppc;
    Bit#(1) epoch;
    Bit#(32) rv1;
    Bit#(32) rv2;
    KonataId k_id; // <- This is a unique identifier per instructions, for logging purposes
    } D2E deriving (Eq, FShow, Bits);

typedef struct {
    MemBusiness mem_business;
    Bit#(32) data;
    DecodedInst dinst;
    KonataId k_id; // <- This is a unique identifier per instructions, for logging purposes
} E2W deriving (Eq, FShow, Bits);

(* synthesize *)
module mkpipelined(RVIfc);
    // Interface with memory and devices
    FIFO#(Mem) toImem <- mkBypassFIFO;
    FIFO#(Mem) fromImem <- mkBypassFIFO;
    FIFO#(Mem) toDmem <- mkBypassFIFO;
    FIFO#(Mem) fromDmem <- mkBypassFIFO;
    FIFO#(Mem) toMMIO <- mkBypassFIFO;
    FIFO#(Mem) fromMMIO <- mkBypassFIFO;

    Ehr#(3, Bit#(32)) pc <- mkEhr(0);
    Vector#(32, Ehr#(2, Bit#(32))) rf <- replicateM(mkEhr(0));
    ScoreboardIfc sb <- mkScoreboard;

    Reg#(Bit#(1)) epoch <- mkReg(0);

    FIFO#(F2D) f2d <- mkFIFO;
    FIFO#(D2E) d2e <- mkFIFO;
    FIFO#(E2W) e2w <- mkFIFO;

	// Code to support Konata visualization
    String dumpFile = "output.log" ;
    let lfh <- mkReg(InvalidFile);
	  Reg#(KonataId) fresh_id <- mkReg(0);
	  Reg#(KonataId) commit_id <- mkReg(0);

	  FIFO#(KonataId) retired <- mkFIFO;
	  FIFO#(KonataId) squashed <- mkFIFO;

    Reg#(Bool) starting <- mkReg(True);
	rule do_tic_logging;
        if (starting) begin
            let f <- $fopen(dumpFile, "w") ;
            lfh <= f;
            $fwrite(f, "Kanata\t0004\nC=\t1\n");
            starting <= False;
        end
		konataTic(lfh);
	endrule

    function Bit#(32) nap(Bit#(32) _pc);
        return _pc + 4;
    endfunction

    rule fetch if (!starting);
        Bit#(32) pc_fetched = pc[0];
        // You should put the pc that you fetch in pc_fetched
        // Below is the code to support Konata's visualization
		    let iid <- fetch1Konata(lfh, fresh_id, 0);
        labelKonataLeft(lfh, iid, $format("0x%x: ", pc_fetched));

        let req = Mem{byte_en: 0,
                      addr: pc_fetched,
                      data: 0};
        toImem.enq(req);

        let pc_predicted = nap(pc_fetched);
        pc[0] <= pc_predicted;
        f2d.enq(F2D{pc: pc_fetched,
                    ppc: pc_predicted,
                    epoch: epoch,
                    k_id: iid});
        // This will likely end with something like:
        // f2d.enq(F2D{ ..... k_id: iid});
        // iid is the unique identifier used by konata, that we will pass around everywhere for each instruction
    endrule

    rule decode if (!starting);
        // TODO
        let resp = fromImem.first(); // `deq` called only if on stall occurred
        let instr = resp.data;
        let decodedInst = decodeInst(instr);

        let rd_idx = getInstFields(instr).rd;
        // let waw = sb.searchd(rd_idx) && decodedInst.valid_rd && (rd_idx != 0);

        let rs1_idx = getInstFields(instr).rs1;
        let rs1 = (rs1_idx == 0) ? 0 : rf[rs1_idx][1];
        let raw1 = sb.search1(rs1_idx) && decodedInst.valid_rs1 && (rs1_idx != 0);

        let rs2_idx = getInstFields(instr).rs2;
        let rs2 = (rs2_idx == 0) ? 0 : rf[rs2_idx][1];
        let raw2 = sb.search2(rs2_idx) && decodedInst.valid_rs2 && (rs2_idx != 0);

        // let stall = waw || raw1 || raw2;
        let stall = raw1 || raw2;
        if (!stall) begin
            fromImem.deq();
            let tmp = f2d.first(); f2d.deq();

            decodeKonata(lfh, tmp.k_id);
            labelKonataLeft(lfh, tmp.k_id, $format("DASM(%x)", instr));
            // To add a decode event in Konata you will likely do something like:
            //  let from_fetch = f2d.first();
            //	decodeKonata(lfh, from_fetch.k_id);
            //  labelKonataLeft(lfh,from_fetch.k_id, $format("Any information you would like to put in the left pane in Konata, attached to the current instruction"));
            if (decodedInst.valid_rd && (rd_idx != 0)) begin
                sb.insert(rd_idx);
            end
            d2e.enq(D2E{dinst: decodedInst,
                        pc: tmp.pc,
                        ppc: tmp.ppc,
                        epoch: tmp.epoch,
                        rv1: rs1,
                        rv2: rs2,
                        k_id: tmp.k_id});
        end
    endrule

    function Bit#(1) next(Bit#(1) _epoch);
        return ~_epoch;
    endfunction

    rule execute if (!starting);
        // TODO
        let tmp = d2e.first(); d2e.deq();

        let inEp = tmp.epoch;
        let dInst = tmp.dinst;
        if (inEp == epoch) begin
            executeKonata(lfh, tmp.k_id);
        // Similarly, to register an execute event for an instruction:
    	//	executeKonata(lfh, k_id);
    	// where k_id is the unique konata identifier that has been passed around that came from the fetch stage
            let imm = getImmediate(dInst);
            Bool mmio = False;
            let data = execALU32(dInst.inst, tmp.rv1, tmp.rv2, imm, tmp.pc);
            let isUnsigned = 0;
            let funct3 = getInstFields(dInst.inst).funct3;
            let size = funct3[1:0];
            let addr = tmp.rv1 + imm;
            Bit#(2) offset = addr[1:0];
            if (isMemoryInst(dInst)) begin
                // Technical details for load byte/halfword/word
                let shift_amount = {offset, 3'b0};
                let byte_en = 0;
                case (size) matches
                    2'b00: byte_en = 4'b0001 << offset;
                    2'b01: byte_en = 4'b0011 << offset;
                    2'b10: byte_en = 4'b1111 << offset;
                endcase
                data = tmp.rv2 << shift_amount;
                addr = {addr[31:2], 2'b00};
                isUnsigned = funct3[2];
                let type_mem = (dInst.inst[5] == 1) ? byte_en : 0;
                let req = Mem{byte_en: type_mem,
                              addr: addr,
                              data: data};
                if (isMMIO(addr)) begin
                    toMMIO.enq(req);
                    labelKonataLeft(lfh, tmp.k_id, $format(" (MMIO) ", fshow(req)));
                    mmio = True;
                end
                else begin
                    labelKonataLeft(lfh, tmp.k_id, $format(" (MEM) ", fshow(req)));
                    toDmem.enq(req);
                end
            end
            else if (isControlInst(dInst)) begin
                labelKonataLeft(lfh, tmp.k_id, $format(" (CTRL)"));
                data = tmp.pc + 4;
            end
            else begin
                labelKonataLeft(lfh, tmp.k_id, $format(" (ALU)"));
            end

            let controlResult = execControl32(dInst.inst, tmp.rv1, tmp.rv2, imm, tmp.pc);
            let nextPc = controlResult.nextPC;

            if (tmp.ppc != nextPc) begin
                pc[1] <= nextPc;
                epoch <= next(epoch);
            end

            e2w.enq(E2W{mem_business: MemBusiness{isUnsigned: unpack(isUnsigned),
                                                  size: size,
                                                  offset: offset,
                                                  mmio: mmio},
                        data: data,
                        dinst: dInst,
                        k_id: tmp.k_id});
        end
        else begin // squash
            let rd_idx = getInstFields(dInst.inst).rd;
            if (dInst.valid_rd && rd_idx != 0) begin
                sb.eRemove(rd_idx);
            end

            squashed.enq(tmp.k_id);
        end
    	// Execute is also the place where we advise you to kill mispredicted instructions
    	// (instead of Decode + Execute like in the class)
    	// When you kill (or squash) an instruction, you should register an event for Konata:

        // squashed.enq(current_inst.k_id);

        // This will allow Konata to display those instructions in grey
    endrule

    rule writeback if (!starting);
        // TODO
        let tmp = e2w.first(); e2w.deq();

        writebackKonata(lfh, tmp.k_id);
        // Similarly, to register an execute event for an instruction:
	   	//	writebackKonata(lfh,k_id);
        retired.enq(tmp.k_id);
	   	// In writeback is also the moment where an instruction retires (there are no more stages)
	   	// Konata requires us to register the event as well using the following:
		// retired.enq(k_id);
        let data = tmp.data;
        let dInst = tmp.dinst;
        let fields = getInstFields(dInst.inst);
        if (isMemoryInst(dInst)) begin // (* // write_val *)
            let resp = ?;
            if (tmp.mem_business.mmio) begin
                resp = fromMMIO.first(); fromMMIO.deq();
            end
            else begin
                resp = fromDmem.first(); fromDmem.deq();
            end
            let mem_data = resp.data;
            mem_data = mem_data >> {tmp.mem_business.offset, 3'b0};
            case ({pack(tmp.mem_business.isUnsigned),
                   tmp.mem_business.size}) matches
                3'b000: data = signExtend(mem_data[ 7:0]);
                3'b001: data = signExtend(mem_data[15:0]);
                3'b100: data = signExtend(mem_data[ 7:0]);
                3'b101: data = signExtend(mem_data[15:0]);
                3'b010: data = mem_data;    // ld memory post operation here, no need for cache to cut out or extend
            endcase
        end
        if (!dInst.legal) begin
            pc[2] <= 0;
        end
        if (dInst.valid_rd) begin
            let rd_idx = fields.rd;
            if (rd_idx != 0) begin
                rf[rd_idx][0] <= data;
                sb.wRemove(rd_idx);
            end
        end
	endrule


	// ADMINISTRATION:

    rule administrative_konata_commit;
		    retired.deq();
		    let f = retired.first();
		    commitKonata(lfh, f, commit_id);
	endrule

	rule administrative_konata_flush;
		    squashed.deq();
		    let f = squashed.first();
		    squashKonata(lfh, f);
	endrule

    method ActionValue#(Mem) getIReq();
		toImem.deq();
		return toImem.first();
    endmethod
    method Action getIResp(Mem a);
    	fromImem.enq(a);
    endmethod
    method ActionValue#(Mem) getDReq();
		toDmem.deq();
		return toDmem.first();
    endmethod
    method Action getDResp(Mem a);
		fromDmem.enq(a);
    endmethod
    method ActionValue#(Mem) getMMIOReq();
		toMMIO.deq();
		return toMMIO.first();
    endmethod
    method Action getMMIOResp(Mem a);
		fromMMIO.enq(a);
    endmethod
endmodule
