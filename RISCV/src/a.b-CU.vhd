library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.constants.all;

entity CU is
	generic(
		MICROCODE_MEM_SIZE 	:     integer := MICROCODE_MEM_SIZE;   	-- Microcode Memory Size
		FUNC_SIZE          	:     integer := FUNC_SIZE;   			-- Func Field Size for R-Type Ops
		OP_CODE_SIZE       	:     integer := OP_CODE_SIZE;    		-- Op Code Size
		ALU_OPC_SIZE       	:     integer := ALU_OPC_SIZE;    		-- ALU Op Code Word Size
		IR_SIZE            	:     integer := IR_SIZE;   			-- Instruction Register Size    
		CW_SIZE            	:     integer := CW_SIZE				-- Control Word Size
		);  
	port(
		Clk                	: in  std_logic;	-- Clock
		Rst                	: in  std_logic;	-- Reset:Active-Low
		
		-- INPUTS
		IR_IN              	: in  std_logic_vector(IR_SIZE - 1 downto 0);
		stall			  	: in std_logic;
		forwarding_ij		: in std_logic_vector(2 downto 0);
		forwarding_ik		: in std_logic_vector(3 downto 0);
		br_j_sig			: in std_logic;
		
		-- OUTPUTS
		-- IF Control Signal
		IR_EN       		: out std_logic;  	-- Instruction Register Enable
		NPC_EN       		: out std_logic;  	-- NextProgramCounter Register Enable
		PC_EN       		: out std_logic;
		PC_SELECTOR			: out std_logic;
		IR_SELECTOR			: out std_logic;
		PC1_EN      		: out std_logic;	 
		 -- ID Control Signals
		rf_we				: out std_logic; 
		IR1_EN				: out std_logic; 
		rega_en   			: out std_logic; 
		regb_en   			: out std_logic; 
		regimm_en 			: out std_logic;
		regwr1_en   		: out std_logic;
		npc1_en			 	: out std_logic; 
		pc2_en      		: out std_logic;
		sel_regA			: out std_logic;
		sel_regB			: out std_logic;
		branch            	: out std_logic;
		jump              	: out std_logic;
		sel_immediate     	: out std_logic_vector(2 downto 0);	 
		-- EX Control Signals
		NPC2_en  			: out std_logic;
		Aluout_en			: out std_logic;
		B1_en    			: out std_logic;
		regwr2_en			: out std_logic;
		sel_OP1         	: out std_logic;
		sel_OP2         	: out std_logic;
		sel_ALU_out     	: out std_logic;
		alu_opcode     		: out std_logic_vector(alu_opc_size-1 downto 0);
		sel_OP1_forwarded	: out std_logic_vector(2 downto 0);
		sel_OP2_forwarded	: out std_logic_vector(2 downto 0);
		sel_muxB1        	: out std_logic;				
		-- MEM Control Signals
		NPC3_en 			: out std_logic;
		LMD_en  			: out std_logic;
		ALuout1_en			: out std_logic;
		sel_mux_mem     	: out std_logic_vector(1 downto 0);
		WR_DRAM         	: out std_logic;
		RD_DRAM         	: out std_logic;
		-- WB Control signals
		NPC4_en 			: out std_logic;
		sel_mux1      		: out std_logic;
		sel_mux2      		: out std_logic
		
		); 
end entity;

architecture str of CU is 

	type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw_mem : mem_array := (   "1110011111111000011111011111100110", -- LUI
									 "1110011111111000011111010111100110", --AUIPC
									 "1110011111111010111111100111100111", -- JAL
									 "1110011111111100101111110011100110", -- BEQ 
									 "1110011111111000001111110111101100", -- LW
									 "1110011111111001001111110011110110", -- SW
									 "1110011111111000001111110111100110", -- ITYPE : addi, andi 
									 "1110011111111001011111110111100110", --srai
									 "1110011111111000001111100111100110"  -- R type: add, xor, slt
                                );
										  
component opcode_decoder is
	port(
		opcode : in std_logic_vector(op_code_size-1 downto 0);
		funct  : in std_logic_vector(func_size-1 downto 0);
		add_mem: out std_logic_vector(3 downto 0)
		);
end component;

component forwarding_proc is 
	generic(
		MICROCODE_MEM_SIZE 	:     integer := MICROCODE_MEM_SIZE;	-- Microcode Memory Size
		FUNC_SIZE          	:     integer := FUNC_SIZE;   			-- Func Field Size for R-Type Ops
		OP_CODE_SIZE       	:     integer := OP_CODE_SIZE;    		-- Op Code Size
		ALU_OPC_SIZE       	:     integer := ALU_OPC_SIZE;    		-- ALU Op Code Word Size
		IR_SIZE            	:     integer := IR_SIZE;   			-- Instruction Register Size    
		CW_SIZE            	:     integer := CW_SIZE				-- Control Word Size
		); 
	port(
		forwarding_ij		: in std_logic_vector(2 downto 0);
		forwarding_ik		: in std_logic_vector(3 downto 0);
		stall_cond          : in std_logic;
		sel_regA_i			: out std_logic;
		sel_regB_i			: out std_logic;
		sel_OP1_forwarded_i	: out std_logic_vector(2 downto 0);
		sel_OP2_forwarded_i	: out std_logic_vector(2 downto 0);
		sel_muxB1_i 		: out  std_logic;
		sel_mux_mem_i 		: out std_logic_vector(1 downto 0)
		);
