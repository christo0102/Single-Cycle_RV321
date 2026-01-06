`timescale 1ns / 1ps  
module Extend (
    input  [31:0] instruction,
    input  [2:0]  ImmSrc,
    output reg [31:0] ImmExt
);
    // specified by the Control Unit (ImmSrc).
    always @(*) begin
        case (ImmSrc)
            // I-Type (for addi, lw, jalr)
            3'b000: ImmExt = { {20{instruction[31]}}, instruction[31:20] };

            // S-Type (for sw, sh, sb)
            3'b001: ImmExt = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };

            // B-Type (for beq, bne, etc.)
            3'b010: ImmExt = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };

            // J-Type (for jal)
            3'b011: ImmExt = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 };

            // U-Type (for lui, auipc)
            3'b100: ImmExt = { instruction[31:12], 12'b0 };

            // Default case to prevent latches and provide a known safe value
            default: ImmExt = 32'h00000000;
        endcase
    end
endmodule
