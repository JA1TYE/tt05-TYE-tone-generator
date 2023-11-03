module spi_decoder(
    input   wire       reset_in,
    input   wire       clk_in,
    input   wire[7:0]  data_in,
    input   wire       data_valid_in,
    input   wire       transaction_valid_in,
    output  reg[15:0]  data_out,
    output  reg[3:0]   addr_out,
    output  reg       data_valid_out
);

    reg[1:0] rx_counter;

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            rx_counter <= 2'h0;
            data_valid_out <= 1'b0;
        end
        else begin
            if(transaction_valid_in == 1'b0)begin
                rx_counter <= 2'h0;
            end
            
            if(data_valid_in == 1'b1)begin
                rx_counter <= (rx_counter == 2'h2)?2'h0:rx_counter + 2'h1;
                if(rx_counter == 2'h0)begin
                    addr_out <= data_in[3:0];
                end
                else if(rx_counter == 2'h1)begin
                    data_out <= {data_in,8'h0};
                end
                else begin
                    data_out <= {data_out[15:8],data_in};
                    data_valid_out <= 1'b1;
                end
            end
            else begin
                data_valid_out <= 1'b0;
            end
        end
    end

endmodule
