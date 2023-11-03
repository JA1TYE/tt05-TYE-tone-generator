`default_nettype none
module master_counter
(
    input   wire    reset_in,
    input   wire    clk_in,
    output  reg     [9:0]count_out   
);

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            count_out <= 10'h0;
        end
        else begin
            count_out <= (count_out==10'h3ff)?10'h0:count_out + 10'h1;
        end
    end


endmodule
