
module apb_slave #(
    parameter NUM_REGS    = 8,
    parameter WAIT_CYCLES = 2
)(
    input  wire        PCLK,
    input  wire        PRESETn,

    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,

    output reg  [31:0] PRDATA,
    output reg         PREADY,
    output reg         PSLVERR
);

    reg [31:0] mem [0:NUM_REGS-1];
    reg [1:0] state,next_state;

    localparam IDLE   = 2'd0;
    localparam SETUP  = 2'd1;
    localparam ACCESS = 2'd2;
    reg [3:0] wait_cnt;
wire [4:0] addr;
assign addr = PADDR[6:2];

    wire valid_addr;

    assign valid_addr = (addr < NUM_REGS);

    integer i;
    always @(posedge PCLK or negedge PRESETn)
    begin
        if(!PRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*)
    begin
        next_state = state;

        case(state)

            IDLE:
            begin
                if(PSEL)
                    next_state = SETUP;
            end
            SETUP:
            begin
                if(PSEL && PENABLE)
                    next_state = ACCESS;
            end

            ACCESS:
            begin
                if(PREADY && PSEL)
                    next_state = SETUP;   // continuous transfer

                else if(PREADY && !PSEL)
                    next_state = IDLE;    // no transfer

                else
                    next_state = ACCESS;  // wait state
            end

        endcase
    end
  
    always @(posedge PCLK or negedge PRESETn)
    begin
        if(!PRESETn)
        begin
            PREADY   <= 0;
            PSLVERR  <= 0;
            PRDATA   <= 0;
            wait_cnt <= 0;

            for(i=0;i<NUM_REGS;i=i+1)
                mem[i] <= 0;
        end
        else
        begin

            case(state)
                IDLE:
                begin
                    PREADY   <= 0;
                    PSLVERR  <= 0;
                    wait_cnt <= 0;
                end
                SETUP:
                begin
                    PREADY   <= 0;
                    PSLVERR  <= 0;
                    wait_cnt <= 0;
                end

                ACCESS:
                begin

                    if(wait_cnt < WAIT_CYCLES)
                    begin
                        wait_cnt <= wait_cnt + 1;
                        PREADY   <= 0;
                    end
                    else
                    begin

                        PREADY <= 1;

                        if(!valid_addr)
                        begin
                            PSLVERR <= 1;
                        end

                        else if(PWRITE)
                        begin
                            mem[addr] <= PWDATA;
                        end

                        else
                        begin
                            PRDATA <= mem[addr];
                        end

                    end

                end

            endcase
        end
    end

endmodule

