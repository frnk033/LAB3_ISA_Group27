library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

package myTypes is
	 
	-- Control unit input sizes
	constant OP_CODE_SIZE	  	: integer := 7;	-- OPCODE field size
	constant FUNC_SIZE          : integer := 3;	-- FUNC field size
	 
-- ALU_Opcode 
	constant add_opc    : std_logic_vector(alu_opc_size-1 downto 0) := "0000";  -- prima della modifica era: "1000"
	constant srai_opc   : std_logic_vector(alu_opc_size-1 downto 0) := "1001";
	constant andi_op	: std_logic_vector(alu_opc_size-1 downto 0) := "1010"; 
	constant xor_op	    : std_logic_vector(alu_opc_size-1 downto 0) := "1110"; 
	constant slt_op    	: std_logic_vector(alu_opc_size-1 downto 0) := "1011";  -- prima della modifica era: "0011"
	constant no_op		: std_logic_vector(alu_opc_size-1 downto 0) := "0000";


	-- R-Type instruction -> OPCODE field
    constant RTYPE			: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0110011";       
	 
	-- R-Type instruction -> FUNC field
	constant RTYPE_ADD  	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "000";
	constant RTYPE_XOR  	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "100";
	constant RTYPE_SLT  	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "010";
	 
	-- I-Type -> OPCODE field
    constant ITYPE			: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0010011";
	 
	-- I-Type instruction -> FUNC field
	constant ITYPE_ADDI  	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "000";
	constant ITYPE_ANDI  	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "111";
	constant ITYPE_SRAI  	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "101";

	-- others instructions --> OPCODE field
	constant LUI	  	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "0110111";
	constant AUIPC	  	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "0010111";
	constant JAL	  	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "1101111";
	constant BEQ   		: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "1100011";
	constant LW     	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "0000011";
	constant SW     	: std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "0100011";

end myTypes;
