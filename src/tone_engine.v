module tone_engine
(
    input          wire reset_in,
    input          wire clk_in,
    output         wire i2s_bclk_out,
    output         wire i2s_ws_out,
    output         wire i2s_d_out,
    input   wire       spi_cs_in,
    input   wire       spi_mosi_in,
    input   wire       spi_sclk_in
);

    wire[9:0] master_count;
    
    //Master Counter
    master_counter MASTER_CNT(reset_in,clk_in,master_count);

    //spi_slave
    wire [7:0] slave_data_out;
    wire slave_data_valid_out;
    wire slave_transaction_valid_out;
    spi_slave SPI_SLAVE(
            .reset_in(reset_in),.clk_in(clk_in),
            .spi_sclk_in(spi_sclk_in),.spi_cs_in(spi_cs_in),.spi_mosi_in(spi_mosi_in),
            .data_out(slave_data_out),.data_valid_out(slave_data_valid_out),
            .transaction_valid_out(slave_transaction_valid_out)
    );

    //spi_decoder
    wire [15:0] decoder_data_out;
    wire [3:0] decoder_addr_out;
    wire decoder_data_valid_out;
    spi_decoder SPI_DEC(
            .reset_in(reset_in),.clk_in(clk_in),
            .data_in(slave_data_out),.data_valid_in(slave_data_valid_out),
            .transaction_valid_in(slave_transaction_valid_out),
            .data_out(decoder_data_out),.addr_out(decoder_addr_out),.data_valid_out(decoder_data_valid_out)
    );


    //Sample Counter
    wire[15:0] sound_data;
    wire sample_data_valid_out;
    sample_counter SAMPLE_CNT(
            .reset_in(reset_in),.clk_in(clk_in),
            .master_count_in(master_count),
            .data_in(decoder_data_out),.addr_in(decoder_addr_out),.data_valid_in(decoder_data_valid_out),
            .data_out(sound_data),.data_valid_out(sample_data_valid_out)
    );

    //I2S Tx
    i2s_out I2S_TX(
            .reset_in(reset_in),.clk_in(clk_in),
            .master_count_in(master_count),
            .data_in(sound_data),
            .data_valid_in(sample_data_valid_out),
            .d_out(i2s_d_out),.ws_out(i2s_ws_out),.bclk_out(i2s_bclk_out)
    );

endmodule
