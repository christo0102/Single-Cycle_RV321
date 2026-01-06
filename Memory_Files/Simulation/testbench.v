`timescale 1ns / 1ps

module tb_RISC_V_Single_Cycle;

    reg clk;
    reg reset;

    RISC_V_Single_Cycle dut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
    end
    always #5 clk = ~clk; // Period = 10ns

    initial begin
        reset = 1;
        #20;
        reset = 0;
        #8000; 
        
        $finish;
    end

endmodule
