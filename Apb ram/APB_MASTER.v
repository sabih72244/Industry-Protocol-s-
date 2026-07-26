module apb_master(clk,reset,transfer,write,addr,wdata,prdata,pready,pslaverr,paddr,psel,penable,pwrite,pwdata,rdata,error);
  
  input clk,reset;
  
  //from bridge
  input transfer;
  input write;
  input [31:0]addr;
  input [31:0]wdata;
  
  //slave input
  input [31:0] prdata;
  input pready;
  input pslaverr;
  
  //master output 
  output reg [31:0]paddr;
  output reg psel,penable,pwrite;
  output reg [31:0]pwdata;
  
  output reg [31:0] rdata;
    output reg        error;
  
  reg [1:0]state,next_state;
  
  parameter idle=2'b00;
  parameter setup=2'b01;
  parameter access=2'b10;
  
  always @(posedge clk or negedge reset)
    begin
      if(!reset)
         state<=idle;
      else
        state<=next_state;
    end
  
  always @(*)
    begin
      next_state = state;
      case(state)
        idle:begin
          if(transfer)
            next_state = setup;
          else
            next_state = idle;
        end
        
        setup: next_state = access;
        
        access: begin
          if(pready && !transfer)
            next_state = idle;
          else if(pready  && transfer)
            next_state = setup;
          else
            next_state = access;
        end
        default: next_state = idle;
        endcase
    end
  
  always @(posedge clk or negedge reset)
    begin
      if(!reset)
        begin
          paddr<=32'd0;
          psel<=1'b0;
          penable<=1'b0;
          pwrite<=1'b0;
          pwdata<=32'd0;
          rdata   <= 32'd0;
            error   <= 1'b0;
        end
      else
        begin
          case(next_state)
            idle: begin
              psel<=1'b0;
              penable<=1'b0;
            end
            setup: begin
              paddr<=addr;
              pwrite<=write;
              pwdata<=wdata;
              penable<=1'b0;
              psel<=1'b1;
            end
            access: begin
              psel<=1'b1;
              penable<=1'b1;
              if(pready)
                    begin
                      if(!pwrite)
                            rdata <= prdata;

                        error <= pslaverr;
                    end
           
            end
          endcase
        end
    end
  
endmodule