end component;							  
										  
	signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
	signal IR_func   : std_logic_vector(FUNC_SIZE-1 downto 0);   	-- Func part of IR when Rtype

	-- control word is shifted to the correct stage
	signal cw1 : std_logic_vector(CW_SIZE - 1 downto 0); 	  -- first stage
	signal cw2 : std_logic_vector(CW_SIZE - 1 - 6 downto 0);  -- second stage
	signal cw3 : std_logic_vector(CW_SIZE - 1 - 18 downto 0); -- third stage
	signal cw4 : std_logic_vector(CW_SIZE - 1 - 25 downto 0); -- fourth stage
   
	-- fixed
	signal cw_stall	: std_logic_vector(CW_SIZE -1 downto 0):= "1111111111111000001111110111100110";     -- cw related to nop

	signal aluOpcode_i: std_logic_vector(alu_opc_size - 1 downto 0);
	signal aluOpcode1 : std_logic_vector(alu_opc_size - 1 downto 0);
	signal aluOpcode2 : std_logic_vector(alu_opc_size - 1 downto 0);
	
	signal sel_regA_i: std_logic;
	signal sel_regA1 : std_logic;

	signal sel_regB_i: std_logic;
	signal sel_regB1 : std_logic;	
	
	signal sel_OP1_forwarded_i: std_logic_vector(2 downto 0);
	signal sel_OP1_forwarded1 : std_logic_vector(2 downto 0);
	signal sel_OP1_forwarded2 : std_logic_vector(2 downto 0);

	signal sel_OP2_forwarded_i: std_logic_vector(2 downto 0);
	signal sel_OP2_forwarded1 : std_logic_vector(2 downto 0);
	signal sel_OP2_forwarded2 : std_logic_vector(2 downto 0);
	
	signal sel_muxB1_i : std_logic;
	signal sel_muxB1_1 : std_logic;
	signal sel_muxB1_2 : std_logic;
	
	signal sel_mux_mem_i: std_logic_vector(1 downto 0);
	signal sel_muxmem1  : std_logic_vector(1 downto 0);
	signal sel_muxmem2  : std_logic_vector(1 downto 0);
	signal sel_muxmem3  : std_logic_vector(1 downto 0);
	
	signal stall_cond		: std_logic;
	
	signal add_cw_mem : std_logic_vector(3 downto 0);
	
	

begin

	IR_opcode(OP_CODE_SIZE-1 downto 0) <= IR_IN(OP_CODE_SIZE-1 downto 0);
	IR_func(FUNC_SIZE-1 downto 0)  <= IR_IN(14 downto 12);

	stall_cond <= stall or br_j_sig; 
	
OPCODE_decodign: opcode_decoder
					port map (opcode => IR_opcode, funct => IR_func, add_mem => add_cw_mem); 

stall_process: process (add_cw_mem, stall_cond) 
begin 
	if stall_cond = '0' then 
		cw1 <= cw_mem(conv_integer(add_cw_mem));
	else
		cw1 <= cw_stall;
	end if; 
end process stall_process;


forw_comp: forwarding_proc
			port map (forwarding_ij => forwarding_ij, forwarding_ik => forwarding_ik, stall_cond => stall_cond, sel_regA_i => sel_regA_i, 
					  sel_regB_i => sel_regB_i, sel_OP1_forwarded_i => sel_OP1_forwarded_i, sel_OP2_forwarded_i => sel_OP2_forwarded_i,
					  sel_muxB1_i => sel_muxB1_i, sel_mux_mem_i => sel_mux_mem_i);


	--stage one control signals
	IR_EN  			<= cw1(CW_SIZE - 1);
	NPC_EN 			<= cw1(CW_SIZE - 2); 
	PC_en  			<= cw1(CW_SIZE - 3); 
	PC_SELECTOR  	<= cw1(CW_SIZE - 4);
	IR_SELECTOR  	<= cw1(CW_SIZE - 5);
	PC1_EN   		<= cw1(CW_SIZE - 6);
	
	--stage two control signals
	IR1_EN 			<= cw2(CW_SIZE-7);
	rega_en 		<= cw2(CW_SIZE-8);
	regb_en 		<= cw2(CW_SIZE-9);
	regimm_en 		<= cw2(CW_SIZE-10);
	regwr1_en 		<= cw2(CW_SIZE-11);
	npc1_en 		<= cw2(CW_SIZE-12);
	pc2_en 			<= cw2(CW_SIZE-13);
	branch 			<= cw2(CW_SIZE-14);
	jump 			<= cw2(CW_SIZE-15);
	sel_immediate 	<= cw2(CW_SIZE-16 downto CW_SIZE-18 );
	
	--stage three control signals
	NPC2_en 		<= cw3(CW_SIZE-19);
	Aluout_en 		<= cw3(CW_SIZE-20);
	B1_en 			<= cw3(CW_SIZE-21);
	regwr2_en 		<= cw3(CW_SIZE-22);
	sel_OP1 		<= cw3(CW_SIZE-23);
	sel_OP2 		<= cw3(CW_SIZE-24);
	sel_ALU_out 	<= cw3(CW_SIZE-25);
	
	--stage four control signals
	rf_we  			<= cw4(CW_SIZE-26);
	NPC3_en 		<= cw4(CW_SIZE-27);
	LMD_en 			<= cw4(CW_SIZE-28);
	Aluout1_en 		<= cw4(CW_SIZE-29);
	WR_DRAM         <= cw4(CW_SIZE-30);
	RD_DRAm         <= cw4(CW_SIZE-31);
	NPC4_en 		<= cw4(CW_SIZE-32);
	sel_mux1 		<= cw4(CW_SIZE-33);
	sel_mux2 		<= cw4(CW_SIZE-34);


