`timescale 1ns/1ps
// ============================================================
// Module  : top_module
// Project : Self-Healing Digital Circuit
// Description:
//   Top-level integration of all sub-modules.
//
//   Data-path:
//     Three ALU instances compute the same operation in parallel.
//     Each ALU output passes through its own fault_injector.
//     The three (possibly corrupted) outputs feed the majority_voter.
//
//   Control-path:
//     risk_estimator monitors the primary ALU output and fault events.
//     redundancy_controller translates risk to enable signals and mode.
//
//   Output mux:
//     mode == SINGLE (00) → output from ALU 0 directly
//     mode == DMR    (01) → output from ALU 0; dmr_error flag set on mismatch
//     mode == TMR    (10) → majority-voted output
//
//   Fault injection wiring:
//     Each injector is independently controllable from the top-level
//     ports, which are driven by the testbench (or a higher-level
//     controller in a real system).
// ============================================================

module top_module (
    input  wire        clk,
    input  wire        rst,

    // ALU operands and operation
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [2:0]  op,

    // Fault injection controls (one set per ALU instance)
    input  wire        fi0_en,
    input  wire [1:0]  fi0_type,
    input  wire [7:0]  fi0_mask,

    input  wire        fi1_en,
    input  wire [1:0]  fi1_type,
    input  wire [7:0]  fi1_mask,

    input  wire        fi2_en,
    input  wire [1:0]  fi2_type,
    input  wire [7:0]  fi2_mask,

    // Primary outputs
    output wire [7:0]  final_result,
    output wire        zero_flag,
    output wire        carry_flag,

    // Status / monitor outputs
    output wire [1:0]  risk_score,
    output wire [1:0]  redundancy_mode,
    output wire        fault_detected,   // any voter disagreement
    output wire        dmr_error         // ALU0 vs ALU1 mismatch in DMR mode
);

    // --------------------------------------------------------
    // ALU enable signals from controller
    // --------------------------------------------------------
    wire alu0_en, alu1_en, alu2_en;

    // --------------------------------------------------------
    // ALU raw outputs
    // --------------------------------------------------------
    wire [7:0] alu0_raw, alu1_raw, alu2_raw;
    wire       alu0_cout, alu1_cout, alu2_cout;
    wire       alu0_zero, alu1_zero, alu2_zero;

    // --------------------------------------------------------
    // Fault-injected outputs
    // --------------------------------------------------------
    wire [7:0] alu0_fi, alu1_fi, alu2_fi;

    // --------------------------------------------------------
    // Voter output
    // --------------------------------------------------------
    wire [7:0] voted_result;
    wire       voter_fault;

    // --------------------------------------------------------
    // ALU instance 0  (always enabled)
    // --------------------------------------------------------
    alu u_alu0 (
        .clk       (clk),
        .rst       (rst | ~alu0_en),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu0_raw),
        .carry_out (alu0_cout),
        .zero      (alu0_zero)
    );

    // --------------------------------------------------------
    // ALU instance 1
    // --------------------------------------------------------
    alu u_alu1 (
        .clk       (clk),
        .rst       (rst | ~alu1_en),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu1_raw),
        .carry_out (alu1_cout),
        .zero      (alu1_zero)
    );

    // --------------------------------------------------------
    // ALU instance 2
    // --------------------------------------------------------
    alu u_alu2 (
        .clk       (clk),
        .rst       (rst | ~alu2_en),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu2_raw),
        .carry_out (alu2_cout),
        .zero      (alu2_zero)
    );

    // --------------------------------------------------------
    // Fault injectors (one per ALU output)
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
        .in0        (alu0_fi),
        .in1        (alu1_fi),
        .in2        (alu2_fi),
        .voted_out  (voted_result),
        .fault_detect(voter_fault)
    );

    // --------------------------------------------------------
    // Risk estimator
    // --------------------------------------------------------
    risk_estimator #(
        .WINDOW_CYCLES(64),
        .TOGGLE_MED   (10),
        .TOGGLE_HIGH  (30),
        .ERROR_MED    (2),
        .ERROR_HIGH   (4)
    ) u_risk (
        .clk              (clk),
        .rst              (rst),
        .monitored_signal (alu0_raw),
        .fault_detect     (voter_fault),
        .risk_score       (risk_score)
    );

    // --------------------------------------------------------
    // Redundancy controller
    // --------------------------------------------------------
    redundancy_controller u_ctrl (
        .clk         (clk),
        .rst         (rst),
        .risk_score  (risk_score),
        .alu0_en     (alu0_en),
        .alu1_en     (alu1_en),
        .alu2_en     (alu2_en),
        .mode        (redundancy_mode)
    );

    // --------------------------------------------------------
    // Output multiplexer
    // --------------------------------------------------------
    // mode: 00=SINGLE, 01=DMR, 10=TMR
    assign final_result = (redundancy_mode == 2'b10) ? voted_result : alu0_fi;
    assign carry_flag   = alu0_cout;
    assign zero_flag    = (final_result == 8'h00);
    assign fault_detected = voter_fault;

    // DMR error: mismatch between ALU0 and ALU1 while in DMR mode
    assign dmr_error = (redundancy_mode == 2'b01) && (alu0_fi != alu1_fi);

endmodule
