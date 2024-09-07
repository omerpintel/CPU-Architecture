--------------- Input Peripheral Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
--------------------------------------------------------
ENTITY GPIO IS
	GENERIC(CtrlBusSize	: integer := 8;
			AddrBusSize	: integer := 32;
			DataBusSize	: integer := 32
			);
	PORT( 
		-- ControlBus	: IN	STD_LOGIC_VECTOR(CtrlBusSize-1 DOWNTO 0);
		ACK							: IN	STD_LOGIC;
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
END GPIO;


ARCHITECTURE dfl OF GPIO IS
	signal not_Address_sig_0 : STD_LOGIC;
	signal pwm_vec : STD_LOGIC_VECTOR( 7 downto 0);
	signal CS_vec : std_logic_vector(6 downto 0);
	
BEGIN	
	not_Address_sig_0 <= not(Address_Bus(0));
	pwm <= pwm_vec(0);
	CS_vec_out <= CS_vec;
	
-- OPT ADDRESS DECODER:

OPT_DECODE:
	OptAddrDecoder
		PORT MAP( 
		reset => rst,
		AddressBus => Address_Bus(11 DOWNTO 0), -- is supposed to be A11,A4,A3,A2
		CS_vec => CS_vec
		);

-- INPUTS:
	SW:	
	InputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				CS			=> CS_vec(4),
				ACK			=> ACK,
				Data		=> DataBus,
				GPInput		=> Switches
			);

-- OUTPUTS:

	LED:
	OutputPeripheral
	GENERIC MAP(SevenSeg => FALSE,
				OutputSize	 => 8)
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(0),
				valid		=> not_Address_sig_0,
				Data		=> DataBus(7 DOWNTO 0),
				BTOUT		=> BTOUT,
				GPOutput	=> LEDs
			);
	
	sevenseg_hex0:
	OutputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,	
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(1),
				valid		=> not_Address_sig_0,
				Data		=> DataBus(7 DOWNTO 0), -- I THINK IT NEEDS TO BE 3 DOWNTO 0
				BTOUT		=> BTOUT,
				GPOutput	=> HEX0
			);
			
	sevenseg_hex1:
	OutputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(1),
				valid		=> Address_Bus(0),
				Data		=> DataBus(7 DOWNTO 0), -- I THINK IT NEEDS TO BE 7 DOWNTO 4
				BTOUT		=> BTOUT,
				GPOutput	=> HEX1
			);
	
	sevenseg_hex2:
	OutputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(2),
				valid		=> not_Address_sig_0,
				Data		=> DataBus(7 DOWNTO 0),
				BTOUT		=> BTOUT,
				GPOutput	=> HEX2
			);
	
	sevenseg_hex3:
	OutputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(2),
				valid		=> Address_Bus(0),
				Data		=> DataBus(7 DOWNTO 0),
				BTOUT		=> BTOUT,
				GPOutput	=> HEX3
			);
			
	sevenseg_hex4:
	OutputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(3),
				valid		=> not_Address_sig_0,
				Data		=> DataBus(7 DOWNTO 0),
				BTOUT		=> BTOUT,
				GPOutput	=> HEX4
			);
			
	sevenseg_hex5:
	OutputPeripheral
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(3),
				valid		=> Address_Bus(0),
				Data		=> DataBus(7 DOWNTO 0),
				BTOUT		=> BTOUT,
				GPOutput	=> HEX5
			);
			
	GPIO9_output:
	OutputPeripheral
	GENERIC MAP(SevenSeg => FALSE,
				PWM_out => TRUE, -- for GPIO9
				OutputSize	 => 8)
	PORT MAP(	MemRead		=> MemRead,
				clk 		=> clk,
				rst			=> rst,
				MemWrite	=> MemWrite_Contol_Bus,
				CS			=> CS_vec(6),
				valid		=> not_Address_sig_0,
				Data		=> DataBus(7 DOWNTO 0),
				BTOUT		=> BTOUT,
				GPOutput	=> pwm_vec
			);

END dfl;