`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 11:55:53 PM
// Design Name: 
// Module Name: apb_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_ram#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)
(
    input                       PCLK,
    input                       PRESETn,

    // APB Signals
    input                       PSEL,
    input                       PENABLE,
    input                       PWRITE,
    input  [ADDR_WIDTH-1:0]     PADDR,
    input  [DATA_WIDTH-1:0]     PWDATA,

    output reg [DATA_WIDTH-1:0] PRDATA,
    output reg                  PREADY,
    output reg                  PSLVERR
);

    // Internal RAM
    reg [DATA_WIDTH-1:0] RAM [0:DEPTH-1];

    integer i;

    always @(posedge PCLK or negedge PRESETn)
    begin
        if(!PRESETn)
        begin
            PRDATA  <= 0;
            PREADY  <= 0;
            PSLVERR <= 0;

            for(i=0;i<DEPTH;i=i+1)
                RAM[i] <= 0;
        end

        else
        begin
            // Default Values
            PREADY  <= 0;
            PSLVERR <= 0;

            //-------------------------
            // APB ACCESS PHASE
            //-------------------------
            if(PSEL && PENABLE)
            begin
                PREADY <= 1;

                // Address Check
                if(PADDR >= DEPTH)
                begin
                    PSLVERR <= 1;
                end

                else
                begin

                    //-----------------
                    // WRITE Operation
                    //-----------------
                    if(PWRITE)
                    begin
                        RAM[PADDR] <= PWDATA;

                        $display(
                        "[WRITE] Time=%0t Address=%d Data=%h",
                        $time,PADDR,PWDATA);
                    end

                    //-----------------
                    // READ Operation
                    //-----------------
                    else
                    begin
                        PRDATA <= RAM[PADDR];

                        $display(
                        "[READ] Time=%0t Address=%d Data=%h",
                        $time,PADDR,RAM[PADDR]);
                    end
                end
            end
        end
    end

endmodule