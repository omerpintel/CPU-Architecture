-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	GENERIC (	 mem_width	: INTEGER := 10;
			 SIM 		: BOOLEAN := FALSE);
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 		: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL JumpAddr 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			: IN 	STD_LOGIC;
			SIGNAL bne				: IN 	STD_LOGIC;
			SIGNAL Jump 			: IN 	STD_LOGIC;
			SIGNAL Zero				: IN 	STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC;
			--for interrupt
			HOLD_PC 				: IN STD_LOGIC;
			NEXT_PC_ISR_EN			: IN STD_LOGIC;
			NEXT_PC_ISR					: IN STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
END Ifetch;	

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4    : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL Mem_Addr 	: STD_LOGIC_VECTOR( mem_width-1 DOWNTO 0 );
	SIGNAL next_PC,PC_DST2	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL mem_clock	: STD_LOGIC;
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 8,
		numwords_a => 256,
		lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = ITCM",
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\Maayan e\Desktop\Architecture - LABS\Final Project\Files I Changes\ASM - Mips\ITCM.hex",
		intended_device_family => "Cyclone"
	)
	
	PORT MAP (
		clock0  		=> mem_clock,
		address_a 		=> Mem_Addr, 
		q_a 			=> Instruction );
		
		mem_clock <= not clock;
		
		
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		ModelSim: 
		IF (SIM = TRUE) GENERATE
				Mem_Addr <= PC( 9 DOWNTO 2 );
		END GENERATE ModelSim;
		
		FPGA: 
		IF (SIM = FALSE) GENERATE
				Mem_Addr <= PC;
		END GENERATE FPGA;
						-- Adder to increment PC by 4        
      		PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
    	   	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		PC_DST2 <= X"00" WHEN Reset = '1' ELSE
					Add_result  WHEN ((Branch = '1') AND (Zero = '1') AND (bne = '0')) ELSE -- PC_SRC2 
					Add_result	WHEN ((Zero = '0') AND (bne = '1')) ELSE
					PC_plus_4( 9 DOWNTO 2 );
						-- Mux to select Jump Address or PC + 4        
		Next_PC <= 	X"00" 	             WHEN Reset = '1' 	       ELSE	
					JumpAddr 			 WHEN (Jump = '1') 		   ELSE -- PC_SRC1
					NEXT_PC_ISR(9 DOWNTO 2)	 WHEN NEXT_PC_ISR_EN = '1' ELSE
					PC_DST2;
					
			
	PROCESS (reset, clock)
		BEGIN
			--WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 9 DOWNTO 2) <= "00000000" ; 
			ELSIF (rising_edge(clock) and HOLD_PC = '0') THEN
				PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
	END PROCESS;
END behavior;



