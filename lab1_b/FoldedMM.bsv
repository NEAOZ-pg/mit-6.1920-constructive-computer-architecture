import Vector::*;
import BRAM::*;

// Time Spent:

interface MM;
    method Action write_row_a(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action write_row_b(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action start();
    method ActionValue#(Vector#(16, Bit#(32))) resp_row_c();
endinterface

module mkMatrixMultiplyFolded(MM);
    BRAM_Configure cfgA = defaultValue;
    BRAM1Port#(Bit#(8), Bit#(32)) a <- mkBRAM1Server(cfgA);

    BRAM_Configure cfgB = defaultValue;
    BRAM1Port#(Bit#(8), Bit#(32)) b <- mkBRAM1Server(cfgB);

    Reg#(Bool) isStartCal <- mkReg(False);
    Reg#(Bool) a_write_ready <- mkReg(True);
    Reg#(Bit#(4)) a_write_num <- mkRegU;
    Reg#(Bit#(4)) a_row_idx <- mkRegU;
    Vector#(16, Reg#(Bit#(32))) aRowbuf <- replicateM(mkRegU);
    Reg#(Bool) b_write_ready <- mkReg(True);
    Reg#(Bit#(4)) b_write_num <- mkRegU;
    Reg#(Bit#(4)) b_row_idx <- mkRegU;
    Vector#(16, Reg#(Bit#(32))) bRowbuf <- replicateM(mkRegU);

    Reg#(Bit#(4)) calRowNum <- mkRegU;
    Reg#(Bit#(4)) calColRowNum <- mkRegU;
    Reg#(Bit#(4)) calColNum <- mkRegU;
    Reg#(Bool) isCalRow <- mkReg(False);
    Reg#(Bool) req_a_ready <- mkReg(True);
    Reg#(Bool) req_b_ready <- mkReg(True);

    rule do_write_a (!a_write_ready);
        // $display("a %d", aRowbuf[a_write_num]);
        // $display("row %d    col %d", a_row_idx, a_write_num);
        a.portA.request.put(BRAMRequest{write: True, // False for read
                                        responseOnWrite: False,
                                        address: zeroExtend(a_row_idx) * 16 + zeroExtend(a_write_num),
                                        datain: aRowbuf[a_write_num]});
        a_write_num <= a_write_num + 1;
        if (a_write_num == 15)
            a_write_ready <= True;
    endrule

    rule do_write_b (!b_write_ready);
        // $display("b %d", bRowbuf[b_write_num]);
        // $display("row %d    col %d", b_row_idx, b_write_num);
        b.portA.request.put(BRAMRequest{write: True, // False for read
                                        responseOnWrite: False,
                                        address: zeroExtend(b_row_idx) * 16 + zeroExtend(b_write_num),
                                        datain: bRowbuf[b_write_num]});
        b_write_num <= b_write_num + 1;
        if (b_write_num == 15)
            b_write_ready <= True;
    endrule

    rule process_a (isCalRow && !req_a_ready);
        // $display("row %d    col %d", calRowNum, calColRowNum);
        a.portA.request.put(BRAMRequest{write: False, // False for read
                            responseOnWrite: False,
                            address: zeroExtend(calRowNum) * 16 + zeroExtend(calColRowNum),
                            datain: ?});
        req_a_ready <= True;
    endrule

    rule process_b (isCalRow && !req_b_ready);
        // $display("row %d    col %d", calRowNum, calColRowNum);
        b.portA.request.put(BRAMRequest{write: False, // False for read
                responseOnWrite: False,
                address: zeroExtend(calColRowNum) * 16 + zeroExtend(calColNum),
                datain: ?});
        req_b_ready <= True;
    endrule

    rule do_cal_c (isStartCal && isCalRow && req_a_ready && req_b_ready);
        if (calColRowNum == 15) begin
            if (calColNum == 15) begin
                isCalRow <= False;
            end
            calColNum <= calColNum + 1;
        end
        calColRowNum <= calColRowNum + 1;

        let out_a <- a.portA.response.get();
        let out_b <- b.portA.response.get();
        $display("a=%d  b=%d\n", out_a, out_b);
        aRowbuf[calColNum] <= aRowbuf[calColNum] + out_a * out_b;
        req_a_ready <= False;
        req_b_ready <= False;
    endrule


    method Action write_row_a(Vector#(16, Bit#(32)) row, Bit#(4) row_idx) if (a_write_ready && !isStartCal);
        a_write_ready <= False;
        a_write_num <= 0;
        a_row_idx <= row_idx;
        for (Integer i = 0; i < 16; i = i + 1) begin
            aRowbuf[i] <= row[i];
        end
    endmethod

    method Action write_row_b(Vector#(16, Bit#(32)) row, Bit#(4) row_idx) if (b_write_ready && !isStartCal);
        b_write_ready <= False;
        b_write_num <= 0;
        b_row_idx <= row_idx;
        for (Integer i = 0; i < 16; i = i + 1) begin
            bRowbuf[i] <= row[i];
        end
    endmethod

    method Action start() if (a_write_ready && b_write_ready && !isStartCal);
        isStartCal <= True;
        calRowNum <= 0;
        calColRowNum <= 0;
        calColNum <= 0;
        isCalRow <= True;
        req_a_ready <= False;
        req_b_ready <= False;
        for (Integer i = 0; i < 16; i = i + 1) begin
            aRowbuf[i] <= 0;
        end
    endmethod

    method ActionValue#(Vector#(16, Bit#(32))) resp_row_c() if (isStartCal && isCalRow == False);
        if (calRowNum == 15) begin
            isStartCal <= False;
            isCalRow <= False;
        end
        else begin
            isCalRow <= True;
        end
        calRowNum <= calRowNum + 1;
        req_a_ready <= False;
        req_b_ready <= False;

        Vector#(16, Bit#(32)) values = replicate(0);
        for (Integer i = 0; i < 16; i = i + 1) begin
            $display("%d", aRowbuf[i]);
            values[i] = aRowbuf[i];
        end

        for (Integer i = 0; i < 16; i = i + 1) begin
                aRowbuf[i] <= 0;
        end
        return values;
    endmethod


endmodule
