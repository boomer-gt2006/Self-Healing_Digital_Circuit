`timescale 1ns/1ps
// ============================================================
// Module  : penta_voter
// Project : Self-Healing Digital Circuit
// Description:
//   8-bit, 5-input majority voter for Penta Modular Redundancy (PMR).
//
//   For each bit position the output is 1 when at least 3 of the
//   5 inputs agree on 1 (simple majority of 5).
//
//   Fault-tolerance:
//     Corrects up to 2 simultaneous module faults.
//     Degrades gracefully: with 3 or more faulty modules that
//     all agree on the wrong value, the voter is overruled.
//
//   Implementation:
//     Per-bit sum of the 5 single-bit inputs (3-bit sum, max = 5).
//     Majority condition: sum >= 3
//       sum >= 3  iff  sum[2] OR (sum[1] AND sum[0])
//       Proof:  3=011 → s[1]&s[0]=1; 4=100 → s[2]=1; 5=101 → s[2]=1
//
// Inputs:
//   in0..in4      - 8-bit results from five ALU instances
//
// Outputs:
//   voted_out     - 8-bit majority-voted output
//   fault_detect  - asserted when any module disagrees with voted_out
//   faulty_module - 5-bit one-hot: bit N high when inN != voted_out
// ============================================================

module penta_voter (
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    input  wire [7:0] in4,
    output wire [7:0] voted_out,
    output wire       fault_detect,
    output wire [4:0] faulty_module
);

    // --------------------------------------------------------
    // Per-bit majority logic via 3-bit population count
    // --------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_vote
            wire [2:0] bit_sum;
            assign bit_sum = {2'b00, in0[i]} + {2'b00, in1[i]} +
                             {2'b00, in2[i]} + {2'b00, in3[i]} +
                             {2'b00, in4[i]};
            // majority = sum >= 3
            assign voted_out[i] = bit_sum[2] | (bit_sum[1] & bit_sum[0]);
        end
    endgenerate

    // --------------------------------------------------------
    // Faulty module identification
    //   Module N is considered faulty when its output disagrees
    //   with the majority-voted result on ANY bit.
    // --------------------------------------------------------
    assign faulty_module[0] = (in0 != voted_out);
    assign faulty_module[1] = (in1 != voted_out);
    assign faulty_module[2] = (in2 != voted_out);
    assign faulty_module[3] = (in3 != voted_out);
    assign faulty_module[4] = (in4 != voted_out);

    // Fault detected if any module disagrees
    assign fault_detect = |faulty_module;

endmodule
