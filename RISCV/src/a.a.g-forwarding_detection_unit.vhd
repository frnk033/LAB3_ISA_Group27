library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.myTypes.all;


entity forwarding_detection_unit is
	generic(
		IR_SIZE    		: integer := IR_SIZE	
        );
	port( 
		IR_IF_ID  		: in std_logic_vector(IR_SIZE-1 downto 0);
		IR_ID_EX  		: in std_logic_vector(IR_SIZE-1 downto 0);
		IR_EX_MEM 		: in std_logic_vector(IR_SIZE-1 downto 0);
		forwarding_ij  	: out std_logic_vector(2 downto 0);
		forwarding_ik  	: out std_logic_vector(3 downto 0)
		);
end forwarding_detection_unit;


architecture beh of forwarding_detection_unit is

begin 

forwarding_detection_proc: process (IR_ID_EX, IR_IF_ID, IR_EX_MEM)

begin

------- instri and instrk compared ---
	if IR_EX_MEM(6 downto 0) = LW then 	
		if IR_IF_ID(6 downto 0) = RTYPE then
			if IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then --both operand equal to destination
				forwarding_ik <= "0001";
			elsif IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "0010";
			elsif IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) then
 				forwarding_ik <= "0011";
			else 
				forwarding_ik <= "0000";
			end if;
		elsif IR_IF_ID(6 downto 0) = ITYPE OR IR_IF_ID(6 downto 0) = LW then  
			if IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then 
				forwarding_ik <= "0010";
			else 
		      forwarding_ik <= "0000";
			end if;
		elsif IR_IF_ID(6 downto 0) = SW then
			if IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "1100";
			elsif IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "0010";
			elsif IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "1011";
			else
		      forwarding_ik <= "0000";
			end if;
		else 
			  forwarding_ik <= "0000";
		end if;
		
	elsif IR_EX_MEM(6 downto 0) = RTYPE OR IR_EX_MEM(6 downto 0) = ITYPE OR IR_EX_MEM(6 downto 0) = LUI OR IR_EX_MEM(6 downto 0) = AUIPC  then
		if IR_IF_ID(6 downto 0) = RTYPE then	
			if IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then --both operand equal to destination
				forwarding_ik <= "0100";
			elsif IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "0101";
			elsif IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) then
 				forwarding_ik <= "0110";
			else 
				forwarding_ik <= "0000";
			end if;	
	   elsif IR_IF_ID(6 downto 0) = ITYPE OR IR_IF_ID(6 downto 0) = LW then
			if IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then 
				forwarding_ik <= "0101";
			else 
		      forwarding_ik <= "0000";
			end if;		
		elsif IR_IF_ID(6 downto 0) = BEQ then	
			if IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then --both operand equal to destination
				forwarding_ik <= "0111";
			elsif IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "1000";
			elsif IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) then
 				forwarding_ik <= "1001";
			else 
				forwarding_ik <= "0000";
			end if;	
		elsif IR_IF_ID(6 downto 0) = SW then
			if IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "1010";
			elsif IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "0101";
			elsif IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "1001";
			else
		      forwarding_ik <= "0000";
			end if;	
		else 
			  forwarding_ik <= "0000";		
		end if;
	elsif IR_EX_MEM(6 downto 0) = JAL then
		if IR_IF_ID(6 downto 0) = RTYPE then	
			if IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then --both operand equal to destination
				forwarding_ik <= "1101";
			elsif IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then
				forwarding_ik <= "1110";
			elsif IR_IF_ID(24 downto 20) = IR_EX_MEM(11 downto 7) then
 				forwarding_ik <= "1111";
			else 
				forwarding_ik <= "0000";
			end if;	
		elsif IR_IF_ID(6 downto 0) = ITYPE OR IR_IF_ID(6 downto 0) = LW OR IR_IF_ID(6 downto 0) = SW then  
			if IR_IF_ID(19 downto 15) = IR_EX_MEM(11 downto 7) then 
				forwarding_ik <= "1110";
			else 
		      forwarding_ik <= "0000";
			end if;
		else 
			  forwarding_ik <= "0000";
		end if;	 
	else	
		forwarding_ik <= "0000";		
	end if; 


	
------ instri and instrj compared ----
   if IR_ID_EX(6 downto 0) = LW then
		if IR_IF_ID(6 downto 0) = SW then 
			if IR_IF_ID(24 downto 20) = IR_ID_EX(11 downto 7) then
				forwarding_ij <= "001";
			else 
				forwarding_ij <= "000";
			end if;
		else
			forwarding_ij <= "000";
		end if;
	
	elsif IR_ID_EX(6 downto 0) = RTYPE OR IR_ID_EX(6 downto 0) = ITYPE OR IR_ID_EX(6 downto 0) = LUI OR IR_ID_EX(6 downto 0) = AUIPC then 
		if IR_IF_ID(6 downto 0) = RTYPE then
			if IR_IF_ID(24 downto 20) = IR_ID_EX(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_ID_EX(11 downto 7) then --both operand equal to destination
				forwarding_ij <= "010";
			elsif IR_IF_ID(19 downto 15) = IR_ID_EX(11 downto 7) then
				forwarding_ij <= "011";
			elsif IR_IF_ID(24 downto 20) = IR_ID_EX(11 downto 7) then
				forwarding_ij <= "100";
			else
				forwarding_ij <= "000";
			end if;
		elsif IR_IF_ID(6 downto 0) = ITYPE OR IR_IF_ID(6 downto 0) = LW then
			if IR_IF_ID(19 downto 15) = IR_ID_EX(11 downto 7) then 
				forwarding_ij <= "011";      ----rivedere questo punto !!!!!!!!!!!!!!!!
			else 
		      forwarding_ij <= "000";
			end if;	
		elsif IR_IF_ID(6 downto 0) = SW then
			if IR_IF_ID(24 downto 20) = IR_ID_EX(11 downto 7) AND IR_IF_ID(19 downto 15) = IR_ID_EX(11 downto 7) then
				forwarding_ij <= "101";
			elsif IR_IF_ID(19 downto 15) = IR_ID_EX(11 downto 7) then
				forwarding_ij <= "110";
			elsif IR_IF_ID(24 downto 20) = IR_ID_EX(11 downto 7) then
				forwarding_ij <= "111";
			else
		      forwarding_ij <= "000";
			end if;	
		else 
			  forwarding_ij <= "000";
		end if;
	
	else
		forwarding_ij <= "000";
	end if;
end process forwarding_detection_proc; 

end architecture;
