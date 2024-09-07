LIBRARY ieee;
USE ieee.std_logic_1164.all;

package aux_package is

-----------------------------------------------------------------
-- MIPS
-----------------------------------------------------------------
-- ALL MIPS COMPONENTS - IN ORDER:

	COMPONENT MIPS IS
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
	END COMPONENT;
	
	COMPONENT Ifetch
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
	END COMPONENT; 
-----------------------------------------------------------------
	COMPONENT Idecode
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
				clock,reset			: IN 	STD_LOGIC;
				INTR			: IN 	STD_LOGIC;
				INTA			: IN 	STD_LOGIC;
				GIE				: OUT	STD_LOGIC
				);
	END COMPONENT;
-----------------------------------------------------------------
	COMPONENT control IS
	   PORT( 	
		Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		ALUSrc 		: OUT 	STD_LOGIC;
		MemtoReg 	: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		RegWrite 	: OUT 	STD_LOGIC;
		MemRead 	: OUT 	STD_LOGIC;
		MemWrite 	: OUT 	STD_LOGIC;
		Branch 		: OUT 	STD_LOGIC;
		ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		clock, reset	: IN 	STD_LOGIC;
		
		-- WE ADDED:
		Func		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		bne			: OUT 	STD_LOGIC;
		Jump		: OUT	STD_LOGIC);
	END COMPONENT;
-----------------------------------------------------------------
	COMPONENT  Execute
   	     PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Funct			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ); 
				Opcode			: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0);
				ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ALUSrc 			: IN 	STD_LOGIC;
				shamt			: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
				Zero 			: OUT	STD_LOGIC;
				ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				JumpAddr		: OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				clock, reset	: IN 	STD_LOGIC );
	END COMPONENT;
-----------------------------------------------------------------

	COMPONENT dmemory
	GENERIC (mem_width	: INTEGER := 10;
			 SIM 		: BOOLEAN := FALSE);
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;
	
 -- PLL COMPONENT:
 
	COMPONENT PLL port(
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   rst.rst
		outclk_0 : out std_logic         -- outclk0.clk
	);
    END COMPONENT;

-----------------------------------------------------------------
-- BASIC TIMER
-----------------------------------------------------------------

COMPONENT BTIMER IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
		MCLK	: IN 	STD_LOGIC;
		reset	: IN 	STD_LOGIC;
		BTCTL	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0); -- control register
		BTCCR0	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- compare register 0
		BTCCR1	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0); -- compare register 1
		BTIFG	: OUT 	STD_LOGIC; -- inturupt flag
		BTOUT	: OUT	STD_LOGIC  -- PWM signal out
		);
END COMPONENT;

-----------------------------------------------------------------
-- DIVIDER
-----------------------------------------------------------------
COMPONENT DIVIDER IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
        DIVIDEND : in std_logic_vector(31 downto 0);
        DIVISOR  : in std_logic_vector(31 downto 0);
        DIVCLK   : in std_logic;
        RST      : in std_logic;
        ENA	     : in std_logic;
        DIVIFG   : out std_logic;
        RESIDUE  : out std_logic_vector(31 downto 0);
        QUOTIENT : out std_logic_vector(31 downto 0)
		);
END COMPONENT;

-----------------------------------------------------------------
-- INTERRUPT
-----------------------------------------------------------------

COMPONENT INTERRUPT IS
	GENERIC(DataBusSize	: integer := 32;
			AddrBusSize	: integer := 12;
			IrqSize	    : integer := 8;
			RegSize		: integer := 8
			);
	PORT( 
			reset		: IN	STD_LOGIC;
			clock		: IN	STD_LOGIC;
			MemReadBus	: IN	STD_LOGIC;
			MemWriteBus	: IN	STD_LOGIC;
			AddressBus	: IN	STD_LOGIC_VECTOR(AddrBusSize-1 DOWNTO 0);
			DataBus		: INOUT	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
			IntrSrc		: IN	STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0); -- IRQ
			CS_5		: IN	STD_LOGIC; -- CHIP SELECT FOR KEYS
			INTA		: IN	STD_LOGIC;
			INTR		: OUT	STD_LOGIC;
