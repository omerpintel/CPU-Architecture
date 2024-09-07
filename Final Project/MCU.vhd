--------------- MCU System Architecture Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;


ENTITY MCU IS
	GENERIC(mem_width	: INTEGER := 8;
			SIM 		: BOOLEAN := TRUE;
			CtrlBusSize	: integer := 8;
			AddrBusSize	: integer := 32;
			DataBusSize	: integer := 32;
			IrqSize		: integer := 8;
			RegSize		: integer := 8
			);
	PORT( 
			pll_clk		: IN	STD_LOGIC; --reset: KEY0 ; clk: PLL  **ALSO HAD ENA**
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
			LEDs				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			Switches			: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			PWM					: OUT   STD_LOGIC;
			KEY0, KEY1, KEY2, KEY3	: IN	STD_LOGIC
		);
END MCU;

ARCHITECTURE dlf OF MCU IS
	SIGNAL rst, clk		: STD_LOGIC;
--	SIGNAL enaSim		: STD_LOGIC;

	-- CHIP SELECT SIGNALS --
	SIGNAL CS_vec		: STD_LOGIC_VECTOR(6 downto 0);
	
	-- GPIO SIGNALS -- 
	SIGNAL MemRead	: 	STD_LOGIC;
	SIGNAL MemWrite	:	STD_LOGIC;
	SIGNAL ControlBus	: 	STD_LOGIC_VECTOR(CtrlBusSize-1 DOWNTO 0);
	SIGNAL AddressBus	: 	STD_LOGIC_VECTOR(AddrBusSize-1 DOWNTO 0);
	SIGNAL DataBus		: 	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
	
	-- BASIC TIMER --
	SIGNAL BTCTL		:	STD_LOGIC_VECTOR(CtrlBusSize-1 DOWNTO 0);
	SIGNAL BTCNT		:	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
	SIGNAL BTCCR0		:	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
	SIGNAL BTCCR1		:	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
	SIGNAL BTIFG		:	STD_LOGIC;
	SIGNAL BTOUT		:	STD_LOGIC;

	
	-- INTERRUPT MODULE --
	SIGNAL IntrSrc		:	STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);
	SIGNAL INTR			:	STD_LOGIC;
	SIGNAL INTA			:	STD_LOGIC;
	
	SIGNAL IntrEn		:	STD_LOGIC_VECTOR(RegSize-1 DOWNTO 0);
	SIGNAL IFG			:	STD_LOGIC_VECTOR(RegSize-1 DOWNTO 0);
	SIGNAL TypeReg		:	STD_LOGIC_VECTOR(RegSize-1 DOWNTO 0);
