library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.constants.all;
use WORK.myTypes.all;

entity alu is
	generic(
		N 			: integer := data_size;
		OP			: integer := alu_Opc_size
		);
	port( 
		DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
		aluOpcode 	: IN std_logic_vector(OP-1 downto 0);
		OUTALU		: OUT std_logic_vector(N-1 downto 0));
end alu;

architecture str of alu is

component SHIFTER is
	generic(
		N			: integer := data_size
		);
	port(
		A			: in std_logic_vector(N-1 downto 0);
		B			: in std_logic_vector(4 downto 0);
		OUTPUT		: out std_logic_vector(N-1 downto 0)
	);
end component;


component add_sub_block is 
	generic(N : integer := data_size);
	port(
		a, b 		: in std_logic_vector(N-1 downto 0);
		add_sub  	: in std_logic;
		cout		: out std_logic;
		s    		: out std_logic_vector(N-1 downto 0)
        );
end component;

component alu_logic is
	generic(N: integer := data_size);
	port(	
		A		: in std_logic_vector(N-1 downto 0);
		B		: in std_logic_vector(N-1 downto 0);
		s		: in std_logic;
		C		: out std_logic_vector(N-1 downto 0)
	);

end component;

component mux4to1 is 
	Generic(N : integer := add_size);
	Port(
		a, b, c, d 	: in std_logic_vector(N-1 downto 0); 
		s         	: in std_logic_vector(1 downto 0); 
		y			: out std_logic_vector(N-1 downto 0)
		); 
end component; 

component comparator is 
	Generic( N		: integer:= data_size);
	Port( A_MSB, B_MSB, add_out_MSB		: In	std_logic;
		  comp_out	: Out	std_logic_vector(N-1 downto 0));
end component; 



signal adder_out, comp_out, logic_out, shift_out: std_logic_vector(N-1 downto 0);
signal cout_adder: std_logic;

begin


add_sub_bl	: add_sub_block 
				port map (a => DATA1, b => DATA2, add_sub => aluOpcode(OP-1), cout => cout_adder, s => adder_out);

-- Only for slt
compare		: comparator 
				port map (add_out_MSB => adder_out(N-1), A_MSB => DATA1(N-1), B_MSB => DATA2(N-1), comp_out => comp_out); 

logic		: alu_logic 
				port map (a => DATA1, b => data2, s => aluOpcode(OP-2), C => logic_out);

shift_block	: shifter 
				port map (a => DATA1, b => data2(4 downto 0), output => shift_out);

final_mux	: mux4to1
				generic map (N => data_size) 
				port map (a => adder_out, b => shift_out, c => logic_out, d => comp_out, s => aluOpcode(1 downto 0), y => OUTALU);   
end str;
