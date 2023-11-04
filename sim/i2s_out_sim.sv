`timescale 1ns/1ps
module i2s_sim();
    logic       reset_in;
    logic       clk_in;
    logic[15:0] data_in;
    logic       data_valid_in;
    logic       d_out;
    logic       ws_out;
    logic       bclk_out;
    logic[9:0]  count_in;  

    master_counter MASTER_CNT(reset_in,clk_in,count_in);
    i2s_out DUT(
        .reset_in(reset_in),.clk_in(clk_in),
        .master_count_in(count_in),
        .data_in(data_in),
        .data_valid_in(data_valid_in),
        .d_out(d_out),.ws_out(ws_out),.bclk_out(bclk_out)
        );

    parameter real clk_unit = (1000_000_000.0/50_000_000.0);

    initial begin
        $dumpfile("i2s_out.vcd");
        $dumpvars(0,i2s_sim);
        $display("clk_unit:%f\n",clk_unit);
        clk_in <= 1'b0;
        reset_in <= 1'b1;
        data_valid_in <=1'b0;
        repeat(10)@(posedge clk_in);
        reset_in    <= 0;
        @(posedge ws_out)
        data_in <= 16'haa_00;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;
        @(posedge ws_out)
        data_in <= 16'h55_55;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;
        repeat(10000)@(posedge clk_in);
        $finish;
    end

    always begin
        #(clk_unit/2.0) clk_in <= ~clk_in;
    end

endmodule