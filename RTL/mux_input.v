`timescale 1ns / 1ps  
module mux_pc(
    input  [31:0] pc_plus4,
    input  [31:0] pc_target,
    input  [31:0] jalr_target,
    input  [1:0]  PCSrc,
    output reg [31:0] pc_next
);
always @(*) begin
    case (PCSrc)
        2'b00: pc_next = pc_plus4;
        2'b01: pc_next = pc_target;
        2'b10: pc_next = jalr_target;
        2'b11: pc_next = 32'b0;
        default: pc_next = pc_plus4;
    endcase
end
endmodule
