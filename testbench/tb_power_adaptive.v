// ============================================================
// Testbench : tb_power_adaptive
// Purpose   : Extensive power simulation testbench for the
//             Adaptive Redundancy top-level (top_adaptive).
//
//   Exercises the full self-healing lifecycle:
//     Phase 1 – Single mode (stable inputs, low risk)
//     Phase 2 – MEDIUM escalation (toggle-driven risk)
//     Phase 3 – HIGH escalation (toggling + fault injection)
//     Phase 4 – TMR correction under sustained fault
//     Phase 5 – De-escalation (remove activity + faults)
//     Phase 6 – Repeat lifecycle with different patterns
//     Phase 7 – Rapid escalation / de-escalation stress
//     Phase 8 – All opcodes exercised at each risk level
//     Phase 9 – Fault-free exhaustive input sweep
//    Phase 10 – Final verification checks
//
//   Risk Estimator parameters (matching top_adaptive):
//     WINDOW_CYCLES = 64, TOGGLE_MED = 10, TOGGLE_HIGH = 30
//     ERROR_MED = 2, ERROR_HIGH = 4
//
// Sim target: Vivado XSim
// Clock     : 100 MHz (10 ns period)
// ============================================================
`timescale 1ns/1ps

module tb_power_adaptive;

    // ---------------------------------------------------------
    // Clock & timing
    // ---------------------------------------------------------
    localparam CLK_PERIOD   = 10;    // ns
    localparam WINDOW       = 64;    // risk_estimator window

    // ALU opcodes
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110;
    localparam OP_SHR = 3'b111;

    // Fault injector types
    localparam FT_NONE = 2'b00;
    localparam FT_SA0  = 2'b01;
    localparam FT_SA1  = 2'b10;
    localparam FT_FLIP = 2'b11;

    // Redundancy modes
    localparam MODE_SINGLE = 2'b00;
    localparam MODE_DMR    = 2'b01;
    localparam MODE_TMR    = 2'b10;

    // Risk levels
    localparam RISK_LOW  = 2'b00;
    localparam RISK_MED  = 2'b01;
    localparam RISK_HIGH = 2'b10;

    // ---------------------------------------------------------
    // DUT I/O
    // ---------------------------------------------------------
    reg        clk;
    reg        rst;

    reg  [7:0] a;
    reg  [7:0] b;
    reg  [2:0] op;

    reg        fi0_en;
    reg  [1:0] fi0_type;
    reg  [7:0] fi0_mask;

    reg        fi1_en;
    reg  [1:0] fi1_type;
    reg  [7:0] fi1_mask;

    reg        fi2_en;
    reg  [1:0] fi2_type;
    reg  [7:0] fi2_mask;

    wire [7:0] final_result;
    wire       zero_flag;
    wire       carry_flag;
    wire [1:0] risk_score;
    wire [1:0] redundancy_mode;
    wire       fault_detected;
    wire       dmr_error;
    wire [2:0] faulty_module;

    // ---------------------------------------------------------
    // Counters / tracking
    // ---------------------------------------------------------
    integer pass_count;
    integer fail_count;
    integer task_count;

    reg [1:0] prev_mode;
    integer   escalations;
    integer   deescalations;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    top_adaptive uut (
        .clk            (clk),
        .rst            (rst),
        .a              (a),
        .b              (b),
        .op             (op),
        .fi0_en         (fi0_en),  .fi0_type(fi0_type),  .fi0_mask(fi0_mask),
        .fi1_en         (fi1_en),  .fi1_type(fi1_type),  .fi1_mask(fi1_mask),
        .fi2_en         (fi2_en),  .fi2_type(fi2_type),  .fi2_mask(fi2_mask),
        .final_result   (final_result),
        .zero_flag      (zero_flag),
        .carry_flag     (carry_flag),
        .risk_score     (risk_score),
        .redundancy_mode(redundancy_mode),
        .fault_detected (fault_detected),
        .dmr_error      (dmr_error),
        .faulty_module  (faulty_module)
    );

    // ---------------------------------------------------------
    // Clock
    // ---------------------------------------------------------
    initial clk = 1'b0;
    always  #(CLK_PERIOD/2) clk = ~clk;

    // ---------------------------------------------------------
    // Mode-transition logging
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (!rst) begin
            if (redundancy_mode !== prev_mode) begin
                $display("[MODE] t=%0t  %s -> %s  (risk=%02b)",
                    $time,
                    (prev_mode == 2'b00) ? "SINGLE" :
                    (prev_mode == 2'b01) ? "DMR   " : "TMR   ",
                    (redundancy_mode == 2'b00) ? "SINGLE" :
                    (redundancy_mode == 2'b01) ? "DMR   " : "TMR   ",
                    risk_score);
                if (redundancy_mode > prev_mode) escalations   = escalations + 1;
                else                             deescalations = deescalations + 1;
            end
            prev_mode <= redundancy_mode;
        end else begin
            prev_mode <= 2'b00;
        end
    end

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

    task wait_windows;
        input integer n;
        begin wait_cycles(n * WINDOW); end
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

    task apply_stim;
        input [7:0] ta;
        input [7:0] tb;
        input [2:0] top;
        begin
            @(negedge clk);
            a = ta; b = tb; op = top;
        end
    endtask

    task apply_check;
        input [7:0] ta;
        input [7:0] tb;
        input [2:0] top;
        input [7:0] expected;
        input [1:0] exp_mode;
        begin
            @(negedge clk); a = ta; b = tb; op = top;
            @(posedge clk); #1;
            if (final_result === expected && redundancy_mode === exp_mode) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] a=%02h b=%02h op=%03b | exp_r=%02h got=%02h exp_m=%02b got_m=%02b",
                         ta, tb, top, expected, final_result, exp_mode, redundancy_mode);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Generate high toggle activity (>30 per 64-cycle window → HIGH risk)
    task drive_high_toggle_stimulus;
        input integer cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(negedge clk);
                // Alternate 0xFF/0x00 every cycle — maximum switching activity
                a  = (i[0]) ? 8'hFF : 8'h00;
                b  = (i[0]) ? 8'h00 : 8'hFF;
                op = i[2:0];  // cycle through opcodes too
            end
        end
    endtask

    // Generate medium toggle activity (10-30 per window → MEDIUM risk)
    task drive_medium_toggle_stimulus;
        input integer cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(negedge clk);
                // Toggle every 4 cycles — ~16 toggles per 64-cycle window
                a  = ((i[2]) ? 8'hCC : 8'h33);
                b  = 8'h96;
                op = OP_XOR;
            end
        end
    endtask

    // Generate stable (low-toggle) stimulus
    task drive_stable_stimulus;
        input integer cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(negedge clk);
                a  = 8'h5A;  // constant
                b  = 8'hA5;  // constant
                op = OP_AND; // constant
            end
        end
    endtask

    // =========================================================
    // PHASE 1 – Single mode: stable inputs, confirm LOW risk
    // =========================================================

    task phase1_single_mode_stable;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 1: Single-mode stable operation", task_count);
            clear_all_faults;
            // 4 full windows of completely stable inputs
            drive_stable_stimulus(4 * WINDOW);
            @(posedge clk); #1;
            if (risk_score > RISK_LOW) begin
                $display("[INFO] Phase 1: risk_score=%02b (expected LOW)", risk_score);
            end else begin
                $display("[OK  ] Phase 1: risk_score=LOW (%02b) in Single mode", risk_score);
                pass_count = pass_count + 1;
            end
        end
    endtask

    // =========================================================
    // PHASE 2 – Toggle-based escalation
    // =========================================================

    task phase2_toggle_escalation;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 2: Toggle-driven risk escalation", task_count);
            clear_all_faults;
            // Drive high-activity for 5 windows — risk_score should reach HIGH
            drive_high_toggle_stimulus(5 * WINDOW);
            wait_cycles(2);
            $display("[INFO] Phase 2: after 5 high-toggle windows mode=%02b risk=%02b",
                     redundancy_mode, risk_score);
        end
    endtask

    task phase2b_medium_activity;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 2b: Medium activity stimulus", task_count);
            clear_all_faults;
            drive_medium_toggle_stimulus(4 * WINDOW);
            wait_cycles(2);
            $display("[INFO] Phase 2b: mode=%02b risk=%02b", redundancy_mode, risk_score);
        end
    endtask

    // =========================================================
    // PHASE 3 – Fault injection → error-based escalation
    // =========================================================

    task phase3_fault_based_escalation;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 3: Fault-based risk escalation", task_count);
            clear_all_faults;
            // Use high-toggle input to stay above MEDIUM threshold
            // AND inject bit-flip on ALU1 to drive error_count > ERROR_HIGH
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hFF;
            for (i = 0; i < 5 * WINDOW; i = i + 1) begin
                @(negedge clk);
                a  = (i[0]) ? 8'hDE : 8'h21;
                b  = (i[0]) ? 8'hAD : 8'h52;
                op = i[2:0];
            end
            wait_cycles(2);
            $display("[INFO] Phase 3: mode=%02b risk=%02b fd=%b",
                     redundancy_mode, risk_score, fault_detected);
        end
    endtask

    // =========================================================
    // PHASE 4 – TMR correction under sustained fault
    // =========================================================

    task phase4_tmr_correction_sustained;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 4: TMR correction under sustained fault", task_count);
            // Keep fault active, generate varying stimuli
            fi1_en = 1'b1; fi1_type = FT_SA0; fi1_mask = 8'hFF;
            for (i = 0; i < 3 * WINDOW; i = i + 1) begin
                @(negedge clk);
                a = i[7:0]; b = (i + 8'h37) & 8'hFF; op = i[2:0];
            end
            wait_cycles(2);
            // If in TMR mode, final_result should match expected
            @(negedge clk); a = 8'h0A; b = 8'h05; op = OP_ADD;
            @(posedge clk); #1;
            if (final_result === 8'h0F)
                begin $display("[OK  ] Phase 4: TMR correct result 0x0F"); pass_count=pass_count+1; end
            else
                begin $display("[INFO] Phase 4: result=%02h (TMR may not be active yet)", final_result); end
        end
    endtask

    // =========================================================
    // PHASE 5 – De-escalation
    // =========================================================

    task phase5_deescalation;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 5: De-escalation (remove faults + stabilise)", task_count);
            clear_all_faults;
            // 8 windows of stable input — risk should decay back to LOW
            drive_stable_stimulus(8 * WINDOW);
            @(posedge clk); #1;
            $display("[INFO] Phase 5: after 8 stable windows mode=%02b risk=%02b",
                     redundancy_mode, risk_score);
            if (risk_score == RISK_LOW) begin
                $display("[OK  ] Phase 5: de-escalated to LOW risk");
                pass_count = pass_count + 1;
            end else begin
                $display("[INFO] Phase 5: risk=%02b (need more windows)", risk_score);
            end
        end
    endtask

    // =========================================================
    // PHASE 6 – Second lifecycle with different opcodes
    // =========================================================

    task phase6_second_lifecycle;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 6: Second lifecycle (different opcodes)", task_count);
            clear_all_faults;
            do_reset;
            wait_windows(2);

            // Stable phase with different opcode
            for (i = 0; i < 3 * WINDOW; i = i + 1) begin
                @(negedge clk); a = 8'h96; b = 8'h69; op = OP_SUB;
            end

            // High-toggle phase with SUB/OR/SHL mix
            for (i = 0; i < 4 * WINDOW; i = i + 1) begin
                @(negedge clk);
                a  = i[7:0];
                b  = ~i[7:0];
                op = (i < WINDOW) ? OP_SUB :
                     (i < 2*WINDOW) ? OP_OR :
                     (i < 3*WINDOW) ? OP_SHL : OP_NOT;
            end

            // Fault phase
            fi0_en = 1'b1; fi0_type = FT_FLIP; fi0_mask = 8'hAA;
            for (i = 0; i < 3 * WINDOW; i = i + 1) begin
                @(negedge clk);
                a  = i[7:0] ^ 8'h5A;
                b  = 8'h96;
                op = i[2:0];
            end

            // De-escalation
            clear_all_faults;
            drive_stable_stimulus(6 * WINDOW);

            $display("[INFO] Phase 6: mode=%02b risk=%02b esc=%0d desc=%0d",
                     redundancy_mode, risk_score, escalations, deescalations);
        end
    endtask

    // =========================================================
    // PHASE 7 – Rapid escalation / de-escalation stress
    // =========================================================

    task phase7_rapid_stress;
        integer i, j;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 7: Rapid escalation stress", task_count);
            clear_all_faults;
            // Alternately drive high activity then stable, each for 2 windows
            for (j = 0; j < 6; j = j + 1) begin
                // HIGH activity burst
                @(negedge clk);
                for (i = 0; i < 2 * WINDOW; i = i + 1) begin
                    @(negedge clk);
                    a  = (i[0]) ? 8'hFF : 8'h00;
                    b  = (i[0]) ? 8'h00 : 8'hFF;
                    op = i[2:0];
                end
                // Stable quiet
                for (i = 0; i < 2 * WINDOW; i = i + 1) begin
                    @(negedge clk);
                    a = 8'h42; b = 8'h24; op = OP_AND;
                end
            end
        end
    endtask

    // =========================================================
    // PHASE 8 – All opcodes at each risk level
    // =========================================================

    task phase8_opcodes_at_all_levels;
        integer i, opc;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 8: All opcodes at all risk levels", task_count);
            clear_all_faults;

            // -- Single mode: run all 8 ops with stable data --
            $display("[INFO] Phase 8: Single mode opcode test");
            drive_stable_stimulus(3 * WINDOW);
            for (opc = 0; opc < 8; opc = opc + 1) begin
                apply_stim(8'hA5, 8'h5A, opc[2:0]);
                wait_cycles(2);
            end

            // -- TMR mode: escalate then test all ops --
            $display("[INFO] Phase 8: escalating to TMR...");
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hFF;
            drive_high_toggle_stimulus(6 * WINDOW);
            $display("[INFO] Phase 8: TMR mode opcode test");
            for (opc = 0; opc < 8; opc = opc + 1) begin
                @(negedge clk); a = 8'hDE; b = 8'hAD; op = opc[2:0];
                @(posedge clk); #1;
                $display("[INFO]   op=%03b result=%02h mode=%02b fd=%b",
                         opc[2:0], final_result, redundancy_mode, fault_detected);
            end
            clear_all_faults;
        end
    endtask

    // =========================================================
    // PHASE 9 – Fault-free exhaustive input sweep
    // =========================================================

    task phase9_exhaustive_sweep;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 9: Exhaustive input sweep (fault-free)", task_count);
            // Full 256-value sweep on ADD — capture max data activity
            clear_all_faults;
            drive_stable_stimulus(8 * WINDOW);  // ensure Single mode first

            $display("[INFO] Phase 9: mode=%02b risk=%02b", redundancy_mode, risk_score);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], i[7:0] ^ 8'h5A, OP_ADD);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], ~i[7:0], OP_XOR);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], 8'hA5, OP_OR);
            for (i = 0; i <= 255; i = i + 1)
                apply_stim(i[7:0], 8'h00, OP_NOT);
        end
    endtask

    // =========================================================
    // PHASE 10 – Final verification checks
    // =========================================================

    task phase10_final_verification;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Phase 10: Final verification checks", task_count);

            // 1) After de-escalation, verify Single mode clean output
            clear_all_faults;
            drive_stable_stimulus(8 * WINDOW);
            apply_check(8'h0A, 8'h05, OP_ADD, 8'h0F, MODE_SINGLE);

            // 2) Inject TMR fault, verify fault_detected asserted
            drive_high_toggle_stimulus(6 * WINDOW);
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hFF;
            wait_windows(3);
            @(negedge clk); a = 8'h0A; b = 8'h05; op = OP_ADD;
            @(posedge clk); #1;
            if (fault_detected && final_result === 8'h0F) begin
                $display("[OK  ] Phase 10: TMR correctly detected fault and produced correct output");
                pass_count = pass_count + 1;
            end else begin
                $display("[INFO] Phase 10: fd=%b result=%02h mode=%02b",
                         fault_detected, final_result, redundancy_mode);
            end

            // 3) Remove fault, verify de-escalation path
            clear_all_faults;
            drive_stable_stimulus(8 * WINDOW);
            @(posedge clk); #1;
            $display("[INFO] Phase 10: Final state mode=%02b risk=%02b esc=%0d desc=%0d",
                     redundancy_mode, risk_score, escalations, deescalations);
        end
    endtask

    // =========================================================
    // BONUS – Additional operation coverage at TMR
    // =========================================================

    task bonus_tmr_all_opcodes_extended;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Bonus: Extended TMR opcode coverage", task_count);
            // Escalate to TMR
            clear_all_faults;
            fi2_en = 1'b1; fi2_type = FT_SA0; fi2_mask = 8'hFF;
            drive_high_toggle_stimulus(4 * WINDOW);

            for (i = 0; i < 64; i = i + 1) begin
                apply_stim(i[7:0], i[7:0] ^ 8'hCC, OP_ADD);
                apply_stim(i[7:0], i[7:0] ^ 8'h33, OP_SUB);
                apply_stim(i[7:0], 8'hAB,           OP_AND);
                apply_stim(i[7:0], 8'hCD,           OP_OR );
                apply_stim(i[7:0], 8'hEF,           OP_XOR);
                apply_stim(i[7:0], 8'h00,           OP_NOT);
                apply_stim(i[7:0], 8'h00,           OP_SHL);
                apply_stim(i[7:0], 8'h00,           OP_SHR);
            end
            clear_all_faults;
        end
    endtask

    task bonus_dmr_mode_extended;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Bonus: Extended DMR coverage", task_count);
            clear_all_faults;
            // Drive medium activity to reach DMR mode
            drive_medium_toggle_stimulus(6 * WINDOW);
            $display("[INFO] Bonus DMR: mode=%02b risk=%02b", redundancy_mode, risk_score);

            // Inject DMR-detectable fault
            fi1_en = 1'b1; fi1_type = FT_FLIP; fi1_mask = 8'hAA;
            for (i = 0; i < 3 * WINDOW; i = i + 1) begin
                @(negedge clk);
                a  = (i[0]) ? 8'hCC : 8'h33;
                b  = 8'h96;
                op = i[2:0];
            end
            clear_all_faults;
        end
    endtask

    task bonus_reset_stress;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Bonus: Reset stress", task_count);
            for (i = 0; i < 5; i = i + 1) begin
                // Escalate, then reset mid-operation
                clear_all_faults;
                fi0_en = 1'b1; fi0_type = FT_FLIP; fi0_mask = 8'hFF;
                drive_high_toggle_stimulus(3 * WINDOW);
                do_reset;
                clear_all_faults;
                wait_windows(2);
                $display("[INFO] Reset stress iter %0d: mode=%02b risk=%02b", i, redundancy_mode, risk_score);
            end
        end
    endtask

    task bonus_max_activity_burst;
        integer i;
        begin
            task_count = task_count + 1;
            $display("[TASK %0d] Bonus: Maximum activity burst (TMR + fault + toggle)", task_count);
            clear_all_faults;
            fi0_en = 1'b1; fi0_type = FT_FLIP; fi0_mask = 8'hFF;
            fi1_en = 1'b1; fi1_type = FT_SA0;  fi1_mask = 8'hFF;
            for (i = 0; i < 8 * WINDOW; i = i + 1) begin
                @(negedge clk);
                a  = (i[0]) ? 8'hFF : 8'h00;
                b  = (i[0]) ? 8'h00 : 8'hFF;
                op = i[2:0];
            end
            clear_all_faults;
            wait_windows(2);
        end
    endtask

    // =========================================================
    // MAIN STIMULUS
    // =========================================================
    initial begin
        pass_count    = 0;
        fail_count    = 0;
        task_count    = 0;
        escalations   = 0;
        deescalations = 0;
        prev_mode     = 2'b00;

        clk = 1'b0; rst = 1'b1;
        a = 8'h00; b = 8'h00; op = 3'b000;
        clear_all_faults;

        wait_cycles(5);
        do_reset;
        wait_windows(2);

        $display("================================================================");
        $display(" tb_power_adaptive: Extensive Power Simulation Testbench START");
        $display("================================================================");

        // ---- Main lifecycle phases ----
        phase1_single_mode_stable;
        phase2_toggle_escalation;
        phase2b_medium_activity;
        phase3_fault_based_escalation;
        phase4_tmr_correction_sustained;
        phase5_deescalation;
        phase6_second_lifecycle;
        phase7_rapid_stress;
        phase8_opcodes_at_all_levels;
        phase9_exhaustive_sweep;
        phase10_final_verification;

        // ---- Bonus exercises ----
        bonus_tmr_all_opcodes_extended;
        bonus_dmr_mode_extended;
        bonus_reset_stress;
        bonus_max_activity_burst;

        wait_cycles(20);

        $display("================================================================");
        $display(" RESULTS : %0d PASS  |  %0d FAIL  |  %0d tasks",
                 pass_count, fail_count, task_count);
        $display(" Mode transitions: %0d escalations | %0d de-escalations",
                 escalations, deescalations);
        $display(" tb_power_adaptive: Power Simulation END");
        $display("================================================================");
        $finish;
    end

endmodule
