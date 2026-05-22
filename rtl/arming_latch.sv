// arming_latch - A latch to hold the armed state of the system
//
// Parameters:
// None
//
// Ports:
// clk    - Clock signal
// arm    - Signal to set the latch
// disarm - Signal to reset the latch
// armed  - Output signal indicating whether the system is armed

`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed = '0
);

  always_ff @(posedge clk) begin
    if (disarm) begin
      armed <= '0;
    end else if (arm) begin
      armed <= '1;
    end
  end

endmodule

