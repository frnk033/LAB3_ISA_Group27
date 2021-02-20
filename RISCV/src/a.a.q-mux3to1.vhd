library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity mux3to1 is 
	Generic(
			N: integer:= data_size
			);
	Port(	
			A:	in	std_logic_vector(N-1 downto 0) ;
			B:	in	std_logic_vector(N-1 downto 0);
			C:  in  std_logic_vector(N-1 downto 0);
			S:	in	std_logic_vector(1 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0)
		);
end entity; 

architecture str of mux3to1 is

begin

	Y <= A when S = "00" else 
	     B when S = "01" else
		 C;
		 
end architecture;