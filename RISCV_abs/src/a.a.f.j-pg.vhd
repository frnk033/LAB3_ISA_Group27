library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity pg is
	port(
		p_a, g_a    : in std_logic;
        p_b, g_b    : in std_logic;
        p_out, g_out: out std_logic);
end entity;

architecture pg_str of pg is

begin
	p_out <= p_a and p_b;
    g_out <= g_a or (p_a and g_b);
end pg_str;
