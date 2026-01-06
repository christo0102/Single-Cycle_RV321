`timescale 1ns / 1ps  
module pc_logic4 ( 
    input  wire [31:0] pc_out, 
    output wire [31:0] pc_plus4 
); 
    assign pc_plus4 = pc_out + 32'd4;
endmodule
