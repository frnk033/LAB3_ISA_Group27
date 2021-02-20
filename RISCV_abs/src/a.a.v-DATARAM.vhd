library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity DataRam is 
	Port( 
		CLK     : IN  std_logic;
        RESET   : IN  std_logic;
	    WR      : IN  std_logic;
		RD      : IN  std_logic;
	    ADD     : IN  std_logic_vector(data_size-1 downto 0);
	    DATAIN  : IN  std_logic_vector(data_size-1 downto 0);
        OUT1    : OUT std_logic_vector(data_size-1 downto 0)
	);
end entity; 

architecture str of DataRam is

	type DataMemtype is array (0 to datamem_size - 1) of std_logic_vector(DataMem_Length - 1 downto 0);
	signal Data_mem : DataMemtype; 
	
	signal mask_add : std_logic_vector(data_size-1 downto 0);

   signal add_unbiased: std_logic_vector(data_size downto 0) := (others => '0');
   signal add_first: std_logic_vector(data_size downto 0) := (others => '0');
   signal flag : std_logic := '0';
  
begin
   
   add_first <= '0' & add(data_size-1 downto 0);

offset_computation: process ( reset, add_first)
begin
	if reset = '0' then
		add_unbiased <= (others => '0');
	else
		if to_integer(unsigned(add_first(data_size downto 0))) >= to_integer(unsigned(offset_dram(data_size downto 0)))  then
			add_unbiased <= std_logic_vector( unsigned(add_first(data_size downto 0)) - unsigned(offset_dram(data_size downto 0)));
		else 
			add_unbiased <= add_first;
		end if;
	end if;
end process;

    mask_add <= add_unbiased(data_size-1 downto 2) & "00";    -- aligned word
	
	Mem: process ( reset, clk, wr, mask_add, datain)

	file mem_fp1: text;
	variable file_line1 : line;
	variable index1 	: integer := 0;
	variable tmp_data_u1: std_logic_vector(IR_SIZE-1 downto 0);
    
	begin
		if reset = '0' and flag = '0' then -- reset
		    file_open(mem_fp1,"../src/z.dram_init_00_asm",READ_MODE);
			while (not endfile(mem_fp1)) loop
				readline(mem_fp1,file_line1);
				hread(file_line1,tmp_data_u1);
				Data_mem(index1)     <= tmp_data_u1(IR_SIZE -1 downto 24);
				Data_mem(index1 + 1) <= tmp_data_u1(23 downto 16);
				Data_mem(index1 + 2) <= tmp_data_u1(15 downto 8); 
				Data_mem(index1 + 3) <= tmp_data_u1(7 downto 0);
				index1 := index1 + 4;
			end loop;
			flag <= '1'; 
		else	
			if rd = '1' then				-- reading
						out1(data_size-1 downto 24) <= Data_mem(to_integer(unsigned(mask_add)));
						out1(23 downto  16) <= Data_mem(to_integer(unsigned(mask_add)) + 1);
						out1(15 downto   8) <= Data_mem(to_integer(unsigned(mask_add)) + 2);
						out1(7  downto   0) <= Data_mem(to_integer(unsigned(mask_add)) + 3);
			end if;
				
		    if clk'event and clk = '1' then 
				if wr = '1' then -- writing
							Data_mem(to_integer(unsigned(mask_add)))    <= datain(data_size-1 downto 24);
							Data_mem(to_integer(unsigned(mask_add))+ 1) <= datain(23 downto 16);
							Data_mem(to_integer(unsigned(mask_add))+ 2) <= datain(15 downto 8); 
							Data_mem(to_integer(unsigned(mask_add))+ 3) <= datain(7 downto 0);
				end if;
			end if;	
		end if;
	end process;	
end architecture;




