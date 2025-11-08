/*
 Message Types

 Author: Hyoukjun Kwon(hyoukjun@gatech.edu)
 

*/


/********** Native Libraries ************/
import Vector::*;
/******** User-Defined Libraries *********/
import Types::*;

/************* Definitions **************/
/* 1. Direction bits */
typedef Bit#(NumPorts) Direction;

Direction north_ = 5'b00001;
Direction east_  = 5'b00010;
Direction south_ = 5'b00100;
Direction west_  = 5'b01000;
Direction local_ = 5'b10000;
Direction null_  = 5'b00000; //It needs to be all zero due to Switch Alloc Unit Logic

/*
Direction north_ = zeroExtend(5'b00001);
Direction east_  = zeroExtend(5'b00010);
Direction south_ = zeroExtend(5'b00100);
Direction west_  = zeroExtend(5'b01000);
Direction local_ = zeroExtend(5'b10000);
Direction null_  = zeroExtend(5'b00000); //It needs to be all zero due to Switch Alloc Unit Logic
*/

/* 2. Direction indice */
typedef Bit#(3) DirIdx;
DirIdx dIdxNorth = 3'b000; //0
DirIdx dIdxEast  = 3'b001; //1
DirIdx dIdxSouth = 3'b010; //2
DirIdx dIdxWest  = 3'b011; //3
DirIdx dIdxLocal = 3'b100; //4
DirIdx dIdxNULL  = 3'b111;


/* 3. Port index corresponding a routing direction  */


/* 4. Source routing */
//typedef Maybe#(Bit#(TAdd#(TLog#(MaxNumNormalPorts), 1)))  SmartDirection;

/********* Method functions **********/
function Bool isValidDirection(Direction dirn);
  return (dirn != null_);
endfunction

function Bool isValidDirIdx(DirIdx idx);
  return (idx != dIdxNULL);
endfunction

/* Format converting functions */
(* noinline *)
function DirIdx dir2Idx(Direction dirn);
  let retIdx = case(dirn)
                 north_ : dIdxNorth;
                 east_  : dIdxEast;
                 south_ : dIdxSouth;
                 west_  : dIdxWest;
                 local_ : dIdxLocal;
                 default: dIdxNULL;
               endcase;
  return retIdx;
endfunction

(* noinline *)
function Direction idx2Dir(DirIdx idx);
  let retDirn = case(idx)
                  dIdxNorth : north_;
                  dIdxEast  : east_;
                  dIdxSouth : south_;
                  dIdxWest  : west_;
                  dIdxLocal : local_;
                  default   : null_;
                endcase;
  return retDirn;
endfunction

(* noinline *)
function DirIdx getReverseIdx(DirIdx idx);
  let retDIdx = case(idx)
                  dIdxNorth : dIdxSouth;
                  dIdxEast  : dIdxWest;
                  dIdxSouth : dIdxNorth;
                  dIdxWest  : dIdxEast;
                  dIdxLocal : dIdxLocal;
                  default   : dIdxNULL;
                endcase;
  return retDIdx;
endfunction
