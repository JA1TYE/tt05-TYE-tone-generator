`default_nettype none
module wave_lut(
    input wire clk_in,
    input wire reset_in,
    input wire[4:0] lut_addr_in,
    input wire[2:0] wave_type_in,
    input wire[4:0] mem_write_addr_in,
    input wire[3:0] mem_write_data_in,
    input wire mem_write_en_in,
    output wire[15:0] data_out
);
    wire [15:0] mem_out;
    wave_mem WAVE_MEM(.clk_in(clk_in),
                .read_addr_in(mem_addr_trans(lut_addr_in,wave_type_in[1:0])),
                .ext_read_data_out(mem_out),
                .write_addr_in(mem_write_addr_in),.write_data_in(mem_write_data_in),.write_en_in(mem_write_en_in)
                );


    assign data_out = (wave_type_in[2])?mem_out:sqr_wave_lookup(lut_addr_in[4:2],wave_type_in[1:0]);
    
    //LFSR for noise
    reg[15:0] lfsr;

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            lfsr <= 16'hffff;
        end
        else begin
            lfsr <= {lfsr[14:0],lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
        end
    end

    function [4:0]mem_addr_trans;
        input [4:0] addr_in;
        input [1:0] type_in;
        if(type_in == 2'h0)begin//Normal
            mem_addr_trans = addr_in;
        end
        else if(type_in == 2'h1)begin//First Half
            mem_addr_trans = {1'b0,addr_in[4:1]};
        end
        else if(type_in == 2'h2)begin//Second Half
            mem_addr_trans = {1'b1,addr_in[4:1]};
        end
        else if(type_in == 2'h3)begin//Shuffling
            mem_addr_trans = {addr_in[0],addr_in[4:1]};
        end
    endfunction

    function [15:0]sqr_wave_lookup;
        input [2:0] addr_in;
        input [1:0] type_in;
        if(type_in == 2'h0)begin//0000 1111(50%)
            sqr_wave_lookup = {15'h0000,addr_in[2]};
        end
        else if(type_in == 2'h1)begin//0000 0001(12.5%)
            if(addr_in == 3'h7)begin
                sqr_wave_lookup = 16'h1;
            end
            else begin
                sqr_wave_lookup = 16'h0;
            end
        end
        else if(type_in == 2'h2)begin//0000 0011(25%)
            if(addr_in == 3'h7 || addr_in == 3'h6)begin
                sqr_wave_lookup = 16'h1;
            end
            else begin
                sqr_wave_lookup = 16'h0;
            end
        end
        else if(type_in == 2'h3)begin//Noise
            sqr_wave_lookup = {15'h0000,lfsr[0]};
        end
    endfunction
    

endmodule

module wave_mem(
    input wire clk_in,
    input wire [4:0] read_addr_in,
    output wire [15:0] ext_read_data_out,
    input wire [4:0] write_addr_in,
    input wire [3:0] write_data_in,
    input wire write_en_in
);

    reg [3:0] mem[0:31];

    assign ext_read_data_out = {mem[read_addr_in],12'b0};

    always@(posedge clk_in)begin
        if(write_en_in == 1'b1)begin
            mem[write_addr_in] <= write_data_in;
        end
    end

endmodule
