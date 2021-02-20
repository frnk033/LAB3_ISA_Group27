library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity execute_stage is
	generic(
		data_size    	: integer := data_size;
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
		alu_opcode     	: in std_logic_vector(alu_opc_size-1 downto 0);
		
		-- forwarding control signals
		sel_OP1_forwarded: in std_logic_vector(2 downto 0);
		sel_OP2_forwarded: in std_logic_vector(2 downto 0);
		sel_muxB1        : in std_logic;
		
		-- inputs:
		-- from decode stage
		PC2_in          : in std_logic_vector(data_size-1 downto 0);
		NPC1_in         : in std_logic_vector(data_size-1 downto 0);
		regA_in         : in std_logic_vector(data_size-1 downto 0);
		regB_in         : in std_logic_vector(data_size-1 downto 0);
		regIMM_in		: in std_logic_vector(data_size-1 downto 0);
		addr_write_in   : in std_logic_vector(add_size-1 downto 0);
		-- from memory stage
		LMD_in     		: in std_logic_vector(data_size-1 downto 0);
		aluout_MEM_in 	: in std_logic_vector(data_size-1 downto 0); 
		NPC3_in       	: in std_logic_vector(data_size-1 downto 0);
		
		--outputs:
		-- to decode stage:
		addr_write_out  : out std_logic_vector(add_size-1 downto 0);
		aluout_reg_out  : out std_logic_vector(data_size-1 downto 0);
		-- to memory stage
		NPC2_out        : out std_logic_vector(data_size-1 downto 0);
		alureg_out      : out std_logic_vector(data_size-1 downto 0);
		B1reg_out       : out std_logic_vector(data_size-1 downto 0));
end entity;

architecture str of execute_stage is

signal 	muxop1_out, muxop2_out, operand1, operand2,
		alu_result, muxAlu_out, muxB1_out, alu_output_reg_ex	: std_logic_vector(data_size-1 downto 0); 

component mux2to1 is
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
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

component mux5to1 is
	Generic(N: integer:= data_size);
	Port(	A:	In	std_logic_vector(N-1 downto 0) ;
			B:	In	std_logic_vector(N-1 downto 0);
			C:	In	std_logic_vector(N-1 downto 0);
			D:	In	std_logic_vector(N-1 downto 0);
			E:	In	std_logic_vector(N-1 downto 0);
			S:	In	std_logic_vector(2 downto 0);
			Y:	Out	std_logic_vector(N-1 downto 0));
end component;

component ALU is
	generic(
		N 			: integer := data_size;
		OP			: integer := alu_Opc_size
		);
	port( 
        DATA1, DATA2 : IN std_logic_vector(N-1 downto 0);
		aluOpcode 	 : IN std_logic_vector(OP-1 downto 0);
        OUTALU		 : OUT std_logic_vector(N-1 downto 0));
end component;


begin 

mux_for_op1		: mux2to1
					port map (A => PC2_in, B => regA_in, S => sel_OP1, Y => muxop1_out);
				 
mux_for_op2		: mux2to1
					port map (A => regB_in, B => regIMM_in, S => sel_OP2, Y => muxop2_out);

mux_for_op1_forwarding	: mux5to1
							port map (A => muxop1_out, B => alu_output_reg_ex, C =>aluout_MEM_in,
									  D => LMD_in, E => NPC3_in, S => sel_OP1_forwarded, Y => Operand1);

mux_for_op2_forwarding	: mux5to1
							port map (A => muxop2_out, B => alu_output_reg_ex, C => aluout_MEM_in,
									  D => LMD_in, E => NPC3_in, S => sel_OP2_forwarded, Y => Operand2);

ALU_unit		: ALU
					port map (DATA1 => Operand1, Data2 => operand2, aluopcode => alu_opcode, OUTALU => alu_result);
								
mux_after_alu 	: mux2to1
					port map (A => alu_result, B => regIMM_in, S => sel_ALU_out, Y => muxAlu_out);

registerALU 	: reg 
					port map (Rst => Rst, CLK => Clk, Enable => Aluout_en, Din => muxAlu_out, Dout =>alu_output_Reg_ex );
aluReg_out <= alu_output_reg_ex;
aluout_reg_out <= alu_output_reg_ex;

registerNPC2 	: reg 
					port map (Rst => Rst, CLK => Clk, Enable => NPC2_en, Din => NPC1_in, Dout => NPC2_out);
					
mux_for_B1  	: mux2to1
					port map (A => regB_in, B =>  LMD_in, S => sel_muxB1, Y => muxB1_out);
								
registerB1  	: reg
					port map (Rst => Rst, CLK => Clk, Enable => B1_en, Din => muxB1_out, Dout => B1reg_out);
								
registerAddrWr 	: reg 
					generic map (data_size => add_size)
					port map (Rst => Rst, CLK => Clk, Enable => regwr2_en, Din => addr_write_in, Dout => addr_write_out);
				
end architecture;
