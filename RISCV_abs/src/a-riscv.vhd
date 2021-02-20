library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all; 
use work.myTypes.all;

entity riscv is				
	port(
		Clk 			: in std_logic;
		Rst 			: in std_logic;			-- Active Low
		
		IRAM_out		: in std_logic_vector(IR_SIZE-1 downto 0);
		IRAM_add		: out std_logic_vector(PC_SIZE-1 downto 0);

		Dram_add 		: out std_logic_vector(data_size-1 downto 0);
		Dram_data_in 	: out std_logic_vector(data_size-1 downto 0);
		Dram_we 		: out std_logic;
		Dram_rd 		: out std_logic;
		Dram_data_out 	: in std_logic_vector(data_Size-1 downto 0)
		);         
end entity; 


architecture str of riscv is 

signal	PC_en_i, PC1_EN_i, pc2_en_i, IR_en_i, NPC_en_i, 
		rf_we_i, regimm_en_i, regb_en_i, rega_en_i, npc1_en_i,
		sel_regB_i, mux_a_sel_i, mux_b_sel_i, branch_i, -- eqz_neqz_i
		B1_en_i, sel_OP1_i, sel_OP2_i, sel_ALU_out_i, sel_muxB1_i,
		alu_output_en_i, npc2_en_i, jump_i, lmd_en_i,
		alu_output_en1_i, NPC3_en_i, NPC4_en_i,
		regwr1_en_i, regwr2_en_i, sel_mux1_i, sel_mux2_i, 
		stall_i, pc_selector_i, ir_selector_i, IR1_EN_i,  br_j_i, sel_RegA_i, 
		mux_branch_sel_i, mux_opa_sel_i	: std_logic;
signal sel_mux_mem_i : std_logic_vector(1 downto 0);
signal  forwarding_ij_i, sel_OP1_forwarded_i, sel_OP2_forwarded_i, sel_immediate_i			: std_logic_vector(2 downto 0);
signal	alu_opcode_i	: std_logic_vector(alu_opc_size-1 downto 0);
signal 	DRAM_data_i, IRAM_add_i, DRAM_add_i, DRAM_d_i		: std_logic_vector(data_SIZE-1 downto 0);
signal 	forwarding_ik_i	: std_logic_vector(3 downto 0);

component datapath is 
	generic(
		datamem_size  	: integer := datamem_size;
		IR_SIZE         : integer := IR_SIZE;
		data_size       : integer := data_size;
		ALU_OPC_SIZE 	: integer := ALU_OPC_SIZE);
	port(
		Rst  		 			: in std_logic; 
		clk  					: in std_logic; 
		--control signals:
		--fetch stage
		IR_EN  		: in  std_logic;
		NPC_EN 		: in  std_logic;
		PC_EN  		: in  std_logic;
		PC_SELECTOR : in  std_logic;
		IR_SELECTOR : in  std_logic;
		PC1_en 		: in  std_logic;
		IRAM_ins    : in  std_logic_vector(IR_SIZE-1 downto 0);         
		--decode stage
		rf_we		: in std_logic; 
		IR1_EN		: in std_logic; 
		rega_en   	: in std_logic; 
		regb_en   	: in std_logic; 
		regimm_en 	: in std_logic;
		regwr1_en   : in std_logic;
		npc1_en		: in std_logic; 
		pc2_en      : in std_logic;
		sel_regA	: in std_logic;
		sel_regB	: in std_logic;
		branch      : in std_logic;
		jump        : in std_logic;
		sel_immediate : in std_logic_vector(2 downto 0);
		--execute stage
		NPC2_en  	: in std_logic;
		Aluout_en	: in std_logic;
		B1_en    	: in std_logic;
		regwr2_en	: in std_logic;
		sel_OP1     : in std_logic;
		sel_OP2     : in std_logic;
		sel_ALU_out : in std_logic;
		alu_opcode  : in std_logic_vector(alu_opc_size-1 downto 0);
		sel_OP1_forwarded: in std_logic_vector(2 downto 0);
		sel_OP2_forwarded: in std_logic_vector(2 downto 0);
		sel_muxB1        : in std_logic;
		--memory stage
		NPC3_en 	: in std_logic;
		LMD_en  	: in std_logic;
		ALuout1_en	: in std_logic;
		sel_mux_mem : in std_logic_vector(1 downto 0);
		DRAM_data   : in std_logic_vector(data_size-1 downto 0);
		--writeback
		NPC4_en 	: in std_logic;
		sel_mux1    : in std_logic;
		sel_mux2    : in std_logic;
		
		--outputs
		IRAM_add    : out std_logic_vector(pc_SIZE-1 downto 0);
		DRAM_add    : out std_logic_vector(data_size-1 downto 0);
		DRAM_d      : out std_logic_vector(data_size-1 downto 0);
		branch_jump_sign_out  : out std_logic;
		stall                 : out std_logic;
		forwarding_ij_out	  : out std_logic_vector(2 downto 0);  
		forwarding_ik_out	  : out std_logic_vector(3 downto 0)  	
		);
end component; 

