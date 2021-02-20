library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity memory_stage is 
	generic(
		IR_SIZE		 	: integer := IR_SIZE; 
		data_size    	: integer := data_size
		);
	port(
		Rst				: in std_logic;
		Clk				: in std_logic;
			
		--control signals
        NPC3_en 		: in std_logic;
		LMD_en  		: in std_logic;
		ALuout1_en		: in std_logic;
			
		-- forwarding control signals
		sel_mux_mem     : in std_logic_vector(1 downto 0);		
			
		-- inputs:
		-- from execute stage
		NPC2_in         : in std_logic_vector(data_size-1 downto 0);
		alureg_in       : in std_logic_vector(data_size-1 downto 0);
		B1reg_in        : in std_logic_vector(data_size-1 downto 0);
		-- from external DATARAM
		Data_ram_i      : in std_logic_vector(data_size-1 downto 0);
		
		-- outputs:
		-- to writeback stage
		DataRam_out     : out std_logic_vector(data_size-1 downto 0);
		alu_1_out       : out std_logic_vector(data_size-1 downto 0);
		NPC2_mem_out    : out std_logic_vector(data_size-1 downto 0);   
		-- to execute stage
		NPC3_out        : out std_logic_vector(data_size-1 downto 0);
		LMD_out         : out std_logic_vector(data_size-1 downto 0);
		aluout_MEM_out  : out std_logic_vector(data_size-1 downto 0); 
		-- to DATARAM
		addr_dataram    : out std_logic_vector(data_size-1 downto 0);
		datain_DRAM     : out std_logic_vector(data_size-1 downto 0)
		);
end entity;

architecture str of memory_stage is 

signal alu_1_out_i, LMD_i	: std_logic_vector(data_size-1 downto 0);

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

component mux3to1 is 
	Generic(
		N: integer:= data_size
		);
	Port(	
		A:	in	std_logic_vector(N-1 downto 0) ;
		B:	in	std_logic_vector(N-1 downto 0);
		C:  in  std_logic_vector(N-1 downto 0);
		S:	in	std_logic_vector(1 downto 0);
		Y:	out	std_logic_vector(N-1 downto 0)
		);
end component;

begin

mux_mem_stage: mux3to1
				port map (A => B1reg_in, B => alu_1_out_i, C => LMD_i, S => sel_mux_mem, Y => datain_DRAM);

registerNPC3 : reg 
			    port map (Rst => Rst, CLK => Clk, Enable => NPC3_en, Din => NPC2_in, Dout => NPC3_out);

registerLMD  : reg 
			    port map (Rst => Rst, CLK => Clk, Enable => LMD_en, Din => Data_ram_i, Dout => LMD_i);
				
LMD_out <= LMD_i;

registerALU1 : reg 
			    port map (Rst => Rst, CLK => Clk, Enable => Aluout1_en, Din => alureg_in, Dout => alu_1_out_i);
					
alu_1_out <= alureg_in;					
aluout_MEM_out <= alu_1_out_i;
NPC2_mem_out <= NPC2_in;
dataram_out <= data_ram_i;	
addr_dataram <= alureg_in;				

end architecture;
