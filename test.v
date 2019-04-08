`timescale 1ns / 1ps

module test;
    reg CLK;
    reg RESET;
    wire [31:0] GPIO;
    wire [15:0] LED;
    
    ARM_SOC Inst_arm_soc(
    .CLK (CLK),
    .RESET (RESET),
    .GPIO (GPIO),
    .LED (LED)
    );
    
    initial begin
        CLK = 0;
        RESET = 1;
        #50;
        RESET = 0;
        #100
        RESET = 1;
    end
    
    always begin
        CLK = ~CLK;
        #5;
    end
    
endmodule
