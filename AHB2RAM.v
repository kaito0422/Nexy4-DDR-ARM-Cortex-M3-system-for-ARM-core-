`timescale 1ns / 1ps

module AHB2RAM
   #(parameter MEMWIDTH = 15)               // Size = 32KB
   (
   input wire           HSEL,
   input wire           HCLK,
   input wire           HRESETn,
   input wire           HREADY,
   input wire    [31:0] HADDR,
   input wire     [1:0] HTRANS,
   input wire           HWRITE,
   input wire     [2:0] HSIZE,
   input wire    [31:0] HWDATA,
   output wire          HREADYOUT,
   output wire    [31:0] HRDATA
   );

   assign HREADYOUT = 1'b1; // Always ready

   // Memory Array
   reg  [31:0] memory[0:(2**(MEMWIDTH-2)-1)];

   // Registers to store Adress Phase Signals
   reg  [31:0] hwdata_mask;
   reg         we;
   reg  [31:0] buf_hwaddr;
    
    // kaito part
    reg [31:0] HRDATA_tmp;
    reg HSEL_tmp;
    always @(posedge HCLK) begin
        /* #10 */ HSEL_tmp <= HSEL;
    end
    assign HRDATA = HRDATA_tmp;
/*    
    reg HWRITE_tmp;
    always @(posedge HCLK) begin
        if(HREADY) begin
            HSEL_tmp <= HSEL;
            HWRITE_tmp <= HWRITE;
        end
    end
    assign HRDATA = HSEL_tmp ? HRDATA_tmp : 32'hzzzz_zzzz;
*/    
   // Sample the Address Phase   
   always @(posedge HCLK or negedge HRESETn)
   begin
      if(!HRESETn)
      begin
         we <= 1'b0;
         buf_hwaddr <= 32'h0;
      end
      else
         if(HREADY)
         begin
            we <= HSEL & HWRITE & HTRANS[1];
            buf_hwaddr <= HADDR;
   
            casez (HSIZE[1:0])
               2'b1?: hwdata_mask <=  32'hFFFFFFFF;                        // Word write
               2'b01: hwdata_mask <= (32'h0000FFFF << (16 * HADDR[1]));    // Halfword write
               2'b00: hwdata_mask <= (32'h000000FF << (8 * HADDR[1:0]));   // Byte write
            endcase
          end
   end
   
   // Read and Write Memory
   always @ (posedge HCLK)
   begin
      if(we)
         memory[buf_hwaddr[MEMWIDTH:2]] <= (HWDATA & hwdata_mask) | (HRDATA & ~hwdata_mask);
      HRDATA_tmp = memory[HADDR[MEMWIDTH:2]];
   end
   
//    always @(*) begin
//       HRDATA_tmp <= memory[HADDR[MEMWIDTH:2]];
//    end

endmodule