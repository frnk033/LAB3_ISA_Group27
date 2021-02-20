library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all;

entity writeback_stage is
	generic(
		data_size   : integer := data_size
		);
	port(
	    Rst 		: in std_logic;
		Clk 		: in std_logic;
		 
		-- control signals 
		NPC4_en 	: in std_logic;
		sel_mux1    : in std_logic;
		sel_mux2    : in std_logic;
		
		-- inputs
		-- from  memory stage
		alu_1_in    : in std_logic_vector(data_size-1 downto 0);
		NPC3_in     : in std_logic_vector (data_size-1 downto 0);
		DataRam_in  : in std_logic_vector(data_size-1 downto 0);
		NPC2_mem_in : in std_logic_vector(data_size-1 downto 0);
		
		-- outputs
		-- to decode stage
		RFdata_out  : out std_logic_vector(data_size-1 downto 0)
		);
end entity;

architecture str of writeback_stage is 

signal out_mux1: std_logic_vector(data_size-1 downto 0);

component reg is
	generic(
		data_size 	: integer := data_size
		);
	port(
		Rst  		: in std_logic; 
		clk  		: in std_logic; 
		enable		: in std_logic;
		Din  		: in std_logic_vector(data_size-1 downto 0);
		Dout 		: out std_logic_vector(data_size-1 downto 0) 
		);
end component;

component mux2to1 is
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
end component;

begin

multiplexer1: mux2to1
				  port map (A => Dataram_in, B => alu_1_in, S => sel_mux1, Y => out_mux1);
				  
multiplexer2: mux2to1
				  port map (A => out_mux1, B => NPC2_mem_in, S => sel_mux2, Y => RFdata_out);
					
end architecture;