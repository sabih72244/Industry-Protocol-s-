`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 11:57:14 PM
// Design Name: 
// Module Name: apb_ram_tb
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


module apb_ram_tb;
reg         PCLK;
reg         PRESETn;
reg         PSEL;
reg         PENABLE;
reg         PWRITE;
reg [3:0]   PADDR;
reg [7:0]   PWDATA;

wire [7:0]  PRDATA;
wire        PREADY;
wire        PSLVERR;

apb_ram DUT(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
);

// Clock Generation
always #5 PCLK = ~PCLK;


//---------------------
// Write Task
//---------------------
task apb_write;
input [3:0] addr;
input [7:0] data;
begin

    @(posedge PCLK);
    PSEL    = 1;
    PENABLE = 0;
    PWRITE  = 1;
    PADDR   = addr;
    PWDATA  = data;

    @(posedge PCLK);
    PENABLE = 1;

    @(posedge PCLK);
    PSEL    = 0;
    PENABLE = 0;

end
endtask


//---------------------
// Read Task
//---------------------
task apb_read;
input [3:0] addr;
begin

    @(posedge PCLK);
    PSEL    = 1;
    PENABLE = 0;
    PWRITE  = 0;
    PADDR   = addr;

    @(posedge PCLK);
    PENABLE = 1;

    @(posedge PCLK);

    $display("--------------------------------");
    $display("Address = %d",addr);
    $display("Read Data = %h",PRDATA);
    $display("--------------------------------");

    PSEL    = 0;
    PENABLE = 0;

end
endtask


initial
begin

    PCLK     = 0;
    PRESETn  = 0;
    PSEL     = 0;
    PENABLE  = 0;
    PWRITE   = 0;
    PADDR    = 0;
    PWDATA   = 0;

    //---------------------
    // Reset
    //---------------------
    #20;
    PRESETn = 1;

    //---------------------
    // Write Operations
    //---------------------
    apb_write(4'd1,8'hAA);
    apb_write(4'd2,8'hBB);
    apb_write(4'd3,8'hCC);
    apb_write(4'd4,8'hDD);

    //---------------------
    // Read Operations
    //---------------------
    apb_read(4'd1);
    apb_read(4'd2);
    apb_read(4'd3);
    apb_read(4'd4);

    //---------------------
    // Invalid Access
    //---------------------
    @(posedge PCLK);
    PSEL    = 1;
    PENABLE = 1;
    PWRITE  = 0;
    PADDR   = 4'd15;

    #10;

    $display("PSLVERR = %b",PSLVERR);

    #50;
    $finish;

end


initial
begin
    $monitor(
    "TIME=%0t PSEL=%b PENABLE=%b PWRITE=%b ADDR=%d WDATA=%h RDATA=%h PREADY=%b",
    $time,PSEL,PENABLE,PWRITE,PADDR,PWDATA,PRDATA,PREADY);
end
endmodule
