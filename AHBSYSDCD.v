`timescale 1ns / 1ps

module AHBSYSDCD(
input wire [31:0] HADDR,
output wire HSEL_S0,        // SRAM
output wire HSEL_S1,        // LED
output wire HSEL_S2,        // UART
output wire HSEL_S3,        // GPIO
output wire HSEL_S4,
output wire HSEL_S5,
output wire HSEL_S6,
output wire HSEL_NO_MAP,    // no map
output reg [2:0] MUX_SEL
);
    
    reg [7:0] dec;
    
    assign HSEL_S0 = dec[0];
    assign HSEL_S1 = dec[1];
    assign HSEL_S2 = dec[2];
    assign HSEL_S3 = dec[3];
    assign HSEL_S4 = dec[4];
    assign HSEL_S5 = dec[5];
    assign HSEL_S6 = dec[6];    
    assign HSEL_NO_MAP = dec[7];
    
    always @(*) begin
        if((HADDR[31:0] >= 32'h2000_0000) & (HADDR[31:0] < 32'h2000_8000)) begin        // SRAM的空间为0x2000_0000 ~ 0x2000_8000
            dec <= 8'b0000_0001;
            MUX_SEL <= 3'b000; 
        end
        else if(HADDR[31:0] == 32'h4000_0000) begin             // LED的地址范围是0x4000_0000
            dec <= 8'b0000_0010;
            MUX_SEL <= 3'b001; 
        end
        else if(HADDR[31:12] == 20'h4000_5) begin               // UART的地址范围是0x4000_5000 ~ 0x4000_5***
            dec <= 8'b0000_0100;
            MUX_SEL <= 3'b010;
        end
        else if(HADDR[31:12] == 20'h4000_8) begin               // GPIO的地址范围0x4000_8000 ~ 0x4000_8008
            dec <= 8'b0000_1000;
            MUX_SEL <= 3'b011; 
        end        
        else begin      // 什么也没选中
            dec <= 8'b1000_0000;
            MUX_SEL <= 3'b111;
        end
    end
    
endmodule
