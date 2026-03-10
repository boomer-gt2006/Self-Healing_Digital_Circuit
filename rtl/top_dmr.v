`timescale 1ns/1ps
// ============================================================
// Module  : top_dmr
// Project : Self-Healing Digital Circuit
// Description:
//   Dual Modular Redundancy (DMR) system.
//
//   Two identical ALU instances compute the same operation.
//   Their outputs are compared bit-by-bit.
//
//   Key properties of DMR:
//     - CAN DETECT a single module fault (mismatch)
//     - CANNOT CORRECT a fault (no voting — tie-break impossible)
//     - On mismatch: primary output (ALU0) is still forwarded,
//       and fault_detected is asserted for the system to act on.
//
//   Fault injection:
//     Each ALU output passes through an independent fault_injector
//     so the testbench can corrupt one or both paths.
//
// Port Summary:
//   a, b, op        - ALU operands and operation select
//   fi0_*/fi1_*     - fault injector controls for ALU0 / ALU1
//   result          - 8-bit output (from ALU0, the primary unit)
//   carry_out       - carry/borrow from ALU0
//   zero            - asserted when result == 0
//   fault_detected  - asserted when ALU0 and ALU1 outputs disagree
// ============================================================

module top_dmr (
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

    // Outputs
    output wire [7:0]  result,
    output wire        carry_out,
    output wire        zero,
    output wire        fault_detected   // mismatch indicator
);

    // ---- Raw ALU outputs ----
    wire [7:0] alu0_raw, alu1_raw;
    wire       alu0_cout, alu1_cout;
    wire       alu0_zero, alu1_zero;

    // ---- Fault-injected outputs ----
    wire [7:0] alu0_fi, alu1_fi;

    // --------------------------------------------------------
    // ALU instance 0 — primary
    // --------------------------------------------------------
    alu u_alu0 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu0_raw),
        .carry_out (alu0_cout),
        .zero      (alu0_zero)
    );

    // --------------------------------------------------------
    // ALU instance 1 — shadow / backup
    // --------------------------------------------------------
    alu u_alu1 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu1_raw),
        .carry_out (alu1_cout),
        .zero      (alu1_zero)
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

    // --------------------------------------------------------
    // DMR comparator
    // Any bit-level mismatch between the two outputs → fault
    // --------------------------------------------------------
    assign fault_detected = (alu0_fi != alu1_fi);

    // --------------------------------------------------------
    // Output driven from primary unit (ALU0)
    // In a real system an external controller would halt or
    // switch to a spare on fault_detected.
    // --------------------------------------------------------
    assign result    = alu0_fi;
    assign carry_out = alu0_cout;
    assign zero      = (alu0_fi == 8'h00);

endmodule
