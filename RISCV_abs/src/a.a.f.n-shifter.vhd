library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use WORK.constants.all;

-- only performs right arithmetic shift.
-- made in separate component in case any improvement is needed

entity SHIFTER is
	generic(
		N			: integer := data_size
		);
	port(	
		A			: in std_logic_vector(N-1 downto 0);
		B			: in std_logic_vector(4 downto 0); 
		OUTPUT		: out std_logic_vector(N-1 downto 0)
	);

end entity SHIFTER;


architecture BEHAVIORAL of SHIFTER is

begin
	
	OUTPUT <= to_StdLogicVector((to_bitvector(A)) sra (conv_integer(B)));

end architecture BEHAVIORAL;



