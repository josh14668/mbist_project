module tb_comparator #(parameter WIDTH = 8 ); 

    // Testbench signals
    logic [WIDTH-1:0] data_t;
    logic [WIDTH-1:0] ramout;
    logic gt, eq, lt;

    // Instantiate the comparator module
    comparator #(WIDTH) uut (
        .data_t(data_t),
        .ramout(ramout),
        .gt(gt),
        .eq(eq),
        .lt(lt)
    );

    initial begin
        // Test case 1: data_t > ramout
        data_t = 8'hFF; // 255
        ramout = 8'hAA; // 170
        #10;
        assert (gt == 1'b1 && eq == 1'b0 && lt == 1'b0) else $fatal("Test case 1 failed");

        // Test case 2: data_t < ramout
        data_t = 8'hAA; // 170
        ramout = 8'hFF; // 255
        #10;
        assert (gt == 1'b0 && eq == 1'b0 && lt == 1'b1) else $fatal("Test case 2 failed");

        // Test case 3: data_t == ramout
        data_t = 8'hBB; // 187
        ramout = 8'hBB; // 187
        #10;
        assert (gt == 1'b0 && eq == 1'b1 && lt == 1'b0) else $fatal("Test case 3 failed");

        $display("All test cases passed!");
        $finish;
    end
endmodule