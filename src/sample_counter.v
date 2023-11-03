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
    reg [15:0] phase_acc[0:3];
    reg [15:0] phase_incr[0:3];
    reg [7:0]  volume[0:3];
    reg [15:0] mix_result;

    assign data_out = mix_result;

    wire [15:0] incr_out;
    assign incr_out = phase_incr[master_count_in[1:0]];

    wire [15:0] a_in;
    assign a_in = (master_count_in[2] == 1'b0)?incr_out:{acc_out[15],acc_out[15],acc_out[15:2]};

    wire [15:0] acc_out;
    assign acc_out = phase_acc[master_count_in[1:0]];

    wire [15:0] b_in;
    assign b_in = (master_count_in[2] == 1'b0)?acc_out:mix_result;

    reg sat_flag;
    wire [15:0]adder_out;

    sat_adder adder(.a_in(a_in),.b_in(b_in),.c_out(adder_out),.sat_en_in(sat_flag));

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            data_valid_out <= 1'b0;
            sat_flag <= 1'b0;
            mix_result <= 16'h0;

            phase_acc[0] <= 16'h0;
            phase_acc[1] <= 16'h0;
            phase_acc[2] <= 16'h0;
            phase_acc[3] <= 16'h0;

            phase_incr[0] <= 16'h0;
            phase_incr[1] <= 16'h0;
            phase_incr[2] <= 16'h0;
            phase_incr[3] <= 16'h0;
        end
        else begin
            //Quick and Dirty...
            if(master_count_in == 10'h0)begin
                phase_acc[0] <= adder_out;
                mix_result <= 16'h0;
            end
            else if(master_count_in == 10'h1)begin
                phase_acc[1] <= adder_out;
            end
            else if(master_count_in == 10'h2)begin
                phase_acc[2] <= adder_out;
            end
            else if(master_count_in == 10'h3)begin
                phase_acc[3] <= adder_out;
                sat_flag <= 1'b1;
            end
            else if(master_count_in == 10'h4)begin
                mix_result <= adder_out;
            end
            else if(master_count_in == 10'h5)begin
                mix_result <= adder_out;
            end
            else if(master_count_in == 10'h6)begin
                mix_result <= adder_out;
            end
            else if(master_count_in == 10'h7)begin
                mix_result <= adder_out;
                sat_flag <= 1'b0;
                data_valid_out <= 1'b1;
            end
            else begin
                data_valid_out <= 1'b0;
            end

            if(data_valid_in == 1'b1)begin
                if(addr_in[3:2] == 2'h0)begin
                    phase_incr[addr_in[1:0]] <= data_in[15:0];
                end else if(addr_in[3:2] == 2'h1)begin
                    volume[addr_in[1:0]] <= data_in[7:0];
                end
            end
        end
    end

endmodule

module sat_adder(
    input   wire[15:0]  a_in,
    input   wire[15:0]  b_in,
    output  wire[15:0]  c_out,
    input   wire        sat_en_in
);
    wire [15:0] result;
    wire signed_ovf;
    
    assign result = a_in + b_in;
    assign signed_ovf = (a_in[15] == b_in[15]) && (a_in[15] != result[15]);
    assign c_out = saturate(result,sat_en_in,signed_ovf); 
    
    function [15:0]saturate;
        input [15:0] value_in;
        input sat_en;
        input ovf;

        if(sat_en == 1'b1)begin
            if(ovf == 1'b1)begin
                if(value_in[15] == 1'b1)begin
                    //If overflow is detected and result[15] is 1, then saturate to 0x7fff
                    saturate = 16'h7fff;
                end
                else begin
                    saturate = 16'h8000;
                end
            end
            else begin
                saturate = value_in;
            end
        end
        else begin
            saturate = value_in;
        end
    endfunction

endmodule
