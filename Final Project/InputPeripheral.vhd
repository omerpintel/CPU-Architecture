--------------- Input Peripheral Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
--------------------------------------------------------
ENTITY InputPeripheral IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
		MemRead		: IN	STD_LOGIC;
		CS			: IN 	STD_LOGIC;
		ACK			: IN	STD_LOGIC;
		Data		: OUT	STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
		GPInput		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
END InputPeripheral;


ARCHITECTURE dlf OF InputPeripheral IS

BEGIN	
	Data <= X"000000" & GPInput WHEN MemRead  = '1' AND CS = '1' ELSE -- make sure it's correct for ack
		(OTHERS => 'Z'); -- changed to '0' from 'Z'
	
END dlf;