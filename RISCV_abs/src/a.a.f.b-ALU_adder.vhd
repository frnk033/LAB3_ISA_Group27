library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity alu_adder is 
	generic(
		N		: integer := data_size
		);
	port(
		a, b	: in std_logic_vector(N-1 downto 0);
		cin  	: in std_logic;
		cout 	: out std_logic;
        s    	: out std_logic_vector(N-1 downto 0)
        );
end entity;


architecture str of alu_adder is 

--signal
signal out_carrygen: std_logic_vector(N/4 downto 0);

--component 
component carry_gen is 
	generic(
		N 		: integer := log2datasize
		);
	port(
		a, b	: in std_logic_vector(2**N-1 downto 0);
		cin		: in std_logic;
		cout  	: out std_logic_vector(2**N/4-1 downto 0)
		);
end component; 

component sum_gen is
	generic(
		N		: integer := data_size
		);
	port(
		a, b	: in std_logic_vector(N -1 downto 0);
		cin  	: in std_logic_vector(N/4 -1  downto 0);
		sum  	: out std_logic_vector(N -1 downto 0)
		);
end component; 

begin

out_carrygen(0) <= cin;
cout <= out_carrygen(N/4);

carry_generation	: carry_gen 
						port map ( a => a, b => b, cin => cin, cout =>  out_carrygen (N/4 downto 1) );

sum_generation		: sum_gen 
						port map ( a => a, b => b, cin => out_carrygen(N/4-1 downto 0), sum => s );
end architecture; 
