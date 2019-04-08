`timescale 1ns / 1ps

module AHB_Slave_no_map(
input wire HCLK,
input wire HRESETn,
input wire HSEL,
input wire [31:0] HADDR,
input wire HWRITE,
input wire [31:0] HWDATA,
output wire [31:0] HRDATA,
output wire HREADYOUT
);
    
    assign HREADYOUT = 1'b1;
    assign HRDATA = 32'hzzzz_zzzz;
    
endmodule
