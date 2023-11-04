`timescale 1ns/1ps
module sample_counter_sim();
    logic       reset_in;
    logic       clk_in;
    logic[9:0]  master_count_in;
    logic[15:0] data_in;
    logic[5:0]  addr_in;
    logic       data_valid_in;
    logic[15:0] data_out;
    logic       data_valid_out;

    master_counter MASTER_CNT(reset_in,clk_in,master_count_in);
    sample_counter DUT(
        .reset_in(reset_in),.clk_in(clk_in),
        .master_count_in(master_count_in),
        .data_in(data_in),.addr_in(addr_in),
        .data_valid_in(data_valid_in),
        .data_out(data_out),.data_valid_out(data_valid_out)
        );

    parameter real clk_unit = (1000_000_000.0/50_000_000.0);

    integer i;

    initial begin
        $dumpfile("sample_counter.vcd");
        $dumpvars(0,sample_counter_sim);
        for(i = 0;i < 4;i++)begin
            $dumpvars(1,DUT.phase_incr[i]);
            $dumpvars(1,DUT.phase_acc[i]);
        end
        $display("clk_unit:%f\n",clk_unit);
        clk_in <= 1'b0;
        reset_in <= 1'b1;
        data_valid_in <=1'b0;
        repeat(10)@(posedge clk_in);
        reset_in    <= 0;
        //Set Phase Increment
        data_in <= 16'h1f_ff;
        addr_in <= 6'h0;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h00_00;
        addr_in <= 6'h1;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h00_00;
        addr_in <= 6'h2;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h1f_ff;
        addr_in <= 6'h3;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        //Set Volume
        data_in <= 16'h00_ff;
        addr_in <= 6'h4;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h00_00;
        addr_in <= 6'h5;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h00_00;
        addr_in <= 6'h6;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;
    
        data_in <= 16'h00_00;
        addr_in <= 6'h7;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        //Set wave type
        data_in <= 16'h00_00;
        addr_in <= 6'h8;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h00_01;
        addr_in <= 6'h9;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        data_in <= 16'h00_04;
        addr_in <= 6'h0a;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;
    
        data_in <= 16'h00_05;
        addr_in <= 6'h0b;
        data_valid_in <= 1'b1;
        @(posedge clk_in);
        data_valid_in <= 1'b0;

        //Set Wave Memory
        for(i = 0;i < 8;i++)begin
            data_in <= i;
            addr_in <= 6'h10+i;
            data_valid_in <= 1'b1;
            @(posedge clk_in);
            data_valid_in <= 1'b0;
        end

        for(i = 0;i < 8;i++)begin
            data_in <= i;
            addr_in <= 6'h18+i;
            data_valid_in <= 1'b1;
            @(posedge clk_in);
            data_valid_in <= 1'b0;
        end

        repeat(100000)@(posedge clk_in);
        $finish;
    end

    always begin
        #(clk_unit/2.0) clk_in <= ~clk_in;
    end

endmodule