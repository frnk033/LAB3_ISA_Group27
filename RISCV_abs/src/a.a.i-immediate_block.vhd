library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity immediate_block is 
	generic(
		ir_size		: integer := IR_size;
		data_size	: integer := data_size 
		);
	port(
		imm_in	: in std_logic_vector(ir_size-1 downto 0);
		sel   	: in std_logic_vector(2 downto 0);
		imm_out	: out std_logic_vector(data_size-1 downto 0)
		);
end entity;

architecture str of immediate_block is 

signal imm0: std_logic_vector(data_size-1 downto 0);
signal imm1: std_logic_vector(data_size-1 downto 0);
signal imm2: std_logic_vector(data_size-1 downto 0);
signal imm3: std_logic_vector(data_size-1 downto 0);
signal imm4: std_logic_vector(data_size-1 downto 0);
signal imm5: std_logic_vector(data_size-1 downto 0);


component mux6to1 is
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			C:	In	std_logic_vector(N-1 downto 0);
			D:	In	std_logic_vector(N-1 downto 0);
			E:	In	std_logic_vector(N-1 downto 0);
			F: In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic_vector(2 downto 0);
			Y:	Out	std_logic_vector(N-1 downto 0));
end component;

begin 

-- needed for addi, lw, andi 
imm0(data_size-1 downto 12) <= (others => imm_in(ir_size-1)) ;
imm0(11 downto 0) <=  imm_in(ir_size-1 downto 20) ;

-- needed for LUI and AUIPC
imm1(data_size-1 downto 12) <= imm_in(ir_size-1 downto 12);
imm1(11 downto 0)  <= (others => '0');

-- needed for BEQ
imm2(data_size-1 downto 12) <= (others => (imm_in(ir_size-1)));
imm2(11) <= imm_in(7);
imm2(10 downto 5) <= imm_in(30 downto 25);
imm2(4 downto 1) <= imm_in(11 downto 8);
imm2(0) <= '0';

-- needed for JAL
imm3(data_size-1 downto 20) <= (others => imm_in(ir_size-1));
imm3(19 downto 12) <= imm_in(19 downto 12);
imm3(11) <= imm_in(20); 
imm3(10 downto 1) <= imm_in(30 downto 21);
imm3(0) <= '0';

-- needed for SW
imm4(data_size-1 downto 12) <= (others => imm_in(ir_size-1));
imm4(11 downto 5) <= imm_in(31 downto 25);
imm4(4 downto 0) <= imm_in(11 downto 7);

-- needed for SRAI
imm5(data_size-1 downto 5) <= (others => (imm_in(24)));
imm5(4 downto 0) <= imm_in(24 downto 20);

mux:  mux6to1
		port map (A=>imm0, B=>imm1, C=>imm2, D=>imm3, E=>imm4, F=>imm5, S=> sel , Y=> imm_out); 

end architecture;
