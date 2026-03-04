`timescale 1ns / 1ps  
module Instruction_Memory ( 
    input  wire [7:0] pc_out, 
    output wire [31:0] instruction 
); 
    reg [31:0] inst_memory [0:255]; 
      assign instruction = inst_memory[pc_out[7:0]]; 
endmodule
