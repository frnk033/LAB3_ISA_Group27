library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.myTypes.all;

entity DATAPATH is
	generic(
		datamem_size  	: integer := datamem_size;
		IR_SIZE         : integer := IR_SIZE;
		add_size        : integer := add_size; 
		data_size       : integer := data_size;
		ALU_OPC_SIZE 	: integer := alu_opc_size);
	port(
		Rst  		 	: in std_logic; 
		clk  			: in std_logic; 
		--control signals:
		--fetch stage
		IR_EN  			: in  std_logic;
		NPC_EN 			: in  std_logic;
		PC_EN  			: in  std_logic;
		PC_SELECTOR 	: in  std_logic;
		IR_SELECTOR 	: in  std_logic;
		PC1_en 			: in  std_logic;
		IRAM_ins        : in  std_logic_vector(IR_SIZE-1 downto 0);         
		--decode stage
		rf_we			: in std_logic; 
		IR1_EN			: in std_logic; 
		rega_en   		: in std_logic; 
		regb_en   		: in std_logic; 
		regimm_en 		: in std_logic;
		regwr1_en   	: in std_logic;
		npc1_en			: in std_logic; 
		pc2_en      	: in std_logic;
		sel_regA		: in std_logic;
		sel_regB		: in std_logic;
		branch          : in std_logic;
		jump            : in std_logic;
		sel_immediate   : in std_logic_vector(2 downto 0);
		--execute stage
		NPC2_en  		: in std_logic;
		Aluout_en		: in std_logic;
		B1_en    		: in std_logic;
		regwr2_en		: in std_logic;
		sel_OP1         : in std_logic;
		sel_OP2         : in std_logic;
		sel_ALU_out     : in std_logic;
		alu_opcode     	: in std_logic_vector(alu_opc_size-1 downto 0);
		sel_OP1_forwarded: in std_logic_vector(2 downto 0);
		sel_OP2_forwarded: in std_logic_vector(2 downto 0);
		sel_muxB1        : in std_logic;
		--memory stage
		NPC3_en 		: in std_logic;
		LMD_en  		: in std_logic;
		Aluout1_en		: in std_logic;
		sel_mux_mem     : in std_logic_vector(1 downto 0);
		DRAM_data      	: in std_logic_vector(data_size-1 downto 0);
		--writeback
		NPC4_en 		: in std_logic;
		sel_mux1      	: in std_logic;
		sel_mux2      	: in std_logic;
		
		--outputs
		IRAM_add              : out std_logic_vector(data_SIZE-1 downto 0);
		DRAM_add              : out std_logic_vector(data_size-1 downto 0);
		DRAM_d                : out std_logic_vector(data_size-1 downto 0);
		branch_jump_sign_out  : out std_logic;
		stall                 : out std_logic;
		forwarding_ij_out	  : out std_logic_vector(2 downto 0); 
		forwarding_ik_out	  : out std_logic_vector(3 downto 0)  		
		);
end entity; 

architecture str of DATAPATH is 

signal 	NPC_out_i, NPC_reg_out_i,  PC1_out_i, PC2_out_i,
		NPC1_out_i,regA_out_i, regB_out_i,regIMM_out_i, 
		instruction_address_out_i ,  aluout_reg_out_i,
		NPC2_out_i, alureg_out_i, B1reg_out_i,
		DataRam_out_i, alu_1_out_i, NPC2_mem_out_i, NPC3_out_i,LMD_out_i, 
		aluout_MEM_out_i,  addr_dataram_i, datain_DRAM_i, RFdata_out_i		:std_logic_vector(data_size-1 downto 0);
signal 	IR_out_i, InstrRAM_out_i: std_logic_vector(IR_size-1 downto 0);
signal 	addr_write_out_i	, addr_write_out_ii    : std_logic_vector(add_size-1 downto 0);

component fetch_stage is
	generic(
		IRAM_SIZE 	 : integer := IRAM_SIZE;
		IR_SIZE  	 : integer := IR_SIZE;
		data_SIZE 	 : integer := data_SIZE;
		IRAM_LENGTH : integer := IRAM_LENGTH
		);
	port(
		Rst  		   : in  std_logic; 
		clk  		   : in  std_logic; 
		--contol signals
		IR_EN  : in  std_logic;
		NPC_EN : in  std_logic;
		PC_EN  : in  std_logic;
		PC_SELECTOR  : in  std_logic;
		IR_SELECTOR  : in  std_logic;
		PC1_en : in std_logic;
		--input
		fetch_in     : in  std_logic_vector(data_SIZE-1 downto 0);
		--outputs
		NPC_out	   : out std_logic_vector(data_SIZE-1 downto 0);
		NPC_reg_out  : out std_logic_vector(data_SIZE-1 downto 0); 
		IR_out	   : out std_logic_vector(IR_SIZE-1  downto 0); -- out of reg
		PC1_out      : out std_logic_vector(data_size-1 downto 0);
		  
		IRAM_out	: in std_logic_vector(IR_SIZE-1 downto 0);
		PC_out_i	: out std_logic_vector(data_SIZE-1 downto 0)
		);
