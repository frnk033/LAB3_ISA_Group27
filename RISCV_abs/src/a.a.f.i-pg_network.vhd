library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity pg_network is
  port (x, y: in std_logic;
        p, g: out std_logic);
end entity;

architecture str_pg of pg_network is

  begin
  p <= x xor y;
  g <= x and y;

end str_pg;
