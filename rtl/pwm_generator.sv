// pwm_generator - generates a PWM signal with configurable period and duty cycle
//
// Parameters:
// PERIOD_CYCLES - Number of clock cycles in one PWM period
// DUTY_CYCLES   - Number of clock cycles output is high
//
// Ports:
// clk     - Clock signal
// rst     - Synchronous reset signal (active high)
// pwm_out - PWM output signal, goes high for DUTY_CYCLES cycles and low for the remainder of the PERIOD_CYCLES

`timescale 1ns / 1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int CountWidth = $clog2(PERIOD_CYCLES);
  localparam int CmpWidth = CountWidth + 1;
  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  always_comb pwm_out = (CmpWidth'(count) < CmpWidth'(DUTY_CYCLES));

endmodule
