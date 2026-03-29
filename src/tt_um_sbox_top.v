module tt_um_sbox_top (
    input        clk,
    input        ena,
    input  [1:0] mode,
    input  [7:0] data_i,
    output reg [7:0] data_o
);

    // Internal wires for each S-box output
    wire [7:0] s0_out, s1_out, s2_out, s3_out;

    // Instantiate S-boxes
    sbox_com u0 (.data_i(data_i), .data_o(s0_out));
    isbox_com u1 (.data_i(data_i), .data_o(s1_out));
    sbox u2 (.data_i(data_i), .data_o(s2_out));
    isbox u3 (.data_i(data_i), .data_o(s3_out));

    // Output selection (ONLY ONE DRIVER for data_o)
    always @(posedge clk) begin
        case (mode)
            2'b00: data_o <= s0_out;
            2'b01: data_o <= s1_out;
            2'b10: data_o <= s2_out;
            2'b11: data_o <= s3_out;
        endcase
    end

endmodule


