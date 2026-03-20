// ============================================================
// Testbench  : tb_accuracy
// Project    : Self-Healing Digital Circuit
// Description:
//   Rigorous accuracy measurement testbench that compares all
//   four hardware architectures under a wide range of stimuli
//   and fault-injection scenarios.
//
//   Architectures under test
//   ─────────────────────────────────────────────────────────
//   1. Baseline  — single ALU with external fault injector
//                  (models a no-redundancy design)
//   2. DMR       — top_dmr.v  (detect only, primary = ALU0)
//   3. TMR       — top_tmr.v  (majority vote, corrects 1 fault)
//   4. Adaptive  — top_adaptive.v (dynamically switches
//                  SINGLE → TMR → PMR based on risk score;
//                  PMR = Penta Modular Redundancy, 5 ALUs,
//                  tolerates 2 simultaneous faults)
//
//   Accuracy Metric
//   ─────────────────────────────────────────────────────────
//   For every applied (a, b, op) vector the testbench computes
//   a software golden reference and compares each DUT's 8-bit
//   result output against it.  Accuracy = correct / total.
//
//   Test Stimulus Categories
//   ─────────────────────────────────────────────────────────
//   A) Corner cases  — zero/max operands, carry/borrow edges,
//      alternating-bit patterns, XOR-self, NOT-self.
//   B) All-operation sweep — N_CORNER random vectors per op.
//   C) Large random sweep  — N_RANDOM fully-random (a,b,op).
//   D) Fault burst + recovery — alternating fault/clean phases
//      exercising the adaptive system's escalation/de-escalation.
//   E) Fully-random fault pattern — en/type/mask randomised
//      independently each clock cycle.
//
//   Fault Injection Scenarios
//   ─────────────────────────────────────────────────────────
//   S0   Fault-free (all-corner + large random)
//   S1   Bit-flip all bits  — ALU0 only
//   S2   Bit-flip all bits  — ALU1 only
//   S3   Bit-flip all bits  — ALU2 only
//   S4   Stuck-at-0 all bits — ALU0 only
//   S5   Stuck-at-1 all bits — ALU0 only
//   S6   Bit-flip LSB only   — ALU0 only
//   S7   Bit-flip nibble (0x0F) — ALU0 only
//   S8   Double fault: bit-flip all — ALU0 + ALU1
//          (TMR fails; Adaptive PMR corrects)
//   S9   Double fault: bit-flip all — ALU1 + ALU2
//          (TMR fails; Adaptive PMR corrects)
//   S10  Triple fault: bit-flip all — ALU0 + ALU1 + ALU2
//          (3-of-5 wrong, PMR also fails)
//   S11  Random fault: en/type/mask random each clock cycle
//          (all 5 fault injectors randomised)
//   S12  Burst fault + recovery: ALU0 flips every N_BURST cycles
//   S13  Double fault: bit-flip all — ALU0 + ALU2 (non-adjacent pair)
//          (another PMR win: 3-of-5 still correct)
//   S14  Quad fault: bit-flip all — ALU0+ALU1+ALU2+ALU3
//          (4-of-5 faulty; PMR hard limit, all fail)
//
//   Adaptive Warm-Up
//   ─────────────────────────────────────────────────────────
//   For fault scenarios (S1–S14) the testbench first runs
//   N_WARMUP clock cycles WITHOUT accumulating accuracy counters.
//   This lets the risk_estimator observe fault events and
//   transition the adaptive system to an appropriate mode
//   before measurement begins.
//
//   Output
//   ─────────────────────────────────────────────────────────
//   A formatted accuracy table is printed to the simulator
//   console at the end of each scenario and a grand-total
//   row summarises overall accuracy.
// ============================================================

`timescale 1ns/1ps

`include "tb_accuracy_cfg.vh"

`ifndef TB_CLK_HALF
`define TB_CLK_HALF 5
`endif

`ifndef TB_N_RANDOM
`define TB_N_RANDOM 10_000
`endif

`ifndef TB_N_CORNER
`define TB_N_CORNER 500
`endif

`ifndef TB_N_WARMUP
`define TB_N_WARMUP 512
`endif

`ifndef TB_N_BURST
`define TB_N_BURST 1_000
`endif

`ifndef TB_SEED
`define TB_SEED 32'hDEAD_BEEF
`endif

