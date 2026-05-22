// editable_counter - A counter that can be incremented/decremented in edit mode or automatically incremented in normal mode
//
// Parameters:
// N        - The number of counts before rolling over (e.g., 24 for hours, 60 for minutes/seconds)
// WIDTH    - The bit width of the count output (e.g., 5 for hours, 6 for minutes/seconds)
//
// Ports:
// clk                  - Clock signal
// tick                 - When high, increments the counter (used for normal mode)
// edit_mode            - When high, enables edit mode where the counter can be incremented/decremented with the inc and dec signals
// inc                  - When high in edit mode, increments the counter
// dec                  - When high in edit mode, decrements the counter
// count [WIDTH-1:0]    - Current count value

`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;

  up_down_counter #(
      .MAX  (WIDTH'(N - 1)),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  assign up = tick_event || inc_event;
  assign enable = (tick_event || inc_event || dec_event) && !(inc_event && dec_event);

endmodule
