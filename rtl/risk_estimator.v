`timescale 1ns/1ps
// ============================================================
// Module  : risk_estimator
// Project : Self-Healing Digital Circuit
// Description:
//   Runtime risk estimation engine.
//   Computes a 2-bit risk score from two independent monitoring
//   channels and combines them via a weighted priority scheme.
//
//   Channel 1 — Switching Activity Monitor
//     Counts transitions on the primary ALU output over a
//     programmable observation window (WINDOW_CYCLES).
//     High toggle rate → increased glitch probability.
//
//   Channel 2 — Error Detection Monitor
//     Counts fault_detect pulses (from the majority voter)
//     within the same observation window.
//     High error count → degraded module health.
//
//   Risk Score Encoding:
//     2'b00 — LOW    : Single mode
//     2'b01 — MEDIUM : TMR mode
//     2'b10 — HIGH   : PMR mode
//
// Parameters:
//   WINDOW_CYCLES - width of observation window in clock cycles
//   TOGGLE_MED    - toggle count threshold: LOW  → MEDIUM
//   TOGGLE_HIGH   - toggle count threshold: MEDIUM → HIGH
//   ERROR_MED     - error count threshold : LOW  → MEDIUM
//   ERROR_HIGH    - error count threshold : MEDIUM → HIGH
// ============================================================

module risk_estimator #(
    parameter WINDOW_CYCLES = 64,
    parameter TOGGLE_MED    = 10,
    parameter TOGGLE_HIGH   = 30,
    parameter ERROR_MED     = 2,
    parameter ERROR_HIGH    = 4
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  monitored_signal,   // ALU output to track
    input  wire        fault_detect,       // from majority_voter
    output reg  [1:0]  risk_score          // 00=LOW 01=MED 10=HIGH
);

    // Internal counters
    reg [7:0]  toggle_count;
    reg [7:0]  error_count;
    reg [6:0]  window_timer;
    reg [7:0]  prev_signal;

    // Intermediate risk levels derived from each channel
    reg [1:0]  toggle_risk;
    reg [1:0]  error_risk;

    // --------------------------------------------------------
    // Window timer and counter update
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            toggle_count <= 8'h00;
            error_count  <= 8'h00;
            window_timer <= 7'h00;
            prev_signal  <= 8'h00;
            risk_score   <= 2'b00;
            toggle_risk  <= 2'b00;
            error_risk   <= 2'b00;
        end else begin
            // Count transitions on monitored signal
            if (monitored_signal != prev_signal)
                toggle_count <= toggle_count + 1;
            prev_signal <= monitored_signal;

            // Count error events from voter
            if (fault_detect)
                error_count <= error_count + 1;

            // Observation window management
            if (window_timer == WINDOW_CYCLES - 1) begin
                // ---- Compute risk directly from counts to avoid 1-window lag ----
                risk_score <=
                  ((toggle_count >= TOGGLE_HIGH) || (error_count >= ERROR_HIGH)) ? 2'b10 :
                  ((toggle_count >= TOGGLE_MED)  || (error_count >= ERROR_MED))  ? 2'b01 : 2'b00;

                // Keep intermediate signals for waveform debugging
                toggle_risk <= (toggle_count >= TOGGLE_HIGH) ? 2'b10 :
                               (toggle_count >= TOGGLE_MED)  ? 2'b01 : 2'b00;
                error_risk  <= (error_count >= ERROR_HIGH)   ? 2'b10 :
                               (error_count >= ERROR_MED)    ? 2'b01 : 2'b00;

                // Reset counters for next window
                toggle_count <= 8'h00;
                error_count  <= 8'h00;
                window_timer <= 7'h00;
            end else begin
                window_timer <= window_timer + 1;
            end
        end
    end

endmodule
