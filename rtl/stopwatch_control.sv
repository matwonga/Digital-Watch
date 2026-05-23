// stopwatch_control - Control logic for a stopwatch, managing start/stop and lap functionality
//
// Parameters:
// None
//
// Ports:
// clk                - Clock signal
// rise_start_stop     - Rising edge signal to toggle start/stop state of the stopwatch
// rise_lap            - Rising edge signal to capture lap time
// counter_rst         - Output signal to reset the stopwatch counter
// counter_enable      - Output signal to enable the stopwatch counter
// lap_hold             - Output signal to hold the current lap time

`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  logic counter_enable_r = 0;
  logic lap_hold_r = 0;
  logic counter_rst_r = 0;

  assign counter_enable = counter_enable_r;
  assign lap_hold       = lap_hold_r;
  assign counter_rst    = counter_rst_r;

  logic both;
  assign both = rise_start_stop && rise_lap;

  always_ff @(posedge clk) begin
    counter_rst_r <= 0;

    if (!both) begin
      if (rise_start_stop) begin
        counter_enable_r <= ~counter_enable_r;
      end else if (rise_lap) begin
        if (counter_enable_r) begin
          lap_hold_r <= ~lap_hold_r;
        end else if (lap_hold_r) begin
          lap_hold_r <= 0;
        end else begin
          counter_rst_r <= 1;
        end
      end
    end
  end

endmodule
