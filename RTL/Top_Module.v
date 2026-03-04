`timescale 1ns / 1ps  
  
module RISC_V_Single_Cycle (
    input  clk,     // System Clock
    input  reset // System Reset
);

    // PC and Fetch Wires
    wire [31:0] pc_out;          // PC output (Address for IMEM)
    wire [31:0] instruction;     // Instruction output from IMEM
    wire [31:0] pc_plus4;        // PC + 4
    wire [31:0] pc_target;       // Branch/Jump Target (PC + ImmExt)
    wire [31:0] pc_next;         // Next PC Mux output
    
    // Control Wires (From Control Unit)
    wire [1:0] ResultSrc;
    wire MemWrite;
    wire ALUSrcB;
    wire ALUSrcA;
    wire [2:0] ImmSrc;           // 3-bit Immediate Source Control
    wire RegWrite;
    wire [3:0] ALU_Ctrl;
    wire [1:0] PCSrc;
    
    // Register File Wires
    wire [31:0] rd1;             // Read Data 1 (RS1)
    wire [31:0] rd2;             // Read Data 2 (RS2, used for ALU B or Store Data)
    wire [31:0] Result;          // Write-back data (Result Mux Output)

    // Immediate Extension, ALU, and Mux Wires
    wire [31:0] ImmExt;          // Output of the Extend module
    wire [31:0] A;               // ALU Operand A (Mux ALUSrcA output)
    wire [31:0] B;               // ALU Operand B (Mux ALUSrcB output)
    wire [31:0] ALU_Result;      // ALU output (Address for DMEM, or ALU result)
    wire zero;                    // ALU Zero Flag
    wire LessThan;              
    // Data Memory Wires
    wire [31:0] Read_Data;       // Read Data from DMEM
    wire [31:0] load_data;       // load data from load unit to write in registers
    wire [31:0] jalr_target;

    // Control Unit Inputs
    wire funct7b5 = instruction[30]; // MSB of funct7 for R-type/I-type (SRA/SUB)
    assign jalr_target = {ALU_Result[31:1], 1'b0};

    // ------------------------------------------------------------------
    // 2. Instantiation of Components
    // ------------------------------------------------------------------

    // 2.1 PC and PC Logic
    PC program_counter (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    pc_logic4 pc_logic_one (
        .pc_out(pc_out),
        .pc_plus4(pc_plus4)
    );

    pc_target pc_logic_two (
        .pc_out(pc_out),
        .ImmExt(ImmExt),
        .pc_target(pc_target)
    );

    mux_pc mux_one (
        .pc_plus4(pc_plus4),
        .pc_target(pc_target),
        .jalr_target(jalr_target),       
        .PCSrc(PCSrc),
        .pc_next(pc_next)
    );
    
    // 2.2 Instruction Memory
    Instruction_Memory imem (
        .pc_out(pc_out[9:2]),
        .instruction(instruction)
    );

    // 2.3 Control Unit
    Control_Unit ctrl_unit (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7b5(funct7b5),
        .zero(zero),
        .LessThan(LessThan),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA),
        .ImmSrc(ImmSrc),        // Connects to Extend module
        .RegWrite(RegWrite),
        .ALU_Ctrl(ALU_Ctrl),
        .PCSrc(PCSrc)           // Connects to mux_pc
    );

    // 2.4 Register File
    Register_file registers (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .rs1(instruction[19:15]), // rs1 address
        .rs2(instruction[24:20]), // rs2 address
        .rd(instruction[11:7]),   // rd address
        .Result(Result),          // Write-back data
        .rd1(rd1),                // Read data 1
        .rd2(rd2)                 // Read data 2 (Store data)
    );

    // 2.5 Immediate Generator
    Extend immediate_generator (
        .instruction(instruction[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );
    
    // 2.6 ALU and Source Muxes
    mux_alu_srca mux_alu_one (
        .pc_out(pc_out),
        .rd1(rd1),
        .ALUSrcA(ALUSrcA),
        .A(A)
    );

    mux_alu_srcb mux_alu_two (
        .rd2(rd2),
        .ImmExt(ImmExt),
        .ALUSrcB(ALUSrcB),
        .B(B)
    );

    ALU #(.LEN(32)) alu_unit (
        .A(A),
        .B(B),
        .ALU_Ctrl(ALU_Ctrl),
        .ALU_Result(ALU_Result),
        .zero(zero),
        .LessThan(LessThan)
    );

    // 2.7 Data Memory
    Data_Memory dmem (
        .clk(clk),
        .MemWrite(MemWrite),
        .ALU_Result(ALU_Result[9:0]), // ALU output is the memory address
        .Write_Data(rd2),        // Store data is from RS2 (rd2)
        .funct3(instruction[14:12]),
        .Read_Data(Read_Data)
    );

    mux_result mux_for_result (
        .ALUResult(ALU_Result),
        .load_data(load_data),
        .pc_plus4(pc_plus4),
        .ResultSrc(ResultSrc),
        .Result(Result)
    );
    
    Load_Unit load_unit (
    .Read_Data(Read_Data),
    .ALU_Result(ALU_Result[1:0]),
    .funct3(instruction[14:12]),
    .load_data(load_data)
    
    );
 
endmodule