-- process to pipeline control words
CW_PIPE: process (Clk, Rst)
begin  -- process Clk
	if Rst = '0' then                   -- asynchronous reset (active low)
		cw2 <= (others => '0');
		cw3 <= (others => '0');
		cw4 <= (others => '0');

		
		aluOpcode1		<= "0000";
		aluOpcode2 		<= "0000";

		

		sel_regA1 <= '0';

		sel_regB1 <= '0';

		sel_OP1_forwarded1 <= "000";
		sel_OP1_forwarded2 <= "000";

		sel_OP2_forwarded1 <= "000";
		sel_OP2_forwarded2 <= "000";
	
		sel_muxB1_1 <= '0';
		sel_muxB1_2 <= '0';
	
		sel_muxmem1 <= "00";
		sel_muxmem2 <= "00";
		sel_muxmem3 <= "00";
	  
	elsif Clk'event and Clk = '1' then  -- rising clock edge

		cw2 <= cw1(CW_SIZE - 1 - 6  downto 0);
		cw3 <= cw2(CW_SIZE - 1 - 18 downto 0);
		cw4 <= cw3(CW_SIZE - 1 - 25 downto 0);
		
		aluOpcode1 <= aluOpcode_i;
		aluOpcode2 <= aluOpcode1;
		
		sel_regA1 <= sel_regA_i;
		
		sel_regB1 <= sel_regB_i;

		sel_OP1_forwarded1 <= sel_OP1_forwarded_i;
		sel_OP1_forwarded2 <= sel_OP1_forwarded1;
	
		sel_OP2_forwarded1 <= sel_OP2_forwarded_i;
		sel_OP2_forwarded2 <= sel_OP2_forwarded1;
		
		sel_muxB1_1 <= sel_muxB1_i;
		sel_muxB1_2 <= sel_muxB1_1;
		
		sel_muxmem1 <= sel_mux_mem_i;
		sel_muxmem2 <= sel_muxmem1;
		sel_muxmem3 <= sel_muxmem2;

    end if;
end process CW_PIPE;


ALU_OPCODE 			<= aluOpcode2;                        
sel_regA       		<= sel_regA1;
sel_regB      		<= sel_regB1;
sel_OP1_forwarded 	<= sel_OP1_forwarded2;
sel_OP2_forwarded 	<= sel_OP2_forwarded2;
sel_muxB1         	<= sel_muxB1_2;
sel_mux_mem        	<= sel_muxmem3;


-- purpose: Generation of ALU OpCode
-- type   : combinational
-- inputs : IR_i
-- outputs: aluOpcode
ALU_OP_CODE_P : process (IR_opcode, IR_func, stall_cond)
begin  -- process ALU_OP_CODE_P
  if stall_cond = '1' then
    aluOpcode_i <= no_op;
  else 
    case conv_integer(unsigned(IR_opcode)) is		-- opcode: 6:0
		when 3	=> aluOpcode_i <= ADD_OPC; -- lw  
		when 19	=> -- ITYPE
			case conv_integer(unsigned(IR_func)) is -- FUNC:  FUNC3 14:12
				when 0 => aluOpcode_i <= ADD_OPC;
				when 5 => aluOpcode_i <= SRAI_OPC;
				when 7 => aluOpcode_i <= ANDI_OP;
				when others => aluOpcode_i <= no_op;
			end case;
		when 23	=> aluOpcode_i <= ADD_OPC; -- auipc
		when 35 => aluOpcode_i <= ADD_OPC; -- sw 
		when 51 => -- RTYPE
			case conv_integer(unsigned(IR_func)) is  -- FUNC: FUNC3 14:12
			  when 0  => aluOpcode_i <= ADD_OPC;
			  when 2  => aluOpcode_i <= SLT_OP;
			  when 4  => aluOpcode_i <= XOR_OP;
			  when others => aluOpcode_i <= no_op;
			end case;
		when 55    => aluOpcode_i <= ADD_OPC; -- lui
		when 99    => aluOpcode_i <= ADD_OPC; -- beq
		when 111  => aluOpcode_i <= ADD_OPC; -- jal
		when others => aluOpcode_i <= no_op;
    end case;
  end if;
end process ALU_OP_CODE_P;

end architecture;
