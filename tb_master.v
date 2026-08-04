`timescale 1ns/1ns

module tb_spi_master;

parameter DATA_WIDTH = 4;
parameter CLK_PERIOD = 10;

reg clk;
reg rst_n;
reg start;
reg [DATA_WIDTH-1:0] tx_data;

wire MOSI;
wire MISO;
wire SCLK;
wire cs_n;
wire busy;
wire done;
wire [DATA_WIDTH-1:0] rx_data;

// Loopback
assign MISO = MOSI;

//=========================================================
// DUT
//=========================================================

spi_master #(
    .DATA_WIDTH(DATA_WIDTH),
    .MODE(2'b00),
    .CLK_DIV(4),
    .MSB_FIRST(1)
) dut (

    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .MISO(MISO),
    .tx_data(tx_data),

    .MOSI(MOSI),
    .SCLK(SCLK),
    .cs_n(cs_n),
    .rx_data(rx_data),
    .busy(busy),
    .done(done)

);

//=========================================================
// Clock
//=========================================================

always #(CLK_PERIOD/2) clk = ~clk;

//=========================================================
// Count SCLK edges
//=========================================================

integer edge_count;

always @(posedge SCLK or negedge SCLK)
begin
    if(!cs_n)
        edge_count = edge_count + 1;
end

//=========================================================
// Task
//=========================================================

task spi_transfer;

input [DATA_WIDTH-1:0] data;

begin

    edge_count = 0;

    tx_data = data;

    @(posedge clk);
    start = 1;

    @(posedge clk);
    start = 0;

    wait(done);

    @(posedge clk);

    $display("--------------------------------------------");
    $display("TX DATA = %b",tx_data);
    $display("RX DATA = %b",rx_data);
    $display("SCLK EDGES = %0d",edge_count);

    if(rx_data == tx_data)
        $display("RESULT : PASS");
    else
        $display("RESULT : FAIL");

    if(edge_count == (2*DATA_WIDTH))
        $display("EDGE COUNT PASS");
    else
        $display("EDGE COUNT FAIL");

    $display("--------------------------------------------");

    repeat(3) @(posedge clk);

end

endtask

//=========================================================
// Stimulus
//=========================================================

initial
begin

    clk   = 0;
    rst_n = 0;
    start = 0;
    tx_data = 0;

    //---------------- Reset ----------------

    #(3*CLK_PERIOD);

    rst_n = 1;

    #(2*CLK_PERIOD);

    //---------------- Test 1 ----------------

    spi_transfer(10'b1011001011);

    //---------------- Test 2 ----------------

    spi_transfer(10'b0000000000);

    //---------------- Test 3 ----------------

    spi_transfer(10'b1111111111);

    //---------------- Test 4 ----------------

    spi_transfer(10'b1010101010);

    //---------------- Test 5 ----------------

    spi_transfer(10'b0101010101);

    //---------------- Test 6 ----------------

    spi_transfer(10'b1100110011);

    //---------------- Test 7 ----------------

    spi_transfer($random);

    //---------------- Reset during idle ----------------

    @(posedge clk);

    rst_n = 0;

    @(posedge clk);

    rst_n = 1;

    #(5*CLK_PERIOD);

    $display("=======================================");
    $display(" ALL TESTS FINISHED ");
    $display("=======================================");

    $stop;

end

//=========================================================
// Monitor
//=========================================================

initial
begin

$monitor(
"time=%0t  state=%0d  SCLK=%b  CS=%b  MOSI=%b  MISO=%b  bit=%0d  busy=%b  done=%b  clk_div=%0d  tx_shift=%b  rx_shift=%b",
$time,
dut.state,
SCLK,
cs_n,
MOSI,
MISO,
dut.bit_count,
busy,
done,
dut.clk_counter,
dut.tx_shift,
dut.rx_shift
);

end

endmodule