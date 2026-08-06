`timescale 1ns/1ps

module SPI_top_connections #(
    parameter DATA_WIDTH = 10,
    parameter MASTER_CLK_DIV = 2,
    parameter MEM_DEPTH = 256,
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH_SLAVE = 8
)(
    input  wire                     clk,
    input  wire                     rst_n,      // active-low reset for master and slave
    input  wire                     start,      // start pulse for master (1 clk cycle)
    input  wire [DATA_WIDTH-1:0]    tx_data,    // master transmit frame (MSB-first)
    output wire [DATA_WIDTH-1:0]    rx_data,    // master received frame
    output wire                     busy,       // master's busy flag
    output wire                     done,       // master's done pulse (1 cycle)

    // SPI pins (exposed)
    output wire                     MOSI,
    input  wire                     MISO,       // optional external MISO; if unused tie low
    output wire                     SCLK,
    output wire                     CS_n
);

    // Internal nets to connect master <-> slave
    wire master_MOSI;
    wire master_MISO;   // source for master's MISO input (driven by slave)
    wire master_SCLK;
    wire master_CS_n;
    wire [DATA_WIDTH-1:0] master_rx;
    wire master_busy;
    wire master_done;

    // Instantiate spi_master
    spi_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_DIV(MASTER_CLK_DIV)
    ) master_u (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .MISO(master_MISO),
        .tx_data(tx_data),
        .MOSI(master_MOSI),
        .SCLK(master_SCLK),
        .cs_n(master_CS_n),
        .rx_data(master_rx),
        .busy(master_busy),
        .done(master_done)
    );

    // Instantiate wrapper_slave (internal loopback slave)
    wrapper_slave #(
        .mem_depth(MEM_DEPTH),
        .addr_width(ADDR_WIDTH),
        .data_width(DATA_WIDTH_SLAVE)
    ) slave_u (
        .mosi(master_MOSI),
        .miso(master_MISO),
        .ss_n(master_CS_n),
        .clk(master_SCLK),
        .rstn(rst_n)
    );

    // Expose signals to top-level pins/ports
    assign MOSI = master_MOSI;
    // If you want to use an external device's MISO pin instead of the internal slave,
    // drive master_MISO from the external MISO input by commenting the slave instantiation
    // and replacing the assignment below:
    //
    // assign master_MISO = MISO;
    //
    // Currently we use the internal slave, so ignore external MISO input port.
    //
    // Expose internal slave-driven MISO on top-level MISO pin for observation (optional):
    assign SCLK = master_SCLK;
    assign CS_n = master_CS_n;

    // Expose master's outputs
    assign rx_data = master_rx;
    assign busy    = master_busy;
    assign done    = master_done;

endmodule