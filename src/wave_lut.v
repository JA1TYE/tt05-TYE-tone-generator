`default_nettype none
module wave_lut(
    input wire clk_in,
    input wire[4:0] lut_addr_in,
    input wire[2:0] wave_type_in,
    input wire[4:0] mem_write_addr_in,
    input wire[3:0] mem_write_data_in,
    input wire mem_write_en_in,
    input wire[7:0] volume_in,
    output wire[15:0] data_out
);
    wire [15:0] mem_out;
    wave_mem WAVE_MEM(.clk_in(clk_in),
                .read_addr_in(lut_addr_in),
                .ext_read_data_out(mem_out),
                .write_addr_in(mem_write_addr_in),.write_data_in(mem_write_data_in),.write_en_in(mem_write_en_in)
                );

    assign data_out = mem_out;//wave_lookup(lut_addr_in,wave_type_in,mem_out);
    /*
    function [15:0]wave_lookup;
        input [3:0] addr_in;
        input [2:0] type_in;
        input [15:0] wave_mem_data_in;
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
        else begin
            wave_lookup = addr_in[2];
        end
    endfunction
    */

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
