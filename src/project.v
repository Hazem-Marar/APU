/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

 
    // =========================
    // Control + Data Separation
    // =========================

    // Mode from LSB of ui_in
    wire mode = ui_in[0];  // 0 = add, 1 = multiply

    // Reconstruct A (force LSB = 0)
    wire [7:0] A = {ui_in[7:1], 1'b0};

    // B unchanged
    wire [7:0] B = uio_in;

    // =========================
    // APPROXIMATE ADDER
    // =========================

    wire [7:0] approx_sum;

    // Lower 4 bits (approximate)
    assign approx_sum[3:0] = A[3:0] | B[3:0];

    // Upper bits (accurate ripple carry)
    wire c4, c5, c6, c7;

    assign {c4, approx_sum[4]} = A[4] + B[4];
    assign {c5, approx_sum[5]} = A[5] + B[5] + c4;
    assign {c6, approx_sum[6]} = A[6] + B[6] + c5;
    assign {c7, approx_sum[7]} = A[7] + B[7] + c6;

    // =========================
    // APPROXIMATE MULTIPLIER
    // =========================

    // Use only upper 4 bits (area reduction)
    wire [3:0] Ah = A[7:4];
    wire [3:0] Bh = B[7:4];

wire [12:0] pp0_w = Bh[0] ? ({8'b0, Ah} << 0) : 13'b0;
wire [12:0] pp1_w = Bh[1] ? ({8'b0, Ah} << 1) : 13'b0;
wire [12:0] pp2_w = Bh[2] ? ({8'b0, Ah} << 2) : 13'b0;
wire [12:0] pp3_w = Bh[3] ? ({8'b0, Ah} << 3) : 13'b0;
wire [12:0] pp4_w = Bh[4] ? ({8'b0, Ah} << 4) : 13'b0;

// sum all contributions
wire [12:0] sum = pp0_w + pp1_w + pp2_w + pp3_w + pp4_w;

// final approximate multiplier output
wire [7:0] approx_mult = sum[7:0]; // truncate only at the end

    // =========================
    // OUTPUT REGISTER
    // =========================

    reg [7:0] result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result <= 8'd0;
        else begin
            case (mode)
                1'b0: result <= approx_sum;
                1'b1: result <= approx_mult;
            endcase
        end
    end

    assign uo_out = result;

    // =========================
    // UNUSED IOs
    // =========================
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;


endmodule
