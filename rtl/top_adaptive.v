`timescale 1ns/1ps
// ============================================================
// Module  : top_adaptive
// Project : Self-Healing Digital Circuit
// Description:
//   Adaptive Redundancy top-level integration with hybrid
//   residue-based verification for module quarantine.
//
//   Modes:
//     00 SINGLE : ALU0 direct output
//     01 TMR    : 3-way vote (healthy modules only)
//     10 PMR    : 5-way vote with quarantined modules masked
//
//   Hybrid extension:
//   - Per-module residue checker validates arithmetic ops
//     (ADD/SUB) in modular domain.
//   - Residue-mismatching modules are quarantined and excluded
//     from voting while keeping at least 3 healthy modules.
// ============================================================

`include "adaptive_risk_cfg.vh"

`ifndef ADP_WINDOW_CYCLES
`define ADP_WINDOW_CYCLES 64
`endif

`ifndef ADP_TOGGLE_MED
`define ADP_TOGGLE_MED 10
`endif

`ifndef ADP_TOGGLE_HIGH
`define ADP_TOGGLE_HIGH 30
`endif

`ifndef ADP_ERROR_MED
`define ADP_ERROR_MED 2
`endif

`ifndef ADP_ERROR_HIGH
`define ADP_ERROR_HIGH 4
`endif

module top_adaptive #(
    parameter integer QUAR_POLICY      = 0,
    parameter integer QUAR_TRIP_COUNT  = 2,
    parameter integer QUAR_CLEAR_COUNT = 8
) (
    input  wire        clk,
    input  wire        rst,

    // ALU inputs
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [2:0]  op,

    // Fault injector controls ? one set per ALU (5 modules for PMR)
    input  wire        fi0_en,
    input  wire [1:0]  fi0_type,
    input  wire [7:0]  fi0_mask,

    input  wire        fi1_en,
    input  wire [1:0]  fi1_type,
    input  wire [7:0]  fi1_mask,

    input  wire        fi2_en,
    input  wire [1:0]  fi2_type,
    input  wire [7:0]  fi2_mask,

    input  wire        fi3_en,
    input  wire [1:0]  fi3_type,
    input  wire [7:0]  fi3_mask,

    input  wire        fi4_en,
    input  wire [1:0]  fi4_type,
    input  wire [7:0]  fi4_mask,

    // Outputs
    output wire [7:0]  final_result,
    output wire        zero_flag,
    output wire        carry_flag,
    output wire [1:0]  risk_score,
    output wire [1:0]  redundancy_mode,
    output wire        fault_detected,
    output wire        tmr_error,
    output wire [4:0]  faulty_module
);

    localparam integer QUAR_POLICY_RESIDUE_ONLY = 0;
    localparam integer QUAR_POLICY_VOTER_ONLY   = 1;
    localparam integer QUAR_POLICY_FUSED_AND    = 2;
    localparam integer QUAR_POLICY_FUSED_OR     = 3;

    // --------------------------------------------------------
    // Utility functions
    // --------------------------------------------------------
    function [2:0] popcount5;
        input [4:0] v;
        begin
            popcount5 = v[0] + v[1] + v[2] + v[3] + v[4];
        end
    endfunction

    function [7:0] pick_alu;
        input [2:0] idx;
        input [7:0] d0;
        input [7:0] d1;
        input [7:0] d2;
        input [7:0] d3;
        input [7:0] d4;
        begin
            case (idx)
                3'd0: pick_alu = d0;
                3'd1: pick_alu = d1;
                3'd2: pick_alu = d2;
                3'd3: pick_alu = d3;
                3'd4: pick_alu = d4;
                default: pick_alu = 8'h00;
            endcase
        end
    endfunction

    // --------------------------------------------------------
    // Internal signals
    // --------------------------------------------------------
    wire [7:0] alu0_raw, alu1_raw, alu2_raw, alu3_raw, alu4_raw;
    wire       alu0_cout;
    wire [7:0] alu0_fi, alu1_fi, alu2_fi, alu3_fi, alu4_fi;

    wire [7:0] voted_result;
    wire       voter_fault;
    wire [7:0] penta_result;

    wire alu0_en, alu1_en, alu2_en, alu3_en, alu4_en;

    wire [4:0] residue_valid;
    wire [4:0] residue_mismatch;
    reg  [4:0] quarantined;
    wire [2:0] healthy_count;

    reg [2:0] tmr_idx0, tmr_idx1, tmr_idx2;
    reg [2:0] tmr_pick_count;
    reg [7:0] tmr_in0, tmr_in1, tmr_in2;
    reg [4:0] tmr_active_mask;
    reg [4:0] tmr_voter_faulty;

    reg [4:0] pmr_active_mask;
    reg [4:0] penta_faulty_filtered;
    reg       penta_fault_filtered;

    reg  [4:0] residue_event;
    reg  [4:0] voter_event;
    reg  [4:0] detect_event;
    reg  [4:0] considered_module;

    reg  [3:0] bad_streak [0:4];
    reg  [5:0] good_streak [0:4];
    integer qi;

    reg fault_detect_gated;

    assign healthy_count = popcount5(~quarantined);

    // --------------------------------------------------------
    // ALU instances ? all run continuously
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

    alu u_alu3 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu3_raw),
        .carry_out (),
        .zero      ()
    );

    alu u_alu4 (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu4_raw),
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

    fault_injector u_fi3 (
        .data_in   (alu3_raw),
        .fault_type(fi3_type),
        .fault_mask(fi3_mask),
        .enable    (fi3_en),
        .data_out  (alu3_fi)
    );

    fault_injector u_fi4 (
        .data_in   (alu4_raw),
        .fault_type(fi4_type),
        .fault_mask(fi4_mask),
        .enable    (fi4_en),
        .data_out  (alu4_fi)
    );

    // --------------------------------------------------------
    // Residue-based verifiers (fault localization signal)
    // --------------------------------------------------------
    residue_checker u_res0 (
        .a(a), .b(b), .op(op), .result(alu0_fi),
        .valid(residue_valid[0]), .mismatch(residue_mismatch[0])
    );

    residue_checker u_res1 (
        .a(a), .b(b), .op(op), .result(alu1_fi),
        .valid(residue_valid[1]), .mismatch(residue_mismatch[1])
    );

    residue_checker u_res2 (
        .a(a), .b(b), .op(op), .result(alu2_fi),
        .valid(residue_valid[2]), .mismatch(residue_mismatch[2])
    );

    residue_checker u_res3 (
        .a(a), .b(b), .op(op), .result(alu3_fi),
        .valid(residue_valid[3]), .mismatch(residue_mismatch[3])
    );

    residue_checker u_res4 (
        .a(a), .b(b), .op(op), .result(alu4_fi),
        .valid(residue_valid[4]), .mismatch(residue_mismatch[4])
    );

    // --------------------------------------------------------
    // Build TMR voter inputs from first 3 non-quarantined ALUs
    // --------------------------------------------------------
    always @(*) begin
        tmr_idx0 = 3'd0;
        tmr_idx1 = 3'd1;
        tmr_idx2 = 3'd2;
        tmr_pick_count = 3'd0;
        tmr_active_mask = 5'b00000;

        if (!quarantined[0] && (tmr_pick_count < 3)) begin
            if (tmr_pick_count == 0) tmr_idx0 = 3'd0;
            else if (tmr_pick_count == 1) tmr_idx1 = 3'd0;
            else tmr_idx2 = 3'd0;
            tmr_pick_count = tmr_pick_count + 1'b1;
        end
        if (!quarantined[1] && (tmr_pick_count < 3)) begin
            if (tmr_pick_count == 0) tmr_idx0 = 3'd1;
            else if (tmr_pick_count == 1) tmr_idx1 = 3'd1;
            else tmr_idx2 = 3'd1;
            tmr_pick_count = tmr_pick_count + 1'b1;
        end
        if (!quarantined[2] && (tmr_pick_count < 3)) begin
            if (tmr_pick_count == 0) tmr_idx0 = 3'd2;
            else if (tmr_pick_count == 1) tmr_idx1 = 3'd2;
            else tmr_idx2 = 3'd2;
            tmr_pick_count = tmr_pick_count + 1'b1;
        end
        if (!quarantined[3] && (tmr_pick_count < 3)) begin
            if (tmr_pick_count == 0) tmr_idx0 = 3'd3;
            else if (tmr_pick_count == 1) tmr_idx1 = 3'd3;
            else tmr_idx2 = 3'd3;
            tmr_pick_count = tmr_pick_count + 1'b1;
        end
        if (!quarantined[4] && (tmr_pick_count < 3)) begin
            if (tmr_pick_count == 0) tmr_idx0 = 3'd4;
            else if (tmr_pick_count == 1) tmr_idx1 = 3'd4;
            else tmr_idx2 = 3'd4;
            tmr_pick_count = tmr_pick_count + 1'b1;
        end

        if (tmr_pick_count < 3) begin
            tmr_idx0 = 3'd0;
            tmr_idx1 = 3'd1;
            tmr_idx2 = 3'd2;
        end

        tmr_in0 = pick_alu(tmr_idx0, alu0_fi, alu1_fi, alu2_fi, alu3_fi, alu4_fi);
        tmr_in1 = pick_alu(tmr_idx1, alu0_fi, alu1_fi, alu2_fi, alu3_fi, alu4_fi);
        tmr_in2 = pick_alu(tmr_idx2, alu0_fi, alu1_fi, alu2_fi, alu3_fi, alu4_fi);

        tmr_active_mask[tmr_idx0] = 1'b1;
        tmr_active_mask[tmr_idx1] = 1'b1;
        tmr_active_mask[tmr_idx2] = 1'b1;
    end

    // --------------------------------------------------------
    // PMR active mask excludes quarantined modules while keeping >=3
    // --------------------------------------------------------
    always @(*) begin
        pmr_active_mask = 5'b11111 & ~quarantined;
        if (popcount5(pmr_active_mask) < 3)
            pmr_active_mask = 5'b11111;
    end

    // --------------------------------------------------------
    // Voters
    // --------------------------------------------------------
    majority_voter u_voter (
        .in0         (tmr_in0),
        .in1         (tmr_in1),
        .in2         (tmr_in2),
        .voted_out   (voted_result),
        .fault_detect(voter_fault)
    );

    penta_voter u_penta (
        .in0         (pmr_active_mask[0] ? alu0_fi : 8'h00),
        .in1         (pmr_active_mask[1] ? alu1_fi : 8'h00),
        .in2         (pmr_active_mask[2] ? alu2_fi : 8'h00),
        .in3         (pmr_active_mask[3] ? alu3_fi : 8'h00),
        .in4         (pmr_active_mask[4] ? alu4_fi : 8'h00),
        .voted_out   (penta_result),
        .fault_detect(),
        .faulty_module()
    );

    always @(*) begin
        penta_faulty_filtered[0] = pmr_active_mask[0] && (alu0_fi != penta_result);
        penta_faulty_filtered[1] = pmr_active_mask[1] && (alu1_fi != penta_result);
        penta_faulty_filtered[2] = pmr_active_mask[2] && (alu2_fi != penta_result);
        penta_faulty_filtered[3] = pmr_active_mask[3] && (alu3_fi != penta_result);
        penta_faulty_filtered[4] = pmr_active_mask[4] && (alu4_fi != penta_result);
        penta_fault_filtered = |penta_faulty_filtered;

        tmr_voter_faulty[0] = tmr_active_mask[0] && (alu0_fi != voted_result);
        tmr_voter_faulty[1] = tmr_active_mask[1] && (alu1_fi != voted_result);
        tmr_voter_faulty[2] = tmr_active_mask[2] && (alu2_fi != voted_result);
        tmr_voter_faulty[3] = tmr_active_mask[3] && (alu3_fi != voted_result);
        tmr_voter_faulty[4] = tmr_active_mask[4] && (alu4_fi != voted_result);

        residue_event[0] = residue_valid[0] && residue_mismatch[0];
        residue_event[1] = residue_valid[1] && residue_mismatch[1];
        residue_event[2] = residue_valid[2] && residue_mismatch[2];
        residue_event[3] = residue_valid[3] && residue_mismatch[3];
        residue_event[4] = residue_valid[4] && residue_mismatch[4];

        case (redundancy_mode)
            2'b01: voter_event = tmr_voter_faulty;
            2'b10: voter_event = penta_faulty_filtered;
            default: voter_event = 5'b00000;
        endcase

        case (QUAR_POLICY)
            QUAR_POLICY_RESIDUE_ONLY: detect_event = residue_event;
            QUAR_POLICY_VOTER_ONLY:   detect_event = voter_event;
            QUAR_POLICY_FUSED_AND:    detect_event = residue_event & voter_event;
            QUAR_POLICY_FUSED_OR:     detect_event = residue_event | voter_event;
            default:                  detect_event = residue_event;
        endcase

        case (redundancy_mode)
            2'b01: considered_module = 5'b00111;
            2'b10: considered_module = 5'b11111;
            default: considered_module = 5'b00000;
        endcase
    end

    // --------------------------------------------------------
    // Risk estimator and controller
    // --------------------------------------------------------
    always @(*) begin
        case (redundancy_mode)
            2'b00:   fault_detect_gated = 1'b0;
            2'b01:   fault_detect_gated = voter_fault;
            2'b10:   fault_detect_gated = penta_fault_filtered;
            default: fault_detect_gated = 1'b0;
        endcase
    end

    risk_estimator #(
        .WINDOW_CYCLES(`ADP_WINDOW_CYCLES),
        .TOGGLE_MED   (`ADP_TOGGLE_MED),
        .TOGGLE_HIGH  (`ADP_TOGGLE_HIGH),
        .ERROR_MED    (`ADP_ERROR_MED),
        .ERROR_HIGH   (`ADP_ERROR_HIGH)
    ) u_risk (
        .clk              (clk),
        .rst              (rst),
        .monitored_signal (alu0_raw),
        .fault_detect     (fault_detect_gated),
        .risk_score       (risk_score)
    );

    redundancy_controller u_ctrl (
        .clk         (clk),
        .rst         (rst),
        .risk_score  (risk_score),
        .alu0_en     (alu0_en),
        .alu1_en     (alu1_en),
        .alu2_en     (alu2_en),
        .alu3_en     (alu3_en),
        .alu4_en     (alu4_en),
        .mode        (redundancy_mode)
    );

    // --------------------------------------------------------
    // Quarantine update with cooldown/reintegration
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            quarantined <= 5'b00000;
            for (qi = 0; qi < 5; qi = qi + 1) begin
                bad_streak[qi]  <= 4'd0;
                good_streak[qi] <= 6'd0;
            end
        end else begin
            for (qi = 0; qi < 5; qi = qi + 1) begin
                if (!considered_module[qi]) begin
                    bad_streak[qi]  <= 4'd0;
                    good_streak[qi] <= 6'd0;
                end else if (detect_event[qi]) begin
                    if (bad_streak[qi] != 4'hF)
                        bad_streak[qi] <= bad_streak[qi] + 1'b1;
                    good_streak[qi] <= 6'd0;
                end else begin
                    bad_streak[qi] <= 4'd0;
                    if (good_streak[qi] != 6'h3F)
                        good_streak[qi] <= good_streak[qi] + 1'b1;
                end

                if (!quarantined[qi] && considered_module[qi] && (healthy_count > 3'd2) &&
                    detect_event[qi] && (bad_streak[qi] >= (QUAR_TRIP_COUNT - 1))) begin
                    quarantined[qi] <= 1'b1;
                end

                if (quarantined[qi] && considered_module[qi] && !detect_event[qi] &&
                    (good_streak[qi] >= QUAR_CLEAR_COUNT)) begin
                    quarantined[qi] <= 1'b0;
                end
            end
        end
    end

    // --------------------------------------------------------
    // Outputs
    // --------------------------------------------------------
    assign final_result = (redundancy_mode == 2'b10) ? penta_result :
                          (redundancy_mode == 2'b01) ? voted_result :
                                                       alu0_fi;
    assign carry_flag   = alu0_cout;
    assign zero_flag    = (final_result == 8'h00);

    assign fault_detected = fault_detect_gated;
    assign tmr_error      = (redundancy_mode == 2'b01) && voter_fault;

    // Expose quarantined modules as persistent faulty status.
    assign faulty_module = quarantined;

endmodule
