`timescale 1ns/1ps
// ============================================================
// Module  : fault_injector
// Project : Self-Healing Digital Circuit
// Description:
//   Configurable fault injection unit used during simulation
//   to verify self-healing capability of the system.
//
//   Fault modes (fault_type):
//     2'b00 - None          : pass-through, no fault
//     2'b01 - Stuck-at-0    : selected bit(s) forced to 0
//     2'b10 - Stuck-at-1    : selected bit(s) forced to 1
//     2'b11 - Bit-flip (XOR): selected bit(s) inverted
//
//   fault_mask selects WHICH bits are affected.
//   enable gates the entire injector (0 = transparent).
//
// Inputs:
//   data_in    - 8-bit original data from ALU
//   fault_type - 2-bit fault model selector
//   fault_mask - 8-bit bit-mask for target bits
//   enable     - master enable for injection
//
// Outputs:
//   data_out   - 8-bit possibly-corrupted output
// ============================================================

module fault_injector (
    input  wire [7:0] data_in,
    input  wire [1:0] fault_type,
    input  wire [7:0] fault_mask,
    input  wire       enable,
    output reg  [7:0] data_out
);

    localparam FAULT_NONE  = 2'b00;
    localparam FAULT_SA0   = 2'b01;  // Stuck-at-0
    localparam FAULT_SA1   = 2'b10;  // Stuck-at-1
    localparam FAULT_FLIP  = 2'b11;  // Bit-flip

    always @(*) begin
        if (!enable) begin
            // Injector disabled — transparent pass-through
            data_out = data_in;
        end else begin
            case (fault_type)
                FAULT_NONE: data_out = data_in;

                // Force masked bits to 0
                FAULT_SA0:  data_out = data_in & (~fault_mask);

                // Force masked bits to 1
                FAULT_SA1:  data_out = data_in | fault_mask;

                // Flip masked bits (XOR injection)
                FAULT_FLIP: data_out = data_in ^ fault_mask;

                default:    data_out = data_in;
            endcase
        end
    end

endmodule
