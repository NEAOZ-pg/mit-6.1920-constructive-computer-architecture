import Vector::*;

typedef Bit#(16) Word;

function Vector#(16, Word) naiveShfl(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) resultVector = in;
    for (Integer i = 0; i < 16; i = i + 1) begin
        Bit#(4) idx = fromInteger(i);
        resultVector[i] = in[shftAmnt+idx];
    end
    return resultVector;
endfunction


function Vector#(16, Word) barrelLeft(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Vector#(16, Word)) resultVector = newVector;
    // Implementation of a left barrel shifter, presented in recitation
    for (Integer i = 0; i < 16; i = i + 1) begin
        for (Integer j = 0; j < 16; j = j + 1) begin
            resultVector[i][j] = in[(i + j) % 16];
        end
    end
    return resultVector[shftAmnt];
endfunction
