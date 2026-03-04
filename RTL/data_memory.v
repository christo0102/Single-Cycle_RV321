`timescale 1ns / 1ps

module Data_Memory #(parameter DEPTH = 256)(
    input  wire        clk,
    input  wire        MemWrite,
    input  wire [2:0]  funct3,
    input  wire [9:0] ALU_Result,
    input  wire [31:0] Write_Data,
    output wire [31:0] Read_Data
);

    reg [31:0] mem [0:DEPTH-1];
    reg [31:0] mem_wdata;
    reg [3:0]  mem_be;

    wire [1:0] addr_lsb;
    wire [7:0] word_addr;

    assign addr_lsb  = ALU_Result[1:0];
    assign word_addr = ALU_Result[9:2];
    assign Read_Data = mem[word_addr];

    always @(*) begin
        mem_be    = 4'b0000;
        mem_wdata = mem[word_addr];

        case (funct3)
            3'b000: begin
                case (addr_lsb)
                    2'b00: begin mem_be = 4'b0001; mem_wdata[7:0]   = Write_Data[7:0]; end
                    2'b01: begin mem_be = 4'b0010; mem_wdata[15:8]  = Write_Data[7:0]; end
                    2'b10: begin mem_be = 4'b0100; mem_wdata[23:16] = Write_Data[7:0]; end
                    2'b11: begin mem_be = 4'b1000; mem_wdata[31:24] = Write_Data[7:0]; end
                endcase
            end

            3'b001: begin
                case (addr_lsb[1])
                    1'b0: begin mem_be = 4'b0011; mem_wdata[15:0]  = Write_Data[15:0]; end
                    1'b1: begin mem_be = 4'b1100; mem_wdata[31:16] = Write_Data[15:0]; end
                endcase
            end

            3'b010: begin
                mem_be    = 4'b1111;
                mem_wdata = Write_Data;
            end
        endcase
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            if (mem_be[0]) mem[word_addr][7:0]   <= mem_wdata[7:0];
            if (mem_be[1]) mem[word_addr][15:8]  <= mem_wdata[15:8];
            if (mem_be[2]) mem[word_addr][23:16] <= mem_wdata[23:16];
            if (mem_be[3]) mem[word_addr][31:24] <= mem_wdata[31:24];
        end
    end

endmodule
