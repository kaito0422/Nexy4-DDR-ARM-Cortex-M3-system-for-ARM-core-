`timescale 1ns / 1ps

module uart_transfer(
input wire clk,
input wire reset_n,

input wire tx_start,
input wire b_tick,
input wire [7:0] d_in,

output reg tx_done,
output wire tx 
);
    
    localparam [1:0] idle_st = 2'b00;
    localparam [1:0] start_st = 2'b01;
    localparam [1:0] data_st = 2'b11;
    localparam [1:0] stop_st = 2'b10;
    
    reg [1:0] current_state;
    reg [1:0] next_state;
    reg [3:0] b_reg;
    reg [3:0] b_next;
    reg [2:0] count_reg;
    reg [2:0] count_next;
    reg [7:0] data_reg;
    reg [7:0] data_next;
    reg tx_reg;
    reg tx_next;
    
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            current_state <= idle_st;
            b_reg <= 0;
            count_reg <= 0;
            data_reg <= 0;
            tx_reg <= 1'b1;
        end else begin
            current_state <= next_state;
            b_reg <= b_next;
            count_reg <= count_next;
            data_reg <= data_next;
            tx_reg <= tx_next;
        end
    end
    
    always @(*) begin
        next_state = current_state;
        tx_done = 1'b0;
        b_next = b_reg;
        count_next = count_reg;
        data_next = data_reg;
        tx_next = tx_reg;
        
        case (current_state)
            idle_st : begin
                tx_next = 1'b1;
                if(tx_start) begin
                    next_state = start_st;
                    b_next = 0;
                    data_next = d_in;
                end
            end
            start_st : begin
                tx_next = 1'b0;
                if(b_tick) begin
                    if(b_reg == 15) begin
                        next_state = data_st;
                        b_next = 0;
                        count_next = 0;
                    end else begin 
                        b_next = b_reg + 1;
                    end
                end
            end
            data_st : begin
                tx_next = data_reg[0];
                if(b_tick) begin
                    if(b_reg == 15) begin
                        b_next = 0;
                        data_next = data_reg >> 1;
                        if(count_reg == 7) begin
                            next_state = stop_st;
                        end else begin
                            count_next = count_reg + 1;
                        end 
                    end else begin
                        b_next = b_reg + 1;
                    end 
                end
            end
            stop_st : begin
                tx_next = 1'b1;
                if(b_tick) begin
                    if(b_reg == 15) begin
                        next_state = idle_st;
                        tx_done = 1'b1;
                    end else begin
                        b_next = b_reg + 1;
                    end
                end
            end
        endcase
    end
    
    assign tx = tx_reg;
    
endmodule
