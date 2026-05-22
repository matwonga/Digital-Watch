// edit_mode_selector - A module that manages three edit modes based on button presses
//
// Parameters:
// HOLD_CYCLES - The number of clock cycles the button must be held down for the 'long_press' signal to go high
//
// Ports:
// clk          - Clock signal
// button       - Input signal representing the button state
// long_press   - Output signal that goes high for one clock cycle when the button has been held for the specified number of cycles
// mode_enable  - 3-bit output where each bit represents whether a specific edit mode is enabled

`timescale 1ns / 1ps

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);
  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  logic armed;
  logic disarm;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  assign enable_counter = armed && press;
  assign reset_counter = !armed;

  assign disarm = press && (count == 2);

  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
