// ============================================================
// Testbench  : tb_residue_quick_check
// Project    : Self-Healing Digital Circuit
// Description:
//   Quick side-by-side accuracy comparison of adaptive
//   architectures with and without residue-based quarantine.
//   Uses fewer test vectors for faster simulation.
// ============================================================

`timescale 1ns/1ps

module tb_residue_quick_check;

    parameter CLK_HALF  = 5;
    parameter N_RANDOM  = 1_000;   // Reduced from 10,000
    parameter N_CORNER  = 50;      // Reduced from 500
    parameter N_WARMUP  = 256;     // Reduced from 512
    parameter SEED      = 32'hDEAD_BEEF;

    reg clk = 0;
    always #CLK_HALF clk = ~clk;
    reg rst;

    // Common stimulus
    reg [7:0] a, b;
    reg [2:0] op;

    reg        fi0_en,  fi1_en,  fi2_en,  fi3_en,  fi4_en;
    reg [1:0]  fi0_type, fi1_type, fi2_type, fi3_type, fi4_type;
    reg [7:0]  fi0_mask, fi1_mask, fi2_mask, fi3_mask, fi4_mask;

    // DUT 1 : Adaptive without Residue
    wire [7:0] no_res_result;
    wire       no_res_zero, no_res_carry;
    wire [1:0] no_res_risk, no_res_mode;
    wire       no_res_fault, no_res_tmr_err;
    wire [4:0] no_res_faulty;

    top_adaptive_no_residue u_no_residue (
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
        .final_result   (no_res_result),
        .zero_flag      (no_res_zero),
        .carry_flag     (no_res_carry),
        .risk_score     (no_res_risk),
        .redundancy_mode(no_res_mode),
        .fault_detected (no_res_fault),
        .tmr_error      (no_res_tmr_err),
        .faulty_module  (no_res_faulty)
    );

    // DUT 2 : Adaptive with Residue
    wire [7:0] with_res_result;
    wire       with_res_zero, with_res_carry;
    wire [1:0] with_res_risk, with_res_mode;
    wire       with_res_fault, with_res_tmr_err;
    wire [4:0] with_res_faulty;

    top_adaptive u_with_residue (
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
        .final_result   (with_res_result),
        .zero_flag      (with_res_zero),
        .carry_flag     (with_res_carry),
        .risk_score     (with_res_risk),
        .redundancy_mode(with_res_mode),
        .fault_detected (with_res_fault),
        .tmr_error      (with_res_tmr_err),
        .faulty_module  (with_res_faulty)
    );

    // Golden reference
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
                    golden_carry = tmp[8];
                end
                3'b010: begin golden = aa & bb; golden_carry = 1'b0; end
                3'b011: begin golden = aa | bb; golden_carry = 1'b0; end
                3'b100: begin golden = aa ^ bb; golden_carry = 1'b0; end
                3'b101: begin golden = ~aa;     golden_carry = 1'b0; end
                3'b110: begin
                    golden       = {aa[6:0], 1'b0};
                    golden_carry = aa[7];
                end
                3'b111: begin
                    golden       = {1'b0, aa[7:1]};
                    golden_carry = aa[0];
                end
                default: begin golden = 8'h00; golden_carry = 1'b0; end
            endcase
        end
    endtask

    integer no_res_ok, no_res_tot;
    integer with_res_ok, with_res_tot;
    integer grand_no_res_ok, grand_no_res_tot;
    integer grand_with_res_ok, grand_with_res_tot;

    task reset_counters;
        begin
            no_res_ok = 0; no_res_tot = 0;
            with_res_ok = 0; with_res_tot = 0;
        end
    endtask

    task merge_grand;
        begin
            grand_no_res_ok  = grand_no_res_ok  + no_res_ok;
            grand_no_res_tot = grand_no_res_tot + no_res_tot;
            grand_with_res_ok   = grand_with_res_ok   + with_res_ok;
            grand_with_res_tot  = grand_with_res_tot  + with_res_tot;
        end
    endtask

    reg [31:0] lfsr;

    task lfsr_step;
        begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        end
    endtask

    task apply_and_check;
        input [7:0] aa, bb;
        input [2:0] opc;
        begin
            a  = aa;
            b  = bb;
            op = opc;
            @(posedge clk); #1;

            compute_golden(aa, bb, opc);

            no_res_tot = no_res_tot + 1;
            with_res_tot = with_res_tot + 1;

            if (no_res_result == golden) no_res_ok = no_res_ok + 1;
            if (with_res_result == golden) with_res_ok = with_res_ok + 1;
        end
    endtask

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

    integer i;

    initial begin
        $dumpfile("tb_residue_quick_check.vcd");
        $dumpvars(0, tb_residue_quick_check);

        lfsr = SEED;
        a = 8'h00; b = 8'h00; op = 3'b000;
        clear_faults;
        grand_no_res_ok = 0; grand_no_res_tot = 0;
        grand_with_res_ok = 0; grand_with_res_tot = 0;
        do_reset;

        $display("");
        $display("====================================================================");
        $display("  RESIDUE-BASED FAULT LOCALIZATION IMPACT (QUICK CHECK)");
        $display("  Comparison: Adaptive (No Residue) vs Adaptive (With Residue)");
        $display("====================================================================");
        $display("| %-50s | No Residue | With Residue | Improvement |", "Scenario");
        $display("|%-52s|------------|--------------|-------------|", "----|");

        // S0 — FAULT-FREE
        reset_counters;
        clear_faults;

        for (i = 0; i < N_CORNER; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end

        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end

        $display("| S0  Fault-free (%0d vectors)                     | %6.2f%%     | %6.2f%%      | %7.2f%%     |",
            no_res_tot, 100.0 * no_res_ok / no_res_tot, 100.0 * with_res_ok / with_res_tot,
            (100.0 * with_res_ok / with_res_tot) - (100.0 * no_res_ok / no_res_tot));
        merge_grand;

        // S1 — SINGLE FAULT: ALU0 BIT-FLIP ALL
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b0; fi2_en = 1'b0; fi3_en = 1'b0; fi4_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S1  ALU0 bit-flip all (%0d cycles + warmup)      | %6.2f%%     | %6.2f%%      | %7.2f%%     |",
            N_RANDOM, 100.0 * no_res_ok / no_res_tot, 100.0 * with_res_ok / with_res_tot,
            (100.0 * with_res_ok / with_res_tot) - (100.0 * no_res_ok / no_res_tot));
        merge_grand;

        // S2 — DOUBLE FAULT: ALU0 + ALU1 BIT-FLIP ALL
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b11; fi0_mask = 8'hFF;
        fi1_en = 1'b1; fi1_type = 2'b11; fi1_mask = 8'hFF;
        fi2_en = 1'b0; fi3_en = 1'b0; fi4_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S2  ALU0+ALU1 bit-flip all (double fault)        | %6.2f%%     | %6.2f%%      | %7.2f%%     |",
            100.0 * no_res_ok / no_res_tot, 100.0 * with_res_ok / with_res_tot,
            (100.0 * with_res_ok / with_res_tot) - (100.0 * no_res_ok / no_res_tot));
        merge_grand;

        // S3 — SINGLE FAULT: ALU0 STUCK-AT-0
        do_reset;
        reset_counters;
        fi0_en = 1'b1; fi0_type = 2'b00; fi0_mask = 8'hFF;
        fi1_en = 1'b0; fi2_en = 1'b0; fi3_en = 1'b0; fi4_en = 1'b0;
        do_warmup(N_WARMUP);
        for (i = 0; i < N_RANDOM; i = i + 1) begin
            lfsr_step; a = lfsr[7:0];
            lfsr_step; b = lfsr[7:0];
            lfsr_step; op = lfsr[2:0];
            apply_and_check(a, b, op);
        end
        $display("| S3  ALU0 stuck-at-0 (single fault)                | %6.2f%%     | %6.2f%%      | %7.2f%%     |",
            100.0 * no_res_ok / no_res_tot, 100.0 * with_res_ok / with_res_tot,
            (100.0 * with_res_ok / with_res_tot) - (100.0 * no_res_ok / no_res_tot));
        merge_grand;

        // GRAND TOTAL
        $display("|%-52s|------------|--------------|-------------|", "----|");
        $display("| Grand Total (%0d scenarios)                      | %6.2f%%     | %6.2f%%      | %7.2f%%     |",
            4,
            100.0 * grand_no_res_ok / grand_no_res_tot,
            100.0 * grand_with_res_ok / grand_with_res_tot,
            (100.0 * grand_with_res_ok / grand_with_res_tot) - (100.0 * grand_no_res_ok / grand_no_res_tot));
        $display("====================================================================");

        $finish;
    end

endmodule