`ifndef TB_FAULT_PROB_PCT
`define TB_FAULT_PROB_PCT 50
`endif

module tb_accuracy;

    // --------------------------------------------------------
    // Simulation parameters — edit here to increase coverage
    // --------------------------------------------------------
    parameter CLK_HALF  = `TB_CLK_HALF;   // 5 ns half-period → 100 MHz
    parameter N_RANDOM  = `TB_N_RANDOM;   // random vectors per scenario
    parameter N_CORNER  = `TB_N_CORNER;   // vectors per operation in per-op test
    parameter N_WARMUP  = `TB_N_WARMUP;   // warm-up clock cycles (not counted)
    parameter N_BURST   = `TB_N_BURST;    // fault-on / fault-off period for S12
    parameter SEED      = `TB_SEED;       // LFSR seed (fixed for reproducibility)
    parameter FAULT_PROB_PCT = `TB_FAULT_PROB_PCT; // fault enable probability for S11

    // --------------------------------------------------------
    // Clock and reset
    // --------------------------------------------------------
    reg clk = 0;
    always #CLK_HALF clk = ~clk;
    reg rst;

    // --------------------------------------------------------
    // Common stimulus signals
    // --------------------------------------------------------
    reg [7:0] a, b;
    reg [2:0] op;

    // Fault injection controls shared across all DUTs
    // fi0-fi2 map to ALU0-ALU2 (used by all architectures);
    // fi3-fi4 map to ALU3-ALU4 (Adaptive PMR only).
    reg        fi0_en,  fi1_en,  fi2_en,  fi3_en,  fi4_en;
    reg [1:0]  fi0_type, fi1_type, fi2_type, fi3_type, fi4_type;
    reg [7:0]  fi0_mask, fi1_mask, fi2_mask, fi3_mask, fi4_mask;

    // --------------------------------------------------------
    // DUT 1 : Baseline — single ALU + external fault injector
    // --------------------------------------------------------
    wire [7:0] alu_raw;
    wire       alu_cout, alu_zero;

    alu u_baseline (
        .clk      (clk),
        .rst      (rst),
        .a        (a),
        .b        (b),
        .op       (op),
        .result   (alu_raw),
        .carry_out(alu_cout),
        .zero     (alu_zero)
    );

    // External fault injector wraps the registered ALU output
    wire [7:0] base_result;
    fault_injector u_fi_base (
        .data_in   (alu_raw),
        .fault_type(fi0_type),
        .fault_mask(fi0_mask),
        .enable    (fi0_en),
        .data_out  (base_result)
    );

    // --------------------------------------------------------
    // DUT 2 : DMR
    // --------------------------------------------------------
    wire [7:0] dmr_result;
    wire       dmr_carry, dmr_zero, dmr_fault;

    top_dmr u_dmr (
        .clk           (clk),
        .rst           (rst),
        .a             (a),
        .b             (b),
        .op            (op),
        .fi0_en        (fi0_en),
        .fi0_type      (fi0_type),
        .fi0_mask      (fi0_mask),
        .fi1_en        (fi1_en),
        .fi1_type      (fi1_type),
        .fi1_mask      (fi1_mask),
        .result        (dmr_result),
        .carry_out     (dmr_carry),
        .zero          (dmr_zero),
        .fault_detected(dmr_fault)
    );

    // --------------------------------------------------------
    // DUT 3 : TMR
    // --------------------------------------------------------
    wire [7:0] tmr_result;
    wire       tmr_carry, tmr_zero, tmr_fault;
    wire [2:0] tmr_faulty;

    top_tmr u_tmr (
        .clk           (clk),
        .rst           (rst),
        .a             (a),
        .b             (b),
        .op            (op),
        .fi0_en        (fi0_en),
        .fi0_type      (fi0_type),
        .fi0_mask      (fi0_mask),
        .fi1_en        (fi1_en),
        .fi1_type      (fi1_type),
        .fi1_mask      (fi1_mask),
        .fi2_en        (fi2_en),
        .fi2_type      (fi2_type),
        .fi2_mask      (fi2_mask),
        .result        (tmr_result),
        .carry_out     (tmr_carry),
        .zero          (tmr_zero),
        .fault_detected(tmr_fault),
        .faulty_module (tmr_faulty)
    );

    // --------------------------------------------------------
    // DUT 4 : Adaptive
    // --------------------------------------------------------
    wire [7:0] adp_result;
    wire       adp_zero, adp_carry;
    wire [1:0] adp_risk, adp_mode;
    wire       adp_fault, adp_tmr_err;
    wire [4:0] adp_faulty;

    top_adaptive u_adaptive (
        .clk            (clk),
        .rst            (rst),
        .a              (a),
        .b              (b),
        .op             (op),
        .fi0_en         (fi0_en),
        .fi0_type       (fi0_type),
        .fi0_mask       (fi0_mask),
        .fi1_en         (fi1_en),
        .fi1_type       (fi1_type),
        .fi1_mask       (fi1_mask),
        .fi2_en         (fi2_en),
        .fi2_type       (fi2_type),
        .fi2_mask       (fi2_mask),
        .fi3_en         (fi3_en),
        .fi3_type       (fi3_type),
        .fi3_mask       (fi3_mask),
        .fi4_en         (fi4_en),
        .fi4_type       (fi4_type),
        .fi4_mask       (fi4_mask),
        .final_result   (adp_result),
        .zero_flag      (adp_zero),
        .carry_flag     (adp_carry),
        .risk_score     (adp_risk),
        .redundancy_mode(adp_mode),
        .fault_detected (adp_fault),
        .tmr_error      (adp_tmr_err),
        .faulty_module  (adp_faulty)
    );

    // --------------------------------------------------------
    // Golden reference (software model of the ALU)
    // --------------------------------------------------------
    reg [7:0] golden;
    reg       golden_carry;

    task compute_golden;
        input [7:0] aa, bb;
        input [2:0] opc;
        reg [8:0] tmp;
        begin
            case (opc)
                3'b000: begin   // ADD
                    tmp          = {1'b0, aa} + {1'b0, bb};
                    golden       = tmp[7:0];
                    golden_carry = tmp[8];
                end
                3'b001: begin   // SUB
                    tmp          = {1'b0, aa} - {1'b0, bb};
                    golden       = tmp[7:0];
                    golden_carry = tmp[8];   // borrow bit
                end
                3'b010: begin golden = aa & bb; golden_carry = 1'b0; end // AND
                3'b011: begin golden = aa | bb; golden_carry = 1'b0; end // OR
                3'b100: begin golden = aa ^ bb; golden_carry = 1'b0; end // XOR
                3'b101: begin golden = ~aa;     golden_carry = 1'b0; end // NOT
                3'b110: begin                                             // SHL
                    golden       = {aa[6:0], 1'b0};
                    golden_carry = aa[7];
                end
                3'b111: begin                                             // SHR
                    golden       = {1'b0, aa[7:1]};
                    golden_carry = aa[0];
                end
                default: begin golden = 8'h00; golden_carry = 1'b0; end
            endcase
        end
    endtask

    // --------------------------------------------------------
    // Accuracy counters (per-scenario)
    // --------------------------------------------------------
    integer base_ok,  base_tot;
    integer dmr_ok,   dmr_tot;
    integer tmr_ok,   tmr_tot;
    integer adp_ok,   adp_tot;

    // Grand-total counters (all scenarios combined)
    integer grand_base_ok,  grand_base_tot;
    integer grand_dmr_ok,   grand_dmr_tot;
    integer grand_tmr_ok,   grand_tmr_tot;
    integer grand_adp_ok,   grand_adp_tot;

    task reset_counters;
        begin
            base_ok = 0; base_tot = 0;
            dmr_ok  = 0; dmr_tot  = 0;
            tmr_ok  = 0; tmr_tot  = 0;
            adp_ok  = 0; adp_tot  = 0;
        end
    endtask

    task merge_grand;
        begin
            grand_base_ok  = grand_base_ok  + base_ok;
            grand_base_tot = grand_base_tot + base_tot;
            grand_dmr_ok   = grand_dmr_ok   + dmr_ok;
            grand_dmr_tot  = grand_dmr_tot  + dmr_tot;
            grand_tmr_ok   = grand_tmr_ok   + tmr_ok;
            grand_tmr_tot  = grand_tmr_tot  + tmr_tot;
            grand_adp_ok   = grand_adp_ok   + adp_ok;
            grand_adp_tot  = grand_adp_tot  + adp_tot;
        end
    endtask

    // --------------------------------------------------------
    // LFSR-based pseudo-random generator (32-bit Galois LFSR)
    // Taps at bits 31, 21, 1, 0  → maximal-length sequence.
    // Using a deterministic seed makes results reproducible.
    // --------------------------------------------------------
    reg [31:0] lfsr;

    task lfsr_step;
        begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        end
    endtask

    function should_inject_fault;
        input [7:0] rnd;
        integer threshold;
        begin
            threshold = (FAULT_PROB_PCT * 256) / 100;
            if (threshold < 0)
                threshold = 0;
            if (threshold > 255)
                threshold = 255;
            should_inject_fault = (rnd < threshold[7:0]);
        end
    endfunction

    // --------------------------------------------------------
    // Core timing task: apply one vector, wait one cycle,
    // compare all DUT outputs against the golden reference.
    // Updates the per-scenario counters.
    // --------------------------------------------------------
    task apply_and_check;
        input [7:0] aa, bb;
        input [2:0] opc;
        begin
            a  = aa;
            b  = bb;
            op = opc;
            @(posedge clk); #1;          // ALU registers result at posedge

            compute_golden(aa, bb, opc); // compute expected value

            base_tot = base_tot + 1;
            dmr_tot  = dmr_tot  + 1;
            tmr_tot  = tmr_tot  + 1;
            adp_tot  = adp_tot  + 1;

            if (base_result == golden) base_ok = base_ok + 1;
            if (dmr_result  == golden) dmr_ok  = dmr_ok  + 1;
            if (tmr_result  == golden) tmr_ok  = tmr_ok  + 1;
            if (adp_result  == golden) adp_ok  = adp_ok  + 1;
        end
    endtask

    // --------------------------------------------------------
    // Warm-up task: drive random inputs for N cycles WITHOUT
    // accumulating counters — lets the adaptive system react.
    // --------------------------------------------------------
    task do_warmup;
        input [31:0] n;
        integer wi;
        begin
            for (wi = 0; wi < n; wi = wi + 1) begin
                lfsr_step; a  = lfsr[7:0];
                lfsr_step; b  = lfsr[7:0];
                lfsr_step; op = lfsr[2:0];
                @(posedge clk); #1;
            end
        end
    endtask

    // --------------------------------------------------------
    // Convenience tasks
    // --------------------------------------------------------
    task clear_faults;
        begin
            fi0_en = 1'b0; fi0_type = 2'b00; fi0_mask = 8'h00;
            fi1_en = 1'b0; fi1_type = 2'b00; fi1_mask = 8'h00;
            fi2_en = 1'b0; fi2_type = 2'b00; fi2_mask = 8'h00;
            fi3_en = 1'b0; fi3_type = 2'b00; fi3_mask = 8'h00;
            fi4_en = 1'b0; fi4_type = 2'b00; fi4_mask = 8'h00;
        end
    endtask

    task do_reset;
        begin
            rst = 1'b1;
            repeat(4) @(posedge clk);
            #1;
            rst = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    // --------------------------------------------------------
    // Print helpers (avoid string-type: use compile-time labels)
    // --------------------------------------------------------
    // Caller uses $display directly for labelled rows.

    // --------------------------------------------------------
    // Per-operation name helper (index → readable string)
    // --------------------------------------------------------
    function [8*4-1:0] op_name;
        input [2:0] idx;
        begin
            case (idx)
                3'd0: op_name = " ADD";
                3'd1: op_name = " SUB";
                3'd2: op_name = " AND";
                3'd3: op_name = "  OR";
                3'd4: op_name = " XOR";
                3'd5: op_name = " NOT";
                3'd6: op_name = " SHL";
                3'd7: op_name = " SHR";
            endcase
        end
    endfunction

    // --------------------------------------------------------
    // Main test body
    // --------------------------------------------------------
    integer i, op_idx;

    // Scenario marker exported to VCD for per-scenario activity analysis.
    // S0..S12 use IDs 0..12, 31 means "outside scenario accounting".
    reg [4:0] scenario_id;
    wire [4:0] scenario_dbg = scenario_id;

    initial begin
        // Dump full hierarchy switching activity for VCD-based
        // dynamic power approximation in post-processing.
        $dumpfile("tb_accuracy.vcd");
        $dumpvars(0, tb_accuracy);

        // ---- Initialise ----
        lfsr = SEED;
        a = 8'h00; b = 8'h00; op = 3'b000;
        scenario_id = 5'd31;
        clear_faults;
        grand_base_ok  = 0; grand_base_tot = 0;
        grand_dmr_ok   = 0; grand_dmr_tot  = 0;
        grand_tmr_ok   = 0; grand_tmr_tot  = 0;
        grand_adp_ok   = 0; grand_adp_tot  = 0;
        do_reset;

        // ---- Header ----
        $display("");
        $display("==========================================================================================================================================");
        $display("  SELF-HEALING DIGITAL CIRCUIT — ARCHITECTURE ACCURACY BENCHMARK");
        $display("  Evaluation: Baseline (Single ALU) | DMR | TMR | Adaptive (Single->TMR->PMR)");
        $display("  Vectors per random scenario: %0d   Warm-up cycles: %0d", N_RANDOM, N_WARMUP);
        $display("==========================================================================================================================================");
        $display("| %-60s | Baseline |   DMR    |   TMR    | Adaptive |", "Scenario");
        $display("|%-62s|----------|----------|----------|----------|", "--------------------------------------------------------------|");

        // ==================================================================
        // S0 — FAULT-FREE  (corner cases + large random sweep)
        //
        //   Expected: all architectures = 100.00 %
        //   This scenario validates functional correctness.
        //   ANY deviation here indicates a design or testbench bug.
        // ==================================================================
        scenario_id = 5'd0;
        reset_counters;
        clear_faults;

        // Corner group A: zero / max operands for every operation
        for (i = 0; i < 8; i = i + 1) begin
            apply_and_check(8'h00, 8'h00, i[2:0]);   // both zero
            apply_and_check(8'hFF, 8'hFF, i[2:0]);   // both max
            apply_and_check(8'h00, 8'hFF, i[2:0]);   // zero vs max
            apply_and_check(8'hFF, 8'h00, i[2:0]);   // max vs zero
        end

        // Corner group B: carry / borrow boundary
        apply_and_check(8'hFF, 8'h01, 3'b000);  // ADD:  FF+01 → 00 carry=1
        apply_and_check(8'h80, 8'h80, 3'b000);  // ADD:  80+80 → 00 carry=1
        apply_and_check(8'hFE, 8'hFF, 3'b000);  // ADD:  FE+FF → FD carry=1
        apply_and_check(8'h00, 8'h01, 3'b001);  // SUB:  00-01 → FF borrow=1
        apply_and_check(8'h01, 8'hFF, 3'b001);  // SUB:  01-FF → 02 borrow=1
        apply_and_check(8'h80, 8'h01, 3'b001);  // SUB:  80-01 → 7F

        // Corner group C: shift edges
        apply_and_check(8'h80, 8'h00, 3'b110);  // SHL: MSB → carry, result 0
        apply_and_check(8'h40, 8'h00, 3'b110);  // SHL: MSB clear
        apply_and_check(8'h01, 8'h00, 3'b111);  // SHR: LSB → carry, result 0
        apply_and_check(8'hFE, 8'h00, 3'b111);  // SHR: even value

        // Corner group D: logic identity cases
        apply_and_check(8'hAA, 8'h55, 3'b010);  // AND alternating → 00
        apply_and_check(8'hAA, 8'h55, 3'b011);  // OR  alternating → FF
        apply_and_check(8'hAA, 8'hAA, 3'b100);  // XOR self        → 00
        apply_and_check(8'h55, 8'h55, 3'b100);  // XOR self        → 00
        apply_and_check(8'hFF, 8'h00, 3'b101);  // NOT ones        → 00
        apply_and_check(8'h00, 8'h00, 3'b101);  // NOT zeros       → FF
        apply_and_check(8'hA5, 8'h00, 3'b101);  // NOT pattern
        apply_and_check(8'hF0, 8'h0F, 3'b010);  // AND nibble mask → 00
        apply_and_check(8'hF0, 8'h0F, 3'b011);  // OR  nibble mask → FF
        apply_and_check(8'hF0, 8'h0F, 3'b100);  // XOR nibble mask → FF

        // Corner group E: alternating-bit stress patterns
        apply_and_check(8'h55, 8'hAA, 3'b000);  // ADD alternating
        apply_and_check(8'hAA, 8'h55, 3'b001);  // SUB alternating
        apply_and_check(8'h55, 8'h55, 3'b010);  // AND same
        apply_and_check(8'hAA, 8'hAA, 3'b011);  // OR  same

        // Large random sweep — all operations, all operand ranges
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a  = lfsr[7:0];
            lfsr_step; b  = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end

        // Sanity assertion: fault-free must be 100 % for ALL architectures
        if (base_ok != base_tot)
            $display("[ASSERTION FAIL] S0: Baseline has errors in fault-free mode! (%0d/%0d)", base_ok, base_tot);
        if (dmr_ok != dmr_tot)
            $display("[ASSERTION FAIL] S0: DMR has errors in fault-free mode! (%0d/%0d)", dmr_ok, dmr_tot);
        if (tmr_ok != tmr_tot)
            $display("[ASSERTION FAIL] S0: TMR has errors in fault-free mode! (%0d/%0d)", tmr_ok, tmr_tot);
        if (adp_ok != adp_tot)
            $display("[ASSERTION FAIL] S0: Adaptive has errors in fault-free mode! (%0d/%0d)", adp_ok, adp_tot);

        $display("| S0  Fault-free — corner cases + %0d random vectors              | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            N_RANDOM,
            100.0 * base_ok / base_tot,
            100.0 * dmr_ok  / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,
            100.0 * adp_ok  / adp_tot);
        merge_grand;

        // ==================================================================
        // S1 — BIT-FLIP ALL BITS, ALU0 FAULTY
        //
        //   Fault:    fi0_en=1, type=FLIP, mask=0xFF (all 8 bits inverted)
        //   Expected: Baseline  ≈   0 %  (only ALU, always corrupted)
        //             DMR       ≈   0 %  (primary=ALU0, also corrupted)
        //             TMR       ≈ 100 %  (2-of-3 majority corrects ALU0)
        //             Adaptive  ≈ 100 %  (escalates to TMR after warmup)
        // ==================================================================
        scenario_id = 5'd1;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b0; fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S1  Bit-flip ALL bits — ALU0 faulty (worst for Single/DMR)    | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S2 — BIT-FLIP ALL BITS, ALU1 FAULTY
        //
        //   Fault:    fi1_en=1, type=FLIP, mask=0xFF
        //   Expected: Baseline  ≈ 100 %  (ALU1 not in baseline)
        //             DMR       ≈ 100 %  (primary ALU0 healthy; ALU1 detected)
        //             TMR       ≈ 100 %  (majority corrects ALU1)
        //             Adaptive  ≈ 100 %  (all modes output from ALU0 or vote)
        // ==================================================================
        scenario_id = 5'd2;
        do_reset;
        reset_counters;
        fi0_en = 1'b0;
        fi1_en = 1'b1; fi1_type = 2'b11; fi1_mask = 8'hFF;
        fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S2  Bit-flip ALL bits — ALU1 faulty                            | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S3 — BIT-FLIP ALL BITS, ALU2 FAULTY
        //
        //   Fault:    fi2_en=1, type=FLIP, mask=0xFF
        //   Expected: Baseline  ≈ 100 %  (no ALU2)
        //             DMR       ≈ 100 %  (no ALU2 in DMR)
        //             TMR       ≈ 100 %  (majority corrects ALU2)
        //             Adaptive  ≈ 100 %  (in TMR mode after warmup)
        // ==================================================================
        scenario_id = 5'd3;
        do_reset;
        reset_counters;
        fi0_en = 1'b0; fi1_en = 1'b0;
        fi2_en = 1'b1; fi2_type = 2'b11; fi2_mask = 8'hFF;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S3  Bit-flip ALL bits — ALU2 faulty                            | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S4 — STUCK-AT-0, ALL BITS, ALU0 FAULTY
        //
        //   Fault:    fi0_en=1, type=SA0, mask=0xFF → result always 0x00
        //   Expected: Baseline  ≈   0 %  (always 0x00)
        //             DMR       ≈   0 %  (primary stuck at 0)
        //             TMR       ≈ 100 %  (majority corrects)
        //             Adaptive  ≈ 100 %  (TMR mode after warmup)
        // ==================================================================
        scenario_id = 5'd4;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b01; fi0_mask = 8'hFF;
        fi1_en = 1'b0; fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S4  Stuck-at-0 ALL bits — ALU0 faulty                          | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S5 — STUCK-AT-1, ALL BITS, ALU0 FAULTY
        //
        //   Fault:    fi0_en=1, type=SA1, mask=0xFF → result always 0xFF
        //   Expected: Baseline  ≈   0 %  (always 0xFF)
        //             DMR       ≈   0 %  (primary stuck at 1)
        //             TMR       ≈ 100 %  (majority corrects)
        //             Adaptive  ≈ 100 %  (TMR mode after warmup)
        // ==================================================================
        scenario_id = 5'd5;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b10; fi0_mask = 8'hFF;
        fi1_en = 1'b0; fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S5  Stuck-at-1 ALL bits — ALU0 faulty                          | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S6 — BIT-FLIP, SINGLE BIT (LSB), ALU0 FAULTY
        //
        //   Fault:    fi0_en=1, type=FLIP, mask=0x01 (bit-0 only)
        //   Effect:   Result bit-0 is always inverted; other bits intact.
        //   Expected: Baseline  < 100 %  (bit-0 always wrong)
        //             DMR       < 100 %  (primary LSB corrupted)
        //             TMR       ≈ 100 %  (majority corrects single-bit flip)
        //             Adaptive  ≈ 100 %  (TMR mode after warmup)
        // ==================================================================
        scenario_id = 5'd6;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'h01;
        fi1_en = 1'b0; fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S6  Bit-flip LSB only — ALU0 faulty                            | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S7 — BIT-FLIP, LOW NIBBLE (0x0F), ALU0 FAULTY
        //
        //   Fault:    fi0_en=1, type=FLIP, mask=0x0F (bits 3:0 inverted)
        //   Expected: Baseline  ≈  0 %  (4 bits always wrong)
        //             DMR       ≈  0 %  (primary nibble corrupted)
        //             TMR       ≈ 100 %  (majority corrects nibble flip)
        //             Adaptive  ≈ 100 %  (TMR mode after warmup)
        // ==================================================================
        scenario_id = 5'd7;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'h0F;
        fi1_en = 1'b0; fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S7  Bit-flip low nibble — ALU0 faulty                          | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S8 — DOUBLE FAULT: ALU0 + ALU1 BIT-FLIP ALL BITS
        //
        //   Fault:    fi0_en=1 FLIP/FF, fi1_en=1 FLIP/FF, fi2-fi4=off
        //   Expected: Baseline  ≈   0 %  (corrupted)
        //             DMR       ≈   0 %  (both modules corrupted; primary wrong)
        //             TMR       ≈   0 %  (2-of-3 faulty; majority votes wrong)
        //             Adaptive  ≈ 100 %  (escalates to PMR: 3-of-5 correct)
        //   KEY: First scenario demonstrating PMR's advantage over TMR.
        //        PMR tolerates 2 simultaneous faults; TMR cannot.
        // ==================================================================
        scenario_id = 5'd8;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b1; fi1_type = 2'b11; fi1_mask = 8'hFF;
        fi2_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S8  Double fault bit-flip ALL — ALU0+ALU1 faulty               | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S9 — DOUBLE FAULT: ALU1 + ALU2 BIT-FLIP ALL BITS
        //
        //   Fault:    fi0=off, fi1_en=1 FLIP/FF, fi2_en=1 FLIP/FF, fi3-fi4=off
        //   Expected: Baseline  ≈ 100 %  (ALU0 healthy, no ALU1/2 in baseline)
        //             DMR       ≈ 100 %  (ALU0 healthy primary; ALU1 is shadow)
        //             TMR       ≈   0 %  (ALU1+ALU2 form wrong majority)
        //             Adaptive  ≈ 100 %  (escalates to PMR: ALU0/3/4 correct)
        //   KEY: PMR corrects even when ALU1+ALU2 form a wrong majority.
        // ==================================================================
        scenario_id = 5'd9;
        do_reset;
        reset_counters;
        fi0_en = 1'b0;
        fi1_en = 1'b1; fi1_type = 2'b11; fi1_mask = 8'hFF;
        fi2_en = 1'b1; fi2_type = 2'b11; fi2_mask = 8'hFF;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S9  Double fault bit-flip ALL — ALU1+ALU2 faulty               | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S10 — TRIPLE FAULT: ALU0 + ALU1 + ALU2 BIT-FLIP ALL BITS
        //
        //   Fault:    fi0,fi1,fi2 all FLIP/FF; fi3,fi4=off
        //   Expected: Baseline  ≈ 0 %
        //             DMR       ≈ 0 %
        //             TMR       ≈ 0 %  (all 3 modules faulty)
        //             Adaptive  ≈ 0 %  (PMR: 3 wrong vs 2 correct → wrong wins)
        //   Note: PMR tolerates 2 faults; 3 faulty modules exceed its limit.
        // ==================================================================
        scenario_id = 5'd10;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b1; fi1_type = 2'b11; fi1_mask = 8'hFF;
        fi2_en = 1'b1; fi2_type = 2'b11; fi2_mask = 8'hFF;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S10 Triple fault bit-flip ALL — ALL ALUs faulty                | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S11 — FULLY RANDOM FAULT INJECTION (mixed realistic environment)
        //
        //   Each clock cycle: en, type, mask chosen independently at random
        //   for every fault injector.  This models a noisy environment where
        //   glitches are unpredictable in location, type, and severity.
        //   Fault probability per injector ≈ 50 % (lfsr bit 0 is equally 0/1).
        // ==================================================================
        scenario_id = 5'd11;
        do_reset;
        reset_counters;
        // Warmup with random faults on all 5 injectors
        begin : warmup_s11
            integer wu;
            for (wu = 0; wu < N_WARMUP; wu = wu + 1) begin
                lfsr_step; fi0_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi0_type = lfsr[1:0];
                lfsr_step; fi0_mask = lfsr[7:0];
                lfsr_step; fi1_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi1_type = lfsr[1:0];
                lfsr_step; fi1_mask = lfsr[7:0];
                lfsr_step; fi2_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi2_type = lfsr[1:0];
                lfsr_step; fi2_mask = lfsr[7:0];
                lfsr_step; fi3_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi3_type = lfsr[1:0];
                lfsr_step; fi3_mask = lfsr[7:0];
                lfsr_step; fi4_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi4_type = lfsr[1:0];
                lfsr_step; fi4_mask = lfsr[7:0];
                lfsr_step; a = lfsr[7:0];
                lfsr_step; b = lfsr[7:0];
                lfsr_step; op = lfsr[2:0];
                @(posedge clk); #1;
            end
        end
        begin : s11_measure
            integer s11_inj_base, s11_inj_dmr, s11_inj_tmr, s11_inj_adp;
            integer s11_det_dmr, s11_det_tmr, s11_det_adp;
            s11_inj_base = 0; s11_inj_dmr = 0; s11_inj_tmr = 0; s11_inj_adp = 0;
            s11_det_dmr  = 0; s11_det_tmr = 0; s11_det_adp = 0;

            for (i = 0; i < N_RANDOM; i = i + 1) begin
                lfsr_step; fi0_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi0_type = lfsr[1:0];
                lfsr_step; fi0_mask = lfsr[7:0];
                lfsr_step; fi1_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi1_type = lfsr[1:0];
                lfsr_step; fi1_mask = lfsr[7:0];
                lfsr_step; fi2_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi2_type = lfsr[1:0];
                lfsr_step; fi2_mask = lfsr[7:0];
                lfsr_step; fi3_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi3_type = lfsr[1:0];
                lfsr_step; fi3_mask = lfsr[7:0];
                lfsr_step; fi4_en   = should_inject_fault(lfsr[7:0]);
                lfsr_step; fi4_type = lfsr[1:0];
                lfsr_step; fi4_mask = lfsr[7:0];
                lfsr_step; a = lfsr[7:0];
                lfsr_step; b = lfsr[7:0];
                lfsr_step; op = lfsr[2:0];

                if (fi0_en) s11_inj_base = s11_inj_base + 1;
                if (fi0_en || fi1_en) s11_inj_dmr = s11_inj_dmr + 1;
                if (fi0_en || fi1_en || fi2_en) s11_inj_tmr = s11_inj_tmr + 1;
                if (fi0_en || fi1_en || fi2_en || fi3_en || fi4_en)
                    s11_inj_adp = s11_inj_adp + 1;

                apply_and_check(a, b, op);

                if (dmr_fault) s11_det_dmr = s11_det_dmr + 1;
                if (tmr_fault) s11_det_tmr = s11_det_tmr + 1;
                if (adp_fault) s11_det_adp = s11_det_adp + 1;
            end

            $display("S11_METRICS|inj_base=%0d|inj_dmr=%0d|inj_tmr=%0d|inj_adp=%0d|det_dmr=%0d|det_tmr=%0d|det_adp=%0d|ok_base=%0d|ok_dmr=%0d|ok_tmr=%0d|ok_adp=%0d|tot=%0d",
                s11_inj_base, s11_inj_dmr, s11_inj_tmr, s11_inj_adp,
                s11_det_dmr, s11_det_tmr, s11_det_adp,
                base_ok, dmr_ok, tmr_ok, adp_ok, base_tot);
        end
        clear_faults;
        $display("| S11 Random fault injection — all 5 injectors randomised/cycle  | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S12 — BURST FAULT + RECOVERY CYCLE (ALU0 only)
        //
        //   Fault pattern: ALU0 bit-flip-all is on for N_BURST cycles,
        //   then off for N_BURST cycles, repeating throughout the test.
        //   This exercises the Adaptive system's escalation AND de-escalation
        //   behaviour over multiple risk-estimation windows.
        //
        //   Expected:
        //     Baseline  — 0 % during fault bursts, 100 % during clean phases
        //     DMR       — same as Baseline (primary faulty during bursts)
        //     TMR       — ~100 % throughout (corrects single fault in bursts)
        //     Adaptive  — graceful: lower accuracy in first burst (before
        //                 escalation), then 100 % once in TMR mode.
        //                 May show some accuracy loss when de-escalating.
        // ==================================================================
        scenario_id = 5'd12;
        do_reset;
        reset_counters;
        begin : burst_loop
            integer bi;
            integer burst_phase;  // 0 = clean, 1 = fault
            integer cycle_in_phase;
            burst_phase    = 0;
            cycle_in_phase = 0;
            clear_faults;
            for (bi = 0; bi < N_RANDOM; bi = bi + 1) begin
                // Toggle phase every N_BURST cycles
                if (cycle_in_phase >= N_BURST) begin
                    cycle_in_phase = 0;
                    burst_phase    = burst_phase ^ 1;
                    if (burst_phase == 1) begin
                        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
                    end else begin
                        fi0_en = 1'b0;
                    end
                    fi1_en = 1'b0; fi2_en = 1'b0;
                end
                cycle_in_phase = cycle_in_phase + 1;

                lfsr_step; a  = lfsr[7:0];
                lfsr_step; b  = lfsr[7:0];
                lfsr_step; op = lfsr[2:0];
                apply_and_check(a, b, op);
            end
        end
        clear_faults;
        $display("| S12 Burst fault+recovery — ALU0 flips every %0d cycles          | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            N_BURST,
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S13 — DOUBLE FAULT: ALU0 + ALU2 BIT-FLIP ALL BITS (non-adjacent)
        //
        //   Fault:    fi0_en=1 FLIP/FF, fi2_en=1 FLIP/FF; fi1,fi3,fi4=off
        //   Tests a non-adjacent 2-of-5 failure pattern.
        //   Expected: Baseline  ≈   0 %  (ALU0 corrupted)
        //             DMR       ≈   0 %  (primary ALU0 corrupted)
        //             TMR       ≈   0 %  (ALU0+ALU2 = 2-of-3 wrong)
        //             Adaptive  ≈ 100 %  (PMR: ALU1,ALU3,ALU4 correct = 3-of-5)
        //   KEY: Confirms PMR corrects any 2-module failure combination.
        // ==================================================================
        scenario_id = 5'd13;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b0;
        fi2_en = 1'b1; fi2_type = 2'b11; fi2_mask = 8'hFF;
        fi3_en = 1'b0; fi4_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S13 Double fault ALU0+ALU2 (non-adjacent pair) — PMR wins       | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // S14 — QUAD FAULT: ALU0+ALU1+ALU2+ALU3 BIT-FLIP ALL BITS
        //
        //   Fault:    fi0,fi1,fi2,fi3 all FLIP/FF; fi4=off
        //   4-of-5 modules simultaneously faulty — PMR hard limit.
        //   Expected: Baseline  ≈ 0 %
        //             DMR       ≈ 0 %
        //             TMR       ≈ 0 %  (all 3 TMR modules faulty)
        //             Adaptive  ≈ 0 %  (PMR: 4 wrong vs 1 correct → wrong wins)
        //   Confirms that PMR requires at most 2 simultaneous faults to correct.
        // ==================================================================
        scenario_id = 5'd14;
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b1; fi1_type = 2'b11; fi1_mask = 8'hFF;
        fi2_en = 1'b1; fi2_type = 2'b11; fi2_mask = 8'hFF;
        fi3_en = 1'b1; fi3_type = 2'b11; fi3_mask = 8'hFF;
        fi4_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S14 Quad fault ALU0-ALU3 (PMR hard limit, 4-of-5 faulty)       | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            100.0 * base_ok / base_tot, 100.0 * dmr_ok / dmr_tot,
            100.0 * tmr_ok  / tmr_tot,  100.0 * adp_ok / adp_tot);
        merge_grand;

        // ==================================================================
        // Grand total across all scenarios
        // ==================================================================
        $display("|%-62s|----------|----------|----------|----------|", "--------------------------------------------------------------|");
        $display("| %-60s | %6.2f%%  | %6.2f%%  | %6.2f%%  | %6.2f%%  |",
            "GRAND TOTAL (all scenarios combined)",
            100.0 * grand_base_ok / grand_base_tot,
            100.0 * grand_dmr_ok  / grand_dmr_tot,
            100.0 * grand_tmr_ok  / grand_tmr_tot,
            100.0 * grand_adp_ok  / grand_adp_tot);
        $display("==========================================================================================================================================");

        // ==================================================================
        // PER-OPERATION ACCURACY (fault-free, N_CORNER vectors each op)
        //
        //   Purpose: verify that all 8 ALU operations produce the correct
        //   result on every architecture with no fault injection active.
        //   Any result below 100 % indicates a functional bug.
        // ==================================================================
        $display("");
        $display("------------------------------------------------------------------------------------------------------------------------------------------");
        $display("  PER-OPERATION ACCURACY — Fault-free, %0d random vectors per operation", N_CORNER);
        $display("  %-10s | Baseline  |    DMR    |    TMR    | Adaptive  |", "Operation");
        $display("  -----------|-----------|-----------|-----------|-----------|");

        scenario_id = 5'd31;
        do_reset;
        clear_faults;
        for (op_idx = 0; op_idx < 8; op_idx = op_idx + 1) begin
            reset_counters;
            for (i = 0; i < N_CORNER; i = i + 1) begin
                lfsr_step; a = lfsr[7:0];
                lfsr_step; b = lfsr[7:0];
                apply_and_check(a, b, op_idx[2:0]);
            end
            $display("  %s        | %6.2f%%   | %6.2f%%   | %6.2f%%   | %6.2f%%   |",
                op_name(op_idx[2:0]),
                100.0 * base_ok / base_tot,
                100.0 * dmr_ok  / dmr_tot,
                100.0 * tmr_ok  / tmr_tot,
                100.0 * adp_ok  / adp_tot);
        end
        $display("  -----------|-----------|-----------|-----------|-----------|");

        // ==================================================================
        // FLAG ACCURACY CHECK (zero flag + carry flag)
        //
        //   Verifies that the zero and carry flags reported by each DUT
        //   correctly reflect the computed result (fault-free mode only).
        // ==================================================================
        $display("");
        $display("------------------------------------------------------------------------------------------------------------------------------------------");
        $display("  FLAG ACCURACY CHECK — Fault-free, %0d random vectors", N_RANDOM);

        do_reset;
        clear_faults;
        begin : flag_check
            integer fc;
            integer zero_errs_base, zero_errs_dmr, zero_errs_tmr, zero_errs_adp;
            integer carry_errs_base, carry_errs_dmr, carry_errs_tmr, carry_errs_adp;
            integer zero_cases, carry_cases;
            reg expected_zero, expected_carry;

            zero_errs_base  = 0; zero_errs_dmr  = 0;
            zero_errs_tmr   = 0; zero_errs_adp  = 0;
            carry_errs_base = 0; carry_errs_dmr = 0;
            carry_errs_tmr  = 0; carry_errs_adp = 0;
            zero_cases  = 0;
            carry_cases = 0;

            for (fc = 0; fc < N_RANDOM; fc = fc + 1) begin
                lfsr_step; a  = lfsr[7:0];
                lfsr_step; b  = lfsr[7:0];
                lfsr_step; op = lfsr[2:0];
                a = a; b = b; op = op;
                @(posedge clk); #1;
                compute_golden(a, b, op);

                expected_zero  = (golden == 8'h00);
                expected_carry = golden_carry;

                // Zero flag: combinational from the result register
                if (expected_zero) begin
                    zero_cases = zero_cases + 1;
                    if (alu_zero  !== 1'b1) zero_errs_base = zero_errs_base + 1;
                    if (dmr_zero  !== 1'b1) zero_errs_dmr  = zero_errs_dmr  + 1;
                    if (tmr_zero  !== 1'b1) zero_errs_tmr  = zero_errs_tmr  + 1;
                    if (adp_zero  !== 1'b1) zero_errs_adp  = zero_errs_adp  + 1;
                end else begin
                    if (alu_zero  !== 1'b0) zero_errs_base = zero_errs_base + 1;
                    if (dmr_zero  !== 1'b0) zero_errs_dmr  = zero_errs_dmr  + 1;
                    if (tmr_zero  !== 1'b0) zero_errs_tmr  = zero_errs_tmr  + 1;
                    if (adp_zero  !== 1'b0) zero_errs_adp  = zero_errs_adp  + 1;
                end

                // Carry flag from the ALU-0 / primary path
                if (op == 3'b000 || op == 3'b001 ||
                    op == 3'b110 || op == 3'b111) begin
                    carry_cases = carry_cases + 1;
                    if (expected_carry) begin
                        if (alu_cout   !== 1'b1) carry_errs_base = carry_errs_base + 1;
                        if (dmr_carry  !== 1'b1) carry_errs_dmr  = carry_errs_dmr  + 1;
                        if (tmr_carry  !== 1'b1) carry_errs_tmr  = carry_errs_tmr  + 1;
                        if (adp_carry  !== 1'b1) carry_errs_adp  = carry_errs_adp  + 1;
                    end else begin
                        if (alu_cout   !== 1'b0) carry_errs_base = carry_errs_base + 1;
                        if (dmr_carry  !== 1'b0) carry_errs_dmr  = carry_errs_dmr  + 1;
                        if (tmr_carry  !== 1'b0) carry_errs_tmr  = carry_errs_tmr  + 1;
                        if (adp_carry  !== 1'b0) carry_errs_adp  = carry_errs_adp  + 1;
                    end
                end
            end

            $display("  Zero flag errors  : Baseline=%0d  DMR=%0d  TMR=%0d  Adaptive=%0d  (out of %0d zero-result cases + rest)",
                zero_errs_base, zero_errs_dmr, zero_errs_tmr, zero_errs_adp, zero_cases);
            $display("  Carry flag errors : Baseline=%0d  DMR=%0d  TMR=%0d  Adaptive=%0d  (out of %0d carry-relevant cases)",
                carry_errs_base, carry_errs_dmr, carry_errs_tmr, carry_errs_adp, carry_cases);
            if (zero_errs_base == 0 && zero_errs_dmr == 0 && zero_errs_tmr == 0 && zero_errs_adp == 0 &&
                carry_errs_base == 0 && carry_errs_dmr == 0 && carry_errs_tmr == 0 && carry_errs_adp == 0)
                $display("  [PASS] All zero and carry flags correct.");
            else
                $display("  [FAIL] Flag mismatches detected — review DUT flag logic.");
        end

        // ==================================================================
        // ADAPTIVE SYSTEM MODE PROFILE (final scenario with fault on ALU0)
        //
        //   Observes which mode the Adaptive system settles in under a
        //   sustained single-ALU fault and reports cycle-by-cycle mode
        //   transitions during a short probe window.
        // ==================================================================
        $display("");
        $display("------------------------------------------------------------------------------------------------------------------------------------------");
        $display("  ADAPTIVE MODE PROFILE — ALU0 bit-flip, first 400 cycles");
        $display("  Cycle |  Risk | Mode        | adp_result correct?");
        $display("  ------|-------|-------------|--------------------");

        do_reset;
        clear_faults;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b0; fi2_en = 1'b0; fi3_en = 1'b0; fi4_en = 1'b0;

        begin : mode_profile
            integer mp;
            reg [1:0] last_mode;
            last_mode = 2'bxx;
            for (mp = 0; mp < 400; mp = mp + 1) begin
                lfsr_step; a = lfsr[7:0];
                lfsr_step; b = lfsr[7:0];
                lfsr_step; op = lfsr[2:0];
                a = a; b = b; op = op;
                @(posedge clk); #1;
                compute_golden(a, b, op);
                if (adp_mode !== last_mode) begin
                    case (adp_mode)
                        2'b00: $display("  %4d  |  %0d    | SINGLE      | %s",
                            mp, adp_risk, (adp_result == golden) ? "YES" : "NO ");
                        2'b01: $display("  %4d  |  %0d    | TMR         | %s",
                            mp, adp_risk, (adp_result == golden) ? "YES" : "NO ");
                        2'b10: $display("  %4d  |  %0d    | PMR (penta) | %s",
                            mp, adp_risk, (adp_result == golden) ? "YES" : "NO ");
                        default: $display("  %4d  |  %0d    | UNKNOWN     | %s",
                            mp, adp_risk, (adp_result == golden) ? "YES" : "NO ");
                    endcase
                    last_mode = adp_mode;
                end
            end
        end
        clear_faults;

        // ==================================================================
        // END
        // ==================================================================
        $display("");
        $display("==========================================================================================================================================");
        $display("  ACCURACY BENCHMARK COMPLETE — %0d total vectors applied.", grand_base_tot);
        $display("==========================================================================================================================================");
        $display("");
        $finish;
    end

endmodule