end component;

component decode_stage is 
	generic(
		IR_SIZE    	: integer := IR_SIZE;
		data_SIZE   : integer := data_SIZE;
		add_size   	: integer := add_size
		);
	port(
		Rst  				: in std_logic; 
		clk  				: in std_logic;
		
		--control signals	
		rf_we				: in std_logic; 
		IR1_EN				: in std_logic; 
		rega_en   			: in std_logic; 
		regb_en   			: in std_logic; 
		regimm_en 			: in std_logic;
		regwr1_en   		: in std_logic;
		npc1_en			 	: in std_logic; 
		pc2_en      		: in std_logic;
		sel_regA			: in std_logic;
		sel_regB			: in std_logic;
		branch            	: in std_logic;
		jump              	: in std_logic;
		sel_immediate     	: in std_logic_vector(2 downto 0);
		
		-- inputs:
      -- from fetch stage
		NPC_in            	: in std_logic_vector(data_SIZE-1 downto 0);
		NPC_reg_in        	: in std_logic_vector(data_SIZE-1 downto 0);
		IR_in	            : in std_logic_vector(IR_SIZE-1  downto 0);    -- from register
		InstrRAM_in       	: in std_logic_vector(IR_SIZE-1 downto 0);     -- NOT from register
		PC1_in            	: in std_logic_vector(data_size-1 downto 0);
		-- from execute stage
		addr_write_in     	: in std_logic_vector(add_size-1 downto 0);
		aluout_reg_in     	: in std_logic_vector(data_size-1 downto 0);
		-- from writeback stage
		RFdata_in         	: in std_logic_vector(data_size-1 downto 0);
		
		-- outputs:
		-- to execute stage:
		PC2_out           	: out std_logic_vector(data_size-1 downto 0);
		NPC1_out          	: out std_logic_vector(data_size-1 downto 0);
		regA_out         	: out std_logic_vector(data_size-1 downto 0);
		regB_out          	: out std_logic_vector(data_size-1 downto 0);
		regIMM_out			: out std_logic_vector(data_size-1 downto 0);
		addr_write_out    	: out std_logic_vector(add_size-1 downto 0);
		-- to fetch stage
		instruction_address_out: out std_logic_vector(data_size-1 downto 0);
		-- to CU
		branch_jump_sign_out: out std_logic;
		stall             	: out std_logic;
		forwarding_ij_out	: out std_logic_vector(2 downto 0);  
		forwarding_ik_out	: out std_logic_vector(3 downto 0)  
		);
end component;

component execute_stage is
	generic(
		data_size      : integer := data_size;
		ALU_OPC_SIZE	: integer := alu_opc_size
		);
	port(
		Rst			 	: in std_logic;
		Clk			 	: in std_logic;
		
		-- control signals
		NPC2_en  		: in std_logic;
		Aluout_en		: in std_logic;
		B1_en    		: in std_logic;
		regwr2_en		: in std_logic;
		sel_OP1         : in std_logic;
		sel_OP2         : in std_logic;
		sel_ALU_out     : in std_logic;
		
		-- alu control signals
		alu_opcode     : in std_logic_vector(alu_opc_size-1 downto 0);
		
		-- forwarding control signals
		sel_OP1_forwarded	: in std_logic_vector(2 downto 0);
		sel_OP2_forwarded	: in std_logic_vector(2 downto 0);
		sel_muxB1        	: in std_logic;
		
		-- inputs:
		-- from decode stage
		PC2_in        		: in std_logic_vector(data_size-1 downto 0);
		NPC1_in          	: in std_logic_vector(data_size-1 downto 0);
		regA_in          	: in std_logic_vector(data_size-1 downto 0);
		regB_in          	: in std_logic_vector(data_size-1 downto 0);
		regIMM_in			: in std_logic_vector(data_size-1 downto 0);
		addr_write_in    	: in std_logic_vector(add_size-1 downto 0);
		-- from memory stage
		LMD_in     			: in std_logic_vector(data_size-1 downto 0);
		aluout_MEM_in 		: in std_logic_vector(data_size-1 downto 0); 
		NPC3_in       		: in std_logic_vector(data_size-1 downto 0);
		
		--outputs:
		-- to decode stage:
		addr_write_out     	: out std_logic_vector(add_size-1 downto 0);
		aluout_reg_out     	: out std_logic_vector(data_size-1 downto 0);
		-- to memory stage
		NPC2_out           	: out std_logic_vector(data_size-1 downto 0);
		alureg_out         	: out std_logic_vector(data_size-1 downto 0);
		B1reg_out          	: out std_logic_vector(data_size-1 downto 0));
