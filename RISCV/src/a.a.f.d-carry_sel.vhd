library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;   
use work.constants.all;

entity carry_sel is
	generic( N : integer := carry_width);                 
	port(
		cin  :  in  std_logic;
       	a, b :  in  std_logic_vector(N-1 downto 0);
       	s    :  out std_logic_vector(N-1 downto 0));
end entity;

architecture str of carry_sel is

  signal rca_0, rca_1 : std_logic_vector(N-1 downto 0);

  component mux2to1 is
    Generic(N: integer:=  add_size );
    Port(   A:	In	std_logic_vector(N-1 downto 0) ;
	    	B:	In	std_logic_vector(N-1 downto 0);
	    	S:	In	std_logic;
	   	    Y:	Out	std_logic_vector(N-1 downto 0));
  end component;

  component RCA is
    generic(N   : integer := carry_width);
    Port(   A	: In std_logic_vector(N-1 downto 0);
	     	B	: In std_logic_vector(N-1 downto 0);
	     	Ci	: In std_logic;
	     	S	: Out std_logic_vector(N-1 downto 0);
	     	Co	: Out std_logic);
    end component;

begin
  
  car_0: RCA
    port map (A => a, B => b, s => rca_0, ci => '0', co => open);

  car_1: RCA
    port map (A => a, B => b, s => rca_1, ci => '1', co => open);

  sel: mux2to1
	generic map (N => carry_width)
    port map (A => rca_0, B => rca_1, S => cin, Y => s);

end str;
