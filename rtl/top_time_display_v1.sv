// top_time_display_v1 - Top-level module for time display on 7-segment displays
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles per second for the input clock
//
// Ports:
// CLOCK_50         - 50 MHz clock input
// SW [1:0]         - Switches to select the tick rate (00: 1Hz, 01: 25Hz, 10: 1kHz, 11: always on)
// HEX5-HEX0 [6:0]  - Seven-segment display outputs for hours, minutes, and seconds

`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  logic tick_rate;
  logic tick_rate_1Hz;
  logic tick_rate_25Hz;
  logic tick_rate_1kHz;

  logic [4:0] hours;
  logic [5:0] minutes, seconds;
  logic [3:0] hour_tens, hour_ones;
  logic [3:0] minute_tens, minute_ones;
  logic [3:0] second_tens, second_ones;

  // Tick Rate Generator for 1Hz
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1)
  ) u_rate_generator_1Hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_rate_1Hz)
  );

  // Tick Rate Generator for 25Hz
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_rate_generator_25Hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_rate_25Hz)
  );

  // Tick Rate Generator for 1kHz
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_rate_generator_1kHz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_rate_1kHz)
  );

  // Select the tick rate based on the switch input
  always_comb begin
    unique case (SW)
      2'b00: tick_rate = tick_rate_1Hz;
      2'b01: tick_rate = tick_rate_25Hz;
      2'b10: tick_rate = tick_rate_1kHz;
      2'b11: tick_rate = 1'b1;
    endcase
  end

  // HMS Counter depending on the tick rate
  hms_counter u_hms_counter (
      .clk(CLOCK_50),
      .enable(tick_rate),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // Binary to BCD for hours
  binary_to_bcd u_binary_to_bcd_hours (
      .bin ({2'b0, hours}),
      .tens(hour_tens),
      .ones(hour_ones)
  );

  seven_segment u_seven_segment_hours_tens (
      .digit(hour_tens),
      .blank(1'b0),
      .segments(HEX5)
  );

  seven_segment u_seven_segment_hours_ones (
      .digit(hour_ones),
      .blank(1'b0),
      .segments(HEX4)
  );

  // Binary to BCD for minutes
  binary_to_bcd u_binary_to_bcd_minutes (
      .bin ({1'b0, minutes}),
      .tens(minute_tens),
      .ones(minute_ones)
  );

  seven_segment u_seven_segment_minutes_tens (
      .digit(minute_tens),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment u_seven_segment_minutes_ones (
      .digit(minute_ones),
      .blank(1'b0),
      .segments(HEX2)
  );

  // Binary to BCD for seconds
  binary_to_bcd u_binary_to_bcd_seconds (
      .bin ({1'b0, seconds}),
      .tens(second_tens),
      .ones(second_ones)
  );

  seven_segment u_seven_segment_seconds_tens (
      .digit(second_tens),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment u_seven_segment_seconds_ones (
      .digit(second_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

endmodule
