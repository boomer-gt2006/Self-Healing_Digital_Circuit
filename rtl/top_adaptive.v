`timescale 1ns/1ps
// ============================================================
// Module  : top_adaptive
// Project : Self-Healing Digital Circuit
// Description:
//   Adaptive Redundancy top-level integration.
//   Combines DMR, TMR, Risk Estimation, and Adaptive Control.
//
//   KEY DESIGN DECISION — Mode-Gated Fault Detection:
//   -------------------------------------------------------
//   All three ALU instances run at all times. The redundancy
//   controller's "enable" signals reflect the *logical* active
//   set, not clock gating (power gating is a physical concern).
//
//   The CRITICAL fix over a naive integration is that the
//   fault_detect signal fed to the risk_estimator is gated by
//   the current mode:
//
//     SINGLE (00): fault_detect_gated = 0
//       No comparison is made. Disabled ALUs output 0 which
//       would cause constant false faults without this gate.
//
//     DMR    (01): fault_detect_gated = (alu0_fi != alu1_fi)
//       Only compare the two active modules.
//
//     TMR    (10): fault_detect_gated = voter_fault
//       3-way comparison from majority_voter.
//
//   Output Selection:
//     SINGLE / DMR : alu0_fi (primary unit)
//     TMR          : voted_result (majority corrected)
//
// Port Summary:
//   a, b, op           - ALU operands and opcode
//   fi{0,1,2}_*        - per-module fault injector controls
//   final_result       - 8-bit system output
//   zero_flag          - asserted when final_result == 0
//   carry_flag         - carry/borrow (from ALU 0)
//   risk_score         - 2-bit risk level (00=LOW 01=MED 10=HIGH)
//   redundancy_mode    - 2-bit current mode (00=Single 01=DMR 10=TMR)
//   fault_detected     - mode-aware fault indicator
//   dmr_error          - DMR-specific mismatch flag
//   faulty_module      - 3-bit one-hot faulty module ID (TMR mode)
// ============================================================

module top_adaptive (
    input  wire        clk,
    input  wire        rst,

    // ALU inputs
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [2:0]  op,

    // Fault injector controls — one set per ALU
    input  wire        fi0_en,
    input  wire [1:0]  fi0_type,
    input  wire [7:0]  fi0_mask,

    input  wire        fi1_en,
    input  wire [1:0]  fi1_type,
    input  wire [7:0]  fi1_mask,

    input  wire        fi2_en,
    input  wire [1:0]  fi2_type,
    input  wire [7:0]  fi2_mask,

    // Outputs
    output wire [7:0]  final_result,
    output wire        zero_flag,
    output wire        carry_flag,
    output wire [1:0]  risk_score,
    output wire [1:0]  redundancy_mode,
    output wire        fault_detected,
    output wire        dmr_error,
    output wire [2:0]  faulty_module
);

    // --------------------------------------------------------
    // Internal wires
    // --------------------------------------------------------
    wire [7:0] alu0_raw, alu1_raw, alu2_raw;
    wire       alu0_cout;
    wire [7:0] alu0_fi,  alu1_fi,  alu2_fi;
    wire [7:0] voted_result;
    wire       voter_fault;

    // Enable signals from redundancy controller
    wire alu0_en, alu1_en, alu2_en;

    // --------------------------------------------------------
    // Mode-gated fault detection — the critical fix
    // --------------------------------------------------------
    // All ALUs always run; disabled ones still output their
    // computed (possibly reset) value. Without mode-gating,
    // ALUs held in reset (output=0) cause permanent mismatches
    // against the active ALU, flooding the risk estimator and
    // locking the system in TMR mode forever.
    // --------------------------------------------------------
    reg fault_detect_gated;

    always @(*) begin
        case (redundancy_mode)
            2'b00:   fault_detect_gated = 1'b0;                  // SINGLE
            2'b01:   fault_detect_gated = (alu0_fi != alu1_fi);  // DMR
            2'b10:   fault_detect_gated = voter_fault;            // TMR
            default: fault_detect_gated = 1'b0;
        endcase
    end

    // --------------------------------------------------------
    // ALU instances — all run continuously
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
    // Majority voter (always active — used in TMR mode)
    // --------------------------------------------------------
    majority_voter u_voter (
        .in0         (alu0_fi),
        .in1         (alu1_fi),
        .in2         (alu2_fi),
        .voted_out   (voted_result),
        .fault_detect(voter_fault)
    );

    // --------------------------------------------------------
    // Risk estimator
    // Receives the mode-gated fault detect to prevent
    // false risk escalation from inactive modules.
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
        .fault_detect     (fault_detect_gated),
        .risk_score       (risk_score)
    );

    // --------------------------------------------------------
    // Adaptive redundancy controller
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
    //   SINGLE/DMR : use ALU 0 output directly
    //   TMR        : use majority-voted output
    // --------------------------------------------------------
    assign final_result = (redundancy_mode == 2'b10) ? voted_result
                                                      : alu0_fi;
    assign carry_flag   = alu0_cout;
    assign zero_flag    = (final_result == 8'h00);

    // --------------------------------------------------------
    // Status outputs
    // --------------------------------------------------------
    assign fault_detected  = fault_detect_gated;

    // DMR mismatch between ALU0 and ALU1 in DMR mode
    assign dmr_error       = (redundancy_mode == 2'b01)
                             && (alu0_fi != alu1_fi);

    // Faulty module identification (relative to voted result)
    assign faulty_module[0] = (alu0_fi != voted_result);
    assign faulty_module[1] = (alu1_fi != voted_result);
    assign faulty_module[2] = (alu2_fi != voted_result);

endmodule
