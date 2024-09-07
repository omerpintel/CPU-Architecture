--------------- Interrupt Controller Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;

ENTITY INTERRUPT IS
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
END INTERRUPT;

ARCHITECTURE structure OF INTERRUPT IS
	SIGNAL IRQ			: STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);
	SIGNAL CLR_IRQ		: STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);
		
	SIGNAL IntrEn		: STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);
	SIGNAL IFG			: STD_LOGIC_VECTOR(IrqSize-1 DOWNTO 0);
	SIGNAL TypeReg		: STD_LOGIC_VECTOR(RegSize-1 DOWNTO 0);
	
	SIGNAL INTA_Delayed : STD_LOGIC;
--	SIGNAL rst_sig, clk_sig : STD_LOGIC;
	
BEGIN
--	rst_sig <= reset;
--	clk_sig <= clock;

--------------------------------------------------------------
Priority_Module: PriorityEncoder
		GENERIC MAP(RegSize => RegSize)
		PORT MAP(reset => reset,
				clock => clock,
				IFG => IFG,
				TYPEx => TypeReg);

--------------------------- IO MCU ---------------------------
-- OUTPUT TO MCU -- 
DataBus <=	X"000000"	& TypeReg 	WHEN ((AddressBus = X"83E" AND MemReadBus = '1') OR (INTA = '0' AND MemReadBus = '0')) ELSE
			X"000000" 	& IntrEn 	WHEN (AddressBus = X"83C" AND MemReadBus = '1') ELSE
			X"000000" 	& IFG		WHEN (AddressBus = X"83D" AND MemReadBus = '1') ELSE
			(OTHERS => 'Z');

--INPUT FROM MCU -- 

PROCESS(clock) 
BEGIN
	IF (falling_edge(clock)) THEN
		IF (AddressBus = X"83C" AND MemWriteBus = '1') THEN
			IntrEn 	<=	DataBus(IrqSize-1 DOWNTO 0);
		END IF;		
	END IF;
END PROCESS;

IFG		<=	DataBus(IrqSize-1 DOWNTO 0)	WHEN (AddressBus = X"83D" AND MemWriteBus = '1') ELSE
			IRQ AND IntrEn;		
TypeReg	<=	DataBus(RegSize-1 DOWNTO 0)	WHEN (AddressBus = X"83E" AND MemWriteBus = '1') ELSE
			(OTHERS => 'Z');
-------------------------------------------------------------

-- Raise INTR when interrupt is happening
PROCESS (clock, IFG) BEGIN 
	IF (rising_edge(CLOCK)) THEN
		IF ((IFG(2) = '1' OR IFG(3) = '1' OR IFG(4) = '1' OR IFG(5) = '1' OR IFG(6) = '1') and GIE = '1') THEN -- 0, 1, 7 are always 0
			INTR <= '1';
		ELSE 
			INTR <= '0';
		END IF;
	END IF;
END PROCESS;

-- Interrupt Vectors
TypeReg	<= 	X"00" WHEN reset  = '1' ELSE	-- main
			X"10" WHEN IFG(2) = '1' ELSE  	-- Basic timer
			X"14" WHEN IFG(3) = '1' ELSE  	-- KEY1
			X"18" WHEN IFG(4) = '1' ELSE	-- KEY2
			X"1C" WHEN IFG(5) = '1' ELSE	-- KEY3
			X"20" WHEN IFG(6) = '1' ELSE	-- DIVIDER
			(OTHERS => 'Z');

-- IRQ_OUT <= IRQ;

PROCESS (clock) BEGIN
	IF (reset = '1') THEN -- if we're in the middle of an interrupt (reset included): delay the other interrupts
		INTA_Delayed <= '1';
	ELSIF (rising_edge(clock)) THEN -- check if should be rising_edge
		INTA_Delayed <= not(INTA);
	END IF;
END PROCESS;

-- Clear IRQ When Interrupt Ack recv
CLR_IRQ(2) <= '0' WHEN (TypeReg = X"10" AND INTA = '0' AND INTA_Delayed = '0') ELSE '1';
CLR_IRQ(3) <= '0' WHEN (TypeReg = X"14" AND INTA = '0' AND INTA_Delayed = '0') ELSE '1';
CLR_IRQ(4) <= '0' WHEN (TypeReg = X"18" AND INTA = '0' AND INTA_Delayed = '0') ELSE '1';
CLR_IRQ(5) <= '0' WHEN (TypeReg = X"1C" AND INTA = '0' AND INTA_Delayed = '0') ELSE '1';
CLR_IRQ(6) <= '0' WHEN (TypeReg = X"20" AND INTA = '0' AND INTA_Delayed = '0') ELSE '1';



------------ BTIMER ---------------
PROCESS (clock, reset, CLR_IRQ(2), IntrSrc(2))
BEGIN
	if reset = '1' THEN
		IRQ(2) <= '0'; -- asynchronic part
	ELSIF rising_edge(clock) THEN -- synchronic part
		IF CLR_IRQ(2) = '0' THEN -- clr_irq is with not(CLR)
			IRQ(2) <= '0';
		ELSIF IntrSrc(2) = '1' THEN
			IRQ(2) <= '1';
		END IF;
	END IF;
END PROCESS;
------------ KEY1 ---------------
PROCESS (clock, reset, CLR_IRQ(3), IntrSrc(3))
BEGIN
	IF (reset = '1') THEN
		IRQ(3) <= '0';
	ELSIF rising_edge(clock) then 
		IF CLR_IRQ(3) = '0' THEN
			IRQ(3) <= '0';
		ELSIF IntrSrc(3) = '1' and CS_5 = '1' THEN
			IRQ(3) <= '1';
		END IF;
	END IF;
END PROCESS;
------------ KEY2 ---------------
PROCESS (clock, reset, CLR_IRQ(4), IntrSrc(4))
BEGIN
	IF (reset = '1') THEN
		IRQ(4) <= '0';
	ELSIF rising_edge(clock) then 
		IF CLR_IRQ(4) = '0' THEN
			IRQ(4) <= '0';
		ELSIF IntrSrc(4) = '1' and CS_5 = '1' THEN
			IRQ(4) <= '1';
		END IF;
	END IF;
END PROCESS;
------------ KEY3 ---------------
PROCESS (clock, reset, CLR_IRQ(5), IntrSrc(5))
BEGIN
	IF (reset = '1') THEN
		IRQ(5) <= '0';
	ELSIF rising_edge(clock) then 
		IF CLR_IRQ(5) = '0' THEN
			IRQ(5) <= '0';
		ELSIF IntrSrc(5) = '1' and CS_5 = '1' THEN
			IRQ(5) <= '1';
		END IF;
	END IF;
END PROCESS;
------------ DIVIDER ---------------
PROCESS (clock, reset, CLR_IRQ(6), IntrSrc(6))
BEGIN
	if reset = '1' THEN
		IRQ(6) <= '0'; -- asynchronic part
	ELSIF rising_edge(clock) THEN -- synchronic part
		IF CLR_IRQ(6) = '0' THEN -- clr_irq is with not(CLR)
			IRQ(6) <= '0';
		ELSIF IntrSrc(6) = '1' THEN
			IRQ(6) <= '1';
		END IF;
	END IF;
END PROCESS;

END structure;