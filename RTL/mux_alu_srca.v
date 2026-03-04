`timescale 1ns / 1ps  
module mux_alu_srca( 
input  [31:0] pc_out, 
input  [31:0] rd1, 
input         
ALUSrcA, 
output [31:0] A 
); 
  assign A = (ALUSrcA) ? rd1 : pc_out; 
endmodule
