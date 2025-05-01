`timescale 1ns/1ps

module tb_counter;
  parameter length = 10;

  logic clk, ld, u_d, cen;
  logic [length-1:0] d_in;
  logic [length-1:0] q;
  logic cout;

  // DUT instantiation
  counter #(.length(length)) dut (
    .d_in(d_in),
    .clk(clk),
    .ld(ld),
    .u_d(u_d),
    .cen(cen),
    .q(q),
    .cout(cout)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  logic [length:0] temp_ref;

  initial begin
    // Reset state
    ld = 0; u_d = 0; cen = 0; d_in = '0;
    @(posedge clk);

    // Load a value and check
    ld = 1; cen = 1; d_in = 10'd512;
    @(posedge clk);
    ld = 0;
    temp_ref = {1'b0, d_in};
    if (q != d_in) $error("FAIL: load mismatch q=%0d, d_in=%0d", q, d_in);
    if (cout != 0) $error("FAIL: cout should be 0 on load");

    // Count up to overflow
    repeat (3) begin
      temp_ref = temp_ref + 1;
      u_d = 1; cen = 1;
      @(posedge clk);
      if (q != temp_ref[length-1:0]) $error("FAIL: up-count mismatch");
      if (cout != temp_ref[length])  $error("FAIL: overflow flag incorrect");
    end

    // Count down to underflow
    repeat (4) begin
      temp_ref = temp_ref - 1;
      u_d = 0; cen = 1;
      @(posedge clk);
      if (q != temp_ref[length-1:0]) $error("FAIL: down-count mismatch");
      if (cout != temp_ref[length])  $error("FAIL: underflow flag incorrect");
    end

    $display("All tests completed for 11-bit counter overflow tracking.");
    $finish;
  end
endmodule
