// -----------------------------------------------------------------------------
// counter_tb_simple.sv   —  Minimal testbench for `counter`
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

localparam int LEN  = 10;
localparam int MAX  = (1 << LEN) - 1;

// DUT inputs / outputs
logic [LEN-1:0] d_in;
logic           clk = 0;
logic           ld, ud, cen;
logic [LEN-1:0] q;
logic           cout;

// Clock: 100 MHz (10 ns period)
always #5 clk = ~clk;

// Device Under Test
counter #(.length(LEN)) dut (
    .d_in (d_in),
    .clk  (clk ),
    .ld   (ld  ),
    .ud   (ud  ),
    .cen  (cen ),
    .q    (q   ),
    .cout (cout)
);

// Reference model (very small)
logic [LEN-1:0] ref_q;
logic           ref_cout;

always_ff @(posedge clk) begin
    ref_cout <= 0;                         // default
    if (cen) begin
        if (ld)            ref_q <= d_in;
        else if (ud)       ref_q <= ref_q + 1;
        else               ref_q <= ref_q - 1;

        // detect overflow / underflow for reference
        if (ud && ref_q == MAX)   ref_cout <= 1;
        if (!ud && ref_q == 0)    ref_cout <= 1;
    end
end

// Simple comparator: stop sim on any mismatch
always_ff @(posedge clk) begin
    if (q !== ref_q) begin
        $error("MISMATCH @%0t  q=%0d  ref=%0d", $time, q, ref_q);
        $finish;
    end
    if (cout !== ref_cout) begin
        $error("COUT mismatch @%0t  cout=%0b  ref=%0b", $time, cout, ref_cout);
        $finish;
    end
end

// -----------------------------------------------------------------------------
// Test sequence (all in one place)
// -----------------------------------------------------------------------------
initial begin
    // --- Initial idle values
    {ld, ud, cen} = 3'b000;
    d_in  = '0;
    ref_q = '0;

    // wait 2 clocks for good measure
    repeat (2) @(posedge clk);

    // ---------------------------------------------------------
    // 1) LOAD 512  -------------------------------------------
    // ---------------------------------------------------------
    ld   = 1;  cen = 1;  d_in = 10'd512;
    @(posedge clk);
    ld   = 0;  d_in = 'x;                           // de-assert
    // --- UP-count 4 steps (512 → 516)
    ud   = 1;
    repeat (4) @(posedge clk);
    ud   = 0;

    // ---------------------------------------------------------
    // 2) DOWN-count to underflow ------------------------------
    // ---------------------------------------------------------
    // go all the way to 0 then one more tick to show underflow
    repeat (517) @(posedge clk);  // 516 → -1 (wraps to 1023)
    // ud is still 0, cen is 1

    // ---------------------------------------------------------
    // 3) Disable counting, ensure hold ------------------------
    // ---------------------------------------------------------
    cen = 0;
    repeat (3) @(posedge clk);    // q should remain constant

    // ---------------------------------------------------------
    // 4) Random quick sanity burst ----------------------------
    // ---------------------------------------------------------
    cen = 1;
    for (int i = 0; i < 20; i++) begin
        ld   = 1;
        d_in = $urandom_range(0, MAX);
        @(posedge clk);
        ld   = 0;
        ud   = $urandom_range(0,1);
        repeat($urandom_range(1,8)) @(posedge clk);
    end

    $display("\n✅  ALL TESTS PASSED");
    $finish;
end

endmodule
