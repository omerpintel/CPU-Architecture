-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;
USE work.aux_package.ALL;

ENTITY MIPS IS
	GENERIC (mem_width	: INTEGER := 10;
			 SIM 		: BOOLEAN := FALSE); -- write false when using the quartus
	PORT(   rst, clk	: IN 	STD_LOGIC; 
		-- Output - important signals to pins for easy display in Simulator
		PC					: OUT   STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,Instruction_out : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, Regwrite_out								 : OUT 	STD_LOGIC;
		-- Outputs for inturupts : WE ADDED
		MemReadBus			: OUT 	STD_LOGIC;
		MemWriteBus			: OUT 	STD_LOGIC;
		AddressBus			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		GIE					: OUT	STD_LOGIC;
		INTR				: IN	STD_LOGIC;
		INTA				: OUT	STD_LOGIC;
		DataBus				: INOUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		ControlBus			: OUT	STD_LOGIC_VECTOR(7 downto 0);
		CS_vec				: IN 	STD_LOGIC_VECTOR(6 downto 0)
		);
END 	MIPS;

ARCHITECTURE dfl OF MIPS IS

-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL Branch 			: STD_LOGIC;
	SIGNAL RegDst 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	-- WE ADDED:
	SIGNAL pll_rst 			: STD_LOGIC;
	SIGNAL JumpAddr        	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL Jump           	: STD_LOGIC;
	SIGNAL bne           	: STD_LOGIC;
	----------------------------------------
	--Interrupt Signals---------------------
	SIGNAL INTA_sig			: STD_LOGIC;
	SIGNAL HOLD_PC			: STD_LOGIC;
	SIGNAL NEXT_PC_ISR_EN	: STD_LOGIC;
	SIGNAL NEXT_PC_ISR		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL MemAddr			: STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= ALU_result( 31 DOWNTO 0 ) WHEN ( MemtoReg = "00" ) ELSE -- SAME AS IN DECODE
						X"00000" & B"00" & PC_plus_4 WHEN ( MemtoReg = "10" ) ELSE 	-- Mux to bypass data memory for Rformat instructions
						read_data;
   Branch_out 		<= Branch;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;
   MemReadBus		<= MemRead;
   pll_rst 			<= '0'; -- CHECK IF OKAY

   ControlBus <= read_data_2(7 downto 0) when (to_integer(unsigned(MemAddr(11 downto 0))) >= 2048) else (others => 'Z'); -- X800 = 2048
   AddressBus <= MemAddr when (to_integer(unsigned(MemAddr(11 downto 0))) >= 2048) else (others => 'Z');
   DataBus    <= read_data when (to_integer(unsigned(MemAddr(11 downto 0))) >= 2048 and CS_vec(5 downto 4) = "00") else (others => 'Z');
   
   -- WE ADDED:
   MemAddr 			<= DataBus 	WHEN (INTA_sig = '0') ELSE ALU_Result;
   
	---------------------------------------
	-- Interrupt---------------------------
	---------------------------------------
	INTA	<= INTA_sig;
	
	PROCESS (clk, INTR, rst)
		VARIABLE INTR_STATE 	: STD_LOGIC_VECTOR(1 DOWNTO 0);

	BEGIN
		IF rst = '1' THEN
			INTR_STATE 		:= "00";
			INTA_sig 		<= '1';
			NEXT_PC_ISR_EN	<= '0';
			HOLD_PC			<= '0';
		
		ELSIF (falling_edge(clk)) THEN
			IF (INTR_STATE = "00") THEN
				IF (INTR = '1') THEN
					INTA_sig	<= '0';
					INTR_STATE	:= "01";
					HOLD_PC		<= '1';
--					GIE			<= '0';
				END IF;
				NEXT_PC_ISR_EN	<= '0';
				
			ELSIF (INTR_STATE = "01") THEN		
				INTA_sig	<= '1';
				INTR_STATE 	:= "10";
								
			ELSE 
				NEXT_PC_ISR	<= read_data;
				INTR_STATE 	:= "00";
				NEXT_PC_ISR_EN	<= '1';
				HOLD_PC		<= '0';
			END IF;
		
		END IF;
	END PROCESS;
	
					-- connect the 5 MIPS components  

				
  IFE : Ifetch
	GENERIC MAP(mem_width 		=> mem_width, SIM => SIM)
	PORT MAP (Instruction 		=> Instruction,
				PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				JumpAddr 		=> JumpAddr,
				Branch 			=> Branch,
				bne				=> bne,
				Jump			=> Jump,
				Zero 			=> Zero,
				PC_out 			=> PC,        		
				clock 			=> clk,  
				reset 			=> rst,
				HOLD_PC 		=> HOLD_PC,
				NEXT_PC_ISR_EN	=> NEXT_PC_ISR_EN,
				NEXT_PC_ISR		=> NEXT_PC_ISR
				);

   ID : Idecode
   	PORT MAP (	read_data_1		=> read_data_1,
        		read_data_2		=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result	 	=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				PC_plus_4_out	=> PC_plus_4,
				Sign_extend 	=> Sign_extend,
        		clock 			=> clk,  
				reset 			=> rst,
				INTR			=> INTR,
				INTA			=> INTA_sig,
				GIE				=> GIE
				);


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				Func			=> Instruction( 5 DOWNTO 0 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				bne				=> bne,
				Jump			=> Jump,
				ALUop 			=> ALUop,
            	clock 			=> clk,
				reset 			=> rst );

   EXE:  Execute
   	PORT MAP (	Read_data_1 => read_data_1,
             	Read_data_2 => read_data_2,
				Sign_extend => Sign_extend,
                Funct		=> Instruction( 5 DOWNTO 0 ),
				Opcode		=> Instruction( 31 DOWNTO 26 ),
				shamt		=> Instruction( 10 DOWNTO 6),
				ALUOp 		=> ALUop,
				ALUSrc 		=> ALUSrc,
				Zero 		=> Zero,
          		ALU_Result	=> ALU_Result,
				JumpAddr	=> JumpAddr,
				Add_Result 	=> Add_Result,
				PC_plus_4	=> PC_plus_4,
           		clock			=> clk,
				reset			=> rst );

   MEM:  dmemory
    GENERIC MAP(mem_width 	=> mem_width,
				SIM => SIM)
	PORT MAP (read_data 	=> read_data,
				address 	=> MemAddr (9 DOWNTO 0), -- alu result or databus
				write_data 	=> read_data_2,
				MemRead 	=> MemRead, 
				Memwrite 	=> MemWrite, 
                clock 		=> clk,  
				reset 		=> rst );
END dfl;