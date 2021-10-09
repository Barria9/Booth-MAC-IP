`ifndef OPERAND_WIDTH
  `define OPERAND_WIDTH 16
`endif
`ifndef ADDR_WIDTH
  `define ADDR_WIDTH 32
`endif
`ifndef DATA_WIDTH
  `define DATA_WIDTH 32
`endif



module top (
  input                               clk,
  input                               rst_n,
  //output    [`DATA_WIDTH-1:0]       mem [0:1],
 

  //output reg  [2*`OPERAND_WIDTH-1:0]  m,
  output reg                          booth_ready,
  input                               pwrite,
  input                               psel,
  input                               penable,
  input       [`ADDR_WIDTH-1:0]       paddr,
  
  input       [`DATA_WIDTH-1:0]       pwdata,
  
  output reg  [`DATA_WIDTH-1:0]       prdata,
 
  output reg                          pready,
  output reg                          slave_err

   );  
 
   
   reg                            booth_en;
   
   wire    [`DATA_WIDTH-1:0]       mem_wire [0:255];
   wire    [`DATA_WIDTH-1:0]       m;
          
   
   
   assign en = pwrite & pready;
 
    always @(posedge clk, negedge rst_n)
  begin
    if (~rst_n) 
    begin
      booth_en      <= 0;
    end
    else if (booth_ready )
    begin
      booth_en      <= 0;
    end
    else if (en && paddr!= 255)
    begin
      booth_en      <= 1;
    end
    else
    begin
      booth_en      <= booth_en;
    end			
  end


  
   booth multiplier (
    .clk(clk),
    .rst_n (rst_n),
    //.a([`DATA_WIDTH-1:`DATA_WIDTH/2 ] mem[paddr]),
    .a( mem_wire[paddr][31:16 ]),
    //.b([`DATA_WIDTH/2 -1:0] mem[paddr] ),
    .b( mem_wire[paddr][15:0]),
    .en(booth_en),
    .ready (booth_ready),
    .m( m)
  );

  apb slave (
   .clk(clk),
   .rst_n(rst_n),
   .pwdata(pwdata),
   .slave_err(slave_err),
   .ready(pready),
   .paddr(paddr),
   .prdata(prdata),
   .psel(psel),
   .penable(penable),
   .pwrite(pwrite),
   .mem(mem_wire),
   .m(m),
   .booth_ready(booth_ready)
  );

endmodule    
   
   
     
