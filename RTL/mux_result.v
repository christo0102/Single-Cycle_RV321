`timescale 1ns / 1ps    
module mux_result( 
input  [31:0] ALUResult, 
input  [31:0] load_data, 
input  [31:0] pc_plus4, 
input  [1:0]  ResultSrc, 
output reg [31:0] Result 
); 
always @(*) begin 
case (ResultSrc) 
2'b00: Result = ALUResult; 
2'b01: Result = load_data; 
2'b10: Result = pc_plus4; 
2'b11: Result = 32'b0; 
default: Result = 32'b0; 
endcase 
end 
endmodule
