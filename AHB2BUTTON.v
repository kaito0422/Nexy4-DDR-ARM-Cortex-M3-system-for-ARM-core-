`timescale 1ns / 1ps

module AHB2BUTTON(
input wire HCLK,
input wire HRESETn,
input wire button_in,

output wire button_out,     // 外部按键的输入值
output reg button_tick
);
    
localparam st_idle   = 2'b00;
localparam st_wait1  = 2'b01;
localparam st_stable = 2'b10;
localparam st_wait0  = 2'b11;
    
    reg [1:0] current_state = st_idle;  // 当前状态
    reg [1:0] next_state = st_idle;     // 下一个状态
    
    reg [21:0] db_clk = {21{1'b1}};         // 这两个变量（reg）用于检查状态是否维持一段时间
    reg [21:0] db_clk_next = {21{1'b1}};
    
    always @(posedge HCLK or negedge HRESETn) begin // 处理系统的阶段
        if(!HRESETn) begin
            current_state <= st_idle;
            db_clk <= 0;
        end else begin                  // 正常情况下，把下一个状态传到当前状态，计数时钟也改变
            current_state <= next_state;
            db_clk <= db_clk_next;
        end
    end
    
    always @(*) begin
        next_state = current_state;     // 默认不改变系统状态，需要按当前状态和外部按键输入情况确定如何改变状态
        db_clk_next = db_clk;
        button_tick = 0;        // 还不知道是干嘛用的
        
        case (current_state)        // 根据当前状态，区分改变系统状态
            st_idle : begin     // 空闲
                if(button_in) begin   // 如果在空闲状态下有按键按下
                    db_clk_next = {21{1'b1}};       // 用于计数达到稳定需要的时间
                    next_state = st_wait1;      // 如果检查到按键按下，则改变状态，进入等待按键输入信号稳定的状态
                end
            end
            st_wait1 : begin    // 有按键按下，等待信号稳定
                if(button_in) begin
                    db_clk_next = db_clk - 1;
                    if(db_clk_next == 0) begin      // 确定达到稳定状态
                        next_state = st_stable;
                        button_tick = 1'b1;     // ?
                    end
                end
            end
            st_stable : begin   // 信号已经稳定
                if(~button_in) begin       // 当前在稳定的状态，检测到按键释放的操作
                    next_state = st_wait0;
                    db_clk_next = {21{1'b1}}; 
                end
            end
            st_wait0 : begin    // 确定按键是否真的释放
                if(~button_in) begin
                    db_clk_next = db_clk - 1;
                    if(db_clk_next == 0) begin      // 确定按键真的释放
                        next_state = st_idle;
                    end
                end else begin  // 之前检测到的按键释放是一个毛刺，应该忽略
                    next_state = st_stable;
                end
            end
        endcase
    end
    
    assign button_out = (current_state == st_stable || current_state == st_wait0) ? 1'b1 : 1'b0;
    
endmodule
