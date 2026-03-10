// ============================================================
// Module  : alu
// Project : Self-Healing Digital Circuit
// Description:
//   8-bit Arithmetic Logic Unit supporting 8 operations.
`timescale 1ns/1ps
//   This module is the core processing unit that will be
//   replicated for redundancy (DMR / TMR).
//
// Inputs:
//   clk       - clock (for registered output variant)
//   rst       - synchronous active-high reset
//   a, b      - 8-bit operands
//   op        - 3-bit operation selector
//
// Outputs:
//   result    - 8-bit computation result
//   carry_out - carry/borrow flag
//   zero      - asserted when result == 0
// ============================================================

module alu (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [2:0]  op,
    output reg  [7:0]  result,
    output reg         carry_out,
    output wire        zero
);

    // Operation encodings
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110;  // Shift left by 1
    localparam OP_SHR = 3'b111;  // Shift right by 1

    wire [8:0] add_result = {1'b0, a} + {1'b0, b};
    wire [8:0] sub_result = {1'b0, a} - {1'b0, b};

    always @(posedge clk) begin
        if (rst) begin
            result    <= 8'h00;
            carry_out <= 1'b0;
        end else begin
            case (op)
                OP_ADD: begin
                    result    <= add_result[7:0];
                    carry_out <= add_result[8];
                end
                OP_SUB: begin
                    result    <= sub_result[7:0];
                    carry_out <= sub_result[8];   // borrow bit
                end
                OP_AND: begin
                    result    <= a & b;
                    carry_out <= 1'b0;
                end
                OP_OR: begin
                    result    <= a | b;
                    carry_out <= 1'b0;
                end
                OP_XOR: begin
                    result    <= a ^ b;
                    carry_out <= 1'b0;
                end
                OP_NOT: begin
                    result    <= ~a;
                    carry_out <= 1'b0;
                end
                OP_SHL: begin
                    result    <= {a[6:0], 1'b0};
                    carry_out <= a[7];            // MSB shifted out
                end
                OP_SHR: begin
                    result    <= {1'b0, a[7:1]};
                    carry_out <= a[0];            // LSB shifted out
                end
                default: begin
                    result    <= 8'h00;
                    carry_out <= 1'b0;
                end
            endcase
        end
    end

    // Zero flag is combinational
    assign zero = (result == 8'h00);

endmodule
