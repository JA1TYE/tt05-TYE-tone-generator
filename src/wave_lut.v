`default_nettype none
module wave_lut(
    input wire clk_in,
    input wire[3:0] lut_addr_in,
    input wire[2:0] wave_type_in,
    input wire[3:0] mem_write_addr_in,
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


    assign data_out = (wave_type_in[2])?mem_out:sqr_wave_lookup(lut_addr_in,wave_type_in[1:0]);
    
    function [3:0]mem_addr_trans;
        input [3:0] addr_in;
        input [1:0] type_in;
        if(type_in == 2'h0)begin//Normal
            mem_addr_trans = addr_in;
        end
        else if(type_in == 2'h1)begin//Reverse
            mem_addr_trans = ~addr_in;
        end
        else if(type_in == 2'h2)begin//First Half
            mem_addr_trans = {1'b0,addr_in[3:1]};
        end
        else if(type_in == 2'h3)begin//Second half
            mem_addr_trans = {1'b1,addr_in[3:1]};
        end
    endfunction

    function [15:0]sqr_wave_lookup;
        input [3:0] addr_in;
        input [1:0] type_in;
        if(type_in == 2'h0)begin//0000 1111
            sqr_wave_lookup = addr_in[3];
        end
        else if(type_in == 2'h1)begin//0000 0001
            if(addr_in[3:1] == 3'h7)begin
                sqr_wave_lookup = 16'h1;
            end
            else begin
                sqr_wave_lookup = 16'h0;
            end
        end
        else if(type_in == 2'h2)begin//0000 0011
            if(addr_in[3:1] == 3'h7 || addr_in[3:1] == 3'h6)begin
                sqr_wave_lookup = 16'h1;
            end
            else begin
                sqr_wave_lookup = 16'h0;
            end
        end
        else if(type_in == 2'h3)begin//0000 0111
            if(addr_in[3:1] == 3'h7 || addr_in[3:1] == 3'h6 || addr_in[3:1] == 3'h5)begin
                sqr_wave_lookup = 16'h1;
            end
            else begin
                sqr_wave_lookup = 16'h0;
            end
        end
    endfunction
    

endmodule

module wave_mem(
    input wire clk_in,
    input wire [3:0] read_addr_in,
    output wire [15:0] ext_read_data_out,
    input wire [3:0] write_addr_in,
    input wire [3:0] write_data_in,
    input wire write_en_in
);

    reg [3:0] mem[0:15];

    assign ext_read_data_out = {mem[read_addr_in],12'b0};

    always@(posedge clk_in)begin
        if(write_en_in == 1'b1)begin
            mem[write_addr_in] <= write_data_in;
        end
    end

endmodule
