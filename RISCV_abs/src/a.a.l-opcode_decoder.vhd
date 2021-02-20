library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.constants.all;


entity opcode_decoder is 
	port(
		opcode : in std_logic_vector(op_code_size-1 downto 0);
		funct  : in std_logic_vector(func_size-1 downto 0);
		add_mem: out std_logic_vector(3 downto 0)
	);
end entity;

architecture str of opcode_decoder is 

begin
 
	add_mem <=	"0000" when opcode = "0110111" else -- LUI 	
				"0001" when opcode = "0010111" else -- AUIPC
				"0010" when opcode = "1101111" else -- JAL
				"0011" when opcode = "1100011" else -- BEQ
				"0100" when opcode = "0000011" else -- LW
				"0101" when opcode = "0100011" else -- SW
				"0110" when opcode = "0010011" AND funct /= "101" else -- addi, andi
				"0111" when opcode = "0010011" AND funct = "101" else  -- srai
				"1000";-- when opcode = "0110011";
end architecture;
