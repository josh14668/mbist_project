`timescale 1ns/1ps

module tb_multiplexer;
  parameter WIDTH = 8;

  // Testbench signals
  logic [WIDTH-1:0] normal_in, bist_in, out;
  logic NbarT;

  // DUT instantiation
  multiplexer #(.WIDTH(WIDTH)) dut (
    .normal_in(normal_in),
    .bist_in(bist_in),
    .NbarT(NbarT),
    .out(out)
  );

  initial begin
    // Case 1: NbarT = 0 -> select normal_in
    normal_in = 8'hA5; bist_in = 8'h5A; NbarT = 0;
    #1;
    assert(out == normal_in) else $error("FAIL: NbarT=0, expected out=normal_in (%h), got %h", normal_in, out);

    // Case 2: NbarT = 1 -> select bist_in
    NbarT = 1;
    #1;
    assert(out == bist_in) else $error("FAIL: NbarT=1, expected out=bist_in (%h), got %h", bist_in, out);

    // Case 3: All 0s and 1s edge case
    normal_in = 8'h00; bist_in = 8'hFF;
    NbarT = 0; #1;
    assert(out == 8'h00) else $error("FAIL: NbarT=0, expected out=00");

    NbarT = 1; #1;
    assert(out == 8'hFF) else $error("FAIL: NbarT=1, expected out=FF");

    // Case 4: Random patterns
    repeat (5) begin
      normal_in = $random;
      bist_in   = $random;
      NbarT     = $random % 2;
      #1;
      if (NbarT)
        assert(out == bist_in) else $error("FAIL: NbarT=1, expected out=bist_in");
      else
        assert(out == normal_in) else $error("FAIL: NbarT=0, expected out=normal_in");
    end

    $display("All multiplexer tests passed.");
    $finish;
  end
endmodule
