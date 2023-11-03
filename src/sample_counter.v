`default_nettype none
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
    reg [2:0]  wave_type[0:3];
    reg [15:0] mix_result;
    reg sqr_buf[0:3];

    assign data_out = mix_result;

    wire [15:0] incr_out;
    assign incr_out = phase_incr[master_count_in[1:0]];

    wire sqr_out;
    wave_lut WAVE_LUT(.data_in(acc_out[15:13]),.wave_type_in(wave_type[master_count_in[1:0]]),.data_out(sqr_out));
    
    wire [15:0] dca_out;
    assign dca_out = dca(sqr_buf[master_count_in[1:0]],volume[master_count_in[1:0]]);

    wire [15:0] a_in;
    assign a_in = (master_count_in[3:2] == 2'b00)?incr_out:{ {2{dca_out[15]}},dca_out[15:2]};

    wire [15:0] acc_out;
    assign acc_out = phase_acc[master_count_in[1:0]];

    wire [15:0] b_in;
    assign b_in = (master_count_in[3:2] == 2'b00)?acc_out:mix_result;

    reg sat_flag;
    wire [15:0]adder_out;

    sat_adder adder(.a_in(a_in),.b_in(b_in),.s_out(adder_out),.sat_en_in(sat_flag));

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
            volume[0] <= 8'h0;
            volume[1] <= 8'h0;
            volume[2] <= 8'h0;
            volume[3] <= 8'h0;

        end
        else begin
            //Update Phase accumulator
            if(master_count_in[9:2] == 8'h00)begin
                phase_acc[master_count_in[1:0]] <= adder_out;
            end
            if(master_count_in[9:2] == 8'h01)begin
                sqr_buf[master_count_in[1:0]] <= sqr_out;
            end
            //Mix each channels
            if(master_count_in[9:2] == 8'h02)begin
                mix_result <= adder_out;
            end

            //initialize mix_result and set sat_flag
            if(master_count_in == 10'h3)begin
                sat_flag <= 1'b1;
                mix_result <= 16'h0;
            end

            if(master_count_in == 10'hb)begin
                sat_flag<= 1'b0;
                data_valid_out <= 1'b1;
            end
            else begin
                data_valid_out <= 1'b0;
            end

            if(data_valid_in == 1'b1)begin
                if(addr_in[3:2] == 2'h0)begin
                    phase_incr[addr_in[1:0]] <= data_in[15:0];
                end
                else if(addr_in[3:2] == 2'h1)begin
                    volume[addr_in[1:0]] <= data_in[7:0];
                end
                else if(addr_in[3:2] == 2'h2)begin
                    wave_type[addr_in[1:0]] <= data_in[2:0];
                end
            end
        end
    end

    function [15:0]dca;
        input   value_in;
        input   [7:0] volume_in;
        reg     [15:0]ext_volume;

        dca = (value_in == 1'b1)?{1'b0,volume_in,volume_in[7:1]}:(~{1'b0,volume_in,volume_in[7:1]});
        
    endfunction

endmodule

module wave_lut(
    input wire[2:0] data_in,
    input wire[2:0] wave_type_in,
    output wire data_out
);
    assign data_out = wave_lookup(data_in,wave_type_in);
    function wave_lookup;
        input [2:0] addr_in;
        input [2:0] type_in;
        if(type_in == 3'h0)begin//0000 1111
            wave_lookup = addr_in[2];
        end
        else if(type_in == 3'h1)begin//0000 0001
            if(addr_in == 3'h7)begin
                wave_lookup = 1'b1;
            end
            else begin
                wave_lookup = 1'b0;
            end
        end
        else if(type_in == 3'h2)begin//0000 0011
            if(addr_in == 3'h7 || addr_in == 3'h6)begin
                wave_lookup = 1'b1;
            end
            else begin
                wave_lookup = 1'b0;
            end
        end
        else if(type_in == 3'h3)begin//0000 0111
            if(addr_in == 3'h7 || addr_in == 3'h6 || addr_in == 3'h5)begin
                wave_lookup = 1'b1;
            end
            else begin
                wave_lookup = 1'b0;
            end
        end
        else if(type_in == 3'h4)begin//0001 1111
            if(addr_in == 3'h0 || addr_in == 3'h1 || addr_in == 3'h2)begin
                wave_lookup = 1'b0;
            end
            else begin
                wave_lookup = 1'b1;
            end
        end
        else if(type_in == 3'h5)begin//0011 1111
            if(addr_in == 3'h0 || addr_in == 3'h1)begin
                wave_lookup = 1'b0;
            end
            else begin
                wave_lookup = 1'b1;
            end
        end
        else if(type_in == 3'h6)begin//0111 1111
            if(addr_in == 3'h0)begin
                wave_lookup = 1'b0;
            end
            else begin
                wave_lookup = 1'b1;
            end
        end
        else if(type_in == 3'h7)begin//0001 1001
            if(addr_in == 3'h4 || addr_in == 3'h5 || addr_in == 3'h7)begin
                wave_lookup = 1'b1;
            end
            else begin
                wave_lookup = 1'b0;
            end
        end
        else begin
            wave_lookup = addr_in[2];
        end
    endfunction

endmodule

module sat_adder(
    input   wire[15:0]  a_in,
    input   wire[15:0]  b_in,
    output  wire[15:0]  s_out,
    input   wire        sat_en_in
);
    wire [15:0] result;
    wire signed_ovf;
    
    assign result = a_in + b_in;
    assign signed_ovf = (a_in[15] == b_in[15]) && (a_in[15] != result[15]);
    assign s_out = saturate(result,sat_en_in,signed_ovf); 
    
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

