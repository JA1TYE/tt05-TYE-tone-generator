`default_nettype none
module sample_counter (
    input wire reset_in,
    input wire clk_in,
    input wire [9:0]master_count_in,
    input wire [15:0]data_in,
    input wire [5:0]addr_in,
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
    reg [15:0] tmp_buf;

    wire [5:0] master_id;
    wire [1:0] slot_id;
    wire [1:0] process_id;
    assign master_id = master_count_in[9:4];
    assign slot_id = master_count_in[3:2];
    assign process_id = master_count_in[1:0];

    assign data_out = mix_result;

    /*
    a_in timetable
    process_id:net
    00:incr_out
    01:dca_out
    10:incr_out
    11:dca_out
    */
    wire [15:0] incr_out;
    assign incr_out = phase_incr[slot_id];

    //wire [15:0] dca_out;
    //assign dca_out = dca(sqr_buf[master_count_in[1:0]],volume[slot_id]);

    wire [15:0] a_in;
    assign a_in = (process_id == 2'b00)?incr_out:wave_out;//{ {2{dca_out[15]}},dca_out[15:2]};

    /*
    b_in timetable
    process_id:net
    00:acc_out
    01:mix_result
    10:acc_out
    11:mix_result
    */
    wire [15:0] acc_out;
    assign acc_out = phase_acc[slot_id];

    wire [15:0] b_in;
    assign b_in = (process_id == 2'b00)?acc_out:mix_result;

    wire [15:0] wave_out;
    wave_lut WAVE_LUT(.clk_in(clk_in),
            .lut_addr_in(acc_out[15:11]),.wave_type_in(wave_type[slot_id]),
            .mem_write_addr_in(addr_in[4:0]),.mem_write_data_in(data_in[3:0]),.mem_write_en_in(data_valid_in & addr_in[5]),
            .volume_in(volume[slot_id]),
            .data_out(wave_out)
            );
    
    wire sat_flag;
    assign sat_flag = (process_id == 2'b01)?1'b1:1'b0;
    
    wire [15:0]adder_out;
    sat_adder adder(.a_in(a_in),.b_in(b_in),.s_out(adder_out),.sat_en_in(sat_flag));



    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            data_valid_out <= 1'b0;
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
            //Update Phase Accumulator
            if(master_id == 6'h00)begin
                if(process_id == 2'b00)begin
                    phase_acc[slot_id] <= adder_out;
                end
                //Wave lookup
                if(process_id == 2'b01)begin
                    mix_result <= adder_out;
                end
            end
            if(master_id == 6'h01)begin
                mix_result <= 16'h0;
            end

            //master_id == 6'h0
            //slot_id == 2'h3
            //process_id == 2'h3
            if(master_count_in == 10'hf)begin
                data_valid_out <= 1'b1;
            end
            else begin
                data_valid_out <= 1'b0;
            end

            if(data_valid_in == 1'b1)begin
                if(addr_in[5:2] == 4'h0)begin
                    phase_incr[addr_in[1:0]] <= data_in[15:0];
                end
                else if(addr_in[5:2] == 4'h1)begin
                    volume[addr_in[1:0]] <= data_in[7:0];
                end
                else if(addr_in[5:2] == 4'h2)begin
                    wave_type[addr_in[1:0]] <= data_in[2:0];
                end
            end
        end
    end

    function [15:0]dca;
        input   value_in;
        input   [7:0] volume_in;

        dca = (value_in == 1'b1)?{1'b0,volume_in,volume_in[7:1]}:(~{1'b0,volume_in,volume_in[7:1]});
        
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
