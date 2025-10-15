module start(Empty);
    // What does this do?

    // Instantiate state
    Reg#(Bool) has_run <- mkReg(False);

    // Runtime rules
    rule do_start if (!has_run);
        has_run <= True;
        $display("Hello world!");
    endrule

    rule finish_start if (has_run);
        $display("Goodbye world!");
        $finish;
    endrule

endmodule
