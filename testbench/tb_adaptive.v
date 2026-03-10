// ============================================================
// Testbench : tb_adaptive
// Project   : Self-Healing Digital Circuit
// Description:
//   Verifies the Adaptive Redundancy architecture end-to-end.
//
//   Test phases:
//   ------------------------------------------------------------------
//   Phase 1 — Startup / Low Risk
//     System boots in SINGLE mode (risk=LOW).
//     Verify correct output and fault_detected = 0.
//
//   Phase 2 — Toggle-Based Escalation to DMR
//     Single mode cannot detect hardware faults. Risk escalates
//     to MEDIUM via high switching activity.
//
//   Phase 3 — Fault-Based Escalation to TMR
//     Now in DMR mode, the comparator works. Inject faults into ALU 1.
//     fault_detect_gated pulses drive risk to HIGH.
//     Mode transitions to TMR.
//
//   Phase 4 — TMR Correction Verification
//     Still in TMR. Errors on ALU 1 are masked successfully.
//
//   Phase 5 — Risk De-escalation
//     Clear faults and stop toggling input. After two windows,
//     risk score drops and mode returns to SINGLE.
// ============================================================

`timescale 1ns / 1ps

module tb_adaptive;

    // --------------------------------------------------------
    // DUT signals
    // --------------------------------------------------------
    reg        clk, rst;
    reg  [7:0] a, b;
    reg  [2:0] op;

    reg        fi0_en,  fi1_en,  fi2_en;
    reg  [1:0] fi0_type, fi1_type, fi2_type;
    reg  [7:0] fi0_mask, fi1_mask, fi2_mask;

    wire [7:0] final_result;
    wire       zero_flag, carry_flag;
    wire [1:0] risk_score;
    wire [1:0] redundancy_mode;
    wire       fault_detected, dmr_error;
    wire [2:0] faulty_module;

    // --------------------------------------------------------
    // DUT instantiation
    // --------------------------------------------------------
    top_adaptive dut (
        .clk            (clk),
        .rst            (rst),
        .a              (a),
        .b              (b),
        .op             (op),
        .fi0_en         (fi0_en),  .fi0_type (fi0_type), .fi0_mask (fi0_mask),
        .fi1_en         (fi1_en),  .fi1_type (fi1_type), .fi1_mask (fi1_mask),
        .fi2_en         (fi2_en),  .fi2_type (fi2_type), .fi2_mask (fi2_mask),
        .final_result   (final_result),
        .zero_flag      (zero_flag),
        .carry_flag     (carry_flag),
        .risk_score     (risk_score),
        .redundancy_mode(redundancy_mode),
        .fault_detected (fault_detected),
        .dmr_error      (dmr_error),
        .faulty_module  (faulty_module)
    );

    // --------------------------------------------------------
    // Clock — 10 ns period
    // --------------------------------------------------------
    initial clk = 0;
    always  #5 clk = ~clk;

    // --------------------------------------------------------
    // Helpers
    // --------------------------------------------------------
    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
            #1;
        end
    endtask

    task clear_faults;
        begin
            fi0_en = 0; fi0_type = 2'b00; fi0_mask = 8'h00;
            fi1_en = 0; fi1_type = 2'b00; fi1_mask = 8'h00;
            fi2_en = 0; fi2_type = 2'b00; fi2_mask = 8'h00;
        end
    endtask

    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input [95:0]  label;
        input         condition;
        input [127:0] detail;
        begin
            if (condition) begin
                $display("[PASS] %-12s | mode=%b risk=%b | %s",
                         label, redundancy_mode, risk_score, detail);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %-12s | mode=%b risk=%b | %s",
                         label, redundancy_mode, risk_score, detail);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // --------------------------------------------------------
    // Logging hooks
    // --------------------------------------------------------
    reg [1:0] prev_mode;
    always @(posedge clk) begin
        if (redundancy_mode !== prev_mode) begin
            $display("[MODE CHANGE] %0t ns : mode %b -> %b  (risk=%b)",
                     $time, prev_mode, redundancy_mode, risk_score);
            prev_mode <= redundancy_mode;
        end
    end

    reg [1:0] prev_risk;
    always @(posedge clk) begin
        if (risk_score !== prev_risk) begin
            $display("[RISK CHANGE] %0t ns : risk %b -> %b",
                     $time, prev_risk, risk_score);
            prev_risk <= risk_score;
        end
    end

    // --------------------------------------------------------
    // Main test
    // --------------------------------------------------------
    integer i;

    initial begin
        $dumpfile("tb_adaptive.vcd");
        $dumpvars(0, tb_adaptive);

        prev_mode = 2'b00;
        prev_risk = 2'b00;
        rst = 1;
        a = 0; b = 0; op = 0;
        clear_faults;
        wait_cycles(8);
        rst = 0;
        wait_cycles(2);

        // ====================================================
        // PHASE 1: Startup — expect SINGLE mode, LOW risk
        // ====================================================
        $display("\n===== PHASE 1: Startup — expect SINGLE mode =====");

        a = 8'h05; b = 8'h03; op = 3'b000; // ADD: 8
        wait_cycles(3);
        check("SINGLE-mode", redundancy_mode === 2'b00, "mode should be 00 (SINGLE) at startup");
        check("SINGLE-result", final_result === 8'h08, "5+3 = 0x08 correct in single mode");
        check("no-fault", fault_detected === 1'b0, "no fault expected with no injection");

        // ====================================================
        // PHASE 2: High switching activity → DMR escalation
        // ====================================================
        $display("\n===== PHASE 2: High Switching Activity → DMR escalation =====");
        // Drive varying inputs using XOR. We want > 10 toggles but < 30 per 64-cycle window.
        // Toggling once every 3 cycles -> 21 toggles per window -> MEDIUM risk.
        for (i = 0; i < 140; i = i + 1) begin
            a  = ((i / 3) % 2 == 0) ? 8'hAA : 8'h55;
            b  = 8'h00;
            op = 3'b100; // XOR
            @(posedge clk); #1;
        end

        check("DMR-mode", redundancy_mode === 2'b01, "mode should be 01 (DMR) due to high Toggle activity");

        // ====================================================
        // PHASE 3: Inject faults on ALU1 → TMR escalation
        // ====================================================
        $display("\n===== PHASE 3: Fault Injection in DMR → TMR escalation =====");
        // We are in DMR now. Enable fault injection on ALU 1 to drive error count up.
        fi1_en   = 1;
        fi1_type = 2'b11;  // bit-flip
        fi1_mask = 8'hFF;

        // Give constant input (no toggle activity) but continuous injection
        for (i = 0; i < 140; i = i + 1) begin
            a = 8'h0A; b = 8'h02; op = 3'b000; // ADD: 12 (0x0C)
            @(posedge clk); #1;
        end

        check("TMR-mode", redundancy_mode === 2'b10, "mode should be 10 (TMR) due to high Error activity");

        // ====================================================
        // PHASE 4: TMR Fault Correction (still having faults)
        // ====================================================
        $display("\n===== PHASE 4: TMR Fault Correction =====");
        // Even with active faults on ALU 1, TMR should majority vote the correct result to the output
        wait_cycles(2);
        check("TMR-corrects", final_result === 8'h0C, "TMR should correct ALU1 bit-flip, result=0x0C");
        check("faulty-mod1", faulty_module[1] === 1'b1, "faulty_module[1] should flag ALU1");

        // ====================================================
        // PHASE 5: Clear Faults & De-escalation
        // ====================================================
        $display("\n===== PHASE 5: Clear faults & De-escalate to SINGLE =====");
        clear_faults;

        // Hold stable input to minimize toggle count for two windows (>128 cycles)
        a = 8'h11; b = 8'h11; op = 3'b000; // ADD: 8'h22
        for (i = 0; i < 140; i = i + 1) begin
            @(posedge clk); #1;
        end

        check("deescalate", redundancy_mode === 2'b00, "mode should have dropped to SINGLE after clearing faults and no toggles");

        // ====================================================
        // Summary
        // ====================================================
        $display("\n========================================");
        $display("  ADAPTIVE REDUNDANCY TEST SUMMARY");
        $display("  Tests passed : %0d", pass_count);
        $display("  Tests failed : %0d", fail_count);
        $display("========================================\n");

        $finish;
    end

    // Watchdog
    initial begin
        #200000;
        $display("[TIMEOUT] Exceeded 200000 ns.");
        $finish;
    end

endmodule
