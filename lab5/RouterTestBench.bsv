import Types::*;
import Vector::*;
import Router::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MessageTypes::*;
// import CreditTypes::*;
import RoutingTypes::*;

/*
  Just for Area/Power estimation of a single router
*/
typedef 20 TestCount;

module mkRouterTestBench();
  Router router <- mkRouter;
  Reg#(Bool) started <- mkReg(False);
  Reg#(Bool) sent <- mkReg(False);
  Reg#(Bool) passed <- mkReg(True);
  Reg#(Data) clkCount <- mkReg(0);
  Vector#(NumPorts, Reg#(Data))    receive_counter <- replicateM(mkReg(0));
  Reg#(Data) flitCount <- mkReg(0);
  Vector#(NumPorts, FIFOF#(Flit))  verify_queue <- replicateM(mkBypassFIFOF);

  rule init(!started);
    if(router.isInited) begin
      started <= True;
    end 
  endrule

  rule doCount(started);
    clkCount <= clkCount +1;
  endrule

  rule rl_insertFlits(clkCount < fromInteger(valueOf(TestCount)));
    if(clkCount == 1) begin
      Flit flit0 = ?;Flit flit1 = ?;Flit flit2 = ?;Flit flit3 = ?;Flit flit4 = ?;
      flit0.flitData = 1;
      flit0.nextDir = north_;
      
      flit1.flitData = 2;
      flit1.nextDir = east_;
      
      flit2.flitData = 3;
      flit2.nextDir = south_;
      
      flit3.flitData = 4;
      flit3.nextDir = west_;
      
      flit4.flitData = 5;
      flit4.nextDir = local_;
      
      // Expect 0,1,2,3,4 from port 0,1,2,3,4
      verify_queue[0].enq(flit0); //N->N 0
      router.dataLinks[0].putFlit(flit0);
      $display("[0;33mInsertFlits[0m\t data=%0d into North-input port0: target North-output port0", flit0.flitData);

      verify_queue[1].enq(flit1); //E->E 1
      router.dataLinks[1].putFlit(flit1);
      $display("[0;33mInsertFlits[0m\t data=%0d into East-input port1: target East-output port1", flit1.flitData);
      
      verify_queue[2].enq(flit2); //S->S 2
      router.dataLinks[2].putFlit(flit2);
      $display("[0;33mInsertFlits[0m\t data=%0d into South-input port2: target South-output port2", flit2.flitData);
      
      verify_queue[3].enq(flit3); //W->W 3
      router.dataLinks[3].putFlit(flit3);
      $display("[0;33mInsertFlits[0m\t data=%0d into West-input port3: target West-output port3", flit3.flitData);
      
      verify_queue[4].enq(flit4); //L->L 4
      router.dataLinks[4].putFlit(flit4);
      $display("[0;33mInsertFlits[0m\t data=%0d into Local-input port4: target Local-output port4", flit4.flitData);
      sent <= True;
    end
    else if(clkCount == 2) begin
      Flit flit0 = ?;Flit flit1 = ?;Flit flit2 = ?;Flit flit3 = ?;Flit flit4 = ?;
      flit0.flitData = 6;flit1.flitData = 7;flit2.flitData = 8;flit3.flitData = 9; flit4.flitData = 10;
      // Expect 1,0,3,4,2 from port 0,1,2,3,4
      flit0.nextDir = east_; 
      flit1.nextDir = north_;
      flit2.nextDir = local_;
      flit3.nextDir = south_;
      flit4.nextDir = west_;

      verify_queue[0].enq(flit1); 
      router.dataLinks[0].putFlit(flit0);
      $display("[0;33mInsertFlits[0m\t data=%0d into North-input port0: target East-output port1", flit0.flitData);

      verify_queue[1].enq(flit0); 
      router.dataLinks[1].putFlit(flit1);
      $display("[0;33mInsertFlits[0m\t data=%0d into East-input port1: target North-output port0", flit1.flitData);
      
      verify_queue[2].enq(flit3); 
      router.dataLinks[2].putFlit(flit2);
      $display("[0;33mInsertFlits[0m\t data=%0d into South-input port2: target Local-output port4", flit2.flitData);
      
      verify_queue[3].enq(flit4); 
      router.dataLinks[3].putFlit(flit3);
      $display("[0;33mInsertFlits[0m\t data=%0d into West-input port3: target South-output port2", flit3.flitData);
      
      verify_queue[4].enq(flit2); 
      router.dataLinks[4].putFlit(flit4);
      $display("[0;33mInsertFlits[0m\t data=%0d into Local-input port4: target West-output port3", flit4.flitData);
      sent <= True;
    end
    else if(clkCount == 3) begin
      Flit flit0 = ?;Flit flit1 = ?;Flit flit2 = ?;Flit flit3 = ?;Flit flit4 = ?;
      flit0.flitData = 11;flit1.flitData = 12;flit2.flitData = 13;flit3.flitData = 14; flit4.flitData = 15;
      // Expect 1,0,3,4,2 from port 0,1,2,3,4
      flit0.nextDir = east_; 
      flit1.nextDir = east_;
      flit2.nextDir = east_;
      flit3.nextDir = south_;
      flit4.nextDir = west_;

      router.dataLinks[0].putFlit(flit0);
      $display("[0;33mInsertFlits[0m\t data=%0d into North-input port0: target East-output port1", flit0.flitData);
      
      router.dataLinks[1].putFlit(flit1);
      $display("[0;33mInsertFlits[0m\t data=%0d into East-input port1: target East-output port1", flit1.flitData);

      verify_queue[1].enq(flit2); 
      router.dataLinks[2].putFlit(flit2);
      $display("[0;33mInsertFlits[0m\t data=%0d into South-input port2: target East-output port1", flit2.flitData);
      
      verify_queue[2].enq(flit3); 
      router.dataLinks[3].putFlit(flit3);
      $display("[0;33mInsertFlits[0m\t data=%0d into West-input port3: target South-output port2", flit3.flitData);
      
      verify_queue[3].enq(flit4); 
      router.dataLinks[4].putFlit(flit4);
      $display("[0;33mInsertFlits[0m\t data=%0d into Local-input port4: target West-output port3", flit4.flitData);
      sent <= True;
    end
    else if(clkCount == 4) begin
      Flit flit1 = ?;
      flit1.flitData = 12;
      flit1.nextDir = east_;
      verify_queue[1].enq(flit1); 
    end
    else if(clkCount == 5) begin
      Flit flit0 = ?;
      flit0.flitData = 11;
      flit0.nextDir = east_;
      verify_queue[1].enq(flit0); 
    end
    else if(clkCount == 6) begin
      Flit flit0 = ?;Flit flit1 = ?;Flit flit2 = ?;Flit flit3 = ?;Flit flit4 = ?;
      flit0.flitData = 16;flit1.flitData = 17;flit2.flitData = 18;flit3.flitData = 19; flit4.flitData = 20;
      // Expect 1,0,3,4,2 from port 0,1,2,3,4
      flit0.nextDir = east_; 
      flit1.nextDir = north_;
      flit2.nextDir = north_;
      flit3.nextDir = south_;
      flit4.nextDir = north_;

      router.dataLinks[0].putFlit(flit0);
      $display("[0;33mInsertFlits[0m\t data=%0d into North-input port0: target East-output port1", flit0.flitData);

      router.dataLinks[1].putFlit(flit1);
      $display("[0;33mInsertFlits[0m\t data=%0d into East-input port1: target North-output port0", flit1.flitData);
      
      verify_queue[0].enq(flit2); 
      router.dataLinks[2].putFlit(flit2);
      $display("[0;33mInsertFlits[0m\t data=%0d into South-input port2: target North-output port0", flit2.flitData);
      
      verify_queue[1].enq(flit0); 
      router.dataLinks[3].putFlit(flit3);
      $display("[0;33mInsertFlits[0m\t data=%0d into West-input port3: target South-output port2", flit3.flitData);
      
      verify_queue[2].enq(flit3); 
      router.dataLinks[4].putFlit(flit4);
      $display("[0;33mInsertFlits[0m\t data=%0d into Local-input port4: target North-output port0", flit4.flitData);
      sent <= True;
    end
    else if(clkCount == 7) begin
      Flit flit4 = ?;
      flit4.flitData = 20;
      flit4.nextDir = north_;
      verify_queue[0].enq(flit4); 
    end
    else if(clkCount == 8) begin
      Flit flit1 = ?;
      flit1.flitData = 17;
      flit1.nextDir = north_;
      verify_queue[0].enq(flit1); 
    end
    else if(clkCount == 9) begin
      Flit flit0 = ?;Flit flit1 = ?;Flit flit2 = ?;Flit flit3 = ?;Flit flit4 = ?;
      flit0.flitData = 21;flit1.flitData = 22;flit2.flitData = 23;flit3.flitData = 24; flit4.flitData = 25;
      // Expect 1,0,3,4,2 from port 0,1,2,3,4
      flit0.nextDir = north_; 
      flit1.nextDir = north_;
      flit2.nextDir = north_;
      flit3.nextDir = north_;
      flit4.nextDir = north_;

      router.dataLinks[0].putFlit(flit0);
      $display("[0;33mInsertFlits[0m\t data=%0d into North-input port0: target North-output port0", flit0.flitData);

      router.dataLinks[1].putFlit(flit1);
      $display("[0;33mInsertFlits[0m\t data=%0d into East-input port1: target North-output port0", flit1.flitData);
      
      router.dataLinks[2].putFlit(flit2);
      $display("[0;33mInsertFlits[0m\t data=%0d into South-input port2: target North-output port0", flit2.flitData);
      
      verify_queue[0].enq(flit3); 
      router.dataLinks[3].putFlit(flit3);
      $display("[0;33mInsertFlits[0m\t data=%0d into West-input port3: target North-output port0", flit3.flitData);
      
      router.dataLinks[4].putFlit(flit4);
      $display("[0;33mInsertFlits[0m\t data=%0d into Local-input port4: target North-output port0", flit4.flitData);
      sent <= True;
    end
    else if(clkCount == 10) begin
      Flit flit0 = ?;
      flit0.flitData = 21;
      flit0.nextDir = north_;
      verify_queue[0].enq(flit0); 
    end
    else if(clkCount == 11) begin
      Flit flit2 = ?;
      flit2.flitData = 23;
      flit2.nextDir = north_;
      verify_queue[0].enq(flit2); 
    end
    else if(clkCount == 12) begin
      Flit flit4 = ?;
      flit4.flitData = 25;
      flit4.nextDir = north_;
      verify_queue[0].enq(flit4); 
    end
    else if(clkCount == 13) begin
      Flit flit1 = ?;
      flit1.flitData = 22;
      flit1.nextDir = north_;
      verify_queue[0].enq(flit1); 
    end
  endrule

  for(Integer i=0;i<valueOf(NumPorts); i=i+1) begin
    rule getFlits_port if(started); // && verify_queue[0].notEmpty);
      let temp_receive_flit <- router.dataLinks[i].getFlit();
      Flit verify_flit_vec = verify_queue[i].first();
      verify_queue[i].deq();
      if (temp_receive_flit.flitData != verify_flit_vec.flitData)  begin
        $fdisplay(stderr, "[0;31mFAIL[0m (port%0d receives %0d, expected %0d)", i, temp_receive_flit.flitData, verify_flit_vec.flitData);
        $finish;
      end
      $display("[0;34mGetFlits[0m \t from port: data=%0d", temp_receive_flit.flitData);
      receive_counter[i] <= receive_counter[i] + 1;
    endrule
  end

  rule done (clkCount == 19);
    if (receive_counter[0] == 10 && receive_counter[1] == 6 && receive_counter[2]==4 && receive_counter[3]==3 && receive_counter[4]==2) begin
      $fdisplay(stderr, "  [0;32mPASS[0m");
      $fdisplay(stderr, "Received %d flits from North-output port0, expected %d", receive_counter[0], 10);
      $fdisplay(stderr, "Received %d flits from East-output port1, expected %d", receive_counter[1], 6);
      $fdisplay(stderr, "Received %d flits from South-output port2, expected %d", receive_counter[2], 4);
      $fdisplay(stderr, "Received %d flits from West-output port3, expected %d", receive_counter[3], 3);
      $fdisplay(stderr, "Received %d flits from Local-output port4, expected %d", receive_counter[4], 2);
    end
    else begin
      $fdisplay(stderr, "  [0;31mFAIL[0m not receiving any messages");
      $fdisplay(stderr, "Received %d flits from North-output port0, expected %d", receive_counter[0], 10);
      $fdisplay(stderr, "Received %d flits from East-output port1, expected %d", receive_counter[1], 6);
      $fdisplay(stderr, "Received %d flits from South-output port2, expected %d", receive_counter[2], 4);
      $fdisplay(stderr, "Received %d flits from West-output port3, expected %d", receive_counter[3], 3);
      $fdisplay(stderr, "Received %d flits from Local-output port4, expected %d", receive_counter[4], 2);
    end
    $finish;
  endrule

endmodule
