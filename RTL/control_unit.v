`timescale 1ns / 1ps      
 module Control_Unit ( 
 input  wire [6:0] opcode, 
 input  wire [2:0] funct3, 
 input  wire       LessThan,
 input  wire       funct7b5, 
 input  wire       zero, 
 // Outputs to other processor components 
 output wire [1:0] ResultSrc, 
 output wire       MemWrite, 
 output wire       ALUSrcB, 
 output wire       ALUSrcA, 
 output wire [2:0] ImmSrc, 
 output wire       RegWrite, 
 output wire [3:0] ALU_Ctrl, 
 output wire [1:0] PCSrc 
 ); 
 // Internal wire to connect the two decoders 
 wire [1:0] ALUOp; 
 wire opcode5; 
 assign opcode5 = opcode[5]; 
 // Instantiate the Main Decoder 
 main_decoder main_dec ( 
 .opcode     (opcode), 
 .funct3     (funct3),
 .zero       (zero),
 .LessThan   (LessThan),
 .PCSrc      (PCSrc), 
 .ResultSrc  (ResultSrc), 
 .MemWrite   (MemWrite), 
 .ALUSrcA     (ALUSrcA), 
 .ALUSrcB    (ALUSrcB), 
 .ImmSrc     (ImmSrc), 
 .RegWrite   (RegWrite), 
 .ALUOp      (ALUOp)      // Connects to the ALU_Decoder 
 ); 
 // Instantiate the ALU Decoder 
 ALU_Decoder alu_dec ( 
 .ALUOp      (ALUOp),     // Input comes from the main_decoder 
 .opcode5    (opcode5), 
 .funct3     (funct3), 
 .funct7b5   (funct7b5), 
 .ALU_Ctrl   (ALU_Ctrl) 
 ); 
 endmodule 
 //---------------------------------------------------------------- 
 // MAIN DECODER 
 //---------------------------------------------------------------- 
 module main_decoder ( 
 input  wire [6:0] opcode, 
 input  wire       LessThan,
 input  wire       zero,
 input  wire [2:0] funct3,
 output reg  [1:0] PCSrc, 
 output reg  [1:0] ResultSrc, 
 output reg        MemWrite, 
 output reg        ALUSrcA, 
 output reg        ALUSrcB, 
 output reg  [2:0] ImmSrc, 
 output reg        RegWrite, 
 output reg  [1:0] ALUOp 
 ); 
 
 wire take_branch;
 
assign take_branch =  (
    (funct3 == 3'b000 && zero)   | // BEQ: take if zero
    (funct3 == 3'b001 && ~zero)  | // BNE: take if not zero
    (funct3 == 3'b100 && LessThan) | // BLT: take if LessThan
    (funct3 == 3'b101 && ~LessThan) | // BGE: take if not LessThan
    (funct3 == 3'b110 && LessThan) | // BLTU: take if LessThan (unsigned)
    (funct3 == 3'b111 && ~LessThan)   // BGEU: take if not LessThan (unsigned)
);
 always @(*) begin 
 ResultSrc = 2'b00; 
 MemWrite  = 1'b0; 
 ALUSrcA   = 1'b1; 
 ALUSrcB   = 1'b0; 
 PCSrc     = 2'b00; 
 ImmSrc    = 3'b000; 
 RegWrite  = 1'b0; 
 ALUOp     = 2'b00; // Default to LW/SW behavior 
 case (opcode) 
 7'b0000011: begin // I-type: lw (except for jalr and addi,andi etc) 
 RegWrite  = 1'b1; 
 ALUSrcA    = 1'b1; 
 ALUSrcB = 1'b1;
 PCSrc   = 2'b00;
 ImmSrc     = 3'b000;
 ALUOp   = 2'b00;
 ResultSrc = 2'b01; // Data from memory 
 end 
 7'b0100011: begin // sw, sb, sh 
 ImmSrc    = 3'b001; // S-type immediate 
 ALUSrcA = 1'b1;
 PCSrc   = 2'b00;
 ALUOp = 2'b00;
 ALUSrcB   = 1'b1; 
 ResultSrc = 2'b00; 
 MemWrite  = 1'b1;
 end 
 7'b0110011: begin // R-type 
 RegWrite  = 1'b1; 
 ALUOp     = 2'b10; 
 ALUSrcA = 1'b1;
 ALUSrcB  = 1'b0;
 ResultSrc = 2'b00;
 PCSrc    = 2'b00;
 
 end 
 7'b1100011: begin // Branch-type 
 ImmSrc    = 3'b010; // B-type immediate 
 ALUOp     = 2'b01; 
 ALUSrcA = 1'b1;
 ALUSrcB = 1'b0;
 ResultSrc = 2'b00; 
 PCSrc     = take_branch ? 2'b01 : 2'b00;
 end 
 7'b0010011: begin // I-type (except for lw and jalr) 
 RegWrite  = 1'b1; 
 ALUOp     = 2'b10; 
 ImmSrc  = 3'b000;
 ALUSrcA = 1'b1;
 ResultSrc = 2'b00;
 ALUSrcB    = 1'b1; 
 end 
 7'b1101111: begin //  JAL-type 
 RegWrite  = 1'b1; 
 PCSrc     = 2'b01; 
 ResultSrc = 2'b10;
 ImmSrc    = 3'b011; 
 end 
 7'b1100111: begin  //  JALR 
 PCSrc     = 2'b10; 
 ALUSrcA   = 1'b1;
 ImmSrc   = 3'b000;
 ALUSrcB    = 1'b1; 
 RegWrite  = 1'b1; 
 ResultSrc = 2'b10; 
 end 
 7'b0110111: begin  // LUI 
 ImmSrc    = 3'b100; 
 ALUSrcB    = 1'b1; 
 RegWrite  = 1'b1; 
 ALUOp     = 2'b11; 
 ResultSrc  = 2'b00;
 PCSrc     = 2'b00;
 end 
 7'b0010111: begin  // AUIPC  
 ImmSrc    = 3'b100; 
 ALUSrcA   = 1'b0; 
 ALUSrcB    = 1'b1; 
 ResultSrc = 2'b00;
 ALUOp  = 2'b00;
 PCSrc = 2'b00;
 RegWrite  = 1'b1; 
 end 
 default: begin // Safe state for unsupported opcodes  
 PCSrc     = 2'b00; 
 ResultSrc = 2'b00; 
 MemWrite  = 1'b0; 
 ALUSrcA   = 1'b0; 
 ALUSrcB    = 1'b0; 
 ImmSrc    = 3'b000; 
 RegWrite  = 1'b0; 
 ALUOp     = 2'b00; 
 end 
 endcase 
 end 
 endmodule 
 //---------------------------------------------------------------- 
 // ALU DECODER 
 //---------------------------------------------------------------- 
 module ALU_Decoder ( 
 input  wire [1:0] ALUOp, 
 input  wire       opcode5, 
 input  wire [2:0] funct3, 
 input  wire       funct7b5, 
 output reg  [3:0] ALU_Ctrl 
 ); 
 // ALU operation encodings 
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
 always @(*) begin 
 case (ALUOp) 
 2'b00: ALU_Ctrl = ADD; // For LW/SW address calculation 
 2'b11: ALU_Ctrl = PASS; // For LUI 
 2'b01: begin // For Branch instructions 
 case (funct3) 
 3'b000: ALU_Ctrl = SUB;  // BEQ 
 3'b001: ALU_Ctrl = SUB;  // BNE 
 3'b100: ALU_Ctrl = SLT;  // BLT 
 3'b101: ALU_Ctrl = SLT;  // BGE 
 3'b110: ALU_Ctrl = SLTU; // BLTU 
 3'b111: ALU_Ctrl = SLTU; // BGEU 
 default: ALU_Ctrl = ADD; // Should not happen 
 endcase 
 end 
 2'b10: begin // For R-Type and I-Type instructions 
 case (funct3) 
 3'b000: ALU_Ctrl = (funct7b5 & opcode5) ? SUB : ADD; 
 3'b001: ALU_Ctrl = SLL; 
 3'b010: ALU_Ctrl = SLT; 
 3'b011: ALU_Ctrl = SLTU; 
 3'b100: ALU_Ctrl = XOR; 
 3'b101: ALU_Ctrl = (funct7b5) ? SRA : SRL; 
 3'b110: ALU_Ctrl = OR; 
 3'b111: ALU_Ctrl = AND; 
 default: ALU_Ctrl = ADD; // Should not happen 
 endcase 
 end 
 default: ALU_Ctrl = ADD; // Default case for safety 
 endcase 
 end 
 endmodule
