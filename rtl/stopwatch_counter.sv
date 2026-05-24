// stopwatch_counter - A stopwatch counter that counts minutes, seconds, and centiseconds (hundredths of a second).
//
// Parameters:
// CYCLES_PER_SECOND - The number of clock cycles in one second
//
// Ports:
// clk      - Clock signal
// rst      - Reset signal (active high)
// enable    - Enable signal for counting (active high)
// minutes   - Output for minutes (0-99)
// seconds   - Output for seconds (0-59)
// centiseconds - Output for centiseconds (0-99)


`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  logic tick;

  cascade_counter #(
      .N0(100),
      .N1(60),
      .N2(100),
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

