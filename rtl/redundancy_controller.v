`timescale 1ns/1ps
// ============================================================
// Module  : redundancy_controller
// Project : Self-Healing Digital Circuit
// Description:
//   Adaptive Redundancy Controller.
//   Translates a 2-bit risk score into enable signals for the
//   five ALU instances and selects the appropriate output
//   multiplexing mode for the output selection logic.
//
//   Risk Score → Active Modules:
//     2'b00 (LOW)    → Module 0 only         (Single operation)
//     2'b01 (MEDIUM) → Modules 0, 1, 2       (TMR — majority vote, tolerates 1 fault)
//     2'b10 (HIGH)   → Modules 0, 1, 2, 3, 4 (PMR — penta vote, tolerates 2 faults)
//
//   mode encoding (to top_adaptive output mux):
//     2'b00 — Single : use alu0 result directly
//     2'b01 — TMR    : use 3-input majority voter result
//     2'b10 — PMR    : use 5-input penta voter result
//
// ============================================================

module redundancy_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  risk_score,     // from risk_estimator
    output reg         alu0_en,        // enable ALU instance 0
    output reg         alu1_en,        // enable ALU instance 1
    output reg         alu2_en,        // enable ALU instance 2
    output reg         alu3_en,        // enable ALU instance 3 (PMR only)
    output reg         alu4_en,        // enable ALU instance 4 (PMR only)
    output reg  [1:0]  mode            // current redundancy mode
);

    localparam MODE_SINGLE = 2'b00;
    localparam MODE_TMR    = 2'b01;
    localparam MODE_PMR    = 2'b10;

    always @(posedge clk) begin
        if (rst) begin
            alu0_en <= 1'b1;   // primary module always on
            alu1_en <= 1'b0;
            alu2_en <= 1'b0;
            alu3_en <= 1'b0;
            alu4_en <= 1'b0;
            mode    <= MODE_SINGLE;
        end else begin
            case (risk_score)
                2'b00: begin   // LOW risk — single module
                    alu0_en <= 1'b1;
                    alu1_en <= 1'b0;
                    alu2_en <= 1'b0;
                    alu3_en <= 1'b0;
                    alu4_en <= 1'b0;
                    mode    <= MODE_SINGLE;
                end
                2'b01: begin   // MEDIUM risk — TMR (3 modules)
                    alu0_en <= 1'b1;
                    alu1_en <= 1'b1;
                    alu2_en <= 1'b1;
                    alu3_en <= 1'b0;
                    alu4_en <= 1'b0;
                    mode    <= MODE_TMR;
                end
                2'b10,         // HIGH risk — PMR (5 modules)
                2'b11: begin   // (treat 11 as HIGH too)
                    alu0_en <= 1'b1;
                    alu1_en <= 1'b1;
                    alu2_en <= 1'b1;
                    alu3_en <= 1'b1;
                    alu4_en <= 1'b1;
                    mode    <= MODE_PMR;
                end
                default: begin
                    alu0_en <= 1'b1;
                    alu1_en <= 1'b0;
                    alu2_en <= 1'b0;
                    alu3_en <= 1'b0;
                    alu4_en <= 1'b0;
                    mode    <= MODE_SINGLE;
                end
            endcase
        end
    end

endmodule
