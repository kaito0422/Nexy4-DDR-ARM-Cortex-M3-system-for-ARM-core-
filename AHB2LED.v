`timescale 1ns / 1ps

module AHB2LED(
input wire HCLK,
input wire HRESETn,

input wire HSEL,
input wire HREADY,
input wire HWRITE,
input wire [31:0] HADDR,
input wire [31:0] HWDATA,
output wire HREADYOUT,
output wire [15:0] LED_OUT
);
    assign HREADYOUT = 1'b1; // Always ready
    
    reg [15:0] LED;
    
    assign LED_OUT = LED;
    
    reg HSEL_tmp;
    reg [31:0] HADDR_tmp;
    reg HWRITE_tmp;
    
    always @(posedge HCLK or negedge HRESETn) begin
        if(!HRESETn) begin
            HADDR_tmp <= 32'h0000_0000;
            HWRITE_tmp <= 1'b0;
            HSEL_tmp <= 1'b0;
        end else if(HREADY) begin
            HADDR_tmp <= HADDR;
            HWRITE_tmp <= HWRITE;      
            HSEL_tmp <= HSEL;      
        end
    end
    
    always @(posedge HCLK) begin
        if(HWRITE_tmp & HSEL_tmp)
            LED = HWDATA[15:0];
//        HRDATA = {(32-8)'h000000, LED[7:0]};
    end
    
endmodule
