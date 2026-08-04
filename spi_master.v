/*
Author: Esther George Fayez Abdo
Module: spi_master
Modelling: RTL
Date: 3/8/2026

*/
module spi_master #(
parameter DATA_WIDTH = 10 ,
parameter MODE = 2'b00 ,
parameter CLK_DIV    = 2 , //clock divider (optional)
parameter MSB_FIRST  = 1  //msb first in being transmitted
)
(
input clk ,
input rst_n , //active_low rst
input start ,
input MISO , //master-in slave-out tristate buffer
input[DATA_WIDTH-1:0] tx_data , //transmitted data

output     MOSI , //master-out
output reg SCLK ,
output reg cs_n , //active_low
output reg [DATA_WIDTH-1:0] rx_data , //recieved data
output reg busy ,
output reg done

);

/////////////////////LOCAL PARAMETERS FOR FSM//////////////////////////////

localparam IDLE     = 2'd0;
localparam LOAD     = 2'd1;
localparam TRANSFER = 2'd2;
localparam FINISH   = 2'd3;

                 //////////////////////////////////////////////////////////////////////////
                       /********************INTERNAL SIGNALS*********************/

wire cpol = MODE[1];  //CPOL : clk polarity --> rising edge , falling edge
wire cpha = MODE[0];  //CPHA : clk phase -->  leading (first edge) , trailing (2nd edge)
reg [DATA_WIDTH-1:0] tx_shift;
reg [DATA_WIDTH-1:0] rx_shift;

reg [$clog2(DATA_WIDTH)-1:0] bit_count;  //clog2 calculates bits needed to count the bits transferred counts 0 to 31

reg [1:0] state; //stores current state in FSM
reg [7:0] clk_counter; //optional for clk divider

              // update mosi when tx_shift changes
assign MOSI = (MSB_FIRST)? tx_shift[DATA_WIDTH-1] : tx_shift[0];

always @(posedge clk or negedge rst_n) begin

if (!rst_n) begin

state  <= IDLE ;
busy <= 1'b0;
done <= 1'b0;
SCLK <= cpol;  //ensuring sclk is at the correct fsm idle level
cs_n <= 1'b1;
clk_counter <= 8'b0;
tx_shift <=0;
rx_shift <=0;
rx_data <=0;
bit_count   <= 0;
//clk_counter <= 0; //optional
end

else begin
case(state)

    IDLE:
    begin
busy <= 1'b0;
done <= 1'b0;
SCLK <= cpol; 
cs_n <= 1'b1;
// start must be asserted for one clk cycle
if (start) begin
 state <= LOAD; 
end
    end


    LOAD:
    begin
tx_shift <= tx_data;
rx_shift <= 0;
bit_count   <= 0;
busy <= 1'b1; //don't transmit any data yet until i finish loading
done <= 1'b0;
cs_n <= 1'b0;
  clk_counter <= 8'b0;

state <= TRANSFER;
    end

//////////////////////////TRANSFER///////////////////////////////

    TRANSFER:
    begin

busy <= 1'b1; //ensure busy flag is raised --> in transfer no data should be loaded


 //clock divider
if (clk_counter == CLK_DIV -1) begin
  clk_counter <= 8'b0;
  SCLK <= ~SCLK;



         //transferring data --> RISING EDGE
     if(SCLK==1'b0) begin


          //takes first 9 bits and concats with miso as lsb and shift left
            if(MSB_FIRST) begin
                rx_shift <= {rx_shift[DATA_WIDTH-2:0], MISO};
                          end
            else begin
                    //shift right and miso msb

                rx_shift <= {MISO , rx_shift[DATA_WIDTH-1:1]};
                          end
      end
     else begin //FALLING EDGE --> SCLK==1

            if (bit_count == DATA_WIDTH-1) begin

                state <= FINISH;
                          end
            else begin  //continue transmitting

                if (MSB_FIRST) begin
                      tx_shift <= tx_shift << 1;
                                end
                else begin //LSB first
                      tx_shift <= tx_shift >> 1;
                                end

            bit_count <= bit_count +1'b1; //increment counter

                  end
           end
  end 


     //increment clk_counter 
    else begin
       clk_counter <= clk_counter + 1;
          end
end

    FINISH:
    begin
 busy <= 1'b0;
done<= 1'b1;
cs_n <=1;
SCLK <=cpol;
rx_data <= rx_shift;
state <= IDLE;
    end

default: state <= IDLE;
endcase
end

end

endmodule
