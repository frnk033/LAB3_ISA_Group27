library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity fetch_stage is 
	generic(
		IRAM_SIZE 	: integer := IRAM_SIZE;
		IR_SIZE  	: integer := IR_SIZE;
		data_SIZE 	: integer := data_SIZE;
		IRAM_LENGTH : integer := IRAM_LENGTH;
		pc_size 	: integer := Pc_size
		);
	port(
		Rst  		: in  std_logic; 
		clk  		: in  std_logic; 
		--contol signals
		IR_EN  		: in  std_logic;
		NPC_EN 		: in  std_logic;
		PC_EN  		: in  std_logic;
		PC_SELECTOR : in  std_logic;
		IR_SELECTOR : in  std_logic;
		PC1_en 		: in std_logic;
		--input
		fetch_in    : in  std_logic_vector(data_SIZE-1 downto 0);
		--outputs
		NPC_out	   	: out std_logic_vector(pc_SIZE-1 downto 0);
		NPC_reg_out : out std_logic_vector(pc_SIZE-1 downto 0); 
		IR_out	   	: out std_logic_vector(IR_SIZE-1  downto 0); -- out of reg
		PC1_out     : out std_logic_vector(pc_size-1 downto 0);
		IRAM_out	: in std_logic_vector(IR_SIZE-1 downto 0);
		PC_out_i	: out std_logic_vector(pc_SIZE-1 downto 0)
		);
end fetch_stage;

architecture beh of fetch_stage is 

	signal adder_out_uns, four              : unsigned(data_SIZE-1 downto 0);
	signal PC_out, adder_out , mux_2to1_out : std_logic_vector(pc_SIZE-1 downto 0); 
	signal IR_selector_out           		: std_logic_vector (IR_SIZE-1 downto 0); 

component adder is 
	generic(
		SIZE : integer := data_size 
	);
	port(
		a, b : in  unsigned(SIZE-1 downto 0);
		z    : out unsigned(SIZE-1 downto 0) 
		);
end component; 

component mux2to1 is
	Generic (
		N: integer:= data_size
		);
	Port(	
		A:	In	std_logic_vector(N-1 downto 0) ;
		B:	In	std_logic_vector(N-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(N-1 downto 0)
		);
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

begin

four <= to_unsigned(4, four'length);

Program_counter : reg
					port map(Rst => Rst, Clk => Clk, Enable => PC_EN, Din => fetch_in, Dout => PC_out); 

Add_to_PC       : Adder
					generic map (SIZE => data_SIZE)
					port map (a => unsigned(PC_out), b => four, z => adder_out_uns);
					
adder_out <= std_logic_vector(adder_out_uns);  
					
Next_progr_count: reg
					port map (Rst => Rst, Clk => Clk, Enable => NPC_EN, Din => mux_2to1_out, Dout => NPC_reg_out);     --NPC_EN
					
PC_out_i <= PC_out;  

Instr_register  : reg
					generic map(data_size => IR_size)
					port map (Rst => Rst, Clk => Clk, Enable => IR_EN, Din => IR_selector_out, Dout => IR_out); 

PC_selection	: mux2to1 
					generic map(N => data_SIZE)
					port map (A => adder_out, B => PC_out, S => PC_SELECTOR, Y => mux_2to1_out );
					
NPC_out <= mux_2to1_out;

IR_SELECTION    : mux2to1 
					generic map (N => IR_SIZE)
					port map (A => IRAM_out, B => NOP, S => IR_SELECTOR, Y => IR_selector_out);

PC1_output  	: reg
					port map (Rst => Rst, Clk => Clk, Enable => PC1_EN, Din => PC_out, Dout => PC1_out); 
end architecture;  
