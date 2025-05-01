`timescale 1ns/1ps

module tb_comparator;
  parameter WIDTH = 8;

  // Testbench signals
  logic [WIDTH-1:0] data_t, ramout;
  logic gt, eq, lt;

  // DUT instantiation
  comparator #(.WIDTH(WIDTH)) dut (
    .data_t(data_t),
    .ramout(ramout),
    .gt(gt),
    .eq(eq),
    .lt(lt)
  );

  initial begin
    // Case 1: data_t > ramout
    data_t = 8'd10; ramout = 8'd5;
    #1;
    assert(gt && !eq && !lt) else $fatal(1, "FAIL: Expected gt=1, eq=0, lt=0 when data_t > ramout");

    // Case 2: data_t == ramout
    data_t = 8'd20; ramout = 8'd20;
    #1;
    assert(!gt && eq && !lt) else $fatal(1, "FAIL: Expected gt=0, eq=1, lt=0 when data_t == ramout");

    // Case 3: data_t < ramout
    data_t = 8'd7; ramout = 8'd15;
    #1;
    assert(!gt && !eq && lt) else $fatal(1, "FAIL: Expected gt=0, eq=0, lt=1 when data_t < ramout");

    // Case 4: Edge cases - max vs min
    data_t = 8'hFF; ramout = 8'h00;
    #1;
    assert(gt) else $fatal(1, "FAIL: Expected gt=1 for max vs min");

    data_t = 8'h00; ramout = 8'hFF;
    #1;
    assert(lt) else $fatal(1, "FAIL: Expected lt=1 for min vs max");

    // Case 5: Random checks
    repeat (5) begin
      data_t = $random;
      ramout = $random;
      #1;
      if (data_t > ramout)
        assert(gt && !eq && !lt) else $fatal(1, "FAIL: gt mismatch on random input");
      else if (data_t == ramout)
        assert(!gt && eq && !lt) else $fatal(1, "FAIL: eq mismatch on random input");
      else
        assert(!gt && !eq && lt) else $fatal(1, "FAIL: lt mismatch on random input");
    end

    $display("All comparator tests passed.");
    $finish;
  end
endmodule
