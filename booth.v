`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 16
`endif

module booth (
  input                               clk,    // Clock
  input                               rst_n,  // Asynchronous reset active low
  input                               en,

  input       [`OPERAND_WIDTH-1:0]    a,
  input       [`OPERAND_WIDTH-1:0]    b,

  //output reg  [2*`OPERAND_WIDTH-1:0]  c,
  output reg  [2*`OPERAND_WIDTH-1:0]  m,
  output reg                          ready
  );

  localparam  [2:0] START  = 3'b000;
  localparam  [2:0] ASSIGN = 3'b001;
  localparam  [2:0] COMP   = 3'b010;
  localparam  [2:0] ALU    = 3'b011;
  localparam  [2:0] SHIFT  = 3'b100;
  localparam  [2:0] RESULT = 3'b101;
  localparam  [2:0] MAC    = 3'b110;

  reg  [2*`OPERAND_WIDTH-1:0]  c;
  reg  [2*`OPERAND_WIDTH-1:0]  mac;
  reg  [2:0] state_reg; // sequential 
  reg  [2:0] next_state_reg; // combinational
  reg  [4:0] count_reg;
  reg        q ;
          

  reg  [2*`OPERAND_WIDTH:0]   mult;
  //reg  [`OPERAND_WIDTH-1:0]   AC;
   //reg                         msb;
  
  
  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      mult      <= 0;
      q         <= 0;
      mac       <= 0; 
      
    end
    else if ( state_reg == ASSIGN)
    begin
        //mult[2*`OPERAND_WIDTH :`OPERAND_WIDTH +1] <= AC;
        mult [`OPERAND_WIDTH :1] <= b;
        mult [0] <= q;
        
    end
   
    else if (state_reg == ALU)
    begin
          
     if(mult[0]==0)
          begin
            mult[2*`OPERAND_WIDTH :`OPERAND_WIDTH +1] <=  mult[2*`OPERAND_WIDTH :`OPERAND_WIDTH +1] - a;
          end
     else
          begin
            mult[2*`OPERAND_WIDTH :`OPERAND_WIDTH +1] <=  mult[2*`OPERAND_WIDTH :`OPERAND_WIDTH +1] + a;
	  end
          
    end
     else if (state_reg == SHIFT)
    begin
        
        mult <= {mult[2*`OPERAND_WIDTH],mult[2*`OPERAND_WIDTH:1]}; 
    end
    
    else if (state_reg == RESULT)
    begin
      //if (ready == 1)
        //begin
          mac <= mac + c;
        //*end
      /*else 
         begin
          mac <= mac;
         end*/
     end
    else
       begin
         mult      <= mult;
         mac <= mac;
       end
    end

  always @(posedge clk, negedge rst_n, posedge en)
  begin
    if (~rst_n) 
    begin
      count_reg <= `OPERAND_WIDTH  ;
      
    end
    else if (next_state_reg == START)
    begin
      count_reg <= `OPERAND_WIDTH  ;
    end
    else if (next_state_reg == SHIFT)
    begin
      count_reg <= count_reg -1;
    end

  end  


  // State Register Difinition
  always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      state_reg <= START;
      
    end
    else if (en)
    begin
      state_reg <= next_state_reg;
    end
  end

  // Next State Logic Definition
  always @(*) 
  begin
    case (state_reg)
      START:
      begin
        next_state_reg = ASSIGN;
        ready = 0;
        c = 0;
        //m = m;
        //count_reg = `OPERAND_WIDTH;
      end
      ASSIGN :
      begin
        next_state_reg = COMP;
        
        //count_reg = `OPERAND_WIDTH +1;
        ready = 0;
        c = 0;
        //m =0;
       
      end
      COMP :
      begin
        if ( (mult[0]^mult[1])==1)
           begin
            next_state_reg = ALU;
           end
        else
           begin
            next_state_reg = SHIFT; 
           end 
         ready = 0;
         c = 0;        
      end

      ALU :
      begin
         next_state_reg = SHIFT;
         
      end
      
      SHIFT :
      begin
        
        //count_reg = count_reg -1;
        if(count_reg==0)
         begin
           next_state_reg = RESULT;
          
         end
        else
         begin
       	  next_state_reg = COMP;
          c = 0;
          ready = 0;
          //m = 0;	
         end
       end

       RESULT :
        begin
           c = mult[2*`OPERAND_WIDTH : 1];
           
           next_state_reg = MAC;
           ready = 0;
           
        //end
      //MAC: 
       //begin
       end
     MAC: 
       begin
        ready = 1;
        m = mac;
          //m = 0;
         next_state_reg = START;
           
       end 
      
      
      
 
    

      default :
      begin
        next_state_reg = START;
        
        c = 0; 
        ready = 0;
         
      end
    endcase
  end

  
endmodule
