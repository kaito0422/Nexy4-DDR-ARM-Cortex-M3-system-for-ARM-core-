`timescale 1ns / 1ps

module AHBSYSPART(
input wire HCLK,
input wire HRESETn,

input wire [31:0] HADDRS,
input wire HWRITES,
input wire [1:0] HTRANSS,
input wire [2:0] HSIZES,
input wire [31:0] HWDATAS,
output wire [31:0] HRDATAS,
output wire HREADYS,

inout wire [31:0] GPIO,
output wire [15:0] LED,
input wire  uart_rx,
output wire uart_tx,

output wire uart_int
);
    
    wire HSEL_RAM;
    wire [31:0] HRDATA_RAM;
    wire HREADYOUT_RAM;
    wire HSEL_LED;
    wire [31:0] HRDATA_LED;
    wire HREADYOUT_LED;
    wire HSEL_GPIO;
    wire [31:0] HRDATA_GPIO;
    wire HREADYOUT_GPIO;
    wire HSEL_UART;
    wire [31:0] HRDATA_UART;
    wire HREADYOUT_UART;    
    wire HSEL_NO_MAP;
    wire [31:0] HRDATA_NO_MAP;
    wire HREADYOUT_NO_MAP;
    
    wire [2:0] MUX_SEL;
    
    AHBSYSDCD u_AHBSYSDCD(
    .HADDR (HADDRS),
    .HSEL_S0 (HSEL_RAM),        // SRAM
    .HSEL_S1 (HSEL_LED),        // LED
    .HSEL_S2 (HSEL_UART),        // UART
    .HSEL_S3 (HSEL_GPIO),        // GPIO
    .HSEL_S4 (),
    .HSEL_S5 (),
    .HSEL_S6 (),
    .HSEL_NO_MAP (HSEL_NO_MAP),    // no map
    .MUX_SEL (MUX_SEL)
    );
    
    AHBSYSMUX u_AHBSYSMUX(
    .HCLK (HCLK),
    .HRESETn (HRESETn),
    
    .MUX_SEL (MUX_SEL),
    
    .HRDATA_S0 (HRDATA_RAM),        // SRAM
    .HRDATA_S1 (HRDATA_LED),        // LED
    .HRDATA_S2 (HRDATA_UART),        // UART
    .HRDATA_S3 (HRDATA_GPIO),        // GPIO
    .HRDATA_S4 (),
    .HRDATA_S5 (),
    .HRDATA_S6 (),
    .HRDATA_NO_MAP (HRDATA_NO_MAP),    // no map
    
    .HREADYOUT_S0 (HREADYOUT_RAM),
    .HREADYOUT_S1 (HREADYOUT_LED),
    .HREADYOUT_S2 (HREADYOUT_UART),
    .HREADYOUT_S3 (HREADYOUT_GPIO),
    .HREADYOUT_S4 (),
    .HREADYOUT_S5 (),
    .HREADYOUT_S6 (),
    .HREADYOUT_NO_MAP (HREADYOUT_NO_MAP),
    
    .HREADY (HREADYS),
    .HRDATA (HRDATAS)
    );
    
    /* RAM */
    AHB2RAM u_AHB2RAM(
    .HSEL (HSEL_RAM),
    .HCLK (HCLK),
    .HRESETn (HRESETn),
    .HREADY (HREADYS),
    .HADDR (HADDRS),
    .HTRANS (HTRANSS),
    .HWRITE (HWRITES),
    .HSIZE (HSIZES),
    .HWDATA (HWDATAS),
    .HREADYOUT (HREADYOUT_RAM),
    .HRDATA (HRDATA_RAM)
    );
    
    /* LED */
    AHB2LED u_AHB2LED(
    .HCLK (HCLK),
    .HRESETn (HRESETn),
    
    .HSEL (HSEL_LED),
    .HREADY (HREADYS),
    .HWRITE (HWRITES),
    .HADDR (HADDRS),
    .HWDATA (HWDATAS),
    .HREADYOUT (HREADYOUT_LED),
    .LED_OUT (LED)
    );
    
    /* UART */
    AHB2UART u_AHB2UART(
    .HCLK (HCLK),
    .HRESETn (HRESETn),
    
    .HADDR (HADDRS),
    .HTRANS (HTRANSS),
    .HWDATA (HWDATAS),
    .HWRITE (HWRITES),
    .HREADY (HREADYS),
    
    .HREADYOUT (HREADYOUT_UART),
    .HRDATA (HRDATA_UART),
    
    .HSEL (HSEL_UART),
    
    .RsRx (uart_rx),
    .RsTx (uart_tx),
    
    .uart_irq (uart_int)
    );    
    
    /* GPIO */
    AHB2GPIO u_AHB2GPIO(
    .HCLK (HCLK),
    .HRESETn (HRESETn),
    .HSEL (HSEL_GPIO),
    
    .HADDR (HADDRS),
    .HREADY (HREADYS),
    .HWRITE (HWRITES),
    .HWDATA (HWDATAS),
    .HRDATA (HRDATA_GPIO),
    .HREADYOUT (HREADYOUT_GPIO),
    
    .gpio_io (GPIO)
    );
    
    /* NO MAP */
    AHB_Slave_no_map u_AHB_Slave_no_map(
    .HCLK (HCLK),
    .HRESETn (HRESETn),
    .HSEL (HSEL_NO_MAP),
    .HADDR (HADDRS),
    .HWRITE (HWRITES),
    .HWDATA (HWDATAS),
    .HRDATA (HRDATA_NO_MAP),
    .HREADYOUT (HREADYOUT_NO_MAP)
    );
    
endmodule
