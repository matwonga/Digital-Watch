// button_hold_detect - Detects when a button has been held down for a specified number of clock cycles
//
// Parameters:
// HOLD_CYCLES - The number of clock cycles the button must be held down for the 'held' output to go high
//
// Ports:
// clk      - Clock signal
// button   - Input signal representing the button state
// held     - Output signal that goes high when the button is held for the specified number of cycles

`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);
  localparam int CmpWidth = CountWidth + 1;

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;

  assign count_rst = !button;
  assign count_enable = button && !held;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) hold_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  assign held = (CmpWidth'(count) >= CmpWidth'(CountMax));

endmodule
