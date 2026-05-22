// binary_to_bcd - converts binary to BCD
//
// Parameters:
// None
//
// Ports:
// bin [6:0]  - Binary input, 0-99
// tens [3:0] - Decimal tens digit (BCD)
// ones [3:0] - Decimal ones digit (BCD)

`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,
    output logic [3:0] tens,
    output logic [3:0] ones
);
  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);

endmodule
