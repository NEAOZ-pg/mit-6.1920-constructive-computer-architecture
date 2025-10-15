import List :: *;
import GetPut :: *;
import StmtFSM :: *;
import Vector::*;         
import BuildVector::*;
import ClientServer::*;
import VectorDot::*;
import RegFile::*;

//RESULT SHOULD BE 354

(* synthesize *)
module mkTb(Empty);

   Reg#(int) ctr <- mkReg(0);
   rule inc_ctr;
      ctr <= ctr+1;
   endrule
   VD mma <- mkVectorDot();

   // A register to control the start rule
   Reg#(Bool) going <- mkReg(True);

   RegFile#(Bit#(2), Bit#(32)) tests <- mkRegFileFullLoad("v3.hex");


   Reg#(Bit#(2)) i <- mkReg(0);

   // This rule kicks off the test FSM, which then runs to completion.
   rule start (going);
      $display("STARTING TEST FOR VECTOR DOT PRODUCT DIM 16... index %d", i);
      going <= False;
      // test_fsm.start;
      mma.start(16, i);
      
   endrule

   rule resp (!going);
      let res <- mma.response();
      $display("GOT ",res,"");
      if (res == tests.sub(i)) $display("Test %d passed",i);
      else $display("Expected %d for test %d",tests.sub(i), i);
      going <= True;
      if (i < 3)
         i <= i+1;
      else
         $finish(1);
   endrule
endmodule 
