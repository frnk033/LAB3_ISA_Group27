library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.myTypes.all; 

-- This block checks if an instruction uses the result of the prevoius load; if this happens, the only way to deal with it is to stall.
-- IR_ID_EX is the first instruction while IR_IF_ID is the following one.
-- First of all, the block checks if IR_ID_EX is a LOAD instruction. Then it distinguishes two cases: 
-- - the one where the IR_IF_ID is a RTYPE instr and so the result of the LOAD can be used by one (or both) of the two operands;
-- - the one where the IR_IF_ID is not a RTYPE and so only one operand is considered because the other field is the immediate value. In this case the instr j and jal 
--   are not taken into account because they don't refer to any operand.

entity stall_detection_unit is
	generic(
		IR_SIZE	: integer := IR_SIZE	
		);
	port( 
		IR_IF_ID	: in std_logic_vector(IR_SIZE-1 downto 0);
		IR_ID_EX	: in std_logic_vector(IR_SIZE-1 downto 0);
		stall   	: out std_logic
		);
end entity;


architecture beh of stall_detection_unit is
begin 

stall_detection_proc: process (IR_ID_EX, IR_IF_ID)
begin
	if IR_ID_EX(6 downto 0) = LW then
		if IR_IF_ID(6 downto 0) = RTYPE then	
			if IR_ID_EX(11 downto 7) = IR_IF_ID(19 downto 15) OR IR_ID_EX(11 downto 7) = IR_IF_ID(24 downto 20) then
				stall <= '1';
			else 
				stall <= '0';
			end if;

		elsif IR_IF_ID(6 downto 0 ) = ITYPE then
				 if IR_ID_EX(11 downto 7) = IR_IF_ID(19 downto 15) then 
					stall <= '1';
				else 
					stall <= '0';
				end if;
		elsif IR_IF_ID(6 downto 0 ) = SW OR IR_IF_ID(6 downto 0 ) = LW then
				 if IR_ID_EX(11 downto 7) = IR_IF_ID(19 downto 15) then 
					stall <= '1';
				else 
					stall <= '0';
				end if;
		else
			stall <= '0';
		end if;

	-- branch problem

	elsif IR_IF_ID(6 downto 0) = BEQ then
			if IR_ID_EX /= NOP then
						if IR_ID_EX(6 downto 0) = RTYPE  OR IR_ID_EX(6 downto 0) = ITYPE OR IR_ID_EX(6 downto 0) = LUI OR IR_ID_EX(6 downto 0) = AUIPC OR IR_ID_EX(6 downto 0) = JAL then
								if IR_IF_ID(24 downto 20) = IR_ID_EX(11 downto 7) OR IR_IF_ID(19 downto 15) = IR_ID_EX(11 downto 7) then 
										stall <= '1';
								else 
										stall <= '0';
								end if;
						else 
										stall <= '0';
						end if;
		
			else 
				stall <= '0';
			end if;
	else 
		stall <= '0';
	end if;
	
end process stall_detection_proc; 

end architecture;



