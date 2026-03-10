// ============================================================
// Testbench : tb_power_alu
// Purpose   : Extensive power simulation testbench for the
//             base ALU module.  Covers all 8 opcodes with
//             multiple vector groups, corner cases, walking
//             patterns, sweep patterns, and high-toggle
//             stress bursts to produce realistic switching
//             activity for SAIF-annotated power analysis.
//
// Sim target: Vivado XSim (xvlog / xelab / xsim)
// Clock     : 100 MHz (10 ns period)
// Total sim  : ~4 000 active clock cycles  (~42 000 ns)
// ============================================================
`timescale 1ns/1ps

module tb_power_alu;

    // ---------------------------------------------------------
    // Parameters
    // ---------------------------------------------------------
    localparam CLK_PERIOD = 10;  // ns

    // ALU opcode encoding (mirrors rtl/alu.v)
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110;
    localparam OP_SHR = 3'b111;

    // ---------------------------------------------------------
    // DUT I/O
    // ---------------------------------------------------------
    reg         clk;
    reg         rst;
    reg  [7:0]  a;
    reg  [7:0]  b;
    reg  [2:0]  op;
    wire [7:0]  result;
    wire        carry_out;
    wire        zero;

    // ---------------------------------------------------------
    // Statistics counters
    // ---------------------------------------------------------
    integer pass_count;
    integer fail_count;
    integer task_count;

    // ---------------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------------
    alu uut (
        .clk      (clk),
        .rst      (rst),
        .a        (a),
        .b        (b),
        .op       (op),
        .result   (result),
        .carry_out(carry_out),
        .zero     (zero)
    );

    // ---------------------------------------------------------
    // Clock generator
    // ---------------------------------------------------------
    initial clk = 1'b0;
    always  #(CLK_PERIOD/2) clk = ~clk;

    // =========================================================
    // INFRASTRUCTURE TASKS
    // =========================================================

    // Wait n rising edges
    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
        end
    endtask

    // Synchronous reset pulse
    task do_reset;
        begin
            @(negedge clk); rst = 1'b1;
            @(posedge clk);
            @(negedge clk); rst = 1'b0;
            @(posedge clk);
        end
    endtask

    // Apply operands + opcode, wait one cycle, check result
    // exp_carry: expected carry_out value
    task apply_check;
        input [7:0] ta;
        input [7:0] tb;
        input [2:0] top;
        input [7:0] expected;
        input       exp_carry;
        begin
            @(negedge clk);
            a  = ta;
            b  = tb;
            op = top;
            @(posedge clk); #1;  // let registered output update
            if (result === expected && carry_out === exp_carry) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] a=%02h b=%02h op=%03b | exp_r=%02h got_r=%02h exp_c=%b got_c=%b",
                         ta, tb, top, expected, result, exp_carry, carry_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Apply stimulus without correctness check (pure activity)
    task apply_stim;
        input [7:0] ta;
        input [7:0] tb;
        input [2:0] top;
        begin
            @(negedge clk);
            a  = ta;
            b  = tb;
            op = top;
        end
    endtask

    // =========================================================
    // GROUP 1 – ADD (OPCODE 3'b000)
    // =========================================================

    task test_add_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_basic", task_count);
            apply_check(8'h00, 8'h00, OP_ADD, 8'h00, 1'b0);
            apply_check(8'h01, 8'h01, OP_ADD, 8'h02, 1'b0);
            apply_check(8'h0A, 8'h05, OP_ADD, 8'h0F, 1'b0);
            apply_check(8'h10, 8'h20, OP_ADD, 8'h30, 1'b0);
            apply_check(8'h14, 8'h07, OP_ADD, 8'h1B, 1'b0);
            apply_check(8'h3C, 8'h3C, OP_ADD, 8'h78, 1'b0);
            apply_check(8'h7F, 8'h01, OP_ADD, 8'h80, 1'b0);
            apply_check(8'hFF, 8'h01, OP_ADD, 8'h00, 1'b1);
            apply_check(8'hFF, 8'hFF, OP_ADD, 8'hFE, 1'b1);
            apply_check(8'h80, 8'h80, OP_ADD, 8'h00, 1'b1);
            apply_check(8'hFE, 8'h02, OP_ADD, 8'h00, 1'b1);
            apply_check(8'h55, 8'h55, OP_ADD, 8'hAA, 1'b0);
        end
    endtask

    task test_add_walking_ones_a;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_walking_ones_a", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_check(8'h01 << i, 8'h01, OP_ADD,
                            (8'h01 << i) + 8'h01,
                            ((8'h01 << i) + 8'h01) > 8'hFF ? 1'b1 : 1'b0);
        end
    endtask

    task test_add_walking_ones_b;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_walking_ones_b", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_stim(8'h01, 8'h01 << i, OP_ADD);
        end
    endtask

    task test_add_double_walking;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_double_walking", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_stim(8'h01 << i, 8'h01 << i, OP_ADD);
        end
    endtask

    task test_add_carry_boundary;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_carry_boundary", task_count);
            apply_check(8'hFE, 8'h01, OP_ADD, 8'hFF, 1'b0);
            apply_check(8'hFE, 8'h02, OP_ADD, 8'h00, 1'b1);
            apply_check(8'hF0, 8'h10, OP_ADD, 8'h00, 1'b1);
            apply_check(8'hAA, 8'h56, OP_ADD, 8'h00, 1'b1);
            apply_check(8'h80, 8'h7F, OP_ADD, 8'hFF, 1'b0);
            apply_check(8'hAA, 8'h55, OP_ADD, 8'hFF, 1'b0);
        end
    endtask

    task test_add_incremental_a;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_incremental_a", task_count);
            for (i = 0; i < 64; i = i + 1)
                apply_stim(i[7:0], 8'hA5, OP_ADD);
        end
    endtask

    task test_add_incremental_b;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_incremental_b", task_count);
            for (i = 0; i < 64; i = i + 1)
                apply_stim(8'h5A, i[7:0], OP_ADD);
        end
    endtask

    task test_add_fibonacci_stress;
        integer i;
        reg [7:0] fa, fb, fc;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_fibonacci_stress", task_count);
            fa = 8'h01; fb = 8'h01;
            for (i = 0; i < 64; i = i + 1) begin
                @(negedge clk); a = fa; b = fb; op = OP_ADD;
                @(posedge clk); #1;
                fc = result;
                fa = fb;
                fb = fc;
            end
        end
    endtask

    task test_add_alternating_carry;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_add_alternating_carry", task_count);
            for (i = 0; i < 32; i = i + 1) begin
                // alternate between overflow and non-overflow
                apply_stim(8'hFF, 8'hFF, OP_ADD);  // overflow
                apply_stim(8'h01, 8'h01, OP_ADD);  // no overflow
            end
        end
    endtask

    // =========================================================
    // GROUP 2 – SUB (OPCODE 3'b001)
    // =========================================================

    task test_sub_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sub_basic", task_count);
            apply_check(8'h0F, 8'h05, OP_SUB, 8'h0A, 1'b0);
            apply_check(8'h10, 8'h10, OP_SUB, 8'h00, 1'b0);
            apply_check(8'h00, 8'h01, OP_SUB, 8'hFF, 1'b1);
            apply_check(8'hFF, 8'hFF, OP_SUB, 8'h00, 1'b0);
            apply_check(8'h80, 8'h01, OP_SUB, 8'h7F, 1'b0);
            apply_check(8'h01, 8'hFF, OP_SUB, 8'h02, 1'b1);
            apply_check(8'h55, 8'hAA, OP_SUB, 8'hAB, 1'b1);
            apply_check(8'hAA, 8'h55, OP_SUB, 8'h55, 1'b0);
        end
    endtask

    task test_sub_walking_operand;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sub_walking_operand", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_stim(8'hFF, 8'h01 << i, OP_SUB);
        end
    endtask

    task test_sub_countdown;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sub_countdown", task_count);
            for (i = 0; i < 64; i = i + 1)
                apply_stim(8'hFF - i[7:0], 8'h01, OP_SUB);
        end
    endtask

    task test_sub_borrow_stress;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sub_borrow_stress", task_count);
            for (i = 0; i < 32; i = i + 1) begin
                apply_stim(8'h00, i[7:0], OP_SUB);  // always borrows
                apply_stim(8'hFF, i[7:0], OP_SUB);  // never borrows
            end
        end
    endtask

    task test_sub_symmetric;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sub_symmetric", task_count);
            for (i = 0; i < 16; i = i + 1) begin
                apply_stim(i[7:0], i[7:0], OP_SUB);        // x - x = 0
                apply_stim(i[7:0] + 8'h10, i[7:0], OP_SUB); // y - x
                apply_stim(i[7:0], i[7:0] + 8'h10, OP_SUB); // x - y (borrow)
            end
        end
    endtask

    // =========================================================
    // GROUP 3 – AND (OPCODE 3'b010)
    // =========================================================

    task test_and_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_and_basic", task_count);
            apply_check(8'hFF, 8'h0F, OP_AND, 8'h0F, 1'b0);
            apply_check(8'hF0, 8'h0F, OP_AND, 8'h00, 1'b0);
            apply_check(8'hAA, 8'h55, OP_AND, 8'h00, 1'b0);
            apply_check(8'hAA, 8'hAA, OP_AND, 8'hAA, 1'b0);
            apply_check(8'hFF, 8'hFF, OP_AND, 8'hFF, 1'b0);
            apply_check(8'h00, 8'hFF, OP_AND, 8'h00, 1'b0);
            apply_check(8'h12, 8'h34, OP_AND, 8'h10, 1'b0);
        end
    endtask

    task test_and_walking_mask;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_and_walking_mask", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_check(8'hFF, 8'h01 << i, OP_AND, 8'h01 << i, 1'b0);
        end
    endtask

    task test_and_nibble_patterns;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_and_nibble_patterns", task_count);
            for (i = 0; i < 16; i = i + 1)
                apply_stim({i[3:0], i[3:0]}, 8'hF0, OP_AND);
        end
    endtask

    task test_and_accumulate;
        integer i;
        reg [7:0] acc;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_and_accumulate", task_count);
            acc = 8'hFF;
            for (i = 0; i < 8; i = i + 1) begin
                @(negedge clk); a = acc; b = ~(8'h01 << i); op = OP_AND;
                @(posedge clk); #1;
                acc = result;  // clear one bit each iteration
            end
        end
    endtask

    task test_and_mask_sweep;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_and_mask_sweep", task_count);
            for (i = 0; i <= 255; i = i + 4)
                apply_stim(8'hAA, i[7:0], OP_AND);
        end
    endtask

    // =========================================================
    // GROUP 4 – OR (OPCODE 3'b011)
    // =========================================================

    task test_or_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_or_basic", task_count);
            apply_check(8'h00, 8'hFF, OP_OR, 8'hFF, 1'b0);
            apply_check(8'hAA, 8'h55, OP_OR, 8'hFF, 1'b0);
            apply_check(8'hF0, 8'h0F, OP_OR, 8'hFF, 1'b0);
            apply_check(8'h00, 8'h00, OP_OR, 8'h00, 1'b0);
            apply_check(8'h12, 8'h34, OP_OR, 8'h36, 1'b0);
            apply_check(8'hFF, 8'h00, OP_OR, 8'hFF, 1'b0);
        end
    endtask

    task test_or_walking_ones;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_or_walking_ones", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_check(8'h00, 8'h01 << i, OP_OR, 8'h01 << i, 1'b0);
        end
    endtask

    task test_or_set_accumulate;
        integer i;
        reg [7:0] acc;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_or_set_accumulate", task_count);
            acc = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                @(negedge clk); a = acc; b = 8'h01 << i; op = OP_OR;
                @(posedge clk); #1;
                acc = result;  // set one bit per iteration
            end
            // acc should now be 0xFF
            apply_check(acc, 8'h00, OP_OR, 8'hFF, 1'b0);
        end
    endtask

    task test_or_incremental;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_or_incremental", task_count);
            for (i = 0; i < 64; i = i + 1)
                apply_stim(i[7:0], 8'hA5, OP_OR);
        end
    endtask

    task test_or_mask_sweep;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_or_mask_sweep", task_count);
            for (i = 0; i <= 255; i = i + 4)
                apply_stim(8'h55, i[7:0], OP_OR);
        end
    endtask

    // =========================================================
    // GROUP 5 – XOR (OPCODE 3'b100)
    // =========================================================

    task test_xor_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_xor_basic", task_count);
            apply_check(8'hFF, 8'hFF, OP_XOR, 8'h00, 1'b0);
            apply_check(8'h00, 8'h00, OP_XOR, 8'h00, 1'b0);
            apply_check(8'hAA, 8'h55, OP_XOR, 8'hFF, 1'b0);
            apply_check(8'hFF, 8'h00, OP_XOR, 8'hFF, 1'b0);
            apply_check(8'h3C, 8'hC3, OP_XOR, 8'hFF, 1'b0);
            apply_check(8'h3C, 8'h3C, OP_XOR, 8'h00, 1'b0);
            apply_check(8'hA5, 8'h5A, OP_XOR, 8'hFF, 1'b0);
        end
    endtask

    task test_xor_self_cancel;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_xor_self_cancel", task_count);
            for (i = 0; i < 32; i = i + 1)
                apply_check(i[7:0], i[7:0], OP_XOR, 8'h00, 1'b0);
        end
    endtask

    task test_xor_walking_ones;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_xor_walking_ones", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_check(8'hFF, 8'h01 << i, OP_XOR, ~(8'h01 << i), 1'b0);
        end
    endtask

    task test_xor_parity_chain;
        integer i;
        reg [7:0] acc;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_xor_parity_chain", task_count);
            acc = 8'h00;
            for (i = 1; i <= 64; i = i + 1) begin
                @(negedge clk); a = acc; b = i[7:0]; op = OP_XOR;
                @(posedge clk); #1;
                acc = result;
            end
        end
    endtask

    task test_xor_double_cancel;
        integer i;
        reg [7:0] saved;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_xor_double_cancel", task_count);
            for (i = 1; i <= 16; i = i + 1) begin
                // XOR once
                @(negedge clk); a = i[7:0]; b = 8'hA5; op = OP_XOR;
                @(posedge clk); #1; saved = result;
                // XOR again — should restore original
                @(negedge clk); a = saved; b = 8'hA5; op = OP_XOR;
                @(posedge clk); #1;
                if (result !== i[7:0]) begin
                    $display("[FAIL] XOR double-cancel: i=%02h got=%02h", i[7:0], result);
                    fail_count = fail_count + 1;
                end else
                    pass_count = pass_count + 1;
            end
        end
    endtask

    // =========================================================
    // GROUP 6 – NOT (OPCODE 3'b101)
    // =========================================================

    task test_not_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_not_basic", task_count);
            apply_check(8'hFF, 8'h00, OP_NOT, 8'h00, 1'b0);
            apply_check(8'h00, 8'h00, OP_NOT, 8'hFF, 1'b0);
            apply_check(8'hAA, 8'h00, OP_NOT, 8'h55, 1'b0);
            apply_check(8'h55, 8'h00, OP_NOT, 8'hAA, 1'b0);
            apply_check(8'hF0, 8'h00, OP_NOT, 8'h0F, 1'b0);
            apply_check(8'h0F, 8'h00, OP_NOT, 8'hF0, 1'b0);
            apply_check(8'hCC, 8'h00, OP_NOT, 8'h33, 1'b0);
            apply_check(8'h33, 8'h00, OP_NOT, 8'hCC, 1'b0);
        end
    endtask

    task test_not_walking_ones;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_not_walking_ones", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_check(8'h01 << i, 8'h00, OP_NOT,
                            ~(8'h01 << i), 1'b0);
        end
    endtask

    task test_not_double_invert;
        integer i;
        reg [7:0] saved;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_not_double_invert", task_count);
            for (i = 0; i < 16; i = i + 1) begin
                @(negedge clk); a = i[7:0]; b = 8'h00; op = OP_NOT;
                @(posedge clk); #1; saved = result;
                @(negedge clk); a = saved; b = 8'h00; op = OP_NOT;
                @(posedge clk); #1;
                if (result !== i[7:0]) begin
                    $display("[FAIL] NOT double-invert: i=%02h got=%02h", i[7:0], result);
                    fail_count = fail_count + 1;
                end else
                    pass_count = pass_count + 1;
            end
        end
    endtask

    task test_not_all_nibbles;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_not_all_nibbles", task_count);
            for (i = 0; i < 16; i = i + 1)
                apply_stim({i[3:0], i[3:0]}, 8'h00, OP_NOT);
        end
    endtask

    // =========================================================
    // GROUP 7 – SHL (OPCODE 3'b110)
    // =========================================================

    task test_shl_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shl_basic", task_count);
            apply_check(8'h01, 8'h00, OP_SHL, 8'h02, 1'b0);
            apply_check(8'h80, 8'h00, OP_SHL, 8'h00, 1'b1);  // MSB out
            apply_check(8'hAA, 8'h00, OP_SHL, 8'h54, 1'b1);
            apply_check(8'h55, 8'h00, OP_SHL, 8'hAA, 1'b0);
            apply_check(8'hFF, 8'h00, OP_SHL, 8'hFE, 1'b1);
            apply_check(8'h00, 8'h00, OP_SHL, 8'h00, 1'b0);
            apply_check(8'h40, 8'h00, OP_SHL, 8'h80, 1'b0);
        end
    endtask

    task test_shl_msb_propagation;
        integer i;
        reg [7:0] val;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shl_msb_propagation", task_count);
            val = 8'h01;
            for (i = 0; i < 9; i = i + 1) begin
                @(negedge clk); a = val; b = 8'h00; op = OP_SHL;
                @(posedge clk); #1;
                val = result;
            end
        end
    endtask

    task test_shl_arbitrary_patterns;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shl_arbitrary_patterns", task_count);
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0] ^ 8'hA5, 8'h00, OP_SHL);
        end
    endtask

    task test_shl_checkerboard_shift;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shl_checkerboard_shift", task_count);
            for (i = 0; i < 16; i = i + 1) begin
                apply_stim(8'hAA, 8'h00, OP_SHL);
                apply_stim(8'h55, 8'h00, OP_SHL);
            end
        end
    endtask

    // =========================================================
    // GROUP 8 – SHR (OPCODE 3'b111)
    // =========================================================

    task test_shr_basic;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shr_basic", task_count);
            apply_check(8'h80, 8'h00, OP_SHR, 8'h40, 1'b0);
            apply_check(8'h01, 8'h00, OP_SHR, 8'h00, 1'b1);  // LSB out
            apply_check(8'hFF, 8'h00, OP_SHR, 8'h7F, 1'b1);  // LSB out
            apply_check(8'hAA, 8'h00, OP_SHR, 8'h55, 1'b0);
            apply_check(8'h55, 8'h00, OP_SHR, 8'h2A, 1'b1);  // LSB out
            apply_check(8'h00, 8'h00, OP_SHR, 8'h00, 1'b0);
            apply_check(8'h02, 8'h00, OP_SHR, 8'h01, 1'b0);
        end
    endtask

    task test_shr_lsb_propagation;
        integer i;
        reg [7:0] val;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shr_lsb_propagation", task_count);
            val = 8'h80;
            for (i = 0; i < 9; i = i + 1) begin
                @(negedge clk); a = val; b = 8'h00; op = OP_SHR;
                @(posedge clk); #1;
                val = result;
            end
        end
    endtask

    task test_shr_arbitrary_patterns;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shr_arbitrary_patterns", task_count);
            for (i = 0; i < 32; i = i + 1)
                apply_stim(i[7:0] ^ 8'h5A, 8'h00, OP_SHR);
        end
    endtask

    task test_shr_checkerboard_shift;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_shr_checkerboard_shift", task_count);
            for (i = 0; i < 16; i = i + 1) begin
                apply_stim(8'hAA, 8'h00, OP_SHR);
                apply_stim(8'h55, 8'h00, OP_SHR);
            end
        end
    endtask

    // =========================================================
    // GROUP 9 – CROSS-OPCODE PATTERNS (maximum toggling)
    // =========================================================

    task test_interleaved_all_ops;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_interleaved_all_ops", task_count);
            for (i = 0; i < 32; i = i + 1) begin
                apply_stim(i[7:0], 8'h5A, OP_ADD);
                apply_stim(i[7:0], 8'hA5, OP_SUB);
                apply_stim(i[7:0], 8'hF0, OP_AND);
                apply_stim(i[7:0], 8'h0F, OP_OR );
                apply_stim(i[7:0], 8'hCC, OP_XOR);
                apply_stim(i[7:0], 8'h00, OP_NOT);
                apply_stim(i[7:0], 8'h00, OP_SHL);
                apply_stim(i[7:0], 8'h00, OP_SHR);
            end
        end
    endtask

    task test_checkerboard_all_ops;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_checkerboard_all_ops", task_count);
            for (i = 0; i < 8; i = i + 1) begin
                apply_stim(8'hAA, 8'h55, i[2:0]);
                apply_stim(8'h55, 8'hAA, i[2:0]);
                apply_stim(8'hF0, 8'h0F, i[2:0]);
                apply_stim(8'h0F, 8'hF0, i[2:0]);
                apply_stim(8'hCC, 8'h33, i[2:0]);
                apply_stim(8'h33, 8'hCC, i[2:0]);
            end
        end
    endtask

    task test_max_toggle_burst;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_max_toggle_burst", task_count);
            // Alternate 0xFF/0x00 on both operands with toggling opcodes
            for (i = 0; i < 64; i = i + 1) begin
                apply_stim(8'hFF, 8'h00, OP_ADD);
                apply_stim(8'h00, 8'hFF, OP_ADD);
                apply_stim(8'hAA, 8'h55, OP_XOR);
                apply_stim(8'h55, 8'hAA, OP_XOR);
                apply_stim(8'hFF, 8'hFF, OP_AND);
                apply_stim(8'h00, 8'h00, OP_OR );
                apply_stim(8'hFF, 8'h00, OP_NOT);
                apply_stim(8'h00, 8'hFF, OP_NOT);
            end
        end
    endtask

    task test_opcode_sweep_all_inputs;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_opcode_sweep_all_inputs (full 256 ADD)", task_count);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], 8'h37, OP_ADD);
            $display("[TASK %0d] test_opcode_sweep_all_inputs (full 256 XOR)", task_count);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], 8'hA3, OP_XOR);
            $display("[TASK %0d] test_opcode_sweep_all_inputs (full 256 NOT)", task_count);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], 8'h00, OP_NOT);
        end
    endtask

    // =========================================================
    // GROUP 10 – BOUNDARY & STRESS
    // =========================================================

    task test_reset_recovery;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_reset_recovery", task_count);
            for (i = 0; i < 4; i = i + 1) begin
                a = 8'hDE; b = 8'hAD; op = OP_ADD;
                wait_cycles(4);
                do_reset;
                apply_check(8'h00, 8'h00, OP_ADD, 8'h00, 1'b0);
            end
        end
    endtask

    task test_all_zero_inputs;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_all_zero_inputs", task_count);
            for (i = 0; i < 8; i = i + 1) begin
                @(negedge clk); a = 8'h00; b = 8'h00; op = i[2:0];
                @(posedge clk); #1;
                if (i[2:0] == OP_NOT) begin
                    if (result !== 8'hFF) begin $display("[FAIL] NOT(0)=%02h",result); fail_count = fail_count+1; end
                    else pass_count = pass_count + 1;
                end else begin
                    if (result !== 8'h00) begin $display("[FAIL] op%0b(0,0)=%02h",i[2:0],result); fail_count=fail_count+1; end
                    else pass_count = pass_count + 1;
                end
            end
        end
    endtask

    task test_all_ones_inputs;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_all_ones_inputs", task_count);
            for (i = 0; i < 8; i = i + 1)
                apply_stim(8'hFF, 8'hFF, i[2:0]);
        end
    endtask

    task test_sequential_accumulate;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_sequential_accumulate", task_count);
            @(negedge clk); a = 8'h01; b = 8'h03; op = OP_ADD;
            @(posedge clk); #1;
            for (i = 0; i < 64; i = i + 1) begin
                @(negedge clk); a = result; b = i[7:0]; op = OP_ADD;
                @(posedge clk); #1;
            end
        end
    endtask

    task test_byte_boundary_patterns;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_byte_boundary_patterns", task_count);
            for (i = 0; i < 8; i = i + 1) begin
                apply_stim(8'h7F, 8'h01, OP_ADD);
                apply_stim(8'h80, 8'hFF, OP_ADD);
                apply_stim(8'hFE, 8'h01, OP_ADD);
                apply_stim(8'h00, 8'h80, OP_SUB);
                apply_stim(8'h80, 8'h00, OP_SUB);
                apply_stim(8'h80, 8'h7F, OP_XOR);
                apply_stim(8'h7F, 8'h80, OP_OR );
                apply_stim(8'hFF, 8'h80, OP_AND);
            end
        end
    endtask

    task test_realistic_alu_workload;
        // A synthetic workload resembling typical ALU usage in a datapath
        integer i;
        reg [7:0] accum, temp;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] test_realistic_alu_workload", task_count);
            accum = 8'h00;
            for (i = 4; i < 68; i = i + 1) begin
                // Add constant
                @(negedge clk); a = accum; b = i[7:0]; op = OP_ADD;
                @(posedge clk); #1; accum = result;
                // Mask lower nibble
                @(negedge clk); a = accum; b = 8'h0F; op = OP_AND;
                @(posedge clk); #1; accum = result;
                // XOR with running constant
                @(negedge clk); a = accum; b = 8'h96; op = OP_XOR;
                @(posedge clk); #1; accum = result;
                // Shift left
                @(negedge clk); a = accum; b = 8'h00; op = OP_SHL;
                @(posedge clk); #1; accum = result;
                // OR with pattern
                @(negedge clk); a = accum; b = i[7:0] & 8'hF0; op = OP_OR;
                @(posedge clk); #1; accum = result;
            end
        end
    endtask

    // =========================================================
    // MAIN STIMULUS
    // =========================================================
    initial begin
        // Initialise
        pass_count = 0; fail_count = 0; task_count = 0;
        clk = 1'b0; rst = 1'b1;
        a = 8'h00; b = 8'h00; op = 3'b000;

        wait_cycles(5);
        do_reset;

        $display("================================================================");
        $display(" tb_power_alu: Extensive Power Simulation Testbench  START");
        $display("================================================================");

        // ---- GROUP 1 : ADD ----
        test_add_basic;
        test_add_walking_ones_a;
        test_add_walking_ones_b;
        test_add_double_walking;
        test_add_carry_boundary;
        test_add_incremental_a;
        test_add_incremental_b;
        test_add_fibonacci_stress;
        test_add_alternating_carry;

        // ---- GROUP 2 : SUB ----
        test_sub_basic;
        test_sub_walking_operand;
        test_sub_countdown;
        test_sub_borrow_stress;
        test_sub_symmetric;

        // ---- GROUP 3 : AND ----
        test_and_basic;
        test_and_walking_mask;
        test_and_nibble_patterns;
        test_and_accumulate;
        test_and_mask_sweep;

        // ---- GROUP 4 : OR ----
        test_or_basic;
        test_or_walking_ones;
        test_or_set_accumulate;
        test_or_incremental;
        test_or_mask_sweep;

        // ---- GROUP 5 : XOR ----
        test_xor_basic;
        test_xor_self_cancel;
        test_xor_walking_ones;
        test_xor_parity_chain;
        test_xor_double_cancel;

        // ---- GROUP 6 : NOT ----
        test_not_basic;
        test_not_walking_ones;
        test_not_double_invert;
        test_not_all_nibbles;

        // ---- GROUP 7 : SHL ----
        test_shl_basic;
        test_shl_msb_propagation;
        test_shl_arbitrary_patterns;
        test_shl_checkerboard_shift;

        // ---- GROUP 8 : SHR ----
        test_shr_basic;
        test_shr_lsb_propagation;
        test_shr_arbitrary_patterns;
        test_shr_checkerboard_shift;

        // ---- GROUP 9 : CROSS-OPCODE ----
        test_interleaved_all_ops;
        test_checkerboard_all_ops;
        test_max_toggle_burst;
        test_opcode_sweep_all_inputs;

        // ---- GROUP 10 : BOUNDARY & STRESS ----
        test_reset_recovery;
        test_all_zero_inputs;
        test_all_ones_inputs;
        test_sequential_accumulate;
        test_byte_boundary_patterns;
        test_realistic_alu_workload;

        wait_cycles(10);

        $display("================================================================");
        $display(" RESULTS : %0d PASS  |  %0d FAIL  |  %0d tasks executed",
                 pass_count, fail_count, task_count);
        $display(" tb_power_alu: Power Simulation END");
        $display("================================================================");
        $finish;
    end

endmodule
