`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
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
        .uio_out(),
        .uio_oe(),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        ui_in = 0;
        uio_in = 0;

        #20;
        rst_n = 1;

        // =========================
        // ADD MODE TESTS
        // =========================
        $display("ADD MODE");

        ui_in = {7'd10, 1'b0}; uio_in = 8'd5;   #10;
        $display("A=10, B=5 → OUT=%d", uo_out);

        ui_in = {7'd50, 1'b0}; uio_in = 8'd20;  #10;
        $display("A=50, B=20 → OUT=%d", uo_out);

        ui_in = {7'd100,1'b0}; uio_in = 8'd100; #10;
        $display("A=100, B=100 → OUT=%d", uo_out);

        // =========================
        // MULT MODE TESTS
        // =========================
        $display("MULT MODE");

        ui_in = {7'd10, 1'b1}; uio_in = 8'd5;   #10;
        $display("A=10, B=5 → OUT=%d", uo_out);

        ui_in = {7'd20, 1'b1}; uio_in = 8'd20;  #10;
        $display("A=20, B=20 → OUT=%d", uo_out);

        ui_in = {7'd100,1'b1}; uio_in = 8'd3;   #10;
        $display("A=100, B=3 → OUT=%d", uo_out);

        $display("TEST COMPLETE");
        $stop;
    end
endmodule
