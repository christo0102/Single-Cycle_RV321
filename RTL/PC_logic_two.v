`timescale 1ns / 1ps  
module pc_target ( 
    input  wire [31:0] pc_out, 
    input  wire [31:0] ImmExt, 
    output wire [31:0] pc_target 
); 
    assign pc_target = pc_out + ImmExt; 
endmodule
