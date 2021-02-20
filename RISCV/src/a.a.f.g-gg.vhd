library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity gg is
	port(
		p_a, g_a, g_b   : in std_logic;
		gg_out          : out std_logic);
end entity;

architecture str of gg is

begin
	gg_out <= (p_a and g_b) or g_a;
end str;
  


    
  
