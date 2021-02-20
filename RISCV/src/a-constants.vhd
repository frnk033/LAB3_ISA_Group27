library ieee;
use ieee.std_logic_1164.all;

package CONSTANTS is 
	constant IRAM_SIZE      	: integer := 96;
	constant DataMem_SIZE  		: integer := 96;
	constant IRAM_LENGTH		: integer := 8;
	constant DataMem_LENGTH 	: integer := 8;
	constant PC_SIZE        	: integer := 32; 
	constant add_size        	: integer := 5;	
	constant data_size       	: integer := 32; 	 
	constant IR_size           	: integer := 32;
	
 	-- Control unit input sizes
	constant MICROCODE_MEM_SIZE : integer := 9;	-- LUT Size
	constant ALU_OPC_SIZE       : integer := 4;	-- ALU Op Code Word Size   
	constant CW_SIZE            : integer := 34;	-- aluop separately
 
	--NOP instruction ----- 
	constant NOP 				: std_logic_vector(IR_SIZE-1 downto 0) := "00000000000000000000000000010011";

    --OFFSET DRAM ---
	constant offset_dram       : std_logic_vector(data_size downto 0) :=  "000001111110000010000000000000000"; -- default offset  			
																	
	-- alu constants: 
	constant log2datasize 		: integer := 5; 	
	constant carry_width 		: integer := 4;
end CONSTANTS;
