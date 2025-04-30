module tb_multiplexer;
    localparam WIDTH = 8;

    // Testbench signals
    logic [WIDTH-1:0] normal_in;
    logic [WIDTH-1:0] bist_in;
    logic NbarT;
    logic [WIDTH-1:0] out;

    // Instantiate the multiplexer module
    multiplexer #(WIDTH) uut (
        .normal_in(normal_in),
        .bist_in(bist_in),
        .NbarT(NbarT),
        .out(out)
    );

    initial begin
        // Test case 1: NbarT = 0, normal_in should be selected
        normal_in = 8'hAA; // 170
        bist_in = 8'h55;   // 85
        NbarT = 1'b0;
        #10;
        assert (out == normal_in) else $fatal("Test case 1 failed");

        // Test case 2: NbarT = 1, bist_in should be selected
        normal_in = 8'hAA; // 170
        bist_in = 8'h55;   // 85
        NbarT = 1'b1;
        #10;
        assert (out == bist_in) else $fatal("Test case 2 failed");

        // Test case 3: NbarT = 0, normal_in should be selected again
        normal_in = 8'hFF; // 255
        bist_in = 8'h00;   // 0
        NbarT = 1'b0;
        #10;
        assert (out == normal_in) else $fatal("Test case 3 failed");

        $display("All test cases passed!");
        $finish;
    end
endmodule

