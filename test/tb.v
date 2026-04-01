`default_nettype none
`timescale 1ns / 1ps

module tb;

  // Signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // DUT
  tt_um_top dut (
      .ui_in(ui_in),
      .uio_in(uio_in),
      .uo_out(uo_out),
      .uio_out(uio_out),
      .uio_oe(uio_oe),
      .ena(ena),
      .clk(clk),
      .rst_n(rst_n)
  );

  // Initialize signals
  initial begin
    clk = 0;
    rst_n = 0;
    ena = 0;
    ui_in = 0;
    uio_in = 0;
  end

  // Clock
  always #5 clk = ~clk;

endmodule
