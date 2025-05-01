module counter #(parameter length = 10)
(
    input  logic [length-1:0] d_in,
    input  logic clk,
    input  logic ld,
    input  logic u_d,
    input  logic cen,
    output logic [length-1:0] q,
    output logic              cout
);

  logic [length-1:0] count = '0;
  logic [length:0]   temp; // One extra bit to detect overflow

  always_ff @(posedge clk) begin
    if (cen) begin
      if (ld) begin
        count <= d_in;
        cout  <= 0;
      end else if (u_d) begin
        temp  = count + 1;
        count <= temp[length-1:0];
        cout  <= temp[length]; // MSB is overflow
      end else begin
        temp  = {1'b0, count} - 1;
        count <= temp[length-1:0];
        cout  <= temp[length]; // Underflow indicated by MSB = 1 (since subtracting)
      end
    end else begin
      cout <= 0;
    end
  end

  assign q = count;

endmodule
