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

module user_top_timer_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
`ifdef FORMAL
    output logic       probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input  logic       clk,
    /* verilator lint_off UNUSED */
    input  logic [3:0] button,
    /* verilator lint_off UNUSED */
    input  logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  assign led = clk ? sw : ~sw;

  logic press0, auto_press0;
  rising_edge_detector u_red0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(press0)
  );
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_ar0 (
      .clk(clk),
      .button(button[0]),
      .pulse(auto_press0)
  );

  logic auto_press1;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_ar1 (
      .clk(clk),
      .button(button[1]),
      .pulse(auto_press1)
  );

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_edit_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  logic in_set_mode;
  assign in_set_mode = |mode_enable;

  logic [4:0] hours_cnt;
  logic [5:0] minutes_cnt;
  logic [5:0] seconds_cnt;
  logic borrow_sec, borrow_min;

  logic timer_nonzero;
  logic timer_nonzero_r = 1'b0;
  assign timer_nonzero = (hours_cnt != 0) || (minutes_cnt != 0) || (seconds_cnt != 0);
  always_ff @(posedge clk) timer_nonzero_r <= timer_nonzero;

  logic running_r = 1'b0;
  logic running;
  assign running = running_r && timer_nonzero_r;

  always_ff @(posedge clk) begin
    if (in_set_mode || !timer_nonzero_r) begin
      running_r <= 1'b0;
    end else if (press0) begin
      if (!running_r) running_r <= 1'b1;
      else running_r <= 1'b0;
    end
  end

  logic tick_1hz;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_rate_1hz (
      .clk (clk),
      .run (running),
      .tick(tick_1hz)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk       (clk),
      .clr       (1'b0),
      .tick      (tick_1hz && running),
      .edit_mode (mode_enable[0]),
      .inc       (auto_press1 && mode_enable[0]),
      .dec       (auto_press0 && mode_enable[0]),
      .count     (seconds_cnt),
      .borrow_out(borrow_sec)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk       (clk),
      .clr       (1'b0),
      .tick      (borrow_sec && running),
      .edit_mode (mode_enable[1]),
      .inc       (auto_press1 && mode_enable[1]),
      .dec       (auto_press0 && mode_enable[1]),
      .count     (minutes_cnt),
      .borrow_out(borrow_min)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk       (clk),
      .clr       (1'b0),
      .tick      (borrow_min && running),
      .edit_mode (mode_enable[2]),
      .inc       (auto_press1 && mode_enable[2]),
      .dec       (auto_press0 && mode_enable[2]),
      .count     (hours_cnt),
      .borrow_out()
  );
  /* verilator lint_on PINCONNECTEMPTY */

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND * 2 / 5)
  ) u_pwm (
      .clk(clk),
      .rst(!in_set_mode),
      .pwm_out(pwm_out)
  );

  logic flash_blank;
  assign flash_blank = in_set_mode && !pwm_out;

  assign seconds_disp  = 7'(seconds_cnt);
  assign minutes_disp  = 7'(minutes_cnt);
  assign hours_disp    = 7'(hours_cnt);

  assign blank_hours   = flash_blank && mode_enable[2];
  assign blank_minutes = flash_blank && mode_enable[1];
  assign blank_seconds = flash_blank && mode_enable[0];

`ifdef FORMAL
  assign probe_running     = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
