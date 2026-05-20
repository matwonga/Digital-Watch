// up_down_counter - display decoder for hexadecimal digits
//
// Parameters:
// MAX      - Maximum value for the counter
// WIDTH    - Binary width of the max value for the counter
//
// Ports:
// clk                  - Clock signal
// enable               - When high, enables the counter
// up                   - When high count increments, when low count decrements
// count [WIDTH-1:0]    - Counter outputs

`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  always_ff @(posedge clk) begin
    if (enable) begin
      if (up) begin
        count <= (count == Max) ? 0 : count + One;
      end else begin
        count <= (count == 0) ? Max : count - One;
      end
    end
  end

endmodule
