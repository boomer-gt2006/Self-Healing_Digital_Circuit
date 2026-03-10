`timescale 1ns/1ps
// ============================================================
// Module  : top_tmr
// Project : Self-Healing Digital Circuit
// Description:
//   Triple Modular Redundancy (TMR) system.
//
//   Three identical ALU instances compute the same operation.
//   A majority voter selects the correct output bit-by-bit.
//
//   Key properties of TMR:
//     - CAN DETECT a single module fault
//     - CAN CORRECT a single module fault via majority vote
//     - With 2/3 modules faulty the voted output may be wrong
//       (design limit — fault_detected is still asserted)
//
//   Fault injection:
//     Each ALU output passes through an independent fault_injector
//     so faults can be selectively injected on any combination.
//
// Port Summary:
//   a, b, op        - ALU operands and operation select
//   fi0/fi1/fi2_*   - fault injector controls for each ALU
//   result          - 8-bit majority-voted output
//   carry_out       - carry/borrow from ALU0 (reference unit)
//   zero            - asserted when voted result == 0
//   fault_detected  - asserted when any module disagrees
//   faulty_module   - 2-bit one-hot: bit0=ALU0 faulty, bit1=ALU1, bit2=ALU2
// ============================================================

module top_tmr (
    input  wire        clk,
    input  wire        rst,

    // ALU inputs
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [2:0]  op,

    // Fault injector — ALU 0
    input  wire        fi0_en,
    input  wire [1:0]  fi0_type,
    input  wire [7:0]  fi0_mask,

    // Fault injector — ALU 1
    input  wire        fi1_en,
    input  wire [1:0]  fi1_type,
    input  wire [7:0]  fi1_mask,

    // Fault injector — ALU 2
    input  wire        fi2_en,
    input  wire [1:0]  fi2_type,
    input  wire [7:0]  fi2_mask,

    // Outputs
    output wire [7:0]  result,
    output wire        carry_out,
    output wire        zero,
    output wire        fault_detected,  // any module disagrees
    output wire [2:0]  faulty_module    // which module(s) appear faulty
);

    // ---- Raw ALU outputs ----
    wire [7:0] alu0_raw, alu1_raw, alu2_raw;
    wire       alu0_cout;

    // ---- Fault-injected outputs ----
    wire [7:0] alu0_fi, alu1_fi, alu2_fi;

    // ---- Voted output ----
    wire [7:0] voted;

    // --------------------------------------------------------
    // ALU instance 0
    // --------------------------------------------------------
    alu u_alu0 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu0_raw),
        .carry_out (alu0_cout),
        .zero      ()
    );

    // --------------------------------------------------------
    // ALU instance 1
    // --------------------------------------------------------
    alu u_alu1 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu1_raw),
        .carry_out (),
        .zero      ()
    );

    // --------------------------------------------------------
    // ALU instance 2
    // --------------------------------------------------------
    alu u_alu2 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu2_raw),
        .carry_out (),
        .zero      ()
    );

    // --------------------------------------------------------
    // Fault injectors
    // --------------------------------------------------------
    fault_injector u_fi0 (
        .data_in   (alu0_raw),
        .fault_type(fi0_type),
        .fault_mask(fi0_mask),
        .enable    (fi0_en),
        .data_out  (alu0_fi)
    );

    fault_injector u_fi1 (
        .data_in   (alu1_raw),
        .fault_type(fi1_type),
        .fault_mask(fi1_mask),
        .enable    (fi1_en),
        .data_out  (alu1_fi)
    );

    fault_injector u_fi2 (
        .data_in   (alu2_raw),
        .fault_type(fi2_type),
        .fault_mask(fi2_mask),
        .enable    (fi2_en),
        .data_out  (alu2_fi)
    );

    // --------------------------------------------------------
    // Majority voter
    // --------------------------------------------------------
    majority_voter u_voter (
        .in0         (alu0_fi),
        .in1         (alu1_fi),
        .in2         (alu2_fi),
        .voted_out   (voted),
        .fault_detect(fault_detected)
    );

    // --------------------------------------------------------
    // Faulty module identification
    //   A module is flagged when it disagrees with the majority
    //   (i.e., its output differs from the voted result).
    // --------------------------------------------------------
    assign faulty_module[0] = (alu0_fi != voted);
    assign faulty_module[1] = (alu1_fi != voted);
    assign faulty_module[2] = (alu2_fi != voted);

    // --------------------------------------------------------
    // Outputs
    // --------------------------------------------------------
    assign result    = voted;
    assign carry_out = alu0_cout;   // carry from reference unit
    assign zero      = (voted == 8'h00);

endmodule
