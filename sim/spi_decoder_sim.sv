`timescale 1ns/1ps
module spi_decoder_sim();
    reg        reset_in;
    reg        clk_in;

    wire[7:0]  slave_data_out;
    wire       slave_data_valid_out;
    wire       slave_transaction_valid_out;

    wire[15:0] decoder_data_out;
    wire[4:0]  decoder_addr_out;
    wire       decoder_data_valid_out;
    
    reg        spi_sclk_in;
    reg        spi_cs_in;
    reg        spi_mosi_in;

    reg[7:0]   slave_data_in;
    reg        slave_data_valid_in;

    spi_slave SPI_SLAVE(
            .reset_in(reset_in),.clk_in(clk_in),
            .spi_sclk_in(spi_sclk_in),.spi_cs_in(spi_cs_in),.spi_mosi_in(spi_mosi_in),
            .data_out(slave_data_out),.data_valid_out(slave_data_valid_out),
            .transaction_valid_out(slave_transaction_valid_out)
    );
    spi_decoder SPI_DEC(
            .reset_in(reset_in),.clk_in(clk_in),
            .data_in(slave_data_out),.data_valid_in(slave_data_valid_out),
            .transaction_valid_in(slave_transaction_valid_out),
            .data_out(decoder_data_out),.addr_out(decoder_addr_out),.data_valid_out(decoder_data_valid_out)
    );

    parameter real clk_unit = (1000_000_000.0/50_000_000.0);

    logic[23:0]sreg;
    integer i;
    task issue_cmd_3byte(logic[7:0]cmd,logic[15:0]dat);
        sreg <= {cmd,dat};
        spi_sclk_in <= 1'b0;
        repeat(10)@(posedge clk_in);
        spi_cs_in <= 1'b0;
        for(i = 0;i < 24;i = i + 1)begin
            repeat(10)@(posedge clk_in);
            spi_mosi_in <= sreg[23];
            sreg <= {sreg[22:0],1'b0};
            repeat(10)@(posedge clk_in);
            spi_sclk_in <= 1'b1;
            repeat(10)@(posedge clk_in);
            spi_sclk_in <= 1'b0;            
        end
        repeat(10)@(posedge clk_in);
        spi_cs_in <= 1'b1;
        repeat(10)@(posedge clk_in);
    endtask


   initial begin
        $dumpfile("spi_decoder.vcd");
        $dumpvars(0,spi_decoder_sim);
        $display("clk_unit:%f\n",clk_unit);
        clk_in <= 1'b0;
        reset_in <= 1'b1;
        slave_data_valid_in <= 1'b0;
        spi_sclk_in <= 1'b0;
        spi_mosi_in <= 1'b0;
        spi_cs_in <= 1'b1;
        repeat(10)@(posedge clk_in);
        reset_in    <= 0;
        repeat(10)@(posedge clk_in);
        slave_data_in <= 8'haa;
        slave_data_valid_in <= 1'b1;
        @(posedge clk_in);
        slave_data_valid_in <= 1'b0;
        repeat(100)@(posedge clk_in);
        issue_cmd_3byte(8'h01,16'h8765);
        repeat(1000)@(posedge clk_in);
        $finish;
    end

    always begin
        #(clk_unit/2.0) clk_in <= ~clk_in;
    end
endmodule