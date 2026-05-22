// rising_edge_detector - Detects rising edges
//
// Parameters:
// None
//
// Ports:
// clk      - Clock signal
// sig_in   - Input signal to detect rising edges on
// rise     - Output signal that goes high for one clock cycle when a rising edge is detected

`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic sig_in_dly;
  always_ff @(posedge clk) sig_in_dly <= sig_in;
  assign rise = sig_in && !sig_in_dly;

endmodule
