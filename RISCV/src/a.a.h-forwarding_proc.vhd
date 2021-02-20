library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.constants.all;


entity forwarding_proc is 
	generic(
		MICROCODE_MEM_SIZE 	:     integer := MICROCODE_MEM_SIZE;   	-- Microcode Memory Size
		FUNC_SIZE          	:     integer := FUNC_SIZE;   	-- Func Field Size for R-Type Ops
		OP_CODE_SIZE       	:     integer := OP_CODE_SIZE;    	-- Op Code Size
		ALU_OPC_SIZE       	:     integer := ALU_OPC_SIZE;    	-- ALU Op Code Word Size
		IR_SIZE            	:     integer := IR_SIZE;   	-- Instruction Register Size    
		CW_SIZE            	:     integer := CW_SIZE		-- Control Word Size
		); 
	port ( forwarding_ij		: in std_logic_vector(2 downto 0);
		   forwarding_ik		: in std_logic_vector(3 downto 0);
		   stall_cond           : in std_logic;
		   sel_regA_i			: out std_logic;
		   sel_regB_i			: out std_logic;
		   sel_OP1_forwarded_i: out std_logic_vector(2 downto 0);
		   sel_OP2_forwarded_i: out std_logic_vector(2 downto 0);
		   sel_muxB1_i : out  std_logic;
		   sel_mux_mem_i : out std_logic_vector(1 downto 0)
		 );
end entity;


architecture str of forwarding_proc is 
begin

forwarding_process: process (forwarding_ij, forwarding_ik, stall_cond)  --stall
begin
	if stall_cond = '1' then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "0001" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "011";
		sel_OP2_forwarded_i <= "011";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
   elsif forwarding_ik = "0010" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "011";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
   elsif forwarding_ik = "0011" and forwarding_ij = "000" then 
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "011";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "0100" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "010";
		sel_OP2_forwarded_i <= "010";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "0101" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "010";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "0110" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "010";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "0111" and forwarding_ij = "000" then
	   sel_regA_i <= '1';
		sel_regB_i <= '1';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1000" and forwarding_ij = "000" then
	   sel_regA_i <= '1';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1001" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '1';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1010" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '1';
		sel_OP1_forwarded_i <= "010";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1011" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '1';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1100" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "011";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '1';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1101" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "100";
		sel_OP2_forwarded_i <= "100";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1110" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "100";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ik = "1111" and forwarding_ij = "000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "100";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
		
		
   elsif forwarding_ij = "001" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "10";
	elsif forwarding_ij = "010" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "001";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "011" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "100" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "001";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "101" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "01";
	elsif forwarding_ij = "110" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "111" and forwarding_ik = "0000" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "01";

		
--
--		--possible combined case

	elsif forwarding_ij = "011" and forwarding_ik = "0101" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "011" and forwarding_ik = "0010" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "100" and forwarding_ik = "0110" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "001";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "100" and forwarding_ik = "0011" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "001";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "100" and forwarding_ik = "0101" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "010";
		sel_OP2_forwarded_i <= "001";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "011" and forwarding_ik = "0110" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "010";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "100" and forwarding_ik = "0010" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "011";
		sel_OP2_forwarded_i <= "001";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "011" and forwarding_ik = "0011" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "011";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "111" and forwarding_ik = "0101" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "010";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "01";
	elsif forwarding_ij = "011" and forwarding_ik = "1001" then
	   sel_regA_i <= '0';
		sel_regB_i <= '1';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "011" and forwarding_ik = "1011" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "001";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '1';
		sel_mux_mem_i	<= "00";
	elsif forwarding_ij = "111" and forwarding_ik = "0010" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "011";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "01";
	elsif forwarding_ij = "001" and forwarding_ik = "0101" then
	   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "010";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "10";
   else 
			   sel_regA_i <= '0';
		sel_regB_i <= '0';
		sel_OP1_forwarded_i <= "000";
		sel_OP2_forwarded_i <= "000";
		sel_muxB1_i <= '0';
		sel_mux_mem_i	<= "00";

	end if;
end process;

end architecture;
