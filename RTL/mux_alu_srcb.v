`timescale 1ns / 1ps  
module mux_alu_srcb( 
input  [31:0] rd2, 
input  [31:0] ImmExt, 
input         
ALUSrcB, 
output [31:0] B 
); 
assign B = (ALUSrcB) ? ImmExt : rd2; 
endmodule
