`timescale 1ns / 1ps
/**********************************************************************
* ²¨ÌØÂÊÎª115200
**********************************************************************/
module baud_generator(
input wire clk,
input wire reset_n,
output wire baud_tick
);
/*    
    reg [9:0] tmp = 0;
    reg tick_change = 0;
    
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            tmp <= 0;
            tick_change <= 0;
        end else begin
            tmp = tmp + 1;
            if(tmp == 434) begin
                tmp <= 0;
                tick_change <= ~tick_change;
            end
        end
    end
    
    assign baud_tick = tick_change;
*/

    reg [21:0] count_reg;
    wire [21:0] count_next;
    
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            count_reg <= 0;
        end else begin
            count_reg <= count_next;
        end
    end
    
    assign count_next = ((count_reg == 26) ? 0 : count_reg + 1'b1);
    assign baud_tick = ((count_reg == 26) ? 1'b1 : 1'b0);
    
endmodule
