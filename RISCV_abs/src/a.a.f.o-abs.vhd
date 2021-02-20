library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.constants.all;

entity abs_block is
	Generic (N			: integer := data_size);
	Port	(a			: in std_logic_vector(N-1 downto 0);
			 abs_out	: out std_logic_vector(N-1 downto 0));
end entity;


architecture str of abs_block is

signal prev_bits : std_logic_vector(N-2 downto 0);

begin

abs_out(0) <= a(0);
prev_bits(0) <= a(0);

logic_chain:	for i in 1 to N-2 generate
					abs_out(i) <= (prev_bits(i-1) and a(N-1)) xor a(i);
					prev_bits(i) <= a(i) or prev_bits(i-1);
				end generate;

	abs_out(N-1) <= (prev_bits(N-2) and a(N-1)) xor a(N-1);


end architecture str;
