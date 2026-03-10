`timescale 1ns/1ps
// ============================================================
// Module  : majority_voter
// Project : Self-Healing Digital Circuit
// Description:
//   8-bit, 3-input majority voter for Triple Modular Redundancy.
//   For each bit position, the output is the value held by
//   at least 2 of the 3 inputs (majority wins).
//
//   Truth table for one bit:
//     a b c | out
//     0 0 0 |  0
//     0 0 1 |  0
//     0 1 0 |  0
//     0 1 1 |  1   <- majority
//     1 0 0 |  0
//     1 0 1 |  1   <- majority
//     1 1 0 |  1   <- majority
//     1 1 1 |  1
//
// Inputs:
//   in0, in1, in2 - 8-bit results from three ALU instances
//
// Outputs:
//   voted_out     - 8-bit majority-voted output
//   fault_detect  - asserted when any input disagrees (DMR check)
// ============================================================

module majority_voter (
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    output wire [7:0] voted_out,
    output wire       fault_detect
);

    // Bitwise majority logic
    assign voted_out = (in0 & in1) | (in1 & in2) | (in0 & in2);

    // Fault detected if any two inputs disagree on any bit
    assign fault_detect = (in0 != in1) | (in1 != in2) | (in0 != in2);

endmodule
