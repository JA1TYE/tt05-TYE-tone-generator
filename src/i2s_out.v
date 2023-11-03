`default_nettype none
module i2s_out 
(
    input   wire reset_in,
    input   wire clk_in,
    input   wire [9:0]master_count_in,
    input   wire [15:0] data_in,
    input   wire data_valid_in,
    output  wire d_out,
    output  wire ws_out,
    output  wire bclk_out   
);
    reg[15:0]                   buffer_reg;
    reg                         buffer_valid;
    reg[15:0]                   shift_reg;

    assign d_out = shift_reg[15];
    assign bclk_out = master_count_in[4];//32fs
    assign ws_out = master_count_in[9];//1024fs

    wire[4:0]   bclk_counter;
    wire[4:0]   ws_counter;

    assign bclk_counter = master_count_in[4:0];
    assign ws_counter = master_count_in[9:5];

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            buffer_reg <= 32'h0;
            buffer_valid <= 1'b0;
            shift_reg <= 32'h0;
        end
        else begin
            if(bclk_counter == 5'h1f)begin
                if(ws_counter == 0)begin
                    if(buffer_valid == 1'b1)begin
                        shift_reg <= buffer_reg;
                        buffer_valid <= 1'b0;
                    end
                    else begin
                        shift_reg <= 16'h0;
                    end
                end
                else begin
                    shift_reg <= {shift_reg[14:0],shift_reg[15]};
                end
            end    

            if(data_valid_in == 1'b1)begin
                buffer_reg <= data_in;
                buffer_valid <= 1'b1;
            end
        end
    end

endmodule
