library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity adder is 
	generic(
		SIZE : integer := data_size 
		);
	port(
		a, b : in  unsigned(SIZE-1 downto 0);
		z    : out unsigned(SIZE-1 downto 0) 
		);
end adder;

architecture beh of adder is 

begin

	z <= a + b ;

end architecture;  