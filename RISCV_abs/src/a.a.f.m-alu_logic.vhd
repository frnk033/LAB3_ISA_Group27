library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;

entity alu_logic is
	generic(N: integer := data_size);
	port(	
		A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(N-1 downto 0);
		s: in std_logic;
		C: out std_logic_vector(N-1 downto 0)
		);
end entity;


architecture BEHAVIORAL of alu_logic is

begin

C <= (A and B) when s = '0' else (A xor B);

end architecture BEHAVIORAL;
