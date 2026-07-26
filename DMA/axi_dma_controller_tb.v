`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2026 01:34:57 AM
// Design Name: 
// Module Name: axi_dma_controller_tb
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


module axi_dma_controller_tb;

    // Parameters
    parameter int ADDR_WD = 32;
    parameter int DATA_WD = 32;
    parameter int CHANNEL_COUNT = 8;
    parameter int MAX_BURST_LEN = 16;
    localparam int STRB_WD = DATA_WD / 8;

    // Clock and Reset
    logic clk;
    logic rst;

    // DMA Command
    logic                 cmd_valid;
    logic [ADDR_WD-1:0]   cmd_src_addr;
    logic [ADDR_WD-1:0]   cmd_dst_addr;
    logic [1:0]           cmd_burst;
    logic [ADDR_WD-1:0]   cmd_len;
    logic [2:0]           cmd_size;
    wire                  cmd_ready;

    // AXI Master Interfaces
    wire                  M_AXI_ARVALID;
    wire  [ADDR_WD-1:0]   M_AXI_ARADDR;
    wire  [7:0]           M_AXI_ARLEN;
    wire  [2:0]           M_AXI_ARSIZE;
    wire  [1:0]           M_AXI_ARBURST;
    logic                 M_AXI_ARREADY;

    logic                 M_AXI_RVALID;
    logic [DATA_WD-1:0]   M_AXI_RDATA;
    logic [1:0]           M_AXI_RRESP;
    logic                 M_AXI_RLAST;
    wire                  M_AXI_RREADY;

    wire                  M_AXI_AWVALID;
    wire  [ADDR_WD-1:0]   M_AXI_AWADDR;
    wire  [7:0]           M_AXI_AWLEN;
    wire  [2:0]           M_AXI_AWSIZE;
    wire  [1:0]           M_AXI_AWBURST;
    logic                 M_AXI_AWREADY;

    wire                  M_AXI_WVALID;
    wire  [DATA_WD-1:0]   M_AXI_WDATA;
    wire  [STRB_WD-1:0]   M_AXI_WSTRB;
    wire                  M_AXI_WLAST;
    logic                 M_AXI_WREADY;

    logic                 M_AXI_BVALID;
    logic [1:0]           M_AXI_BRESP;
    wire                  M_AXI_BREADY;

    // Instantiate the Device Under Test (DUT)
    // Note: Ensure your dmac_read, dmac_buffer, and dmac_write are compiled alongside this.
    axi_dma_controller #(
        .ADDR_WD(ADDR_WD),
        .DATA_WD(DATA_WD),
        .CHANNEL_COUNT(CHANNEL_COUNT),
        .MAX_BURST_LEN(MAX_BURST_LEN)
    ) dut (.*);

    // Clock Generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD Dumping for Waveform Viewer
    initial begin
        $dumpfile("axi_dma_waveform.vcd");
        $dumpvars(0, tb_axi_dma_controller);
    end

    // Main Test Sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        cmd_valid = 0;
        cmd_src_addr = 0;
        cmd_dst_addr = 0;
        cmd_burst = 0;
        cmd_len = 0;
        cmd_size = 0;
        
        M_AXI_ARREADY = 0;
        M_AXI_RVALID  = 0;
        M_AXI_RDATA   = 0;
        M_AXI_RRESP   = 0;
        M_AXI_RLAST   = 0;
        
        M_AXI_AWREADY = 0;
        M_AXI_WREADY  = 0;
        M_AXI_BVALID  = 0;
        M_AXI_BRESP   = 0;

        // Apply Reset
        #20 rst = 0;
        #10;

        // Issue DMA Command (e.g., Transfer 2 beats of 32-bit data)
        @(posedge clk);
        cmd_valid    <= 1;
        cmd_src_addr <= 32'h1000_0000;
        cmd_dst_addr <= 32'h2000_0000;
        cmd_burst    <= 2'b01; // INCR
        cmd_len      <= 1;     // 2 beats (Length = beats - 1)
        cmd_size     <= 3'b010; // 4 bytes per beat

        // Wait for DUT to accept command
        wait(cmd_ready == 1'b1);
        @(posedge clk);
        cmd_valid <= 0;

        // Wait enough time for the automated AXI responders (below) to finish
        #500;
        $display("Simulation Complete.");
        $finish;
    end

    // ==========================================
    // Automated AXI Slave Responders
    // ==========================================

    // 1. Mock AXI Read Address Channel
    always @(posedge clk) begin
        if (M_AXI_ARVALID && !M_AXI_ARREADY) begin
            M_AXI_ARREADY <= 1; // Accept address
        end else begin
            M_AXI_ARREADY <= 0;
        end
    end

    // 2. Mock AXI Read Data Channel
    always @(posedge clk) begin
        if (M_AXI_ARVALID && M_AXI_ARREADY) begin
            // Wait a cycle then send data
            @(posedge clk);
            M_AXI_RVALID <= 1;
            M_AXI_RDATA  <= 32'hAAAA_1111; // Beat 1
            M_AXI_RLAST  <= 0;
            wait(M_AXI_RREADY);
            
            @(posedge clk);
            M_AXI_RVALID <= 1;
            M_AXI_RDATA  <= 32'hBBBB_2222; // Beat 2 (Last)
            M_AXI_RLAST  <= 1;
            wait(M_AXI_RREADY);

            @(posedge clk);
            M_AXI_RVALID <= 0;
            M_AXI_RLAST  <= 0;
        end
    end

    // 3. Mock AXI Write Address Channel
    always @(posedge clk) begin
        if (M_AXI_AWVALID && !M_AXI_AWREADY) begin
            M_AXI_AWREADY <= 1; // Accept write address
        end else begin
            M_AXI_AWREADY <= 0;
        end
    end

    // 4. Mock AXI Write Data Channel
    always @(posedge clk) begin
        if (M_AXI_WVALID && !M_AXI_WREADY) begin
            M_AXI_WREADY <= 1; // Accept write data
        end else begin
            M_AXI_WREADY <= 0;
        end
    end

    // 5. Mock AXI Write Response Channel
    always @(posedge clk) begin
        if (M_AXI_WVALID && M_AXI_WREADY && M_AXI_WLAST) begin
            // Send response after last beat
            @(posedge clk);
            M_AXI_BVALID <= 1;
            M_AXI_BRESP  <= 2'b00; // OKAY
            wait(M_AXI_BREADY);
            
            @(posedge clk);
            M_AXI_BVALID <= 0;
        end
    end

endmodule