ICARUS = iverilog
VVP = vvp

i2s_out.o:	i2s_out_sim.sv ../src/i2s_out.v ../src/master_counter.v
			$(ICARUS) -g2012 -o i2s_out.o $^
i2s_out:	i2s_out.o
			$(VVP) i2s_out.o

spi_decoder.o:	spi_decoder_sim.sv ../src/spi_decoder.v ../src/spi_slave.v
			$(ICARUS) -g2012 -o spi_decoder.o $^
spi_decoder:	spi_decoder.o
			$(VVP) spi_decoder.o

sample_counter.o:	sample_counter_sim.sv ../src/sample_counter.v ../src/master_counter.v ../src/wave_lut.v
			$(ICARUS) -g2012 -o sample_counter.o $^
sample_counter:	sample_counter.o
			$(VVP) sample_counter.o

top.o:	top_sim.sv ../src/tone_engine.v ../src/i2s_out.v ../src/master_counter.v ../src/sample_counter.v
			$(ICARUS) -g2012 -o top.o $^
top:	top.o
			$(VVP) top.o