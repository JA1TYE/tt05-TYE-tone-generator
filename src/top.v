`default_nettype none

module tt_um_ja1tye_sound_generator (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset;
    assign reset = ~rst_n;

    // use bidirectionals as inputs
    assign uio_oe = 8'b00001000;
    assign uio_out[7:4] = 4'h0;
    assign uio_out[2:0] = 3'h0;

    wire i2s_bclk_out;
    wire i2s_ws_out;
    wire i2s_d_out;
    wire spi_cs_in;
    wire spi_mosi_in;
    wire spi_miso_out;
    wire spi_sclk_in;

    assign uo_out[0] = i2s_bclk_out;
    assign uo_out[1] = i2s_ws_out;
    assign uo_out[2] = i2s_d_out;
    
    assign uio_in[0] = spi_cs_in;
    assign uio_in[1] = spi_mosi_in;
    assign uio_in[2] = spi_sclk_in;
    assign uio_out[3] = spi_miso_out;

    //Instantiate tone engine
    tone_engine tg(
        .clk_in(clk),.reset_in(reset),
        .i2s_bclk_out(i2s_bclk_out),.i2s_ws_out(i2s_ws_out),.i2s_d_out(i2s_d_out),
        .spi_cs_in(spi_cs_in),.spi_mosi_in(spi_mosi_in),.spi_miso_out(spi_miso_out),.spi_sclk_in(spi_sclk_in)
        );


endmodule