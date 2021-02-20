library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity  mux6to1 is 
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			C:	In	std_logic_vector(N-1 downto 0);
			D:	In	std_logic_vector(N-1 downto 0);
			E:	In	std_logic_vector(N-1 downto 0);
			F: In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic_vector(2 downto 0);
			Y:	Out	std_logic_vector(N-1 downto 0));
end entity;

architecture BEHAVIORAL of mux6to1 is
begin
	Y <= A when S = "000" else 
	     B when S = "001" else 
		 C when S = "010" else
		 D when S = "011" else
		 E when S = "100" else 
		 F;
end BEHAVIORAL;