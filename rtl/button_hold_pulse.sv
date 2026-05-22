// button_hold_pulse - Generates a pulse when a button has been held down for a specified number of clock cycles
//
// Parameters:
// HOLD_CYCLES - The number of clock cycles the button must be held down for the 'pulse' output to go high
//
// Ports:
// clk      - Clock signal
// button   - Input signal representing the button state
// pulse    - Output signal that goes high for one clock cycle when the button has been held for the specified number of cycles

`timescale 1ns / 1ps

module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic held;
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
