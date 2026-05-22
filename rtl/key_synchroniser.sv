// key_synchroniser - A module to synchronise asynchronous key inputs to the clock domain
//
// Parameters:
// None
//
// Ports:
// clk        - Clock signal
// key_n      - 4-bit input representing the state of 4 keys
// key_sync   - 4-bit output representing the synchronised state of the keys

`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,
    output logic [3:0] key_sync = '0
);

  logic [3:0] key_sync_d = '0;

  always_ff @(posedge clk) begin
    key_sync_d <= ~key_n;
    key_sync   <= key_sync_d;
  end

endmodule

