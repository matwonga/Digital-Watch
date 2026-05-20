// mod_n_counter - implements a modulo-N counter
//
// Parameters:
// N        - The modulo value for the counter
// WIDTH    - The bit width of the counter output
//
// Ports:
// clk                  - Clock signal
// rst                  - Synchronous reset signal (active high)
// enable               - When high, enables the counter to count on the next clock edge
// count [WIDTH-1:0]    - Current count value, rolls over to 0 after reaching N-1

`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);

  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
    end else if (enable) begin
      count <= (count == WIDTH'(N - 1)) ? '0 : count + One;
    end else begin
      count <= count;
    end
  end

endmodule
