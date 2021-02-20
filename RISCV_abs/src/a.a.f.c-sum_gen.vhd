library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity sum_gen is
  generic (N :  integer := data_size;
		   CW: integer := carry_width);
-- generic with data_size multiple of carry_width, which is the "step" with which the carry is taken
  port	  (a, b : in std_logic_vector(N -1 downto 0);
       	   cin  : in std_logic_vector(N/CW -1  downto 0);
       	   sum  : out std_logic_vector(N -1 downto 0));
end entity;

architecture str of sum_gen is
  
component carry_sel is 
generic(N :  integer := carry_width);                    
  port (cin  :  in  std_logic;
        a, b :  in  std_logic_vector(N-1 downto 0);
        s    :  out std_logic_vector(N-1 downto 0));
end component;

begin

structure: for i in 0 to N/CW-1 generate 
	car_sel: carry_sel
			port map (
				cin => cin(i), 
				a 	=> a(CW*(i+1)-1 downto CW*i), 
				b 	=> b(CW*(i+1)-1 downto CW*i), 
				s 	=> sum(CW*(i+1)-1 downto CW*i));
end generate;
end str;


