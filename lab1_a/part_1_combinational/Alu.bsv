typedef enum {
	Add,
	ShiftL,
	And,
	Not
} InstructionType deriving (Eq,FShow, Bits);

function Bit#(32) alu (InstructionType ins, Bit#(32) v1, Bit#(32) v2);
	Bit#(32) y;
	case(ins)
		Add: y = v1 + v2;
		ShiftL: y = v1 << v2;
		And: y = v1 & v2;
		Not: y = ~v1;
	endcase
	return y;
endfunction

