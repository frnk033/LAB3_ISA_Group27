library IEEE;
use IEEE.std_logic_1164.all;
use WORK.all;
use WORK.constants.all;

entity tb_RISCV is
end tb_RISCV;

architecture TEST of tb_RISCV is

signal 		Clock		: std_logic := '1';
signal 		Reset		: std_logic := '1';
signal		IRAM_out_i, IRAM_out_tb: std_logic_vector(IR_SIZE-1 downto 0);
signal 		IRAM_add_i	, IRAM_add_tb: std_logic_vector(PC_SIZE-1 downto 0);
signal		Dram_add_i, Dram_data_in_i,	Dram_data_out_i, Dram_add_tb, Dram_data_in: std_logic_vector(data_size-1 downto 0);
signal		Dram_we_i, Dram_rd_i : std_logic;

component riscv is 
	generic(
		IR_SIZE	: integer := IR_SIZE;	-- Instruction Register Size
		PC_SIZE	: integer := PC_SIZE	-- Program Counter Size
		);      						-- ALU_OPC_SIZE if explicit ALU Op Code Word Size
	port(
		Clk : in std_logic;
		Rst : in std_logic;			-- Active Low
		
		IRAM_out		: in std_logic_vector(IR_SIZE-1 downto 0);
		IRAM_add		: out std_logic_vector(PC_SIZE-1 downto 0);

		Dram_add 		: out std_logic_vector(data_size-1 downto 0);
		Dram_data_in 	: out std_logic_vector(data_size-1 downto 0);
		Dram_we 		: out std_logic;
		Dram_rd 		: out std_logic;
		Dram_data_out 	: in std_logic_vector(data_Size-1 downto 0)
		);         
end component;

component DataRam is
	generic(
		datamem_size   : integer := datamem_size;     
		A     		   : integer := data_size;
        D     		   : integer := data_size;
		DataMem_Length : integer := DataMem_Length
    );
	port( 
		CLK     : IN  std_logic;
        RESET   : IN  std_logic;
	    WR      : IN  std_logic;
		RD      : IN  std_logic;
		ADD     : IN  std_logic_vector(A-1 downto 0);
	    DATAIN  : IN  std_logic_vector(D-1 downto 0);
        OUT1    : OUT std_logic_vector(D-1 downto 0)
	);
end component; 

component IRAM is
	generic(
		IRAM_SIZE 		: integer := IRAM_SIZE;
		PC_SIZE   		: integer := PC_SIZE;
		IR_SIZE    		: integer := IR_SIZE;
		IRAM_length		: integer := IRAM_LENGTH); 
	port(
		Rst  : in  std_logic;
		Addr : in  std_logic_vector(PC_SIZE - 1 downto 0);
		Dout : out std_logic_vector(IR_SIZE - 1 downto 0)
	);

end component;
	
begin

	-- instance of RISCV
U1	: riscv
		Port Map( 
			Clk 		=> Clock,
			Rst 		=> Reset,
			IRAM_out	=> IRAM_out_tb,
			IRAM_add 	=> IRAM_add_tb,
			Dram_add 	=> Dram_add_tb,
			Dram_data_in 	=> Dram_data_in_i,
			Dram_we 	=> Dram_we_i,
			Dram_rd 	=> Dram_rd_i,
			Dram_data_out 	=> Dram_data_out_i
		);
			
IR	: IRAM
		Port map(
			Rst 	=> Reset,
			Addr 	=> Iram_add_tb,
			Dout 	=> Iram_out_tb
		);
			
DR 	: Dataram 
		Port map(
			CLK 	=> Clock,
			RESET 	=> Reset,
			WR 		=> Dram_we_i,
			RD 		=> Dram_rd_i,
			Add 	=> Dram_add_tb,
			Datain 	=> Dram_data_in_i,
			out1 	=> Dram_data_out_i
		);
			
PCLOCK	: process(Clock)
	begin
		Clock <= not(Clock) after 0.5 ns;	
	end process;
	
Reset <= '0', '1' after 5 ns, '0' after 300 ns, '1' after 305 ns;

end TEST;

-------------------------------

configuration CFG_TB of tb_RISCV  is
	for TEST
	end for;
end CFG_TB;

