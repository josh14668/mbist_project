module counter #(parameter length = 10)
(
    input logic[length-1:0] d_in,
    input logic clk,
    input logic ld,
    input logic ud,
    input logic cen,
    output logic[length-1:0] q,
    output logic cout
);
    logic [length-1:0] count;

    always_ff @(posedge clk) begin
        if (cen) begin
            if (ld) begin
                count <= d_in;
            end else if (ud) begin
                count <= q + 1;
            end else begin
                count <= q - 1;
            end
        end
    end

    assign q = count;
    assign cout = cen && (
                  (ud && (count == {length{1'b1}})) || // Overflow: Incrementing at max value
                  (!ud && (count == 0))             // Underflow: Decrementing at zero
                ); 


endmodule

