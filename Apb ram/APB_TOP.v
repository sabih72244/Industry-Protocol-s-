
module apb_top(

    input clk,
    input reset,

    input transfer,
    input write,
    input [31:0] addr,
    input [31:0] wdata,

    output [31:0] rdata,
    output error
);
    wire [31:0] paddr;
    wire        psel;
    wire        penable;
    wire        pwrite;
    wire [31:0] pwdata;

    wire [31:0] prdata;
    wire        pready;
    wire        pslaverr;

    apb_master master_inst(
        .clk(clk),
        .reset(reset),

        .transfer(transfer),
        .write(write),
        .addr(addr),
        .wdata(wdata),

        .prdata(prdata),
        .pready(pready),
        .pslaverr(pslaverr),

        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),

        .rdata(rdata),
        .error(error)
    );

    apb_slave slave_inst(
        .PCLK(clk),
        .PRESETn(reset),

        .PADDR(paddr),
        .PSEL(psel),
        .PENABLE(penable),
        .PWRITE(pwrite),
        .PWDATA(pwdata),

        .PRDATA(prdata),
        .PREADY(pready),
        .PSLVERR(pslaverr)
    );

endmodule
