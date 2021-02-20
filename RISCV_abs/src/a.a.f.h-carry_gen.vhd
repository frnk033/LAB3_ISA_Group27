library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.constants.all;

entity carry_gen is	
	generic(N 		: integer := log2datasize);
	port(	a, b  	: in std_logic_vector(2**N-1 downto 0);
			cin		: in std_logic;
			cout  	: out std_logic_vector(2**N/4-1 downto 0));
end entity;

architecture str_gen of carry_gen is

-- strategy: a matrix of p and g signals. The total num of rows is log2datasize + 1. 
-- Follow slides scheme to place blocks, assuming "carry step" is 4 and using same indexes for easier interpretation.
-- Divide the structure into sections:
-- .1: pg network, every column is filled
-- .2: "linear part": rows 1 and 2 have each half components of the previous.
--	   Navigate the matrix and place blocks properly, skipping one every two then one every four.
--     First block to the right is GG
-- .3: "logaritmic/constant part", with respect to the number of GGs (1-2-4-8) per row and total blocks per row respectively.
--		Generate constant number of blocks. Logaritmic relations with the row to define generation of GGs.
--		Connections to the closest GG to the right, same for PG. Elaborated some relations to do that, ask if ok or too
--		strict/complex

type SignalVector is array (N downto 0) of std_logic_vector(2**N-1 downto 0);
signal p_sig, g_sig : SignalVector;
  
component  pg
	port (p_a, g_a    : in std_logic;
		  p_b, g_b    : in std_logic;
          p_out, g_out: out std_logic);
end component;

component  pg_network is
	port (x, y: in std_logic;
          p, g: out std_logic);
end component;

component gg is
	port (p_a, g_a, g_b   : in std_logic;
          gg_out          : out std_logic);
end component;

begin

g_sig(0)(0) <= (a(0) and b(0)) or ((a(0) xor b(0)) and cin);

pg_net: for t in 1 to 2**N-1 generate
		network: pg_network
			port map (x => a(t) , y => b(t) , p => p_sig(0)(t) , g => g_sig(0)(t)); 
end generate;

-- navigate matrix
rows: for i in 1 to N generate
	columns: for j in 0 to 2**N-1 generate
		-- "linear" part
		lin: if(i <= 2) generate -- THIS MAY BE GENERIC DEPENDING ON CARRY "STEP", BUT CAN'T FIGURE OUT ARCHITECTURE
			gen_up: if( ((j+1)mod(2**i)) = 0) generate -- generate 1 every 2, 4
				gg_block1: if(j < 2**i) generate
					gg_block_up : gg port map (p_a => p_sig(i-1)(j), g_a => g_sig(i-1)(j),
											   g_b => g_sig(i-1)(j - 2**(i-1)), gg_out => g_sig(i)(j));
				end generate;
				pg_block1: if (j >= 2**i) generate
					pg_block_up : pg port map (p_a => p_sig(i-1)(j), g_a => g_sig(i-1)(j),
											   p_b => p_sig(i-1)(j - 2**(i-1)), g_b => g_sig(i-1)(j - 2**(i-1)),
											   p_out => p_sig(i)(j), g_out => g_sig(i)(j));
				end generate;
			end generate;
		end generate;
		-- "logaritmic/constant" part
		log_const: if (i > 2) generate
			gen_down: if(((j+1) mod 4 = 0) and (j mod (2**i) >= 2**(i-1))) generate -- not very "elegant"...but seems to be ok...
				gg_block2: if(j < 2**i) generate
					gg_block_down : gg port map (p_a => p_sig(i-1)(j), g_a => g_sig(i-1)(j),
												 g_b => g_sig(i-1)((j/2**(i-1))*2**(i-1) -1), -- expoit division rounding...
												 gg_out => g_sig(i)(j));
				end generate;
				pg_block2: if (j >= 2**i) generate
					pg_block_down : pg port map (p_a => p_sig(i-1)(j), g_a => g_sig(i-1)(j),
												 p_b => p_sig(i-1)((j/2**(i-1))*2**(i-1) -1), 
												 g_b => g_sig(i-1)((j/2**(i-1))*2**(i-1) -1),
												 p_out => p_sig(i)(j), g_out => g_sig(i)(j));
				end generate; 
			end generate;
		end generate;

		-- from the last row, I take the outputs
		last: if (i = N) generate
			every4: if (((j+1) mod 4) = 0) generate
				cout(j/4) <= g_sig(i)(j);
			end generate;
		end generate;

		-- finally: connection between levels -> where I don't put blocks but signal goes down
		-- take the empty places, conditions should be similar as before...but not sure
		levels: if ((((j+1) mod 4) = 0) and ((j mod (2**i)) < 2**(i-1))) generate
			p_sig(i)(j) <= p_sig(i-1)(j);
			g_sig(i)(j) <= g_sig(i-1)(j);
		end generate;
	end generate;
end generate;
end str_gen;



	