end component;

component memory_stage is
	generic(
		IR_SIZE		 : integer := IR_SIZE;
		data_size    : integer := data_size
		);
	port(
		Rst			 : in std_logic;
		Clk			 : in std_logic;
			
		--control signals
        NPC3_en 	: in std_logic;
		LMD_en  	: in std_logic;
		ALuout1_en	: in std_logic;

		-- forwarding control signals
		sel_mux_mem : in std_logic_vector(1 downto 0);		
			
		-- inputs:
		-- from execute stage
		NPC2_in     : in std_logic_vector(data_size-1 downto 0);
		alureg_in   : in std_logic_vector(data_size-1 downto 0);
		B1reg_in    : in std_logic_vector(data_size-1 downto 0);
		-- from external DATARAM
		Data_ram_i  : in std_logic_vector(data_size-1 downto 0);
		
		-- outputs:
		-- to writeback stage
		DataRam_out : out std_logic_vector(data_size-1 downto 0);
		alu_1_out   : out std_logic_vector(data_size-1 downto 0);
		NPC2_mem_out: out std_logic_vector(data_size-1 downto 0);   
		-- to execute stage
		NPC3_out    : out std_logic_vector(data_size-1 downto 0);
		LMD_out     : out std_logic_vector(data_size-1 downto 0);
		aluout_MEM_out  : out std_logic_vector(data_size-1 downto 0); 
		-- to DATARAM
		addr_dataram    : out std_logic_vector(data_size-1 downto 0);
		datain_DRAM     : out std_logic_vector(data_size-1 downto 0)
		);
end component;

component writeback_stage is
	generic(
		data_size	: integer := data_size
		);
	port(
	    Rst : in std_logic;
		Clk : in std_logic;
		 
		-- control signals 
		NPC4_en 	: in std_logic;
		sel_mux1    : in std_logic;
		sel_mux2    : in std_logic;
		
		-- inputs
		-- from  memory stage
		alu_1_in    : in std_logic_vector(data_size-1 downto 0);
		NPC3_in     : in std_logic_vector (data_size-1 downto 0);
		DataRam_in  : in std_logic_vector(data_size-1 downto 0);
		NPC2_mem_in : in std_logic_vector(data_size-1 downto 0);
		
		-- outputs
		-- to decode stage
		RFdata_out  : out std_logic_vector(data_size-1 downto 0)
		);
end component;

begin

FETCH: fetch_stage
		port map(
			Rst  		=> Rst,  
			clk   		=> Clk, 
			-- inputs
			IR_EN     	=> IR_EN,
			NPC_EN   	=> NPC_EN,
			PC_EN  		=> PC_EN,
			PC_SELECTOR	=> PC_SELECTOR,
			IR_SELECTOR => IR_SELECTOR,
			PC1_en    	=> PC1_en,
			fetch_in    => instruction_address_out_i, 
			IRAM_out	=> IRAM_ins,
			--outputs
			NPC_out	    => NPC_out_i, 
			NPC_reg_out => NPC_reg_out_i, 
			IR_out	    => IR_out_i, -- out of reg
			PC1_out     => PC1_out_i,
			PC_out_i	=> IRAM_add
		);			 

