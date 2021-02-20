library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity decode_stage is 
	generic(
		IR_SIZE    	: integer := IR_SIZE;
		data_SIZE   : integer := data_SIZE;
		add_size   	: integer := add_size);
	port(
		Rst  			: in std_logic; 
		clk  			: in std_logic;
		
	   --control signals	
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
		
		-- inputs:
      -- from fetch stage
		NPC_in          : in std_logic_vector(data_SIZE-1 downto 0);
		NPC_reg_in      : in std_logic_vector(data_SIZE-1 downto 0);
		IR_in	        : in std_logic_vector(IR_SIZE-1  downto 0);    -- form register
		InstrRAM_in     : in std_logic_vector(IR_SIZE-1 downto 0);     -- NOT from register
		PC1_in          : in std_logic_vector(data_size-1 downto 0);
		-- from execute stage
		addr_write_in   : in std_logic_vector(add_size-1 downto 0);
		aluout_reg_in   : in std_logic_vector(data_size-1 downto 0);
		-- from writeback stage
		RFdata_in       : in std_logic_vector(data_size-1 downto 0);
		
		-- outputs:
		-- to execute stage:
		PC2_out         : out std_logic_vector(data_size-1 downto 0);
		NPC1_out        : out std_logic_vector(data_size-1 downto 0);
		regA_out        : out std_logic_vector(data_size-1 downto 0);
		regB_out        : out std_logic_vector(data_size-1 downto 0);
		regIMM_out		: out std_logic_vector(data_size-1 downto 0);
		addr_write_out  : out std_logic_vector(add_size-1 downto 0);
		-- to fetch stage
		instruction_address_out	: out std_logic_vector(data_size-1 downto 0);
		-- to CU
		branch_jump_sign_out	: out std_logic;
		stall             		: out std_logic;
		forwarding_ij_out		: out std_logic_vector(2 downto 0);
		forwarding_ik_out		: out std_logic_vector(3 downto 0) 
		);
end entity;

architecture str of decode_stage is

signal 	A, B, 
		imm_block_out, imm_block_out_shifted,  
		muxA_out, muxB_out,
		adder_out			: std_logic_vector(data_size-1 downto 0);
signal IR1_out            	: std_logic_vector(IR_size-1 downto 0);
signal eq_NOTeq, branch_sign, branch_jump_sign : std_logic;
signal adder_out1         	: unsigned (data_size-1 downto 0);

component registerfile is 
	generic(
		A     : integer := add_size;
        D     : integer := data_size
        );
	port( 
		CLK		: IN std_logic;
        RESET	: IN std_logic;
	    WR		: IN std_logic;
	    ADD_WR	: IN std_logic_vector(A-1 downto 0);
	    ADD_RD1	: IN std_logic_vector(A-1 downto 0);
	    ADD_RD2	: IN std_logic_vector(A-1 downto 0);
	    DATAIN	: IN std_logic_vector(D-1 downto 0);
        OUT1	: OUT std_logic_vector(D-1 downto 0);
	    OUT2	: OUT std_logic_vector(D-1 downto 0));
end component;

component reg is
	generic(
		data_size 	: integer := data_size
		);
	port(
		Rst  		: in std_logic; 
		clk  		: in std_logic; 
		enable		: in std_logic;
		Din  		: in std_logic_vector(data_size-1 downto 0);
		Dout 		: out std_logic_vector(data_size-1 downto 0) 
		);
end component;

component mux2to1 is
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
end component;

component adder is
	generic(
		SIZE : integer := data_size 
		);
	port(
		a, b : in  unsigned(SIZE-1 downto 0);
		z    : out unsigned(SIZE-1 downto 0) 
		);
end component;

component comparator_block is
	generic(
		SIZE : integer := data_size 
		);
	port(
		a, b : in  std_logic_vector(SIZE-1 downto 0);
		z    : out std_logic 
		);
end component;

component immediate_block is
	generic(
		ir_size 	: integer := IR_size;
		data_size	: integer := data_size 
		);
	port(
		imm_in	: in std_logic_vector(ir_size-1 downto 0);
		sel   	: in std_logic_vector(2 downto 0);
		imm_out	: out std_logic_vector(data_size-1 downto 0)
			);
end component;

component stall_detection_unit is
	generic(
		IR_SIZE	: integer := IR_SIZE	
		);
	port( 
		IR_IF_ID	: in std_logic_vector(IR_SIZE-1 downto 0);
		IR_ID_EX	: in std_logic_vector(IR_SIZE-1 downto 0);
		stall   	: out std_logic
		);
end component;

component forwarding_detection_unit is
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
end component;

begin

Register_File	: registerfile
					port map (CLK => clk, RESET => rst, WR => rf_we, ADD_WR => addr_write_in, ADD_RD1 => IR_in(19 downto 15),
							  ADD_RD2 => IR_in(24 downto 20), DATAIN => RFdata_in, OUT1 => A, OUT2 => B);

Imm_Block    	: immediate_block
					port map (imm_in => IR_in, sel => sel_immediate , imm_out => imm_block_out);
					
Stall_check  	: stall_detection_unit
					port map (IR_IF_ID => InstrRAM_in, IR_ID_EX => IR_in, stall => stall);
					
IR1_register 	: reg
					generic map (data_size => IR_size)
					port map (Rst => Rst, CLK => Clk, Enable => IR1_EN, Din => IR_in, Dout => IR1_out);

Forwarding   	: forwarding_detection_unit
					port map (IR_IF_ID => InstrRAM_in, IR_ID_EX => IR_in, IR_EX_MEM => IR1_out,
							  forwarding_ij => forwarding_ij_out, forwarding_ik => forwarding_ik_out);

MuxA         	: mux2to1
					port map (A => A, B => aluout_reg_in, S => sel_regA, Y => muxA_out);
					
MuxB         	: mux2to1
					port map (A => B, B => aluout_reg_in, S => sel_regB, Y => muxB_out);	
	
Equality_check 	: comparator_block
					port map (a => muxA_out, b => muxB_out, z => eq_NOTeq);
					  
branch_sign <= eq_NOTeq AND branch;
branch_jump_sign <= branch_sign OR jump;
branch_jump_sign_out <= branch_jump_sign;

imm_block_out_shifted <= imm_block_out; 
Address_addition: adder
					port map (a => unsigned(PC1_in), b => unsigned(imm_block_out_shifted), z => adder_out1);
							  adder_out <= std_logic_vector(adder_out1);
		
Mux_for_PC 		: mux2to1
					port map (A => NPC_in, B => adder_out, S => branch_jump_sign, Y => instruction_address_out);
						
registerPC2  	: reg 
					port map (Rst => Rst, CLK => Clk, Enable => pc2_en, Din => PC1_in, Dout => PC2_out);
			
registerNPC1 	: reg 
					port map (Rst => Rst, CLK => Clk, Enable => NPC1_en, Din => NPC_in, Dout => NPC1_out);
			 
registerA 		: reg 
					port map (Rst => Rst, CLK => Clk, Enable => regA_en, Din => muxA_out, Dout => regA_out);
			 
registerB 		: reg 
					port map (Rst => Rst, CLK => Clk, Enable => regB_en, Din => muxB_out, Dout => regB_out);
			 
registerIMM 	: reg 
					port map (Rst => Rst, CLK => Clk, Enable => regIMM_en, Din => imm_block_out, Dout => regIMM_out);
			 
			 
registerAddrWR 	: reg 
					generic map (data_size => add_size)
					port map (Rst => Rst, CLK => Clk, Enable => regwr1_en, Din => IR_in(11 downto 7), Dout => addr_write_out);
end architecture;
