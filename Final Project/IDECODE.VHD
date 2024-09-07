						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 		: IN 	STD_LOGIC;
			MemtoReg 		: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegDst 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			PC_plus_4_out   : IN    STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			Sign_extend 	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset		: IN 	STD_LOGIC;
			INTR			: IN 	STD_LOGIC;
			INTA			: IN 	STD_LOGIC;
			GIE				: OUT	STD_LOGIC
			);
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL opcode						: STD_LOGIC_VECTOR( 5 DOWNTO 0);
	SIGNAL funct						: STD_LOGIC_VECTOR( 5 DOWNTO 0);
	signal PC_plus_4_temp				: STD_LOGIC_VECTOR( 9 DOWNTO 0 );

BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
	opcode						<= Instruction( 31 DOWNTO 26);
	funct						<= Instruction( 5 DOWNTO 0);
	
					-- Read Register 1 Operation
	read_data_1 <= register_array( CONV_INTEGER( read_register_1_address ) );
	
					-- Read Register 2 Operation
	read_data_2 <= register_array( CONV_INTEGER( read_register_2_address ) );
	
					-- Mux for Register Write Address
	write_register_address <= write_register_address_1 WHEN RegDst = "01" ELSE
								"11111" WHEN RegDst = "10" ELSE -- 31
							write_register_address_0;
							 
					-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result( 31 DOWNTO 0 ) WHEN ( MemtoReg = "00" ) ELSE
				X"00000" & B"00" & PC_plus_4_temp WHEN ( MemtoReg = "10" ) ELSE
				read_data;
			
					-- Sign Extend 16-bits to 32-bits
    Sign_extend <= X"0000" & Instruction_immediate_value WHEN Instruction_immediate_value(15) = '0' ELSE
				X"FFFF" & Instruction_immediate_value;
				
					-- GIE flag for INTERRUPTS
	GIE 		<= register_array(26)(0);

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '0';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;
			register_array(26)(0) <= '1';  -- set GIE to 1 after reset
  		ELSIF RegWrite = '1' AND write_register_address /= 0 THEN
		      register_array( CONV_INTEGER( write_register_address)) <= write_data;
		END IF;
		------ $k0 update ------
		IF (INTR = '1') THEN
			register_array(26)(0) <= '0';  -- clr GIE in $k0
		ELSIF (read_register_1_address = "11011" AND opcode = "000000" and funct = X"8") THEN
			register_array(26)(0) <= '1';  -- set GIE in $k0 when jump register $k1
		END IF;
		
		------ Edit $k1 section ------
		IF (INTA = '0') THEN
			register_array(27) <= "00" & X"00000" & PC_plus_4_out(9 DOWNTO 0);
		END IF;
		PC_plus_4_temp <= PC_plus_4_out;
	END PROCESS;
END behavior;


