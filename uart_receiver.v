`timescale 1ns / 1ps

module uart_receiver(
input wire clk,
input wire reset_n,

input baud_tick,
input wire rx,

output reg rx_done,
output wire [7:0] dout
);
localparam [1:0] idle_st  = 2'b00;    
localparam [1:0] start_st = 2'b01;
localparam [1:0] data_st  = 2'b11;
localparam [1:0] stop_st  = 2'b10;      
    
    reg [1:0] current_state;
    reg [1:0] next_state;
    reg [3:0] b_reg;        // 波特率/过采样计数器
    reg [3:0] b_next;
    reg [2:0] count_reg;    // 数据位计数器
    reg [2:0] count_next;
    reg [7:0] data_reg;     // 数据寄存器
    reg [7:0] data_next;
    
    always @(posedge clk or negedge reset_n) begin          // 状态转换
        if(!reset_n) begin
            current_state <= idle_st;
            b_reg <= 0;
            count_reg <= 0;
            data_reg <= 0;
        end else begin
            current_state <= next_state;
            b_reg <= b_next;
            count_reg <= count_next;
            data_reg <= data_next;
        end
    end   
    
    always @(*) begin
        next_state = current_state;     // 默认情况下不改变状态
        b_next = b_reg;
        count_next = count_reg;
        data_next = data_reg;
        rx_done = 1'b0;         // 默认情况下，接收没有完成
        
        case (current_state)
            idle_st : begin     // 空闲
                if(~rx) begin          // 低电平表示起始位
                    next_state = start_st;
                    b_next = 0;
                end
            end
            start_st : begin    // 起始位
                if(baud_tick) begin
                    if(b_reg == 7) begin
                        next_state = data_st;
                        b_next = 0;
                        count_next = 0;
                    end else begin
                        b_next = b_reg + 1'b1;
                    end
                end
            end
            data_st : begin     // 数据位
                if(baud_tick) begin
                    if(b_reg == 15) begin
                        b_next = 0;
                        data_next = {rx, data_reg[7:1]};
                        if(count_next == 7) begin
                            next_state = stop_st;
                        end else begin
                            count_next = count_reg + 1'b1;
                        end
                    end else begin
                        b_next = b_reg + 1;
                    end
                end
            end
            stop_st : begin     // 结束位
                if(baud_tick) begin
                    if(b_reg == 15) begin
                        next_state = idle_st;
                        rx_done = 1'b1;
                    end else begin
                        b_next = b_reg + 1;
                    end
                end
            end
        endcase
    end
    
    assign dout = data_reg;
    
endmodule
