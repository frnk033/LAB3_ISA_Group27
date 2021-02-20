//`timescale 1ns

module tb_riscv ();

   wire CLK_i;
   wire RST_n_i;
   wire [31:0] Iram_out_i;
   wire [31:0] Iram_out_tb;
   wire [31:0] Iram_add_i;
   wire [31:0] Iram_add_tb;	
   wire [31:0] Dram_data_in_i;
   wire [31:0] Dram_data_out_i;
   wire [31:0] Dram_add_i;
   wire [31:0] Dram_add_tb;	
   wire [31:0] Dram_data_in;
   wire Dram_we_i;
   wire Dram_rd_i;


   clk_gen CG(.CLK(CLK_i),
	      .RST_n(RST_n_i));

   IRAM IR(      .Rst(RST_n_i),
		         .Addr(Iram_add_tb),
		         .Dout(Iram_out_tb));

	DataRam DR(.CLK(CLK_i),
	             .RESET(RST_n_i),
		         .WR(Dram_we_i),
		         .RD(Dram_rd_i),
		         .ADD(Dram_add_tb),
		         .DATAIN(Dram_data_in_i),
		         .OUT1(Dram_data_out_i));

   riscv U1(.Clk(CLK_i),
	              .Rst(RST_n_i),
	              .IRAM_out(Iram_out_tb),
	              .IRAM_add(Iram_add_tb),
	              .Dram_add(Dram_add_tb),
                  .Dram_data_in(Dram_data_in_i),
	              .Dram_we(Dram_we_i),
	              .Dram_rd(Dram_rd_i),
	              .Dram_data_out(Dram_data_out_i));
			

endmodule

		   
