import List :: *;
import GetPut :: *;
import StmtFSM :: *;
import Vector::*;         
import BuildVector::*;
import ClientServer::*;
import FoldedMM::*;
import RegFile::*;

module mkTb(Empty);
   Reg#(int) ctr <- mkReg(0);
   rule inc_ctr;
      ctr <= ctr+1;
   endrule
   RegFile#(Bit#(4), Vector#(16,Vector#(16,Bit#(32)))) tests <- mkRegFileFullLoad("test.hex");
   MM mma <- mkMatrixMultiplyFolded();

   Reg#(Bool) verbose <- mkReg(True);
   Reg#(Bit#(10)) ctr_fsm <- mkReg(0);
   Reg#(Bit#(4)) test_number <- mkReg(0);
 
   Stmt random_test =
     (seq 
      while (1'b0 == 1'b0)
         seq
            action 
               $display("Start test %d", test_number/3);
               ctr_fsm <= 0;
            endaction
            while (ctr_fsm < 16)
               action 
                  ctr_fsm <= ctr_fsm + 1;
                  if (verbose) $display("A[%d,:] ", ctr_fsm, fshow( tests.sub(test_number)[ctr_fsm]));
                  if (verbose) $display("B[%d,:] ", ctr_fsm, fshow( tests.sub(test_number+1)[ctr_fsm]));
                  mma.write_row_a(tests.sub(test_number)[ctr_fsm], truncate(ctr_fsm));
                  mma.write_row_b(tests.sub(test_number+1)[ctr_fsm], truncate(ctr_fsm));
               endaction
            action
               ctr_fsm <= 0;
               mma.start();
            endaction
            while(ctr_fsm < 16)
               action 
                  ctr_fsm <= ctr_fsm + 1;
                  let x <- mma.resp_row_c();
                  let expected = tests.sub(test_number+2)[ctr_fsm];
                  if (x != expected) begin
                   $display("Row number", ctr_fsm, fshow(x));
                   $display("Expected ", fshow(expected));
                   $finish(1);
                  end else 
                          $display("Rows %d matches", ctr_fsm);
               endaction
            action 
               if (test_number == 9) begin 
                  $display("Test passed");
                  $finish(0);
               end else 
                  test_number <= test_number + 3;
            endaction
         endseq
     endseq);
 
   FSM test_fsm <- mkFSM(random_test);

   // A register to control the start rule
   Reg#(Bool) going <- mkReg(False);

   // This rule kicks off the test FSM, which then runs to completion.
   rule start (!going);
      going <= True;
      test_fsm.start;
   endrule
endmodule 
