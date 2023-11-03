module spi_slave(
    input   wire       reset_in,
    input   wire       clk_in,
    input   wire       spi_sclk_in,
    input   wire       spi_cs_in,
    input   wire       spi_mosi_in,
    output  wire       spi_miso_out,
    input   wire[7:0]  data_in,
    input   wire       data_valid_in,
    output  wire[7:0]   data_out,
    output  reg        data_valid_out,
    output  wire       transaction_valid_out       
);

    assign spi_miso_out = tx_shift_reg[7];
    assign transaction_valid_out = ~async_cs[1];

    reg[1:0] async_cs;
    reg[1:0] async_mosi;
    reg[1:0] async_sclk;
    reg      sclk_edge;

    //2-FF Synchronizer
    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            async_cs <= 2'h3;
            async_mosi <= 2'h0;
            async_sclk <= 2'h0;
            sclk_edge <= 1'b0;
        end
        else begin
            async_cs[0] <= spi_cs_in;
            async_cs[1] <= async_cs[0];
            async_mosi[0] <= spi_mosi_in;
            async_mosi[1] <= async_mosi[0];
            async_sclk[0] <= spi_sclk_in;
            async_sclk[1] <= async_sclk[0];
            sclk_edge <= async_sclk[1];
        end
    end

    reg[7:0]    rx_shift_reg;
    reg[7:0]    rx_buf_reg;
    reg[2:0]    rx_count;

    assign data_out = rx_buf_reg;

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            rx_shift_reg <= 8'h0;
            rx_buf_reg <= 8'h0;
            rx_count <= 3'h0;
            data_valid_out <= 1'b0;
        end
        else begin
            if(data_valid_out == 1'b1)begin
                data_valid_out <= 1'b0;
            end
            if(async_cs[1] == 1'b1)begin
                rx_count <= 0;
            end
            else begin
                if(sclk_edge == 1'b0 && async_sclk[1] == 1'b1)begin
                    rx_shift_reg <= {rx_shift_reg[6:0],async_mosi[1]};
                    rx_count <= rx_count + 1;
                    if(rx_count == 7)begin
                        rx_buf_reg <= {rx_shift_reg[6:0],async_mosi[1]};
                        data_valid_out <= 1'b1;
                    end
                end
            end
        end
    end

    reg[7:0]    tx_shift_reg;
    reg[7:0]    tx_buf_reg;
    reg[2:0]    tx_count;

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            tx_shift_reg <= 8'h0;
            tx_buf_reg <= 8'h0;
            tx_count <= 3'h0;
        end
        else begin
            if(data_valid_in == 1'b1)begin
                tx_buf_reg <= data_in;
            end
            if(async_cs[1] == 1'b1)begin
                tx_count <= 0;
            end
            else begin
                if(sclk_edge == 1'b1 && async_sclk[1] == 1'b0)begin
                    if(tx_count == 7)begin
                        tx_shift_reg <= tx_buf_reg;
                    end
                    else begin
                        tx_shift_reg <= {tx_shift_reg[6:0],1'b0};
                    end
                    tx_count <= tx_count + 1;
                end
            end
        end
    end
endmodule
