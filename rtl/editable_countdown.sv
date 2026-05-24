// editable_countdown - A countdown timer that can be edited by the user
//
// Parameters:
// MAX   - The maximum value the countdown can be set to (default: 59)
// WIDTH - The bit width of the count output (default: 6, which can represent
//
// Ports:
// clk          - Clock signal
// clr          - Synchronous clear signal to reset the countdown to zero
// tick         - Signal that triggers the countdown to decrement
// edit_mode     - When high, allows the count to be edited using the inc and dec signals
// inc           - Signal to increment the count when in edit mode
// dec           - Signal to decrement the count when in edit mode
// count         - The current value of the countdown
// borrow_out    - Signal that goes high for one clock cycle when the countdown reaches zero and ticks down

`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH -1:0] count,
    output logic borrow_out
);

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable((tick && !edit_mode) || ((inc ^ dec) && edit_mode)),
      .up(inc && edit_mode),
      .count(count)
  );

  assign borrow_out = tick && !edit_mode && !clr && (count == 0);

endmodule
