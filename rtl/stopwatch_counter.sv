// cascade_counter - A counter that cascades three sub-counters together
//
// Parameters:
// N2, N1, N0 - Maximum count values for the three sub-counters
// W2, W1, W0 - Output widths for the three sub-counters
// Ports:
// clk        - Clock signal
// rst        - Synchronous reset signal
// enable     - When high, enables the counter
// count2     - Output of the most significant sub-counter
// count1     - Output of the middle sub-counter
// count0     - Output of the least significant sub-counter

`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  logic tick;

  cascade_counter #(
      .N0(100),  // Centiseconds
      .N1(60),   // Seconds
      .N2(100),  // Minutes
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_stopwatch (
      .clk(clk),
      .rst(rst),
      .enable(tick && enable),
      .count0(centiseconds),
      .count1(seconds),
      .count2(minutes)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_rate_gen (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );

endmodule

