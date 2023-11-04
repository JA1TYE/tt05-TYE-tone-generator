`default_nettype none

module tt_um_ja1tye_sound_generator (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset;
    assign reset = ~rst_n;

    //Bidir pins aren't used
    assign uio_oe = 8'b00000000;
    assign uio_out[7:0] = 8'h0;
    assign uo_out[7:3] = 5'h0;

    wire i2s_bclk_out;
    wire i2s_ws_out;
    wire i2s_d_out;
    wire spi_cs_in;
    wire spi_mosi_in;
    wire spi_sclk_in;

    assign uo_out[0] = i2s_bclk_out;
    assign uo_out[1] = i2s_ws_out;
    assign uo_out[2] = i2s_d_out;
    
    assign spi_cs_in = ui_in[0];//RP2040 SPI1 CS
    assign spi_sclk_in = ui_in[1];//RP2040 SPI1 SCLK
    assign spi_mosi_in = ui_in[2];//RP2040 SPI1 TX


    //Instantiate tone engine
    tone_engine tg(
        .clk_in(clk),.reset_in(reset),
        .i2s_bclk_out(i2s_bclk_out),.i2s_ws_out(i2s_ws_out),.i2s_d_out(i2s_d_out),
        .spi_cs_in(spi_cs_in),.spi_mosi_in(spi_mosi_in),.spi_sclk_in(spi_sclk_in)
        );


endmodule
