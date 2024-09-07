--------------- Priority Encoder Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;

ENTITY PriorityEncoder IS
	GENERIC(RegSize		: integer := 8
			);
	PORT( 
			reset		: IN	STD_LOGIC;
			clock		: IN	STD_LOGIC;
			IFG			: IN STD_LOGIC_VECTOR(RegSize-1 downto 0);
			TYPEx		: OUT STD_LOGIC_VECTOR(RegSize-1 downto 0)
		);
END PriorityEncoder;

ARCHITECTURE dlf OF PriorityEncoder IS
BEGIN
		TYPEx <= X"10" when IFG(2) = '1' else
				 X"14" when IFG(2) = '0' and IFG(3) = '1' else
				 X"18" when IFG(2) = '0' and IFG(3) = '0' and IFG(4) = '1' else
				 X"1C" when IFG(2) = '0' and IFG(3) = '0' and IFG(4) = '0' and IFG(5) = '1' else
				 X"20" when IFG(2) = '0' and IFG(3) = '0' and IFG(4) = '0' and IFG(5) = '0' and IFG(6) = '1' else
				 (others => 'Z');
END dlf;