component CU is 
	generic(
		MICROCODE_MEM_SIZE	: integer := MICROCODE_MEM_SIZE;-- Microcode Memory Size
		FUNC_SIZE          	: integer := FUNC_SIZE; 		-- Func Field Size for R-Type Ops
		OP_CODE_SIZE       	: integer := OP_CODE_SIZE;   	-- Op Code Size
		ALU_OPC_SIZE       	: integer := ALU_OPC_SIZE;   	-- ALU Op Code Word Size
		IR_SIZE            	: integer := IR_SIZE;   		-- Instruction Register Size    
		CW_SIZE            	: integer := CW_SIZE			-- Control Word Size
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
		IR_EN       		: out std_logic;  	-- Instruction Register Latch Enable
		NPC_EN       		: out std_logic;  	-- NextProgramCounter Register Latch Enable
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
		branch           	: out std_logic;
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
end component; 

begin 

control_unit : CU
				port map(
					Clk             => Clk, 
					Rst             => Rst, 
					
					-- Inputs
					IR_IN           => IRAM_out, 
					stall 			=> stall_i,
					forwarding_ij 	=> forwarding_ij_i,
					forwarding_ik 	=> forwarding_ik_i,
					br_j_sig 		=> br_j_i,
	
					-- Outputs
					-- IF Control Signals
					IR_EN     		=> IR_EN_i,
					PC_EN			=> PC_EN_i,
					NPC_EN    		=> NPC_EN_i, 
					PC_SELECTOR		=> PC_SELECTOR_i,
					IR_SELECTOR		=> IR_SELECTOR_i, 
					PC1_EN			=> PC1_EN_i, 
					 
					-- ID Control Signals
					RF_WE           => rf_we_i,
					IR1_EN          => IR1_EN_i,
					RegA_EN   		=> RegA_en_i, 
					RegB_EN   		=> RegB_en_i,
					RegIMM_EN 		=> RegImm_en_i,
					regwr1_en		=> regwr1_en_i,
					npc1_en			=> npc1_en_i, 
					pc2_en			=> pc2_en_i,	
					sel_regA		=> sel_RegA_i,
					sel_regB		=> sel_regB_i,
					branch			=> branch_i,
					jump			=> jump_i,
					sel_immediate	=> sel_immediate_i,
					 
					-- EX Control Signals
					ALUOUT_EN   	=> alu_output_en_i,
					npc2_en			=> npc2_en_i,
					B1_en			=> B1_en_i,
					regwr2_en 		=> regwr2_en_i, 	
					sel_OP1			=> sel_OP1_i,
					sel_OP2			=> sel_OP2_i,
					sel_ALU_out		=> sel_ALU_out_i,
					alu_opcode		=> alu_opcode_i,
					sel_OP1_forwarded => sel_OP1_forwarded_i,
					sel_OP2_forwarded => sel_OP2_forwarded_i,
					sel_muxB1		=> sel_muxB1_i,

					-- MEM Control Signals
					NPC3_en			=> NPC3_en_i,
					sel_mux_mem 	=> sel_mux_mem_i,
					LMD_EN    		=> lmd_en_i, 
					aluout1_en  	=> alu_output_en1_i,
					WR_DRAM         => dram_we,
					RD_DRAM			=> dram_rd,

					-- WB Control signals
					NPC4_en			=> NPC4_en_i,
					sel_mux1		=> sel_mux1_i,
					sel_mux2		=> sel_mux2_i
				);

data_path : datapath
			port map(			
				Rst				=> Rst, 
				clk  		    => Clk,
				-- fetch stage
				PC_en     	=> PC_en_i,  
				IR_en    	=> IR_en_i, 
				NPC_en    	=> NPC_en_i, 
				pc_selector	=> pc_selector_i, 
				ir_selector	=> ir_selector_i,
				PC1_EN		=> PC1_EN_i,
				IRAM_ins	=> IRAM_out,
				
				-- decode stage
				rf_we		=> rf_we_i,
				IR1_EN		=> IR1_EN_i,
				sel_immediate => sel_immediate_i, 
				regimm_en 	=> regimm_en_i,  
				regb_en   	=> regb_en_i,  
				rega_en   	=> rega_en_i, 
				regwr1_en 	=> regwr1_en_i, 
				npc1_en     => npc1_en_i, 
				pc2_en		=> pc2_en_i,
				sel_regA	=> sel_regA_i,
				sel_regB	=> sel_regB_i,
				branch      => branch_i,
				jump		=> jump_i,
				
				-- execute stage
				alu_opcode  => alu_opcode_i, 
				aluout_en   => alu_output_en_i,  
				npc2_en     => npc2_en_i, 
				B1_en		=> B1_en_i,
				regwr2_en	=> regwr2_en_i,
				sel_OP1		=> sel_OP1_i,
				sel_OP2		=> sel_OP2_i,
				sel_ALU_out	=> sel_ALU_out_i,
				sel_OP1_forwarded	=> sel_OP1_forwarded_i,
				sel_OP2_forwarded	=> sel_OP2_forwarded_i,
				sel_muxB1	=> sel_muxB1_i,
				
				-- memory stage
				NPC3_en		=> NPC3_en_i,
				lmd_en    	=> lmd_en_i,  
				aluout1_en  => alu_output_en1_i,
				sel_mux_mem	=> sel_mux_mem_i,
				DRAM_data	=> DRAM_data_out,
				
				-- writeback stage
				NPC4_en		=> NPC4_en_i,
				sel_mux1	=> sel_mux1_i,
				sel_mux2	=> sel_mux2_i,

				-- Outputs
				stall 					=> stall_i, 
				forwarding_ij_out   	=> forwarding_ij_i,
				forwarding_ik_out   	=> forwarding_ik_i, 
				branch_jump_sign_out	=> br_j_i,
				IRAM_add				=> IRAM_add,
				DRAM_add				=> DRAM_add,
				DRAM_d					=> DRAM_data_in
			);
end architecture;