--			IRQ_OUT		: OUT   STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);
--			INTR_Active	: OUT	STD_LOGIC;
--			CLR_IRQ_OUT	: OUT	STD_LOGIC_VECTOR(5 DOWNTO 0);
			GIE			: IN	STD_LOGIC
		);
END COMPONENT;
-----------------------------------------------------------------
	component PriorityEncoder IS
		GENERIC(RegSize		: integer := 8);
		PORT(	reset		: IN	STD_LOGIC;
				clock		: IN	STD_LOGIC;
				IFG			: IN STD_LOGIC_VECTOR(RegSize-1 downto 0);
				TYPEx		: OUT STD_LOGIC_VECTOR(RegSize-1 downto 0));
	END component;

-----------------------------------------------------------------
-- GPIO
-----------------------------------------------------------------
COMPONENT GPIO IS
	GENERIC(CtrlBusSize	: integer := 8;
			AddrBusSize	: integer := 32;
			DataBusSize	: integer := 32
			);
	PORT( 
		-- ControlBus	: IN	STD_LOGIC_VECTOR(CtrlBusSize-1 DOWNTO 0);
		ACK							: IN	STD_LOGIC; -- check what this is for
		MemRead						: IN 	STD_LOGIC;
		clk							: IN 	STD_LOGIC;
		rst							: IN 	STD_LOGIC;
		MemWrite_Contol_Bus			: IN 	STD_LOGIC;
		Address_Bus					: IN	STD_LOGIC_VECTOR(AddrBusSize-1 DOWNTO 0);
		BTOUT						: IN 	STD_LOGIC; -- pwm 
--		BTIFG						: IN	STD_LOGIC; -- interrupt
		DataBus						: INOUT	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0); -- for input AND output
		HEX0, HEX1					: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2, HEX3					: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4, HEX5					: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
		LEDs						: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		PWM							: out 	STD_LOGIC; -- make sure the size is correct
		Switches					: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
		CS_vec_out					: OUT	std_logic_vector(6 downto 0)
		);
END COMPONENT;
-----------------------------------------------------------------

component OptAddrDecoder IS
	PORT( 
		reset 						: IN	STD_LOGIC;
		AddressBus					: IN	STD_LOGIC_VECTOR(11 DOWNTO 0); -- is supposed to be A11,A4,A3,A2
		CS_vec						: out 	std_logic_vector(6 downto 0) -- vector for: LEDs, HEXs (3 * 2), SW, KEYs
		);
END component;
-----------------------------------------------------------------

component OutputPeripheral IS -- THIS PERIPHERAL IS USED FOR 6 (SEVEN SEGMENT) HEX DISPLAY & 10 LEDS
	GENERIC (SevenSeg		: BOOLEAN := TRUE;  -- Using 7 segment display
			 PWM_out		: BOOLEAN := FALSE; -- Using PWM
			 OutputSize		: INTEGER := 7); -- 7 for hexadecimal (seven segment), 8 for LEDs, 1 for pwm

	PORT( 
		MemRead		: IN	STD_LOGIC;
		clk			: IN 	STD_LOGIC;
		rst			: IN 	STD_LOGIC;
		MemWrite	: IN	STD_LOGIC;
		CS			: IN 	STD_LOGIC;
		valid		: IN	STD_LOGIC;
		Data		: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		BTOUT		: IN 	STD_LOGIC; -- pwm 
		GPOutput	: OUT	STD_LOGIC_VECTOR(OutputSize-1 DOWNTO 0) -- change to leds when needed
		);
END component;
-----------------------------------------------------------------

component InputPeripheral IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
		MemRead		: IN	STD_LOGIC;
		CS			: IN 	STD_LOGIC;
		ACK			: IN	STD_LOGIC;
		Data		: OUT	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
		GPInput		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
END component;
-----------------------------------------------------------------

component SevenSegDecoder is
	generic(hex_size : integer := 4; -- number of bits for hexadecimal
            seg_size : integer := 7 -- 7 segment display
    );

	port( -- INPUTS:
        num : in std_logic_vector(hex_size-1 downto 0);
        -- OUPUTS:
        seven_seg_of_num : out std_logic_vector(seg_size-1 downto 0)
    );
end component;

end aux_package;