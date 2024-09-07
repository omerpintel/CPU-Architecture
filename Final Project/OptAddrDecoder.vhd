--------------- Optimized Address Decoder Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
--------------------------------------------------------
ENTITY OptAddrDecoder IS
	PORT( 
		reset 						: IN	STD_LOGIC;
		AddressBus					: IN	STD_LOGIC_VECTOR(11 DOWNTO 0); -- is supposed to be A11,A4,A3,A2
		CS_vec						: out 	std_logic_vector(6 downto 0) -- vector for: LEDs, HEXs (3 * 2), SW, KEYs
		);
END OptAddrDecoder;
-- ADD GPIO9'S ADDRESS

ARCHITECTURE dfl OF OptAddrDecoder IS

BEGIN
	
	CS_vec(0) <= '0' when reset = '1' else -- FOR LEDS
				 '1' when AddressBus(11 downto 0) = X"800" else
				 '0';
				 
	CS_vec(1) <= '0' when reset = '1' else -- FOR HEX0 AND HEX1
				 '1' when (AddressBus(11 downto 0) = X"804" or AddressBus(11 downto 0) = X"805") else
				 '0';

	CS_vec(2) <= '0' when reset = '1' else -- FOR HEX2 AND HEX3
				 '1' when (AddressBus(11 downto 0) = X"808" or AddressBus(11 downto 0) = X"809") else
				 '0';

	CS_vec(3) <= '0' when reset = '1' else -- FOR HEX4 AND HEX5
				 '1' when (AddressBus(11 downto 0) = X"80C" or AddressBus(11 downto 0) = X"80D") else
				 '0';

	CS_vec(4) <= '0' when reset = '1' else -- FOR SW's
				 '1' when AddressBus(11 downto 0) = X"810" else
				 '0';

	CS_vec(5) <= '0' when reset = '1' else -- FOR KEYS
				 '1' when AddressBus(11 downto 0) = X"814" else
				 '0';
				 
	-- CS_vec(6) <= '0' when reset = '1' else -- FOR GPIO9
				 -- '1' when AddressBus(11 downto 0) = X"818" else
				 -- '0';
	CS_vec(6) <= '0'; -- always 1 so that the pwm signal will always work (not really using gpio component)

END dfl;