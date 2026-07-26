`timescale 1ns/1ps

module tb;

reg clk;
reg reset;

reg transfer;
reg write;
reg [31:0] addr;
reg [31:0] wdata;

wire [31:0] rdata;
wire error;

apb_top DUT (
    .clk(clk),
    .reset(reset),
    .transfer(transfer),
    .write(write),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .error(error)
);


//----------------------------------
// Clock
//----------------------------------
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


//----------------------------------
// Dump
//----------------------------------
initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0,tb);
end


//----------------------------------
// Monitor
//----------------------------------
initial begin
    $monitor(
    "T=%0t state=%0d next=%0d transfer=%b write=%b addr=%h paddr=%h wdata=%h pwdata=%h pready=%b rdata=%h",
    $time,
    DUT.master_inst.state,
    DUT.master_inst.next_state,
    transfer,
    write,
    addr,
    DUT.master_inst.paddr,
    wdata,
    DUT.master_inst.pwdata,
    DUT.master_inst.pready,
    rdata
    );
end

/* //======================write read back==============================
//----------------------------------
// Test
//----------------------------------
initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // WRITE 0xAAAA1111 -> addr 0
    //----------------------------------
    @(negedge clk);
    transfer = 1;
    write    = 1;
    addr     = 32'h00000000;
    wdata    = 32'hAAAA1111;

   
  @(posedge DUT.master_inst.pready);
@(negedge clk);

addr  = 32'h4;
wdata = 32'hBBBB2222;



    //----------------------------------
    // READ addr 0
    //----------------------------------
   
  @(posedge DUT.master_inst.pready);
@(negedge clk);

    write    = 0;
    addr     = 32'h00000000;


    $display("\nREAD ADDR0 = %h\n",rdata);

    //----------------------------------
    // READ addr 4
    //----------------------------------
   
  @(posedge DUT.master_inst.pready);
@(negedge clk);

    addr     = 32'h00000004;


    $display("\nREAD ADDR4 = %h\n",rdata);

    //----------------------------------
    // Stop transfers
    //----------------------------------
    @(negedge clk);
    transfer = 0;

    #50;

    //----------------------------------
    // Check memory directly
    //----------------------------------
    $display("mem[0] = %h", DUT.slave_inst.mem[0]);
    $display("mem[1] = %h", DUT.slave_inst.mem[1]);

    $finish;

end
*/
  
/*  //=========================address overwrite==============
  initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // WRITE #1
    //----------------------------------
    @(negedge clk);
    transfer = 1;
    write    = 1;
    addr     = 32'h00000000;
    wdata    = 32'hAAAA1111;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // WRITE #2 (Overwrite same address)
    //----------------------------------
    addr     = 32'h00000000;
    wdata    = 32'hBBBB2222;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // READ SAME ADDRESS
    //----------------------------------
    write    = 0;
    addr     = 32'h00000000;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // Display Result
    //----------------------------------
    $display("\n==============================");
    $display("OVERWRITE TEST");
    $display("==============================");
    $display("READ DATA = %h", rdata);
    $display("MEM[0]    = %h", DUT.slave_inst.mem[0]);

    //----------------------------------
    // PASS / FAIL
    //----------------------------------
    if(rdata == 32'hBBBB2222 &&
       DUT.slave_inst.mem[0] == 32'hBBBB2222)
    begin
        $display("TEST PASSED");
    end
    else
    begin
        $display("TEST FAILED");
    end

    //----------------------------------
    // Stop
    //----------------------------------
    transfer = 0;

    #50;
    $finish;

end

*/
  
/* //=======================invalid ddress=========
  initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // INVALID WRITE
    //----------------------------------
    @(negedge clk);

    transfer = 1;
    write    = 1;

    addr     = 32'h20;      // INVALID
    wdata    = 32'hDEADBEEF;

    //----------------------------------
    // Wait for completion
    //----------------------------------
    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // Display Results
    //----------------------------------
    $display("\n========================");
    $display("INVALID ADDRESS TEST");
    $display("========================");

    $display("ADDR       = %h", addr);
    $display("SLAVE ADDR = %0d", DUT.slave_inst.addr);
    $display("VALID_ADDR = %b", DUT.slave_inst.valid_addr);
    $display("PSLVERR    = %b", DUT.slave_inst.PSLVERR);
    $display("ERROR      = %b", error);

    //----------------------------------
    // PASS / FAIL
    //----------------------------------
    if(error == 1'b1)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    //----------------------------------
    // Stop
    //----------------------------------
    transfer = 0;

    #50;
    $finish;

end
*/
  
 /* //===================read before write(reset)===============
  initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // READ BEFORE WRITE
    //----------------------------------
    @(negedge clk);

    transfer = 1;
    write    = 0;
    addr     = 32'h00000000;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // Display
    //----------------------------------
    $display("\n========================");
    $display("READ BEFORE WRITE TEST");
    $display("========================");

    $display("PRDATA = %h",
             DUT.slave_inst.PRDATA);

    $display("RDATA  = %h",
             rdata);

    //----------------------------------
    // PASS / FAIL
    //----------------------------------
    if(rdata == 32'h00000000)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    //----------------------------------
    // Stop
    //----------------------------------
    transfer = 0;

    #50;
    $finish;

end
*/
  
/*  //==========================reset during transaction=================
  
  initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Release Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // Start Write Transaction
    //----------------------------------
    @(negedge clk);

    transfer = 1;
    write    = 1;
    addr     = 32'h00000000;
    wdata    = 32'hAAAAAAAA;

    //----------------------------------
    // Wait a little
    //----------------------------------
    #15;

    //----------------------------------
    // RESET in middle of transfer
    //----------------------------------
    reset = 0;

    #20;

    //----------------------------------
    // Check States
    //----------------------------------
    $display("\n========================");
    $display("RESET DURING TRANSFER");
    $display("========================");

    $display("MASTER STATE = %0d",
              DUT.master_inst.state);

    $display("SLAVE STATE  = %0d",
              DUT.slave_inst.state);

    $display("MEM[0]       = %h",
              DUT.slave_inst.mem[0]);

    //----------------------------------
    // PASS / FAIL
    //----------------------------------
    if(DUT.master_inst.state == 0 &&
       DUT.slave_inst.state  == 0)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    #50;
    $finish;

end
*/
  
/*  //=====================max address================================
  
  initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // WRITE TO LAST VALID ADDRESS
    //----------------------------------
    @(negedge clk);

    transfer = 1;
    write    = 1;
    addr     = 32'h0000001C;
    wdata    = 32'h12345678;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // READ FROM LAST VALID ADDRESS
    //----------------------------------
    write = 0;
    addr  = 32'h0000001C;

    @(posedge DUT.master_inst.pready);
    @(posedge clk);

    //----------------------------------
    // Display
    //----------------------------------
    $display("\n========================");
    $display("MAX ADDRESS TEST");
    $display("========================");

    $display("RDATA  = %h", rdata);
    $display("MEM[7] = %h", DUT.slave_inst.mem[7]);

    //----------------------------------
    // PASS / FAIL
    //----------------------------------
    if(rdata == 32'h12345678 &&
       DUT.slave_inst.mem[7] == 32'h12345678)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    transfer = 0;

    #50;
    $finish;

end
*/
  
  //=====================multiple address=========
  
  initial begin

    //----------------------------------
    // Init
    //----------------------------------
    reset    = 0;
    transfer = 0;
    write    = 0;
    addr     = 0;
    wdata    = 0;

    //----------------------------------
    // Reset
    //----------------------------------
    #20;
    reset = 1;

    //----------------------------------
    // WRITE #1
    //----------------------------------
    @(negedge clk);
    transfer = 1;
    write    = 1;
    addr     = 32'h00;
    wdata    = 32'h11111111;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // WRITE #2
    //----------------------------------
    addr  = 32'h04;
    wdata = 32'h22222222;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // WRITE #3
    //----------------------------------
    addr  = 32'h08;
    wdata = 32'h33333333;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);

    //----------------------------------
    // WRITE #4
    //----------------------------------
    addr  = 32'h0C;
    wdata = 32'h44444444;

    @(posedge DUT.master_inst.pready);
    @(negedge clk);
//----------------------------------
// READ #1
//----------------------------------
write = 0;
addr  = 32'h00;

@(posedge DUT.master_inst.pready);

// Prepare next transaction immediately
addr = 32'h04;

@(posedge clk);
$display("READ[0x00] = %h", rdata);


//----------------------------------
// READ #2
//----------------------------------
@(posedge DUT.master_inst.pready);

// Prepare next transaction immediately
addr = 32'h08;

@(posedge clk);
$display("READ[0x04] = %h", rdata);


//----------------------------------
// READ #3
//----------------------------------
@(posedge DUT.master_inst.pready);

// Prepare next transaction immediately
addr = 32'h0C;

@(posedge clk);
$display("READ[0x08] = %h", rdata);


//----------------------------------
// READ #4
//----------------------------------
@(posedge DUT.master_inst.pready);

@(posedge clk);
$display("READ[0x0C] = %h", rdata);

    //----------------------------------
    // Memory Check
    //----------------------------------
    $display("\nMEM[0] = %h", DUT.slave_inst.mem[0]);
    $display("MEM[1] = %h", DUT.slave_inst.mem[1]);
    $display("MEM[2] = %h", DUT.slave_inst.mem[2]);
    $display("MEM[3] = %h", DUT.slave_inst.mem[3]);

    //----------------------------------
    // PASS / FAIL
    //----------------------------------
    if(DUT.slave_inst.mem[0] == 32'h11111111 &&
       DUT.slave_inst.mem[1] == 32'h22222222 &&
       DUT.slave_inst.mem[2] == 32'h33333333 &&
       DUT.slave_inst.mem[3] == 32'h44444444)
    begin
        $display("\n******** TEST PASSED ********");
    end
    else
    begin
        $display("\n******** TEST FAILED ********");
    end

    //----------------------------------
    // Stop
    //----------------------------------
    @(negedge clk);
    transfer = 0;

    #50;
    $finish;

end
  
endmodule
