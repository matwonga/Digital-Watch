// snapshot_mux - A simple snapshot multiplexer that holds the input value when the hold signal is asserted
//
// Parameters:
// WIDTH  - The bit width of the input and output signals
//
// Ports:
// clk    - Clock signal
// hold   - When high, the output q holds its value and does not update with changes
// d      - Input data signal
// q      - Output data signal that either follows d or holds its value based on the hold signal

`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] snapshot = '0;

  always_ff @(posedge clk) begin
    if (!hold) snapshot <= d;
  end

  assign q = hold ? snapshot : d;

endmodule
