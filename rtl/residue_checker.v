`timescale 1ns/1ps
// ============================================================
// Module  : residue_checker
// Project : Self-Healing Digital Circuit
// Description:
//   Residue-based verification for modular arithmetic operations.
//
//   This checker validates ALU outputs for arithmetic ops only:
//     - ADD: (a + b) mod M == result mod M
//     - SUB: (a - b) mod M == result mod M
//
//   For non-arithmetic ops (AND/OR/XOR/NOT/SHL/SHR), the checker
//   marks the result as not-valid for residue verification.
//
//   Default modulus M = 3 to keep hardware small.
// ============================================================

module residue_checker #(
    parameter MODULUS = 3
) (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    input  wire [7:0] result,
    output wire       valid,
    output wire       mismatch
);

    function [1:0] mod3_8;
        input [7:0] x;
        reg [3:0] acc;
        begin
            acc = x[7:6] + x[5:4] + x[3:2] + x[1:0];
            while (acc >= 3)
                acc = acc - 3;
            mod3_8 = acc[1:0];
        end
    endfunction

    reg [1:0] ra;
    reg [1:0] rb;
    reg [1:0] rr;
    reg [1:0] expected;
    reg       valid_r;

    always @(*) begin
        ra = mod3_8(a);
        rb = mod3_8(b);
        rr = mod3_8(result);

        valid_r  = 1'b0;
        expected = 2'd0;

        case (op)
            3'b000: begin // ADD
                valid_r  = 1'b1;
                expected = ra + rb;
                if (expected >= 3)
                    expected = expected - 3;
            end
            3'b001: begin // SUB
                valid_r = 1'b1;
                if (ra >= rb)
                    expected = ra - rb;
                else
                    expected = ra + 3 - rb;
            end
            default: begin
                valid_r  = 1'b0;
                expected = 2'd0;
            end
        endcase
    end

    assign valid    = valid_r;
    assign mismatch = valid_r && (rr != expected);

endmodule
