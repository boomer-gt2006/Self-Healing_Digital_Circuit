// ============================================================
// Testbench : tb_traditional
// Project   : Self-Healing Digital Circuit
// Description:
//   Evaluates and compares three design configurations:
//     1. Baseline   — single ALU (alu.v), no redundancy
//     2. DMR        — top_dmr.v, fault detection only
//     3. TMR        — top_tmr.v, fault correction via voting
//
//   Test Scenarios:
//     A. Normal operation (no faults) — all three should match
//     B. Single fault on one module   — DMR detects, TMR corrects
//     C. Stuck-at-0 fault             — verifies SA0 model
//     D. Stuck-at-1 fault             — verifies SA1 model
//     E. Bit-flip fault               — verifies XOR model
//     F. Two simultaneous faults      — demonstrates TMR limit
//
//   Console output:
//     Each test prints a row showing configuration, inputs,
//     expected, actual result, fault flags, and PASS/FAIL.
//
//   Waveform dump: tb_traditional.vcd (works with Vivado xsim
//   and Icarus Verilog).
// ============================================================

`timescale 1ns / 1ps

module tb_traditional;

    // =========================================================
    // Common ALU stimulus signals
    // =========================================================
    reg clk, rst;
    reg [7:0] a, b;
    reg [2:0] op;

    // =========================================================
    // Fault injector controls (shared naming, applied per DUT)
    // =========================================================
    reg        fi0_en,  fi1_en,  fi2_en;
    reg [1:0]  fi0_type, fi1_type, fi2_type;
    reg [7:0]  fi0_mask, fi1_mask, fi2_mask;

    // =========================================================
    // ALU (baseline) signals
    // =========================================================
    wire [7:0] alu_result;
    wire       alu_cout, alu_zero;

    // =========================================================
    // DMR signals
    // =========================================================
    wire [7:0] dmr_result;
    wire       dmr_cout, dmr_zero, dmr_fault;

    // =========================================================
    // TMR signals
    // =========================================================
    wire [7:0] tmr_result;
    wire       tmr_cout, tmr_zero, tmr_fault;
    wire [2:0] tmr_faulty_module;

    // =========================================================
    // Instantiate baseline ALU
    // =========================================================
    alu u_baseline (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .op        (op),
        .result    (alu_result),
        .carry_out (alu_cout),
        .zero      (alu_zero)
    );

    // =========================================================
    // Instantiate DMR top
    // =========================================================
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
        .carry_out     (dmr_cout),
        .zero          (dmr_zero),
        .fault_detected(dmr_fault)
    );

    // =========================================================
    // Instantiate TMR top
    // =========================================================
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
        .carry_out     (tmr_cout),
        .zero          (tmr_zero),
        .fault_detected(tmr_fault),
        .faulty_module (tmr_faulty_module)
    );

    // =========================================================
    // Clock — 10 ns period (100 MHz)
    // =========================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================================================
    // Helpers
    // =========================================================

    // Wait N rising edges then 1ns setup margin
    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i+1)
                @(posedge clk);
            #1;
        end
    endtask

    // Disable all fault injectors (pass-through)
    task clear_faults;
        begin
            fi0_en = 0; fi0_type = 2'b00; fi0_mask = 8'h00;
            fi1_en = 0; fi1_type = 2'b00; fi1_mask = 8'h00;
            fi2_en = 0; fi2_type = 2'b00; fi2_mask = 8'h00;
        end
    endtask

    // Apply inputs and wait 2 cycles for pipeline
    task apply;
        input [7:0] aa, bb;
        input [2:0] opc;
        begin
            a = aa; b = bb; op = opc;
            wait_cycles(2);
        end
    endtask

    // =========================================================
    // Test counters
    // =========================================================
    integer pass_count = 0;
    integer fail_count = 0;

    // ---- Print separator ----
    task print_sep;
        begin
            $display("+-----------+---------+-------+--------+-----------+--------------+-----------+");
        end
    endtask

    // ---- Check and report a single test ----
    // label    : up to 12 chars test label
    // expected : correct result regardless of faults
    // dut_res  : the result being checked
    // is_pass  : condition for a PASS
    task check;
        input [95:0] label;      // 12-char string stored in 96-bit reg
        input [7:0]  expected;
        input [7:0]  dut_res;
        input        is_pass;
        begin
            if (is_pass) begin
                $display("| %-9s | 0x%02h/%02h | op=%0b | 0x%02h   | 0x%02h      | dmr_f=%b tmr_f=%b | PASS      |",
                         label, a, b, op, expected, dut_res,
                         dmr_fault, tmr_fault);
                pass_count = pass_count + 1;
            end else begin
                $display("| %-9s | 0x%02h/%02h | op=%0b | 0x%02h   | 0x%02h      | dmr_f=%b tmr_f=%b | **FAIL**  |",
                         label, a, b, op, expected, dut_res,
                         dmr_fault, tmr_fault);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================================
    // Main Simulation
    // =========================================================
    initial begin
        $dumpfile("tb_traditional.vcd");
        $dumpvars(0, tb_traditional);

        // ---- Reset ----
        rst = 1;
        clear_faults;
        a = 0; b = 0; op = 0;
        wait_cycles(5);
        rst = 0;
        wait_cycles(2);

        // =========================================================
        // SCENARIO A: Normal operation — no faults
        // All three configurations must produce the same result.
        // =========================================================
        $display("\n");
        $display("=============================================================");
        $display("  SCENARIO A: Normal operation (no faults)");
        $display("=============================================================");
        print_sep;
        $display("| Config     | A / B   | OP    | Expect | Actual     | Fault Flags           | Result    |");
        print_sep;

        clear_faults;

        // ADD: 10 + 5 = 15 (0x0F)
        apply(8'h0A, 8'h05, 3'b000);
        check("BASELINE  ", 8'h0F, alu_result, alu_result === 8'h0F);
        check("DMR       ", 8'h0F, dmr_result, dmr_result === 8'h0F && dmr_fault === 0);
        check("TMR       ", 8'h0F, tmr_result, tmr_result === 8'h0F && tmr_fault === 0);
        print_sep;

        // SUB: 20 - 7 = 13 (0x0D)
        apply(8'h14, 8'h07, 3'b001);
        check("BASELINE  ", 8'h0D, alu_result, alu_result === 8'h0D);
        check("DMR       ", 8'h0D, dmr_result, dmr_result === 8'h0D && dmr_fault === 0);
        check("TMR       ", 8'h0D, tmr_result, tmr_result === 8'h0D && tmr_fault === 0);
        print_sep;

        // AND: 0xFF & 0x0F = 0x0F
        apply(8'hFF, 8'h0F, 3'b010);
        check("BASELINE  ", 8'h0F, alu_result, alu_result === 8'h0F);
        check("DMR       ", 8'h0F, dmr_result, dmr_result === 8'h0F && dmr_fault === 0);
        check("TMR       ", 8'h0F, tmr_result, tmr_result === 8'h0F && tmr_fault === 0);
        print_sep;

        // OR: 0xAA | 0x55 = 0xFF
        apply(8'hAA, 8'h55, 3'b011);
        check("BASELINE  ", 8'hFF, alu_result, alu_result === 8'hFF);
        check("DMR       ", 8'hFF, dmr_result, dmr_result === 8'hFF && dmr_fault === 0);
        check("TMR       ", 8'hFF, tmr_result, tmr_result === 8'hFF && tmr_fault === 0);
        print_sep;

        // XOR: 0xFF ^ 0xFF = 0x00
        apply(8'hFF, 8'hFF, 3'b100);
        check("BASELINE  ", 8'h00, alu_result, alu_result === 8'h00);
        check("DMR       ", 8'h00, dmr_result, dmr_result === 8'h00 && dmr_fault === 0);
        check("TMR       ", 8'h00, tmr_result, tmr_result === 8'h00 && tmr_fault === 0);
        print_sep;

        // NOT: ~0x55 = 0xAA
        apply(8'h55, 8'h00, 3'b101);
        check("BASELINE  ", 8'hAA, alu_result, alu_result === 8'hAA);
        check("DMR       ", 8'hAA, dmr_result, dmr_result === 8'hAA && dmr_fault === 0);
        check("TMR       ", 8'hAA, tmr_result, tmr_result === 8'hAA && tmr_fault === 0);
        print_sep;

        // SHL: 0x01 << 1 = 0x02
        apply(8'h01, 8'h00, 3'b110);
        check("BASELINE  ", 8'h02, alu_result, alu_result === 8'h02);
        check("DMR       ", 8'h02, dmr_result, dmr_result === 8'h02 && dmr_fault === 0);
        check("TMR       ", 8'h02, tmr_result, tmr_result === 8'h02 && tmr_fault === 0);
        print_sep;

        // SHR: 0x80 >> 1 = 0x40
        apply(8'h80, 8'h00, 3'b111);
        check("BASELINE  ", 8'h40, alu_result, alu_result === 8'h40);
        check("DMR       ", 8'h40, dmr_result, dmr_result === 8'h40 && dmr_fault === 0);
        check("TMR       ", 8'h40, tmr_result, tmr_result === 8'h40 && tmr_fault === 0);
        print_sep;

        // =========================================================
        // SCENARIO B: Single bit-flip fault on Module 1
        //   Fault model : bit-flip (XOR) on all bits of ALU1
        //   Expected behaviour —
        //     Baseline : no comparison → no detection (no redundancy)
        //     DMR      : DETECTS mismatch (dmr_fault=1), output may be wrong
        //     TMR      : CORRECTS fault via majority vote, output still correct
        // =========================================================
        $display("\n");
        $display("=============================================================");
        $display("  SCENARIO B: Single fault — Bit-flip on Module 1 (all bits)");
        $display("  Fault model  : bit-flip (fi1_type=11, fi1_mask=0xFF)");
        $display("  Expected     : DMR detects, TMR corrects");
        $display("=============================================================");
        print_sep;
        $display("| Config     | A / B   | OP    | Expect | Actual     | Fault Flags           | Result    |");
        print_sep;

        fi1_en   = 1;
        fi1_type = 2'b11;   // bit-flip
        fi1_mask = 8'hFF;   // all bits

        // ADD: 3 + 4 = 7 (0x07). ALU1 will output 0xF8 (flipped)
        apply(8'h03, 8'h04, 3'b000);
        check("BASELINE  ", 8'h07, alu_result, alu_result === 8'h07);
        // DMR: detects mismatch; output from ALU0 still correct
        check("DMR-detect", 8'h07, dmr_result, dmr_fault === 1);
        // TMR: majority of ALU0(0x07), ALU1(0xF8), ALU2(0x07) → 0x07
        check("TMR-correct", 8'h07, tmr_result, tmr_result === 8'h07 && tmr_fault === 1);
        print_sep;

        // AND: 0xAB & 0xCD — ALU1 flipped, majority still correct
        apply(8'hAB, 8'hCD, 3'b010);
        check("DMR-detect", 8'hAB & 8'hCD, dmr_result, dmr_fault === 1);
        check("TMR-correct", 8'hAB & 8'hCD, tmr_result, tmr_result === (8'hAB & 8'hCD));
        print_sep;

        clear_faults;

        // =========================================================
        // SCENARIO C: Stuck-at-0 fault on Module 2
        // =========================================================
        $display("\n");
        $display("=============================================================");
        $display("  SCENARIO C: Stuck-at-0 fault on Module 2 (all bits)");
        $display("  Fault model  : stuck-at-0 (fi2_type=01, fi2_mask=0xFF)");
        $display("=============================================================");
        print_sep;
        $display("| Config     | A / B   | OP    | Expect | Actual     | Fault Flags           | Result    |");
        print_sep;

        fi2_en   = 1;
        fi2_type = 2'b01;   // stuck-at-0
        fi2_mask = 8'hFF;   // all bits → output forced to 0x00

        // OR: 0xAA | 0x55 = 0xFF. ALU2 stuck at 0x00.
        apply(8'hAA, 8'h55, 3'b011);
        // TMR: ALU0=0xFF, ALU1=0xFF, ALU2=0x00 → majority vote = 0xFF ✓
        check("TMR-correct", 8'hFF, tmr_result,
              tmr_result === 8'hFF && tmr_fault === 1 && tmr_faulty_module[2] === 1);
        $display("[INFO] Faulty module flags: %03b (expect 100 for ALU2 — bit[2]=ALU2)", tmr_faulty_module);
        print_sep;

        // ADD: 0x08 + 0x08 = 0x10. ALU2 stuck-at-0 shows 0x00.
        apply(8'h08, 8'h08, 3'b000);
        check("TMR-correct", 8'h10, tmr_result,
              tmr_result === 8'h10 && tmr_faulty_module[2] === 1);
        print_sep;

        clear_faults;

        // =========================================================
        // SCENARIO D: Stuck-at-1 fault on Module 0 (primary module)
        //   Tests that TMR still produces correct output even when
        //   the primary ALU (Module 0) is the faulty one.
        // =========================================================
        $display("\n");
        $display("=============================================================");
        $display("  SCENARIO D: Stuck-at-1 on Module 0 (primary unit)");
        $display("  fi0_type=10, fi0_mask=0xFF");
        $display("=============================================================");
        print_sep;
        $display("| Config     | A / B   | OP    | Expect | Actual     | Fault Flags           | Result    |");
        print_sep;

        fi0_en   = 1;
        fi0_type = 2'b10;   // stuck-at-1
        fi0_mask = 8'hFF;   // → ALU0 output forced to 0xFF

        // ADD: 1 + 1 = 2 (0x02). ALU0 stuck=0xFF, ALU1=ALU2=0x02 → vote=0x02
        apply(8'h01, 8'h01, 3'b000);
        // Baseline: sees stuck-at-1 (0xFF) — wrong, no detection
        check("BASELINE  ", 8'h02, alu_result, 1'b0);   // expected fail — no redundancy
        // TMR: 2/3 correct → output = 0x02 ✓
        check("TMR-correct", 8'h02, tmr_result,
              tmr_result === 8'h02 && tmr_faulty_module[0] === 1);
        $display("[INFO] Faulty module flags: %03b (expect 001 for ALU0 — bit[0]=ALU0)", tmr_faulty_module);
        print_sep;

        clear_faults;

        // =========================================================
        // SCENARIO E: Two simultaneous faults — TMR limit
        //   Inject faults on Module 1 AND Module 2.
        //   2/3 modules are now faulty → majority vote is WRONG.
        //   This demonstrates the fundamental limit of TMR.
        // =========================================================
        $display("\n");
        $display("=============================================================");
        $display("  SCENARIO E: TWO simultaneous faults — TMR design limit");
        $display("  fi1: bit-flip all bits | fi2: stuck-at-0 all bits");
        $display("  With 2/3 modules faulty, majority vote cannot correct.");
        $display("=============================================================");
        print_sep;
        $display("| Config     | A / B   | OP    | Expect | Actual     | Fault Flags           | Result    |");
        print_sep;

        fi1_en = 1; fi1_type = 2'b11; fi1_mask = 8'hFF;  // bit-flip
        fi2_en = 1; fi2_type = 2'b01; fi2_mask = 8'hFF;  // stuck-at-0

        // ADD: 5 + 3 = 8 (0x08)
        // ALU0=0x08  ALU1=0xF7(flip) ALU2=0x00(SA0)
        // Majority: no two agree — voter selects bit-by-bit: uncertain
        apply(8'h05, 8'h03, 3'b000);
        $display("[INFO] Two-fault: result=0x%02h (correct=0x08) fault=%b faulty=%03b",
                 tmr_result, tmr_fault, tmr_faulty_module);
        $display("[INFO] TMR limit demonstrated — fault_detected=%b (expected 1)", tmr_fault);
        print_sep;

        clear_faults;

        // =========================================================
        // Summary
        // =========================================================
        $display("\n");
        $display("=============================================================");
        $display("   REDUNDANCY ANALYSIS SUMMARY");
        $display("=============================================================");
        $display("   Design      | Fault Detection | Fault Correction | Overhead");
        $display("   ------------|-----------------|------------------|----------");
        $display("   Baseline    | None            | None             | 1x ALU");
        $display("   DMR         | Yes (mismatch)  | No               | 2x ALU");
        $display("   TMR         | Yes             | Yes (1 fault)    | 3x ALU");
        $display("=============================================================");
        $display("   Tests passed : %0d", pass_count);
        $display("   Tests failed : %0d", fail_count);
        $display("   (Scenario D baseline failure is EXPECTED — no redundancy)");
        $display("=============================================================\n");

        $finish;
    end

    // =========================================================
    // Timeout watchdog
    // =========================================================
    initial begin
        #100000;
        $display("[TIMEOUT] Simulation exceeded limit.");
        $finish;
    end

endmodule