--	SIGNAL IRQ_OUT		:	STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);

	SIGNAL GIE			:	STD_LOGIC;
	SIGNAL INTR_Active	:	STD_LOGIC;
	SIGNAL CLR_IRQ		:	STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	-- DIVIDER MODULE --
	SIGNAL DIVIDEND		: STD_LOGIC_VECTOR(DataBusSize-1 downto 0);
	SIGNAL DIVISOR		: STD_LOGIC_VECTOR(DataBusSize-1 downto 0);
	SIGNAL QUOTIENT		: STD_LOGIC_VECTOR(DataBusSize-1 downto 0);
	SIGNAL RESIDUE		: STD_LOGIC_VECTOR(DataBusSize-1 downto 0);
	SIGNAL DIV_IFG		: STD_LOGIC;
	SIGNAL ENA_DIVIDER	: STD_LOGIC := '0';

	-- Hanan's
	SIGNAL ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,Instruction_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Branch_out, Zero_out, Memwrite_out, Regwrite_out : STD_LOGIC;
	SIGNAL PC : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
	rst 	<= not(KEY0); -- key0 starts at '1'
	IntrSrc	<=  '0' & DIV_IFG & (NOT KEY3) & (NOT KEY2) & (NOT KEY1) & BTIFG & "00";
	ENA_DIVIDER <= '1' when AddressBus(11 downto 0) = X"830" else '0';
	
	-- MCLK: PLL 
	-- PORT MAP (
				-- refclk => pll_clk,
				-- outclk_0 => clk );
	clk <= pll_clk;

	PROCESS(clk)
	BEGIN
		if (falling_edge(clk)) then -- writing on falling edge
			-- writing to the peripherals components (signals)
			if(AddressBus(11 DOWNTO 0) = X"81C" AND MemWrite = '1') then
				BTCTL <= ControlBus;
			END IF;
			if(AddressBus(11 DOWNTO 0) = X"824" AND MemWrite = '1') then
				BTCCR0 <= DataBus;
			END IF;
			if(AddressBus(11 DOWNTO 0) = X"828" AND MemWrite = '1') then
				BTCCR1 <= DataBus;
			END IF;
			if(AddressBus(11 DOWNTO 0) = X"82C" AND MemWrite = '1') then
				DIVIDEND <= DataBus;
			END IF;
			if(AddressBus(11 DOWNTO 0) = X"830" AND MemWrite = '1') then
				DIVISOR <= DataBus;
			END IF;
			-- writing to memory *************************************
		END IF;
	END PROCESS;

	CPU: MIPS
		GENERIC MAP (
					mem_width => mem_width,
					SIM => SIM)
		PORT MAP	(
					rst => rst,
					clk => clk,
					PC => PC,
					ALU_result_out => ALU_result_out,
					read_data_1_out => read_data_1_out,
					read_data_2_out => read_data_2_out,
					write_data_out => write_data_out,
					Instruction_out => Instruction_out, 
					Branch_out => Branch_out,
					Zero_out => Zero_out,
					Memwrite_out => Memwrite_out,
					Regwrite_out => Regwrite_out,
					MemReadBus => MemRead,
					MemWriteBus => MemWrite,
					AddressBus => AddressBus,
					GIE => GIE,
					INTR => INTR,
					INTA => INTA,
					DataBus => DataBus,
					CS_vec => CS_vec);

	IO_interface: GPIO
		PORT MAP	(
					ACK => INTA,
					MemRead => MemRead,
					clk => clk,
					rst => rst,
					MemWrite_Contol_Bus => MemWrite,
					Address_Bus => AddressBus,
					BTOUT => BTOUT,
					DataBus => DataBus,
					HEX0 => HEX0,
					HEX1 => HEX1,
					HEX2 => HEX2,
					HEX3 => HEX3,
					HEX4 => HEX4,
					HEX5 => HEX5,
					LEDs => LEDs,
					PWM => PWM,
					Switches =>Switches,
					CS_vec_out => CS_vec
					);

	Basic_Timer: BTIMER
		GENERIC MAP ( DataBusSize => DataBusSize)
		PORT MAP(
			MCLK => clk,
			reset => rst,
			BTCTL	=> BTCTL,
			BTCCR0	=> BTCCR0,
			BTCCR1	=> BTCCR1,
			BTIFG	=> BTIFG,
			BTOUT	=> BTOUT
		);

	Intr_Controller_Component: INTERRUPT
		GENERIC MAP(
			DataBusSize	=> DataBusSize,
			AddrBusSize	=> AddrBusSize,
			IrqSize		=> IrqSize,
			RegSize 	=> RegSize
		)
		PORT MAP(
			reset => rst,
			clock => clk,
			MemReadBus => MemRead,
			MemWriteBus => MemWrite,
			AddressBus => AddressBus,
			DataBus => DataBus,
			IntrSrc => IntrSrc,
			CS_5 => CS_vec(5),
			INTA => INTA,
			INTR => INTR,
			GIE => GIE);
		
		
	---- ADD DIVIDER AS WELL
	Divider_Component: DIVIDER
		GENERIC MAP(DataBusSize	=> DataBusSize)
		PORT MAP(
			DIVIDEND	 	=> DIVIDEND,
			DIVISOR			=> DIVISOR,
			DIVCLK			=> clk,
			RST				=> rst,
			ENA				=> ENA_DIVIDER,
			DIVIFG 		=> DIV_IFG,
			RESIDUE			=> RESIDUE,
			QUOTIENT		=> QUOTIENT
		);
END dlf;