`timescale 1ns / 1ps

module fifo #(parameter DWIDTH = 8, AWIDTH = 1)(
input wire clk,
input wire reset_n,

input wire rd,
input wire wr,
input wire [7:0] w_data,

output wire empty,
output wire full,
output wire [7:0] r_data
);

    reg [DWIDTH - 1:0] array_reg [2**AWIDTH - 1:0];     // 定义2^AWIDTH个寄存器，每个寄存器为DWIDTH位，用于保存FIFO中的每一个字节
    reg [AWIDTH - 1:0] w_ptr_reg;       // 当前处理的是FIFO中的哪一个字节
    reg [AWIDTH - 1:0] w_ptr_next;      // 下一个处理的是FIFO中的哪一个字节
    reg [AWIDTH - 1:0] w_ptr_succ;      // 用于临时保存指针下一个要指向的位置 
    reg [AWIDTH - 1:0] r_ptr_reg;
    reg [AWIDTH - 1:0] r_ptr_next;
    reg [AWIDTH - 1:0] r_ptr_succ;    
    
    reg full_reg;       // 保存的是FIFO是否满的信息
    reg empty_reg;      // 保存的是FIFO是否空的信息
    reg full_next;
    reg empty_next;
    
    wire w_en;
    
    assign w_en = wr & ~full_reg;   // 写信号，且FIFO没有满（对FIFO进行写操作的条件）
    assign full = full_reg;
    assign empty = empty_reg;
    
    always @(posedge clk) begin
        if(w_en) begin              // 如果当前可以执行写操作，则把写数据写入FIFO的寄存器中
            array_reg[w_ptr_reg] <= w_data;  // w_ptr_reg指向的是当前FIFO中空的
        end
    end
    
    assign r_data = array_reg[r_ptr_reg];
    
    always @(posedge clk or negedge reset_n) begin      // 状态/阶段转换
        if(!reset_n) begin      // 让各类表示状态的寄存器清零
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;            
        end
    end
    
    always @(*) begin
        w_ptr_succ = w_ptr_reg + 1;     // 该处每一个阶段，w_ptr_reg不一定改变。当该值加到头之后会自动变为0
        r_ptr_succ = r_ptr_reg + 1;
    
        w_ptr_next = w_ptr_reg;     // 默认情况下，不改变状态，除非有读写操作发生了
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;
        
        case ({w_en, rd})
            2'b01 :  begin      // 不写，有读操作
                if(~empty_reg) begin
                    r_ptr_next = r_ptr_succ;
                    full_next = 1'b0;
                    if(r_ptr_succ == w_ptr_reg) begin       // 读操作的指针指向写操作的时候，表示写还没来得及写，所以一次的读操作还不能进行
                        empty_next = 1'b1;
                    end
                end
            end
            2'b10 :  begin      // 写操作，不读
                if(~full_reg) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if(w_ptr_succ == r_ptr_reg) begin       // 写操作的指针指向读操作的时候，表示下次下操作会把之前还没读走的数据覆盖掉，所以下次不能写
                        full_next = 1'b1;
                    end
                end
            end
            2'b11 :  begin      // 即写，又读
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;
            end                        
        endcase
    end

endmodule
