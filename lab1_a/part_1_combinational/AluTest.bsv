import Vector::*;
import BuildVector::*;
import RegFile::*;
import StmtFSM :: *;
import Alu::*;

module mkTest(Empty);
   RegFile#(Bit#(4),  Tuple3#(Bit#(32), Bit#(32), Bit#(32))) tests <- mkRegFileFullLoad("alutests.hex");
   Reg#(Bool) verbose <- mkReg(True);
   Reg#(Bit#(10)) ctr_fsm <- mkReg(0);
   Stmt random_test =
     (seq
         action 
            ctr_fsm <= 0;
         endaction
         while (ctr_fsm < 4)
            action 
               // Add
               ctr_fsm <= ctr_fsm + 1;
               let test = tests.sub(truncate(ctr_fsm));
               Tuple3#(Bit#(32), Bit#(32), Bit#(32)) req = test;
               let v1 = tpl_1(req);
               let v2 = tpl_2(req);
               let resp = tpl_3(req);
               let resStudent = alu(Add, v1 ,v2);
               if (resp != resStudent) begin
                    $display("The test expected that :", fshow(Add), " %x %x = %x", v1, v2, resp);
                    $display("The design under test produced instead the value", resStudent);
                    $finish(1);
               end
            endaction
         action
            ctr_fsm <= 0;
         endaction
         while (ctr_fsm < 4)
            action 
               // Shift
               ctr_fsm <= ctr_fsm + 1;
               let test = tests.sub(truncate(ctr_fsm + 4));
               Tuple3#(Bit#(32), Bit#(32), Bit#(32)) req = test;
               let v1 = tpl_1(req);
               let v2 = tpl_2(req);
               let resp = tpl_3(req);
               let resStudent = alu(ShiftL, v1 ,v2);
               if (resp != resStudent) begin
                    $display("The test expected that :", fshow(ShiftL), " %x %x = %x", v1, v2, resp);
                    $display("The design under test produced instead the value", resStudent);
                    $finish(1);
               end
            endaction
         action
            ctr_fsm <= 0;
         endaction
         while (ctr_fsm < 4)
            action 
               // Shift
               ctr_fsm <= ctr_fsm + 1;
               let test = tests.sub(truncate(ctr_fsm + 8));
               Tuple3#(Bit#(32), Bit#(32), Bit#(32)) req = test;
               let v1 = tpl_1(req);
               let v2 = tpl_2(req);
               let resp = tpl_3(req);
               let resStudent = alu(And, v1 ,v2);
               if (resp != resStudent) begin
                    $display("The test expected that :", fshow(And), " %x %x = %x", v1, v2, resp);
                    $display("The design under test produced instead the value %x", resStudent);
                    $finish(1);
               end
            endaction
         action
            ctr_fsm <= 0;
         endaction
         while (ctr_fsm < 4)
            action 
               // Shift
               ctr_fsm <= ctr_fsm + 1;
               let test = tests.sub(truncate(ctr_fsm + 12));
               Tuple3#(Bit#(32), Bit#(32), Bit#(32)) req = test;
               let v1 = tpl_1(req);
               let v2 = tpl_2(req);
               let resp = tpl_3(req);
               let resStudent = alu(Not, v1 ,v2);
               if (resp != resStudent) begin
                    $display("The test expected that :", fshow(Not), " %x %x = %x", v1, v2, resp);
                    $display("The design under test produced instead the value %x", resStudent);
                    $finish(1);
               end
            endaction
         action
            ctr_fsm <= 0;
         endaction
         action
            $display("Test passed");
            $finish(0);
        endaction
      endseq);
 
   FSM test_fsm <- mkFSM(random_test);
   Reg#(Bool) going <- mkReg(False);

   rule start (!going);
      going <= True;
      test_fsm.start;
   endrule
endmodule
