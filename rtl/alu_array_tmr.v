// ============================================================
// Module  : alu_array_tmr
// Project : Self-Healing Digital Circuit
// Description:
//   Triple Modular Redundancy using ALU arrays instead of
//   single ALUs.  Three identical alu_array instances
//   (each with NUM_ALUS independent 8-bit ALUs) compute the
//   same operations.  A majority_voter per slot picks the
//   correct result and flags disagreements.
//
//   Architecture:
//     Array 0 ──┐
//     Array 1 ──┼──► majority_voter[0..NUM_ALUS-1] ──► result_flat
//     Array 2 ──┘                                   ──► fault_detected_flat
//
//   This design is intended to maximise:
//     - Logic density (3 × 32 = 96 ALU instances)
//     - Switching activity (fully random per-cycle stimulus)
//     - SAIF net matching (flat synthesis: -flatten_hierarchy full)
//
// Parameters:
//   NUM_ALUS  – ALUs per array (default 32); total ALUs = 3 × NUM_ALUS
//
// Inputs:
//   clk, rst
//   a_flat  – NUM_ALUS * 8 bits (fan-out to all 3 arrays identically)
//   b_flat  – NUM_ALUS * 8 bits
//   op_flat – NUM_ALUS * 3 bits
//
// Outputs:
//   result_flat        – NUM_ALUS * 8 bits (majority-voted per slot)
//   carry_out_flat     – NUM_ALUS bits  (from array 0, reference)
//   zero_flat          – NUM_ALUS bits  (from voted result)
//   fault_detected_flat– NUM_ALUS bits  (any slot has inter-array disagreement)
// ============================================================
`timescale 1ns/1ps

module alu_array_tmr #(
    parameter NUM_ALUS = 32
) (
    input  wire                       clk,
    input  wire                       rst,

    // Shared inputs — broadcast to all three arrays
    input  wire [NUM_ALUS*8-1:0]      a_flat,
    input  wire [NUM_ALUS*8-1:0]      b_flat,
    input  wire [NUM_ALUS*3-1:0]      op_flat,

    // Outputs
    output wire [NUM_ALUS*8-1:0]      result_flat,
    output wire [NUM_ALUS-1:0]        carry_out_flat,
    output wire [NUM_ALUS-1:0]        zero_flat,
    output wire [NUM_ALUS-1:0]        fault_detected_flat
);

    // ---- Raw outputs from each array ----
    wire [NUM_ALUS*8-1:0] arr0_result, arr1_result, arr2_result;
    wire [NUM_ALUS-1:0]   arr0_carry,  arr1_carry,  arr2_carry;
    wire [NUM_ALUS-1:0]   arr0_zero,   arr1_zero,   arr2_zero;

    // --------------------------------------------------------
    // Array 0  (reference)
    // --------------------------------------------------------
    alu_array #(.NUM_ALUS(NUM_ALUS)) u_arr0 (
        .clk           (clk),
        .rst           (rst),
        .a_flat        (a_flat),
        .b_flat        (b_flat),
        .op_flat       (op_flat),
        .result_flat   (arr0_result),
        .carry_out_flat(arr0_carry),
        .zero_flat     (arr0_zero)
    );

    // --------------------------------------------------------
    // Array 1
    // --------------------------------------------------------
    alu_array #(.NUM_ALUS(NUM_ALUS)) u_arr1 (
        .clk           (clk),
        .rst           (rst),
        .a_flat        (a_flat),
        .b_flat        (b_flat),
        .op_flat       (op_flat),
        .result_flat   (arr1_result),
        .carry_out_flat(arr1_carry),
        .zero_flat     (arr1_zero)
    );

    // --------------------------------------------------------
    // Array 2
    // --------------------------------------------------------
    alu_array #(.NUM_ALUS(NUM_ALUS)) u_arr2 (
        .clk           (clk),
        .rst           (rst),
        .a_flat        (a_flat),
        .b_flat        (b_flat),
        .op_flat       (op_flat),
        .result_flat   (arr2_result),
        .carry_out_flat(arr2_carry),
        .zero_flat     (arr2_zero)
    );

    // --------------------------------------------------------
    // Per-slot majority voters
    //   For each ALU index i, vote across the three arrays.
    // --------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < NUM_ALUS; i = i + 1) begin : voter_inst
            wire [7:0] voted_i;
            wire       fd_i;

            majority_voter u_voter (
                .in0        (arr0_result[i*8 +: 8]),
                .in1        (arr1_result[i*8 +: 8]),
                .in2        (arr2_result[i*8 +: 8]),
                .voted_out  (voted_i),
                .fault_detect(fd_i)
            );

            assign result_flat      [i*8 +: 8] = voted_i;
            assign fault_detected_flat[i]       = fd_i;
        end
    endgenerate

    // --------------------------------------------------------
    // Carry and zero from array 0 (reference unit)
    // --------------------------------------------------------
    assign carry_out_flat = arr0_carry;
    assign zero_flat      = arr0_zero;

endmodule
