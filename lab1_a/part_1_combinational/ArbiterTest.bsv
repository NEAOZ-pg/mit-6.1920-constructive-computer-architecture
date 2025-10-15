import Vector::*;
import BuildVector::*;
import RegFile::*;
import StmtFSM :: *;
import CombArbiter::*;

module mkTest(Empty);
   RegFile#(Bit#(4), Vector#(16,Tuple2#(Bit#(1),Bit#(31)))) tests <- mkRegFileFullLoad("arbitertests.hex");
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
               Vector#(16, Bit#(1)) valid = replicate(0);
               Vector#(16, Bit#(31)) data= replicate(0);
               for (Integer i= 0; i<16; i= i+1) begin 
                  valid[i] = tpl_1(test[i]);
                  data[i] = tpl_2(test[i]);
               end
               let resArbiterStudent = arbitrate(valid, data);
               if (resArbiterStudent.valid) begin 
                  if (valid[resArbiterStudent.index] != 1) begin 
                      $display("Test vector is ready: %x, data: ", valid, fshow(data));
                      $display("Student's arbiter suggested the nonready index %d",resArbiterStudent.index);
                      $finish(1);
                  end
                  if (data[resArbiterStudent.index] != resArbiterStudent.data) begin 
                      $display("Test vector is ready: %x, data: ", valid, fshow(data));
                      $display("Student's arbiter returned incorrect value %d",resArbiterStudent.index);
                      $finish(1);
                  end
               end
               else begin 
                  Bool allInvalid = True;
                  for (Integer i = 0; i<16; i=i+1) begin 
                     if (valid[i]==1) allInvalid = False;
                  end
                  if (!allInvalid) begin 
                      $display("Test vector is ready: %x, data: ", valid, fshow(data));
                      $display("Student's arbiter failed to find a ready entry while such an entry existed");
                      $finish(1);
                  end
               end

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
