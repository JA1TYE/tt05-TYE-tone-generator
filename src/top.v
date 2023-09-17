`default_nettype none

module tt_um_ja1tye_sound_generator #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg [23:0] acc;
    reg [15:0] freq;

    wire [23:0] incr;

    wire reset;
    assign reset = ~rst_n;

    assign incr[23:0] = {freq,8'h0};//(freq[3:0] > 4'hc)?(freq[15:4] << 4'hc):(freq[15:4] << freq[3:0]);

    assign uo_out = acc[23:16];
    // use bidirectionals as inputs
    assign uio_oe = 8'b00000000;

    always @(posedge clk) begin
        if (reset) begin
            acc <= 0;
            freq <= 0;
        end else begin
            freq <= {uio_in,ui_in}; 
            acc <= acc + incr;
        end
    end

endmodule