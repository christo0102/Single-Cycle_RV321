`timescale 1ns / 1ps

module Load_Unit (
    input  wire [31:0] Read_Data,   // 32-bit word from Data Memory
    input  wire [31:0] ALU_Result,
    input  wire [2:0]  funct3,       // Instruction[14:12]
    output reg  [31:0] load_data     // Data to write back to regfile
);
    wire [1:0] addr_lsb;
    reg [7:0]  byte_data;
    reg [15:0] half_data;
    assign addr_lsb  = ALU_Result[1:0];
    always @(*) begin
        // defaults
        byte_data = 8'b0;
        half_data = 16'b0;
        load_data = 32'b0;

        // select byte
        case (addr_lsb)
            2'b00: byte_data = Read_Data[7:0];
            2'b01: byte_data = Read_Data[15:8];
            2'b10: byte_data = Read_Data[23:16];
            2'b11: byte_data = Read_Data[31:24];
        endcase

        // select halfword
        case (addr_lsb[1])
            1'b0: half_data = Read_Data[15:0];
            1'b1: half_data = Read_Data[31:16];
        endcase

        // load type decode
        case (funct3)
            3'b000: load_data = {{24{byte_data[7]}}, byte_data};   // LB
            3'b001: load_data = {{16{half_data[15]}}, half_data}; // LH
            3'b010: load_data = Read_Data;                         // LW
            3'b100: load_data = {24'b0, byte_data};                // LBU
            3'b101: load_data = {16'b0, half_data};                // LHU
            default: load_data = Read_Data;
        endcase
    end

endmodule
