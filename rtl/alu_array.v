// ============================================================
// Module  : alu_array
// Project : Self-Healing Digital Circuit
// Description:
//   Array of NUM_ALUS independent 8-bit ALUs driven by
//   independent inputs.  The sole purpose of this module is
//   to increase logic density and switching activity for a
//   meaningful SAIF-annotated power analysis comparison.
//
// Parameters:
//   NUM_ALUS  – number of ALU instances (default 32)
//
// Inputs  : clk, rst
//   a_flat  – NUM_ALUS * 8  bits (packed a operands)
//   b_flat  – NUM_ALUS * 8  bits (packed b operands)
//   op_flat – NUM_ALUS * 3  bits (packed opcodes)
//
// Outputs :
//   result_flat    – NUM_ALUS * 8   bits
//   carry_out_flat – NUM_ALUS * 1   bits
//   zero_flat      – NUM_ALUS * 1   bits
// ============================================================
`timescale 1ns/1ps

module alu_array #(
    parameter NUM_ALUS = 32
) (
    input  wire                       clk,
    input  wire                       rst,
    input  wire [NUM_ALUS*8-1:0]      a_flat,
    input  wire [NUM_ALUS*8-1:0]      b_flat,
    input  wire [NUM_ALUS*3-1:0]      op_flat,
    output wire [NUM_ALUS*8-1:0]      result_flat,
    output wire [NUM_ALUS-1:0]        carry_out_flat,
    output wire [NUM_ALUS-1:0]        zero_flat
);

    genvar i;
    generate
        for (i = 0; i < NUM_ALUS; i = i + 1) begin : alu_inst
            alu u_alu (
                .clk      (clk),
                .rst      (rst),
                .a        (a_flat [i*8 +: 8]),
                .b        (b_flat [i*8 +: 8]),
                .op       (op_flat[i*3 +: 3]),
                .result   (result_flat   [i*8 +: 8]),
                .carry_out(carry_out_flat[i]),
                .zero     (zero_flat     [i])
            );
        end
    endgenerate

endmodule
