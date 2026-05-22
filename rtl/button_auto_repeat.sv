// button_auto_repeat - Generates a pulse when a button is pressed and continues to generate pulses while held down
//
// Parameters:
// HOLD_CYCLES - The number of clock cycles the button must be held down before auto-repeat starts
// REPEAT_CYCLES - The number of clock cycles between auto-repeat pulses (must be smaller than HOLD_CYCLES)
//
// Ports:
// clk      - Clock signal
// button   - Input signal from the button
// pulse    - Output pulse signal that goes high on button press and continues to pulse while held down

`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic rise;
  logic held;
  logic pulse_train;

  rising_edge_detector button_rise (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

  assign pulse = rise | (button & pulse_train);

endmodule
