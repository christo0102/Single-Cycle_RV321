`timescale 1ns / 1ps  
module Data_Memory #(parameter DEPTH = 256)( 
    input wire  clk,
    input wire  MemWrite,
    input wire [31:0]  ALU_Result,
    input wire [31:0]  Write_Data,
    output wire [31:0] Read_Data
); 
    reg [31:0] mem [0:DEPTH-1]; 
    assign Read_Data = mem[ALU_Result[9:2]]; 
    always @(posedge clk) begin 
        if (MemWrite) begin 
            mem[ALU_Result[9:2]] <= Write_Data; 
        end 
    end 
   
endmodule
