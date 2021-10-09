`ifndef ADDR_WIDTH
  `define ADDR_WIDTH 32
`endif
`ifndef DATA_WIDTH
  `define DATA_WIDTH 32
`endif

module apb (
  input                            clk,    // Clock
  input                            rst_n,  // Asynchronous reset active low
  input                            pwrite,
  input                            psel,
  input                            penable,
  input       [`ADDR_WIDTH-1:0]    paddr,
  input       [`DATA_WIDTH-1:0]    pwdata,
    
  input    reg 		           booth_ready,
  //input reg   [`DATA_WIDTH-1:0]    c,
  output reg  [`DATA_WIDTH-1:0]    prdata,
  //output reg  [`DATA_WIDTH-1:0]    m,
  output reg                       ready,
  input  reg  [`DATA_WIDTH-1:0]    m,                  
  //output reg  [`DATA_WIDTH-1:0]    mem [0:255] ,
  output reg                       slave_err
  );

  localparam  [1:0] IDLE       = 2'b00;
  localparam  [1:0] SETUP      = 2'b01;
  localparam  [1:0] READ_WRITE = 2'b10;
  //localparam  [1:0] RESULT     = 2'b11;

  reg  [1:0]            state_reg; // sequential 
  reg  [1:0]            next_state_reg; // combinational

  reg  [`DATA_WIDTH-1:0]    mem [0:255] ;
  
 
initial 
 begin
      integer i;
    
      for( i = 0; i<256; i = i + 1)
        begin
           mem [i] = 32'd0;
        end 
    
 end

 always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      //ready = 0;
      prdata <= 0;
    end
    else if (next_state_reg == READ_WRITE)
      begin
       if (pwrite == 1 )//&& paddr != 1)
        begin
          if ( paddr == 32'd255)
             begin
               mem[paddr] <= m;
             end
 	  
          else
            begin
            mem[paddr] <= pwdata;
            end
            //ready <= 1;
        end
       else 
         begin
             prdata <= mem[paddr];
             //ready <= 1;
         end
      end
      
  end
         


  // State Register Difinition
  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      ready = 0;
      state_reg <= IDLE;
      prdata = 0;
    end
    else
    begin
      state_reg <= next_state_reg;
    end
  end

  // Next State Logic Definition
  always @(*) 
  begin
    case (state_reg)
      IDLE :
       begin
      
         
       prdata = 0;
       ready = 0;
        if( psel == 1)
           begin
           next_state_reg = SETUP;
           end
        else
           begin
           next_state_reg = IDLE;
           end
        end

      SETUP :
      begin        
         
        if ( penable == 1) 
        begin
          next_state_reg = READ_WRITE;          
          
        end
       
        else if (!psel)          
         begin
          next_state_reg = IDLE;
         end
      end
     READ_WRITE :
      begin       
         next_state_reg = IDLE;
         ready = 1;    
            
            

       if (paddr > 32'h000000FF)
         begin
           slave_err = 1;
         end
       else 
         begin
          slave_err = 0;
         end
      end

      default :
      begin
        next_state_reg = IDLE;
        //prdata = 0;
        
         
      end
    endcase
  end

  
endmodule