DECODE: decode_stage
		port map(
			Rst  		=> Rst, 
			clk  		=> Clk, 
			--inputs
			rf_we		=> rf_we,
			IR1_EN		=> IR1_EN,  
			rega_en   	=> rega_en, 
			regb_en   	=> regb_en,
			regimm_en 	=> regimm_en, 
			regwr1_en   => regwr1_en, 
			npc1_en		=> npc1_en,
			pc2_en      => pc2_en,
			sel_regA	=> sel_regA,
			sel_regB	=> sel_regB,
			branch      => branch, 
			jump        => jump, 
			sel_immediate	=> sel_immediate,
			NPC_in          => NPC_out_i, 
			NPC_reg_in      => NPC_reg_out_i,
			IR_in	        => IR_out_i,    -- form register
			InstrRAM_in     => IRAM_ins,     -- NOT from register
			PC1_in          => PC1_out_i, 
			addr_write_in   => addr_write_out_ii,
			aluout_reg_in   => aluout_reg_out_i,
			RFdata_in       => RFdata_out_i,
			
			-- outputs:
			PC2_out         => PC2_out_i, 
			NPC1_out        => NPC1_out_i,
			regA_out        => regA_out_i, 
			regB_out        => regB_out_i,
			regIMM_out		=> regIMM_out_i,
			addr_write_out  => addr_write_out_i,
			instruction_address_out => instruction_address_out_i, 
			-- to CU
			branch_jump_sign_out	=> branch_jump_sign_out,
			stall                 	=> stall,
			forwarding_ij_out		=> forwarding_ij_out,  
			forwarding_ik_out	    => forwarding_ik_out							
		);

EXECUTE: execute_stage
		port map(
			Rst			 		=> Rst, 
			Clk			 		=> Clk,
			-- inputs
			NPC2_en  			=> NPC2_en,
			Aluout_en 			=> Aluout_en, 
			B1_en     			=> B1_en, 
			regwr2_en 			=> regwr2_en, 
			sel_OP1         	=> sel_OP1,
			sel_OP2         	=> sel_OP2,
			sel_ALU_out     	=> sel_ALU_out, 
			alu_opcode     		=> alu_opcode,
			sel_OP1_forwarded 	=> sel_OP1_forwarded,
			sel_OP2_forwarded	=> sel_OP2_forwarded, 
			sel_muxB1        	=> sel_muxB1,
			
			-- inputs:
			PC2_in           	=> PC2_out_i,
			NPC1_in          	=> NPC1_out_i,
			regA_in          	=> regA_out_i,
			regB_in          	=> regB_out_i,
			regIMM_in	     	=> regIMM_out_i,
			addr_write_in    	=> addr_write_out_i,
			-- from memory stage
			LMD_in     			=> LMD_out_i,
			aluout_MEM_in 		=> aluout_MEM_out_i,
			NPC3_in      		=> NPC3_out_i,
			
			--outputs:
			-- to decode stage:
			addr_write_out     	=> addr_write_out_ii, 
			aluout_reg_out     	=>  aluout_reg_out_i,
			-- to memory stage
			NPC2_out          	=> NPC2_out_i,
			alureg_out         	=> alureg_out_i,
			B1reg_out          	=> B1reg_out_i						
		);
						
MEMORY: memory_stage
		port map (
			Rst	   			=> Rst,
			Clk				=> Clk,
			-- inputs
			NPC3_en 		=> NPC3_en,
			LMD_en  		=> LMD_en,
			ALuout1_en 		=> Aluout1_en,
			sel_mux_mem 	=> sel_mux_mem,
			
			-- inputs:
			-- from execute stage
			NPC2_in         => NPC2_out_i,
			alureg_in       => alureg_out_i,
			B1reg_in        => B1reg_out_i,
			-- from external DATARAM
			Data_ram_i      => Dram_data, 
			
			-- outputs:
			-- to writeback stage
			DataRam_out     => DataRam_out_i,
			alu_1_out       => alu_1_out_i,
			NPC2_mem_out	=> NPC2_mem_out_i, 
			-- to execute stage
			NPC3_out        => NPC3_out_i,
			LMD_out        	=> LMD_out_i,
			aluout_MEM_out 	=> aluout_MEM_out_i, 
			-- to DATARAM
			addr_dataram    => addr_dataram_i,
			datain_DRAM     => datain_DRAM_i
		);
Dram_add <= addr_dataram_i;
DRAM_d   <= datain_DRAM_i;

WRITEBACK: writeback_stage
		port map(
			Rst 			=> Rst, 
			Clk 			=> Clk,
				
			NPC4_en 		=> NPC4_en,
			sel_mux1      	=> sel_mux1,
			sel_mux2      	=> sel_mux2,
				
			-- inputs
			-- from  memory stage
			alu_1_in      	=> alu_1_out_i,
			NPC3_in        	=> NPC3_out_i,
			DataRam_in     	=> DataRam_out_i,
			NPC2_mem_in    	=> NPC2_mem_out_i,
				
			-- outputs
			-- to decode stage
			RFdata_out    	=> RFdata_out_i
		);
end architecture;