library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity add_sub_block is 
	generic(
		N		: integer := data_size
		);
	port(
		a, b 	: in std_logic_vector(N-1 downto 0);
		add_sub : in std_logic;
		cout	: out std_logic;
        s    	: out std_logic_vector(N-1 downto 0)
        );
end entity;


architecture str of add_sub_block is 

--signal
signal b_to_add: std_logic_vector(N-1 downto 0);

--component 
component alu_adder is 
	generic(
		N		: integer := data_size
		);
	port(
		a, b 	: in std_logic_vector(N-1 downto 0);
		cin  	: in std_logic;
		cout 	: out std_logic;
        s    	: out std_logic_vector(N-1 downto 0)
    );
end component;

begin

add_sub_xor	:	for i in 0 to N-1 generate
					b_to_add(i) <= B(i) xor add_sub;
				end generate;


alu_add		: alu_adder
				port map ( a => a, b => b_to_add, cin => add_sub, cout => cout, s => s );
				
end architecture; 
