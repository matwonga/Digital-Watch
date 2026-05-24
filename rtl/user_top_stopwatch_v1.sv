// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------

`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    /* verilator lint_off UNUSED */
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic [6:0] centiseconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  assign led = clk ? sw : ~sw;

  assign blank_hours = '0;
  assign blank_minutes = '0;
  assign blank_seconds = '0;

  assign hours_disp = '0;

  logic start_stop;
  rising_edge_detector u_rising_edge0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(start_stop)
  );

  logic lap_reset;
  rising_edge_detector u_rising_edge1 (
      .clk(clk),
      .sig_in(button[1]),
      .rise(lap_reset)
  );

  logic lap_hold;
  logic rst;
  logic counter_enable;
  stopwatch_control u_stopwatch_control (
      .clk(clk),
      .rise_start_stop(start_stop),
      .rise_lap(lap_reset),
      .counter_rst(rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  logic [6:0] minutes_live;
  logic [5:0] seconds_live;
  logic [6:0] centiseconds_live;

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch_counter (
      .clk(clk),
      .rst(rst),
      .enable(counter_enable),
      .minutes(minutes_live),
      .seconds(seconds_live),
      .centiseconds(centiseconds_live)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_mux_minutes (
      .clk(clk),
      .hold(lap_hold),
      .d(minutes_live),
      .q(minutes_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_mux_seconds (
      .clk(clk),
      .hold(lap_hold),
      .d(centiseconds_live),
      .q(seconds_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_mux_centiseconds (
      .clk(clk),
      .hold(lap_hold),
      .d({1'b0, seconds_live}),
      .q(centiseconds_disp)
  );

endmodule
