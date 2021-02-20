library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;   
use work.constants.all;

entity comparator is 
	Generic( N		: integer:= data_size);
	Port( A_MSB, B_MSB, add_out_MSB		: In	std_logic;
		  comp_out	: Out	std_logic_vector(N-1 downto 0));
end entity; 

architecture str of comparator is 

begin 

comp_out(0) <= ( (A_MSB xor B_MSB) and A_MSB ) or
				( not(A_MSB xor B_MSB) and add_out_MSB );

comp_out(N-1 downto 1) <= (others => '0');

end architecture; 
