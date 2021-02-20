library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all; 

-- used in the decoder stage for branch instruction

entity comparator_block is 
	generic(
		SIZE : integer := data_size 
		);
	port(
		a, b : in  std_logic_vector(SIZE-1 downto 0);
		z    : out std_logic
		);
end entity;

architecture beh of comparator_block is 

begin

check_eq: process	(a, b)
begin
	if a = b then
		z <= '1' ;
	else 
		z <= '0';
	end if;
end process check_eq;	 
		 
end architecture;  
