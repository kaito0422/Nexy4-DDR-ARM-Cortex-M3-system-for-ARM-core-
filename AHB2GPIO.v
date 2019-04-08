`timescale 1ns / 1ps
/**********************************************************************
GPIO 对外给出的接口
    1. 写方向寄存器（0x40008000）
    2. 写输出数据寄存器（0x40008004）
    3. 读输出数据寄存器（0x40008008）
**********************************************************************/
module AHB2GPIO(
input wire HCLK,
input wire HRESETn,
input wire HSEL,

input wire [31:0] HADDR,
input wire HREADY,
input wire HWRITE,
input wire [31:0] HWDATA,
output reg [31:0] HRDATA,
output wire HREADYOUT,

inout wire [31:0] gpio_io
);
    assign HREADYOUT = 1'b1;

    wire [31:0] io_in;
    reg [31:0] io_out;
    reg [31:0] io_dir;
    reg [31:0] io;
    
    integer i;
    reg [31:0] HADDR_tmp;
    reg HSEL_tmp;
    reg HWRITE_tmp;
    
    assign gpio_io = io;
    
    always @(*) begin
        for(i = 0; i < 32; i = i + 1) begin
            io[i] <= (io_dir[i] == 0) ? 1'bz : io_out[i];
        end
    end
    
    always @(posedge HCLK or negedge HRESETn) begin
        if(!HRESETn) begin
            HADDR_tmp <= 32'h0;
            HSEL_tmp <= 1'b0;
            HWRITE_tmp <= 1'b0;           
        end else begin
            HADDR_tmp <= HADDR;
            HSEL_tmp <= HSEL;
            HWRITE_tmp <= HWRITE;
        end
    end
    
    always @(posedge HCLK) begin   // posedge HCLK
        if(HSEL_tmp == 1) begin // 选中
            if(HWRITE_tmp == 1) begin   // 写操作
                case (HADDR_tmp[3:0])
                    4'h0 : begin
                        io_dir <= HWDATA;
                    end
                    4'h4 : begin
                        io_out <= HWDATA;
                    end
                    4'h8 : begin
                        /* do nothing */
                    end
                endcase
            end else begin      // 读操作
                case (HADDR_tmp[3:0])
                    4'h0 : begin
                        HRDATA <= io_dir;
                    end
                    4'h4 : begin
                        HRDATA <= io_out;
                    end
                    4'h8 : begin
                        HRDATA <= io;
                    end
                endcase
            end
        end
    end
    
endmodule

