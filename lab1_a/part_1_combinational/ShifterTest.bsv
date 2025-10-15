import Vector::*;
import BuildVector::*;
import RegFile::*;
import StmtFSM :: *;
import Shifter::*;

module mkTest(Empty);
   RegFile#(Bit#(4), Tuple2#(Bit#(4),Vector#(16,Bit#(16)))) tests <- mkRegFileFullLoad("shiftertests.hex");
   Reg#(Bool) verbose <- mkReg(True);
   Reg#(Bit#(10)) ctr_fsm <- mkReg(0);
   Stmt random_test =
     (seq
         action 
            ctr_fsm <= 0;
         endaction
         while (ctr_fsm < 16)
            action 
               ctr_fsm <= ctr_fsm + 1;
               let test = tests.sub(truncate(ctr_fsm));
               let shftAmnt = tpl_1(test);
               let data = tpl_2(test);
               let reference = naiveShfl(data, shftAmnt);
               let resStudent = barrelLeft(data, shftAmnt);
               if (reference != resStudent) begin
                    $display("The reference design said:", fshow(data), " shifted left by %d ", shftAmnt, "=", fshow(reference));
                    $display("The design under test gave a result", fshow(resStudent));
                    $finish(1);
               end
            endaction
        action
            $display("Left barrel shifter test passed");
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
