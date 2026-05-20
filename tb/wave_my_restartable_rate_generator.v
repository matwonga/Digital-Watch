`timescale 1ns / 1ps
module wave_my_restartable_rate_generator;
  reg  clk = 0;
  reg  run = 0;
  wire tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) dut (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_my_restartable_rate_generator.vcd");
    $dumpvars(0, wave_my_restartable_rate_generator);

    #20;
    run = 1;

    #20;
    run = 0;
    #20 $finish;
  end
endmodule
