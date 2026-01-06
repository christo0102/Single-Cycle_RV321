`timescale 1ns / 1ps         
module ALU #( 
parameter LEN = 32 
)( 
input  wire [LEN-1:0] A, 
input  wire [LEN-1:0] B, 
input  wire [3:0]    ALU_Ctrl, 
output reg  [LEN-1:0] ALU_Result, 
output wire zero ,
output wire LessThan
); 
localparam ADD  = 4'b0000; 
localparam SUB  = 4'b0001; 
localparam AND  = 4'b0010; 
localparam OR   = 4'b0011; 
localparam XOR  = 4'b0100; 
localparam SLL  = 4'b0101; 
localparam SRL  = 4'b0110; 
localparam SRA  = 4'b0111; 
localparam SLT  = 4'b1000; 
localparam SLTU = 4'b1001; 
localparam PASS = 4'b1010; 

wire signed_less = ($signed(A) < $signed(B));
wire unsigned_less = (A < B);

assign LessThan = (ALU_Ctrl == SLT) ? signed_less : (ALU_Ctrl == SLTU) ? unsigned_less : 1'b0;
always @(*) begin 
case (ALU_Ctrl) 
ADD:   ALU_Result = A + B; 
SUB:   ALU_Result = A - B; 
AND:   ALU_Result = A & B; 
OR:    ALU_Result = A | B; 
XOR:   ALU_Result = A ^ B; 
SLL:   ALU_Result = A << B[4:0]; 
SRL:   ALU_Result = A >> B[4:0]; 
// logical right 
SRA:   ALU_Result = ($signed(A)) >>> B[4:0]; // arithmetic right 
SLT:   ALU_Result = ($signed(A) < $signed(B)) ? {{LEN-1{1'b0}}, 1'b1} : 'b0; 
SLTU:  ALU_Result = (A < B) ? {{LEN-1{1'b0}}, 1'b1} : 'b0; 
PASS:  ALU_Result = B; 
default: ALU_Result = {LEN{1'b0}}; 
endcase 
end 
assign zero = (ALU_Result == {LEN{1'b0}}); 
endmodule
