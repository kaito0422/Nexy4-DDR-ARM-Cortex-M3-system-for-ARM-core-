`timescale 1ns / 1ps

module AHB2UART(
input wire HCLK,
input wire HRESETn,

input wire HSEL,

/* AHB总线接口 */
input wire [31:0] HADDR,
input wire [1:0] HTRANS,
input wire [31:0] HWDATA,
input wire HWRITE,
input wire HREADY,
output wire HREADYOUT,
output wire [31:0] HRDATA,

/* uart的传输信号线 */
input wire RsRx,
output wire RsTx,

/* uart产生的中断 */
output wire uart_irq
);

    wire [7:0] uart_wdata;      // 获取通过AHB总线传入的要通过串口进行传输的数据
    wire [7:0] uart_rdata;      // 通过uart接收到的数据，准备通过AHB总线传给cpu
                                // 这两组线和AHB接口连
    
    wire uart_wr;       // 这两根线标记的是当前uart是否有读写发生（允许同时读写）
    wire uart_rd;
    
    wire [7:0] tx_data;     // 从fifo中获取一个字节后，通过tx传输出去
    wire [7:0] rx_data;     // 从外部rx获取一个字节后，传给fifo
    wire [7:0] status;      // uart的状态，empty和full（用来传给cpu）
    
    wire tx_full;       // 这4个信号用于表示两个fifo的empty/full情况
    wire tx_empty;
    wire rx_full;
    wire rx_empty;
    
    wire tx_done;   
    wire rx_done;
    
    wire b_tick;        // 波特率发生器产生的信号
    
    reg [1:0] last_HTRANS;
    reg [31:0] last_HADDR;
    reg last_HWRITE;
    reg last_HSEL;
    
    always @(posedge HCLK) begin
        if(HREADY) begin
            last_HTRANS <= HTRANS;
            last_HWRITE <= HWRITE;
            last_HSEL <= HSEL;
            last_HADDR <= HADDR;
        end
    end
    
    assign HREADYOUT = ~tx_full;        // 该信号表示向上游设备说明当前uart设备是否可用，当tx_full的时候，表示tx fifo满了，此时cpu不能向uart发送数据
    
    assign uart_wr = last_HTRANS[1] & last_HWRITE & last_HSEL & (last_HADDR[7:0] == 8'h00);
    
    assign uart_wdata = HWDATA[7:0];
    
    assign uart_rd = last_HTRANS[1] & ~last_HWRITE & last_HSEL & (last_HADDR[7:0] == 8'h00);
    
    assign HRDATA = (last_HADDR[7:0] == 8'h00) ? {24'h0000_00, uart_rdata}:{24'h0000_00, status};
    assign status = {6'b000000, tx_full, rx_empty};
    
    assign uart_irq = ~rx_empty;    // 用于表示receiver fifo是否是空的，如果不是则表示uart已经接收到数据，cpu可以来读取，于是就像cpu请求中断
    
    baud_generator u_baud_generator(        // 波特率发生器
    .clk (HCLK),
    .reset_n (HRESETn),
    .baud_tick (b_tick)
    );
    
    fifo #(.DWIDTH(8), .AWIDTH(4)) u_fifo_tx(   // uart的transfer FIFO
    .clk (HCLK),
    .reset_n (HRESETn),
    
    .rd (tx_done),
    .wr (uart_wr),
    .w_data (uart_wdata[7:0]),
    .r_data (tx_data[7:0]),
    
    .empty (tx_empty),
    .full (tx_full)
    );
    
    fifo #(.DWIDTH(8), .AWIDTH(4)) u_fifo_rx(   // uart的receiver FIFO
        .clk (HCLK),
        .reset_n (HRESETn),
        
        .rd (uart_rd),
        .wr (rx_done),
        .w_data (rx_data[7:0]),
        .r_data (uart_rdata[7:0]),
        
        .empty (rx_empty),
        .full (rx_full)
        );
        
    uart_receiver u_uart_receiver(  // uart接收器
        .clk (HCLK),
        .reset_n (HRESETn),
        
        .baud_tick (b_tick),
        .rx (RsRx),
        
        .rx_done (rx_done),
        .dout (rx_data[7:0])
        ); 
    
    uart_transfer u_uart_transfer(  //  uart发送器
        .clk (HCLK),
        .reset_n (HRESETn),
        
        .tx_start (!tx_empty),
        .b_tick (b_tick),
        .d_in (tx_data[7:0]),
        
        .tx_done (tx_done),
        .tx (RsTx)
        );
    
endmodule
