--  Execute module (implements the data ALU and Branch Address Adder  
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Funct		    : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ); 
			Opcode			: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0);
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			JumpAddr		: OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC;
			shamt			: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0));
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput     	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_cmd				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );

BEGIN
	Ainput <= Read_data_1;
						-- ALU input mux
	Binput <= Read_data_2 WHEN ( ALUSrc = '0' ) 
						  ELSE  Sign_extend( 31 DOWNTO 0 );
						-- Generate ALU control bits
	ALU_cmd <=	"0000" WHEN (ALUOp = "10" and Funct = "100100") or (ALUOp = "11" and Opcode = "001100") ELSE -- and
				"0001" WHEN (ALUOp = "10" and Funct = "100101") or (ALUOp = "11" and Opcode = "001101") ELSE -- or
				"0010" WHEN (ALUOp = "10" and (Funct = "100000" or Funct = "100001")) or (ALUOp = "11" and Opcode = "001000") or (ALUOp = "00") ELSE  -- add (signed) / lw, sw
				"0011" WHEN (ALUOp = "10" and Funct = "100110") or (ALUOp = "11" and Opcode = "001110") ELSE -- xor
				"0100" WHEN  Opcode = "011100" ELSE -- MUL
				"0101" WHEN (ALUOp = "10" and Funct = "000000") ELSE -- sll 
				"0110" WHEN (ALUOp = "10" and Funct = "100010") or (ALUOp = "01") ELSE -- sub (signed) / branch
				"0111" WHEN (ALUOp = "10" and Funct = "101010") or (ALUOp = "11" and Opcode = "001010") ELSE -- slt
				"1000" WHEN (ALUOp = "10" and Funct = "000010") ELSE -- srl
				"1001" WHEN (ALUOp = "11" and Opcode = "001111") ELSE  -- lui 
				"1010";
				

						-- Generate Zero Flag
	Zero <= '1' -- bcond
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result  <= X"0000000" & B"000"  & ALU_output_mux( 31 )  WHEN  ALU_cmd = "0111"  ELSE
				  ALU_output_mux( 31 DOWNTO 0 ); -- Adder to compute Branch Address
				  
	-------------  Calc Branch Address --------------------

	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) + Sign_extend( 7 DOWNTO 0 );
	Add_result 	<= Branch_Add( 7 DOWNTO 0 );

	-------------  Calc PC Address when jumping --------------------
	
	JumpAddr    <= Sign_extend(7 DOWNTO 0) WHEN (Opcode = "000010" OR Opcode = "000011") ELSE -- jump and jal
				   read_data_1(9 DOWNTO 2); -- jr	
	
	
PROCESS ( ALU_cmd, Ainput, Binput )
	variable temp_mul : STD_LOGIC_VECTOR (63 DOWNTO 0);
	BEGIN
					-- Select ALU operation
 	CASE ALU_cmd IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput;
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALUresult = A_input XOR B_input
 	 	WHEN "0011" 	=>	ALU_output_mux  <= Ainput XOR Binput;
						-- ALU performs ALUresult = A_input * B_input
 	 	WHEN "0100" 	=>	temp_mul := Ainput * Binput;
							ALU_output_mux  <= temp_mul(31 DOWNTO 0);
						-- ALU performs SLL 
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= STD_LOGIC_VECTOR(SHIFT_LEFT(unsigned(Binput), to_integer(unsigned(shamt)))); 
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SRL
  	 	WHEN "1000" 	=>	ALU_output_mux 	<= STD_LOGIC_VECTOR(SHIFT_right(unsigned(Binput), to_integer(unsigned(shamt))));
						-- ALU performs LUI	
		WHEN "1001" 	=>	ALU_output_mux 	<= STD_LOGIC_VECTOR(SHIFT_LEFT(unsigned(Binput), 16)); 
		
 	 	WHEN OTHERS	    =>	ALU_output_mux 	<= X"00000000" ;
		
		
  	END CASE;
  END PROCESS;
END behavior;


