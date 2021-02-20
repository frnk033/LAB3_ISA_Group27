library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity registerfile is
	generic(
		A     : integer := add_size;
        D     : integer := data_size
        );
	port(
		CLK: 		IN std_logic;
        RESET:   	IN std_logic;
	    WR: 		IN std_logic;
	    ADD_WR: 	IN std_logic_vector(A-1 downto 0);
	    ADD_RD1: 	IN std_logic_vector(A-1 downto 0);
	    ADD_RD2: 	IN std_logic_vector(A-1 downto 0);
	    DATAIN: 	IN std_logic_vector(D-1 downto 0);
        OUT1: 		OUT std_logic_vector(D-1 downto 0);
	    OUT2: 		OUT std_logic_vector(D-1 downto 0));
end registerfile;

architecture A of registerfile is

	subtype REG_ADDR is natural range 0 to 2**(A) - 1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(D-1 downto 0); 
	signal REGISTERS : REG_ARRAY ; 

begin 

out1 <= registers(to_integer(unsigned(add_rd1)));
out2 <= registers(to_integer(unsigned(add_rd2)));

REGs: process (reset, clk, add_wr, wr)	
begin

	if reset = '0' then 
  		registers <= (others=>(others =>'0'));
 	else	
	--
	      if clk'event and clk = '1' then
				if wr = '1' then
					registers (to_integer(unsigned(add_wr))) <= datain;
				end if; 	
			end if;
  	end if;

end process;

end A;
