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
    11:dca_out
    */
    wire [15:0] incr_out;
    assign incr_out = phase_incr[slot_id];

    wire [15:0] a_in;
    assign a_in = (process_id[1] == 1'b0)?incr_out:tmp_buf;

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
    assign b_in = (process_id[1] == 1'b0)?acc_out:mix_result;

    wire [15:0] wave_out;
    wire [2:0] wave_type_out;
    assign wave_type_out = wave_type[slot_id];
    wave_lut WAVE_LUT(.clk_in(clk_in),
            .lut_addr_in(acc_out[15:11]),.wave_type_in(wave_type_out),
            .mem_write_addr_in(addr_in[4:0]),.mem_write_data_in(data_in[3:0]),.mem_write_en_in(data_valid_in & addr_in[5]),
            .data_out(wave_out)
            );
        
    wire [15:0]adder_out;
    assign adder_out = a_in + b_in;

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            data_valid_out <= 1'b0;
            mix_result <= 16'h0;
            tmp_buf <= 16'h0;
            
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
                    tmp_buf <= wave_out;
                end
                //Volume adjustment
                if(process_id == 2'b10)begin
                    tmp_buf <= dca(tmp_buf,volume[slot_id],wave_type_out[2]);
                end
                //Mixing
                if(process_id == 2'b11)begin
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
        input   [15:0]value_in;
        input   [7:0] volume_in;
        input   type_flag_in;

        if(type_flag_in == 1'b0)begin
            dca = (value_in[0] == 1'b1)?{3'h0,volume_in,volume_in[7:3]}:(~{3'h0,volume_in,volume_in[7:3]});
        end
        else begin
            if(volume_in[7:6] == 2'h0)begin
                dca = 16'h0000;
            end
            else if(volume_in[7:6] == 2'h1)begin
                dca = {{6{value_in[15]}},value_in[15:6]};
            end
            else if(volume_in[7:6] == 2'h2)begin
                dca = {{4{value_in[15]}},value_in[15:4]};
            end
            else if(volume_in[7:6] == 2'h3)begin
                dca = {{2{value_in[15]}},value_in[15:2]};
            end
        end
        
    endfunction

endmodule
