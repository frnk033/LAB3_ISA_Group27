library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity  mux2to1 is 
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
end entity;

architecture BEHAVIORAL of mux2to1 is
begin
	Y <= A when S = '0' else B; 
end BEHAVIORAL;