module sample_counter (
    input wire reset_in,
    input wire clk_in,
    input wire [9:0]master_count_in,
    input wire [15:0]data_in,
    input wire [3:0]addr_in,
    input wire data_valid_in,
    output wire [15:0]data_out,
    output reg data_valid_out
);

    //DDS Phase accumulator
    reg [15:0] phase_acc;
    reg [15:0] phase_incr;

    assign data_out = phase_acc[15:0];

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            phase_acc <= 16'h0;
            phase_incr <= 16'h0;
            data_valid_out <= 1'b0;
        end
        else begin
            if(master_count_in == 10'h0)begin
                phase_acc <= phase_acc + phase_incr;
                data_valid_out <= 1'b1;
            end
            else begin
                data_valid_out <= 1'b0;
            end

            if(data_valid_in == 1'b1)begin
                phase_incr <= data_in[15:0];
            end
        end
    end
endmodule
