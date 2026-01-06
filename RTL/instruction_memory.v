`timescale 1ns / 1ps  
module Instruction_Memory ( 
    input  wire [31:0] pc_out, 
    output wire [31:0] instruction 
); 
    reg [31:0] inst_memory [0:255]; 
     initial begin 
       $readmemh("instruction.mem", inst_memory); 
       end 
      assign instruction = inst_memory[pc_out[9:2]]; 
endmodule
