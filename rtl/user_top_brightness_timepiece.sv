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

module user_top_brightness_timepiece #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic [3:0] button,
    input  logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  // ----------------------------------------------------------------
  // Inner display signals from user_top
  // ----------------------------------------------------------------
  logic blank_hours_inner, blank_minutes_inner, blank_seconds_inner;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (blank_hours_inner),
      .blank_minutes(blank_minutes_inner),
      .blank_seconds(blank_seconds_inner)
  );

  localparam int PwmPeriod = CYCLES_PER_SECOND / 1000;
  localparam int PwmPeriodWidth = $clog2(PwmPeriod);

  /* verilator lint_off WIDTHTRUNC */
  logic [PwmPeriodWidth-1:0] pwm_count;
  /* verilator lint_on WIDTHTRUNC */

  mod_n_counter #(
      .N    (PwmPeriod),
      .WIDTH(PwmPeriodWidth)
  ) u_pwm_counter (
      .clk   (clk),
      .rst   (1'b0),
      .enable(1'b1),
      .count (pwm_count)
  );

  logic pwm_on;
  logic [1:0] brightness_sel;
  assign brightness_sel = sw[9:8];

  always_comb begin
    case (brightness_sel)
      2'b00:   pwm_on = (pwm_count < PwmPeriodWidth'(PwmPeriod / 8));
      2'b01:   pwm_on = (pwm_count < PwmPeriodWidth'(PwmPeriod / 4));
      2'b11:   pwm_on = (pwm_count < PwmPeriodWidth'(PwmPeriod / 2));
      2'b10:   pwm_on = 1'b1;
      default: pwm_on = 1'b0;
    endcase
  end

  assign blank_hours   = blank_hours_inner || !pwm_on;
  assign blank_minutes = blank_minutes_inner || !pwm_on;
  assign blank_seconds = blank_seconds_inner || !pwm_on;

endmodule
