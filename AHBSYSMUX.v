`timescale 1ns / 1ps

module AHBSYSMUX(
input wire HCLK,
input wire HRESETn,

input wire [2:0] MUX_SEL,

input wire [31:0] HRDATA_S0,        // SRAM
input wire [31:0] HRDATA_S1,        // LED
input wire [31:0] HRDATA_S2,        // UART
input wire [31:0] HRDATA_S3,        // GPIO
input wire [31:0] HRDATA_S4,        // 
input wire [31:0] HRDATA_S5,        // 
input wire [31:0] HRDATA_S6,        // 
input wire [31:0] HRDATA_NO_MAP,    // no map

input wire HREADYOUT_S0,
input wire HREADYOUT_S1,
input wire HREADYOUT_S2,
input wire HREADYOUT_S3,
input wire HREADYOUT_S4,
input wire HREADYOUT_S5,
input wire HREADYOUT_S6,
input wire HREADYOUT_NO_MAP,

output reg HREADY,
output reg [31:0] HRDATA
);
    
    reg [2:0] MUX_SEL_tmp;
    
    always @(posedge HCLK or negedge HRESETn) begin
        if(!HRESETn) begin
            MUX_SEL_tmp <= 3'b111;
        end
        else if(HREADY) begin
            MUX_SEL_tmp <= MUX_SEL;
        end
    end
    
    always @(*) begin
        case(MUX_SEL_tmp)
            3'b000 : begin
                HREADY <= HREADYOUT_S0;
                HRDATA <= HRDATA_S0;
            end
            3'b001 : begin
                HREADY <= HREADYOUT_S1;
                HRDATA <= HRDATA_S1;
            end
            3'b010 : begin
                HREADY <= HREADYOUT_S2;
                HRDATA <= HRDATA_S2;
            end
            3'b011 : begin
                HREADY <= HREADYOUT_S3;
                HRDATA <= HRDATA_S3;
            end
            3'b100 : begin
                HREADY <= HREADYOUT_S4;
                HRDATA <= HRDATA_S4;
            end
            3'b101 : begin
                HREADY <= HREADYOUT_S5;
                HRDATA <= HRDATA_S5;
            end   
            3'b110 : begin
                HREADY <= HREADYOUT_S6;
                HRDATA <= HRDATA_S6;
            end                                                      
            3'b111 : begin
                HREADY <= HREADYOUT_NO_MAP;
                HRDATA <= HRDATA_NO_MAP;
            end                                    
        endcase
    end
    
endmodule
