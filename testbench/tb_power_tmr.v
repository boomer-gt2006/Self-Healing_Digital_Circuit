// ============================================================
// Testbench : tb_power_tmr
// Purpose   : Extensive power simulation testbench for the
//             Traditional TMR top-level (top_tmr).
//
//   Covers:
//     - All 8 ALU opcodes under clean conditions
//     - Single-module faults: SA0 / SA1 / bit-flip on each ALU
//     - Dual-module concurrent faults
//     - All fault masks (full-byte, nibble, walking-bit)
//     - Rapid fault-inject / clear cycling
//     - Sustained fault presence over many cycles
//     - Input sweeps during active faults for high toggle count
//
// Fault injector types:
//   2'b00 = none  2'b01 = SA0  2'b10 = SA1  2'b11 = bit-flip
//
// Sim target: Vivado XSim
// Clock     : 100 MHz (10 ns period)
// ============================================================
`timescale 1ns/1ps

module tb_power_tmr;

    // ---------------------------------------------------------
    // Clock period
    // ---------------------------------------------------------
    localparam CLK_PERIOD = 10;

    // ALU opcodes
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110;
    localparam OP_SHR = 3'b111;

    // Fault types
    localparam FT_NONE = 2'b00;
    localparam FT_SA0  = 2'b01;
    localparam FT_SA1  = 2'b10;
    localparam FT_FLIP = 2'b11;

    // ---------------------------------------------------------
    // DUT I/O
    // ---------------------------------------------------------
    reg        clk;
    reg        rst;

    reg  [7:0] a;
    reg  [7:0] b;
    reg  [2:0] op;

    // Fault injector 0 (ALU 0)
    reg        fi0_en;
    reg  [1:0] fi0_type;
    reg  [7:0] fi0_mask;

    // Fault injector 1 (ALU 1)
    reg        fi1_en;
    reg  [1:0] fi1_type;
    reg  [7:0] fi1_mask;

    // Fault injector 2 (ALU 2)
    reg        fi2_en;
    reg  [1:0] fi2_type;
    reg  [7:0] fi2_mask;

    wire [7:0] result;
    wire       carry_out;
    wire       zero;
    wire       fault_detected;
    wire [2:0] faulty_module;

    // ---------------------------------------------------------
    // Statistics
    // ---------------------------------------------------------
    integer pass_count;
    integer fail_count;
    integer task_count;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    top_tmr uut (
        .clk           (clk),
        .rst           (rst),
        .a             (a),
        .b             (b),
        .op            (op),
        .fi0_en        (fi0_en),  .fi0_type(fi0_type),  .fi0_mask(fi0_mask),
        .fi1_en        (fi1_en),  .fi1_type(fi1_type),  .fi1_mask(fi1_mask),
        .fi2_en        (fi2_en),  .fi2_type(fi2_type),  .fi2_mask(fi2_mask),
        .result        (result),
        .carry_out     (carry_out),
        .zero          (zero),
        .fault_detected(fault_detected),
        .faulty_module (faulty_module)
    );

    // ---------------------------------------------------------
    // Clock
    // ---------------------------------------------------------
    initial clk = 1'b0;
    always  #(CLK_PERIOD/2) clk = ~clk;

    // =========================================================
    // INFRASTRUCTURE TASKS
    // =========================================================

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
        end
    endtask

    task do_reset;
        begin
            @(negedge clk); rst = 1'b1;
            @(posedge clk);
            @(negedge clk); rst = 1'b0;
        end
    endtask

    task clear_all_faults;
        begin
            fi0_en = 0; fi0_type = FT_NONE; fi0_mask = 8'h00;
            fi1_en = 0; fi1_type = FT_NONE; fi1_mask = 8'h00;
            fi2_en = 0; fi2_type = FT_NONE; fi2_mask = 8'h00;
        end
    endtask

    // Apply stimulus and wait one clock
    task apply_stim;
        input [7:0] ta;
        input [7:0] tb;
        input [2:0] top;
        begin
            @(negedge clk);
            a = ta; b = tb; op = top;
        end
    endtask

    // Apply and check correctness + fault_detected flag
    task apply_check;
        input [7:0]  ta;
        input [7:0]  tb;
        input [2:0]  top;
        input [7:0]  expected;
        input        exp_fd;         // expected fault_detected
        input [63:0] label;
        begin
            @(negedge clk); a = ta; b = tb; op = top;
            @(posedge clk); #1;
            if (result === expected && fault_detected === exp_fd) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %-8s a=%02h b=%02h op=%03b | exp=%02h got=%02h fd_exp=%b fd_got=%b",
                         label, ta, tb, top, expected, result, exp_fd, fault_detected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================================
    // GROUP 1 – CLEAN OPERATION (all opcodes, no faults)
    // =========================================================

    task test_clean_all_opcodes;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_clean_all_opcodes", task_count);
            clear_all_faults;

            apply_check(8'h0A, 8'h05, OP_ADD, 8'h0F, 1'b0, "ADD   ");
            apply_check(8'h14, 8'h07, OP_SUB, 8'h0D, 1'b0, "SUB   ");
            apply_check(8'hFF, 8'h0F, OP_AND, 8'h0F, 1'b0, "AND   ");
            apply_check(8'hAA, 8'h55, OP_OR,  8'hFF, 1'b0, "OR    ");
            apply_check(8'hFF, 8'hFF, OP_XOR, 8'h00, 1'b0, "XOR   ");
            apply_check(8'h55, 8'h00, OP_NOT, 8'hAA, 1'b0, "NOT   ");
            apply_check(8'h01, 8'h00, OP_SHL, 8'h02, 1'b0, "SHL   ");
            apply_check(8'h80, 8'h00, OP_SHR, 8'h40, 1'b0, "SHR   ");
        end
    endtask

    task test_clean_extensive_add;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_clean_extensive_add", task_count);
            clear_all_faults;
            for (i = 0; i < 64; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'hA5, OP_ADD);
        end
    endtask

    task test_clean_sweep_all_ops;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_clean_sweep_all_ops", task_count);
            clear_all_faults;
            for (i = 0; i < 32; i = i + 1) begin
                apply_stim(i[7:0], 8'h5A, OP_ADD);
                apply_stim(i[7:0], 8'hA5, OP_SUB);
                apply_stim(i[7:0], 8'hC3, OP_AND);
                apply_stim(i[7:0], 8'h3C, OP_OR );
                apply_stim(i[7:0], 8'hCC, OP_XOR);
                apply_stim(i[7:0], 8'h00, OP_NOT);
                apply_stim(i[7:0], 8'h00, OP_SHL);
                apply_stim(i[7:0], 8'h00, OP_SHR);
            end
        end
    endtask

    task test_clean_checker_burst;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_clean_checker_burst", task_count);
            clear_all_faults;
            for (i = 0; i < 64; i = i + 1) begin
                apply_stim(8'hAA, 8'h55, OP_XOR);
                apply_stim(8'h55, 8'hAA, OP_XOR);
                apply_stim(8'hFF, 8'h00, OP_ADD);
                apply_stim(8'h00, 8'hFF, OP_SUB);
            end
        end
    endtask

    // =========================================================
    // GROUP 2 – SINGLE-MODULE FAULTS: SA0 ON EACH MODULE
    // =========================================================

    task test_sa0_alu0_correct_by_tmr;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sa0_alu0_correct_by_tmr", task_count);
            clear_all_faults;
            // Full byte stuck-at-0 on ALU0
            fi0_en = 1'b1; fi0_type = FT_SA0; fi0_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0] | 8'h80, i[7:0], OP_ADD);
            wait_cycles(2);
            // Verify TMR produces correct result and raises fault_detected
            apply_check(8'h0A, 8'h05, OP_ADD, 8'h0F, 1'b1, "SA0M0 ");
            clear_all_faults;
        end
    endtask

    task test_sa0_alu1_correct_by_tmr;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sa0_alu1_correct_by_tmr", task_count);
            clear_all_faults;
            fi1_en = 1'b1; fi1_type = FT_SA0; fi1_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0] | 8'h40, i[7:0] ^ 8'h55, OP_OR);
            apply_check(8'h0A, 8'h05, OP_ADD, 8'h0F, 1'b1, "SA0M1 ");
            clear_all_faults;
        end
    endtask

    task test_sa0_alu2_correct_by_tmr;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sa0_alu2_correct_by_tmr", task_count);
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_SA0; fi2_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0] | 8'h20, i[7:0], OP_XOR);
            apply_check(8'hAA, 8'h55, OP_XOR, 8'hFF, 1'b1, "SA0M2 ");
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 3 – SINGLE-MODULE FAULTS: SA1 ON EACH MODULE
    // =========================================================

    task test_sa1_alu0;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sa1_alu0", task_count);
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_SA1; fi0_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'hA5, OP_AND);
            apply_check(8'hF0, 8'h0F, OP_AND, 8'h00, 1'b1, "SA1M0 ");
            clear_all_faults;
        end
    endtask

    task test_sa1_alu1;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sa1_alu1", task_count);
            clear_all_faults;
            fi1_en = 1'b1; fi1_type = FT_SA1; fi1_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0], 8'h96, OP_SUB);
            apply_check(8'h14, 8'h07, OP_SUB, 8'h0D, 1'b1, "SA1M1 ");
            clear_all_faults;
        end
    endtask

    task test_sa1_alu2;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sa1_alu2", task_count);
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_SA1; fi2_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0], 8'h00, OP_NOT);
            apply_check(8'h55, 8'h00, OP_NOT, 8'hAA, 1'b1, "SA1M2 ");
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 4 – SINGLE-MODULE FAULTS: BIT-FLIP ON EACH MODULE
    // =========================================================

    task test_flip_alu0_fullbyte;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_flip_alu0_fullbyte", task_count);
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_FLIP; fi0_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'h5A, OP_ADD);
            apply_check(8'h55, 8'h55, OP_ADD, 8'hAA, 1'b1, "FLIPM0");
            clear_all_faults;
        end
    endtask

    task test_flip_alu1_fullbyte;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_flip_alu1_fullbyte", task_count);
            clear_all_faults;
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'hA5, OP_XOR);
            apply_check(8'hAA, 8'h55, OP_XOR, 8'hFF, 1'b1, "FLIPM1");
            clear_all_faults;
        end
    endtask

    task test_flip_alu2_fullbyte;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_flip_alu2_fullbyte", task_count);
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_FLIP; fi2_mask = 8'hFF;
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0], 8'h00, OP_SHL);
            apply_check(8'h01, 8'h00, OP_SHL, 8'h02, 1'b1, "FLIPM2");
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 5 – WALKING-BIT FAULT MASKS
    // =========================================================

    task test_walking_mask_all_modules;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_walking_mask_all_modules", task_count);
            for (i = 0; i < 8; i = i + 1) begin
                clear_all_faults;
                // Walking-bit SA0 on each module in turn
                fi0_en = 1'b1; fi0_type = FT_SA0; fi0_mask = 8'h01 << i;
                apply_stim(8'hFF, 8'h00, OP_ADD); wait_cycles(2);
                clear_all_faults;
                fi1_en = 1'b1; fi1_type = FT_SA1; fi1_mask = 8'h01 << i;
                apply_stim(8'hFF, 8'h00, OP_OR ); wait_cycles(2);
                clear_all_faults;
                fi2_en = 1'b1; fi2_type = FT_FLIP; fi2_mask = 8'h01 << i;
                apply_stim(8'hFF, 8'h00, OP_AND); wait_cycles(2);
            end
            clear_all_faults;
        end
    endtask

    task test_nibble_mask_variants;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_nibble_mask_variants", task_count);
            for (i = 0; i < 16; i = i + 1) begin
                clear_all_faults;
                fi0_en = 1'b1; fi0_type = FT_FLIP;
                fi0_mask = {i[3:0], ~i[3:0]};
                apply_stim(8'hDE, 8'hAD, OP_XOR); wait_cycles(2);
                // Different fault on ALU1
                fi1_en = 1'b1; fi1_type = FT_SA0;
                fi1_mask = {~i[3:0], i[3:0]};
                apply_stim(8'hBE, 8'hEF, OP_AND); wait_cycles(2);
            end
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 6 – DUAL-MODULE FAULTS (two modules corrupted)
    // =========================================================

    task test_dual_fault_m0_m1;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_dual_fault_m0_m1", task_count);
            clear_all_faults;
            // Both ALU0 and ALU1 flipped — TMR output may be wrong but
            // fault_detected should still be asserted
            fi0_en = 1'b1; fi0_type = FT_SA0; fi0_mask = 8'hF0;
            fi1_en = 1'b1; fi1_type = FT_SA1; fi1_mask = 8'h0F;
            for (i = 0; i < 24; i = i + 1)
                apply_stim(i[7:0], 8'hC3, OP_XOR);
            wait_cycles(2);
            clear_all_faults;
        end
    endtask

    task test_dual_fault_m1_m2;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_dual_fault_m1_m2", task_count);
            clear_all_faults;
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hAA;
            fi2_en = 1'b1; fi2_type = FT_FLIP; fi2_mask = 8'h55;
            for (i = 0; i < 24; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'hFF, OP_OR);
            wait_cycles(2);
            clear_all_faults;
        end
    endtask

    task test_dual_fault_m0_m2;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_dual_fault_m0_m2", task_count);
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_SA1; fi0_mask = 8'hCC;
            fi2_en = 1'b1; fi2_type = FT_SA0; fi2_mask = 8'h33;
            for (i = 0; i < 24; i = i + 1)
                apply_stim(i[7:0], 8'h96, OP_ADD);
            wait_cycles(2);
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 7 – FAULT INJECT / CLEAR CYCLING
    // =========================================================

    task test_rapid_fault_cycle;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_rapid_fault_cycle", task_count);
            for (i = 0; i < 32; i = i + 1) begin
                // Inject fault
                @(negedge clk);
                case (i[1:0])
                    2'b00: begin fi0_en=1; fi0_type=FT_FLIP; fi0_mask=8'hFF; end
                    2'b01: begin fi1_en=1; fi1_type=FT_SA0;  fi1_mask=8'hFF; end
                    2'b10: begin fi2_en=1; fi2_type=FT_SA1;  fi2_mask=8'hFF; end
                    2'b11: begin fi0_en=1; fi0_type=FT_SA0;  fi0_mask=8'hAA;
                                 fi1_en=1; fi1_type=FT_SA1;  fi1_mask=8'h55; end
                endcase
                a = i[7:0]; b = ~i[7:0]; op = i[2:0];
                wait_cycles(3);
                // Clear fault
                clear_all_faults;
                @(posedge clk);
                apply_stim(i[7:0], i[7:0], OP_ADD); wait_cycles(2);
            end
            clear_all_faults;
        end
    endtask

    task test_sustained_fault_burst;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sustained_fault_burst", task_count);
            clear_all_faults;
            // Sustain fault on ALU1 for 128 cycles while sweeping input
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hFF;
            for (i = 0; i <= 127; i = i + 1)
                apply_stim(i[7:0], 8'h5A ^ i[7:0], OP_ADD);
            clear_all_faults;
            // Verify correct result after clearing fault
            apply_check(8'h10, 8'h10, OP_ADD, 8'h20, 1'b0, "SUSFLT");
        end
    endtask

    task test_fault_all_types_sequence;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_fault_all_types_sequence", task_count);
            for (i = 0; i < 8; i = i + 1) begin
                // Rotate through all 4 fault types on ALU0
                clear_all_faults;
                fi0_en = 1'b1; fi0_type = i[1:0]; fi0_mask = 8'h01 << i;
                apply_stim(8'hAB, 8'hCD, i[2:0]);
                wait_cycles(4);
            end
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 8 – HIGH-ACTIVITY INPUT SWEEPS UNDER FAULT
    // =========================================================

    task test_input_sweep_under_sa0;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_input_sweep_under_sa0", task_count);
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_SA0; fi0_mask = 8'hFF;
            // Full 256-input sweep on ADD operation
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], 8'h37, OP_ADD);
            clear_all_faults;
        end
    endtask

    task test_input_sweep_under_flip;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_input_sweep_under_flip", task_count);
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_FLIP; fi2_mask = 8'hAA;
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'hFF, OP_XOR);
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 9 – TOGGLE STRESS (maximum switching activity)
    // =========================================================

    task test_max_toggle_no_fault;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_max_toggle_no_fault", task_count);
            clear_all_faults;
            for (i = 0; i < 128; i = i + 1) begin
                apply_stim(8'hFF, 8'h00, OP_ADD);
                apply_stim(8'h00, 8'hFF, OP_ADD);
                apply_stim(8'hAA, 8'h55, OP_XOR);
                apply_stim(8'h55, 8'hAA, OP_XOR);
            end
        end
    endtask

    task test_max_toggle_with_fault;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_max_toggle_with_fault", task_count);
            clear_all_faults;
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hFF;
            for (i = 0; i < 128; i = i + 1) begin
                apply_stim(8'hFF, 8'h00, OP_ADD);
                apply_stim(8'h00, 8'hFF, OP_SUB);
                apply_stim(8'hCC, 8'h33, OP_XOR);
                apply_stim(8'h33, 8'hCC, OP_OR );
            end
            clear_all_faults;
        end
    endtask

    // =========================================================
    // GROUP 10 – VERIFICATION CHECKS
    // =========================================================

    task test_tmr_correction_verified;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_tmr_correction_verified", task_count);
            clear_all_faults;

            // No fault — clean baseline
            apply_check(8'h12, 8'h34, OP_ADD, 8'h46, 1'b0, "CLEAN ");

            // Fault on ALU0 — TMR corrects
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_FLIP; fi0_mask = 8'hFF;
            apply_check(8'h12, 8'h34, OP_ADD, 8'h46, 1'b1, "FLTM0 ");

            // Fault on ALU1 — TMR corrects
            clear_all_faults;
            fi1_en = 1'b1; fi1_type = FT_SA0;  fi1_mask = 8'hFF;
            apply_check(8'h12, 8'h34, OP_ADD, 8'h46, 1'b1, "FLTM1 ");

            // Fault on ALU2 — TMR corrects
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_SA1;  fi2_mask = 8'hFF;
            apply_check(8'h12, 8'h34, OP_ADD, 8'h46, 1'b1, "FLTM2 ");

            clear_all_faults;
        end
    endtask

    task test_faulty_module_identification;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_faulty_module_identification", task_count);

            // Inject SA0 on ALU0, check faulty_module[0]==1
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_SA0; fi0_mask = 8'hFF;
            @(negedge clk); a = 8'hFF; b = 8'h01; op = OP_ADD;
            @(posedge clk); #1;
            if (faulty_module[0] !== 1'b1) begin
                $display("[FAIL] faulty_module[0] not set for ALU0 fault"); fail_count=fail_count+1;
            end else pass_count = pass_count + 1;

            // Inject flip on ALU2, check faulty_module[2]==1
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_FLIP; fi2_mask = 8'hFF;
            @(negedge clk); a = 8'hFF; b = 8'h01; op = OP_ADD;
            @(posedge clk); #1;
            if (faulty_module[2] !== 1'b1) begin
                $display("[FAIL] faulty_module[2] not set for ALU2 fault"); fail_count=fail_count+1;
            end else pass_count = pass_count + 1;

            clear_all_faults;
        end
    endtask

    task test_all_opcodes_per_fault_type;
        integer ft, i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_all_opcodes_per_fault_type", task_count);
            for (ft = 1; ft <= 3; ft = ft + 1) begin
                clear_all_faults;
                fi0_en = 1'b1; fi0_type = ft[1:0]; fi0_mask = 8'h55;
                for (i = 0; i < 8; i = i + 1)
                    apply_stim(8'hA5, 8'h5A, i[2:0]);
                wait_cycles(2);
            end
            clear_all_faults;
        end
    endtask

    task test_reset_under_fault;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_reset_under_fault", task_count);
            fi0_en = 1'b1; fi0_type = FT_FLIP; fi0_mask = 8'hFF;
            fi2_en = 1'b1; fi2_type = FT_SA0;  fi2_mask = 8'hFF;
            apply_stim(8'hDE, 8'hAD, OP_ADD); wait_cycles(4);
            do_reset;
            clear_all_faults;
            apply_check(8'h00, 8'h00, OP_ADD, 8'h00, 1'b0, "RSRST ");
        end
    endtask

    // =========================================================
    // MAIN STIMULUS
    // =========================================================
    initial begin
        pass_count = 0; fail_count = 0; task_count = 0;
        clk = 1'b0; rst = 1'b1;
        a = 8'h00; b = 8'h00; op = 3'b000;
        clear_all_faults;

        wait_cycles(5);
        do_reset;

        $display("================================================================");
        $display(" tb_power_tmr: Extensive Power Simulation Testbench  START");
        $display("================================================================");

        // ---- GROUP 1: Clean operation ----
        test_clean_all_opcodes;
        test_clean_extensive_add;
        test_clean_sweep_all_ops;
        test_clean_checker_burst;

        // ---- GROUP 2: SA0 single-module ----
        test_sa0_alu0_correct_by_tmr;
        test_sa0_alu1_correct_by_tmr;
        test_sa0_alu2_correct_by_tmr;

        // ---- GROUP 3: SA1 single-module ----
        test_sa1_alu0;
        test_sa1_alu1;
        test_sa1_alu2;

        // ---- GROUP 4: Bit-flip single-module ----
        test_flip_alu0_fullbyte;
        test_flip_alu1_fullbyte;
        test_flip_alu2_fullbyte;

        // ---- GROUP 5: Walking masks ----
        test_walking_mask_all_modules;
        test_nibble_mask_variants;

        // ---- GROUP 6: Dual-module faults ----
        test_dual_fault_m0_m1;
        test_dual_fault_m1_m2;
        test_dual_fault_m0_m2;

        // ---- GROUP 7: Fault cycling ----
        test_rapid_fault_cycle;
        test_sustained_fault_burst;
        test_fault_all_types_sequence;

        // ---- GROUP 8: Sweeps under fault ----
        test_input_sweep_under_sa0;
        test_input_sweep_under_flip;

        // ---- GROUP 9: Max toggle ----
        test_max_toggle_no_fault;
        test_max_toggle_with_fault;

        // ---- GROUP 10: Verification ----
        test_tmr_correction_verified;
        test_faulty_module_identification;
        test_all_opcodes_per_fault_type;
        test_reset_under_fault;

        wait_cycles(20);

        $display("================================================================");
        $display(" RESULTS : %0d PASS  |  %0d FAIL  |  %0d tasks",
                 pass_count, fail_count, task_count);
        $display(" tb_power_tmr: Power Simulation END");
        $display("================================================================");
        $finish;
    end

endmodule
