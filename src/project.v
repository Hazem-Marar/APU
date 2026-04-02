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
    wire [1:0] mode = {ui_in[0],uio_in[0]};  // 0 = add, 1 = multiply, 2=magnitude comparator, 3=divide

    // Reconstruct A (force LSB = 0)
    wire [7:0] A = {ui_in[7:1], 1'b0};

    // B unchanged
    wire [7:0] B = {uio_in[7:1],1'b0};

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

wire [12:0] pp0_w;
    assign pp0_w = Bh[0] ? ({8'b0, Ah} << 0) : 13'b0;
wire [12:0] pp1_w;
    assign pp1_w = Bh[1] ? ({8'b0, Ah} << 1) : 13'b0;
wire [12:0] pp2_w;
    assign pp2_w = Bh[2] ? ({8'b0, Ah} << 2) : 13'b0;
wire [12:0] pp3_w;
    assign pp3_w = Bh[3] ? ({8'b0, Ah} << 3) : 13'b0;


// sum all contributions
wire [12:0] sum = pp0_w + pp1_w + pp2_w + pp3_w;

// final approximate multiplier output
wire [7:0] approx_mult = sum[7:0]; // truncate only at the end

    // =========================
    // MAGNITUDE COMPARATOR
    // =========================
wire gt, lt, eq;

// Bit equality signals
wire [7:0] eq_bit;
assign eq_bit = ~(A ^ B);  // 1 if bits equal

// Greater-than logic
assign gt =
    ( A[7] & ~B[7]) |
    (eq_bit[7] &  A[6] & ~B[6]) |
    (eq_bit[7] & eq_bit[6] &  A[5] & ~B[5]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] &  A[4] & ~B[4]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] &  A[3] & ~B[3]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & eq_bit[3] &  A[2] & ~B[2]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & eq_bit[3] & eq_bit[2] &  A[1] & ~B[1]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & eq_bit[3] & eq_bit[2] & eq_bit[1] &  A[0] & ~B[0]);

// Less-than logic (mirror)
assign lt =
    (~A[7] & B[7]) |
    (eq_bit[7] & ~A[6] & B[6]) |
    (eq_bit[7] & eq_bit[6] & ~A[5] & B[5]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & ~A[4] & B[4]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & ~A[3] & B[3]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & eq_bit[3] & ~A[2] & B[2]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & eq_bit[3] & eq_bit[2] & ~A[1] & B[1]) |
    (eq_bit[7] & eq_bit[6] & eq_bit[5] & eq_bit[4] & eq_bit[3] & eq_bit[2] & eq_bit[1] & ~A[0] & B[0]);

// Equality
assign eq = &eq_bit;  // all bits equal

    wire [7:0] cmp_out;

assign cmp_out = gt ? 8'd1 :
                 lt ? 8'd2 :
                      8'd0;

    // =========================
    // APPROXIMATE DIVIDER
    // =========================
wire [7:0] B_safe = (B == 0) ? 8'd1 : B;

wire [2:0] shift;

assign shift =
    (B_safe[7]) ? (B_safe[6] ? 3'd7 : 3'd6) :
    (B_safe[6]) ? (B_safe[5] ? 3'd6 : 3'd5) :
    (B_safe[5]) ? (B_safe[4] ? 3'd5 : 3'd4) :
    (B_safe[4]) ? (B_safe[3] ? 3'd4 : 3'd3) :
    (B_safe[3]) ? (B_safe[2] ? 3'd3 : 3'd2) :
    (B_safe[2]) ? (B_safe[1] ? 3'd2 : 3'd1) :
    (B_safe[1]) ? (B_safe[0] ? 3'd1 : 3'd0) :
                  3'd0;

wire [7:0] approx_div = A >> shift;
                    
    // =========================
    // OUTPUT REGISTER
    // =========================

    reg [7:0] result;
always @(*) begin
    if (!rst_n)
        result = 8'd0;
    else begin
        case (mode)
            2'b00: result = approx_sum;
            2'b01: result = approx_mult;
            2'b10: result = cmp_out;
            2'b11: result = approx_div;
            default: result = 8'd0;
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
