library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aux_package.all;
--------------------------------------------------------
ENTITY AdderSub IS
  GENERIC (n : INTEGER := 8);
  PORT ( x,y	  :	IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		 sub_cont :	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
         cout	  :	OUT STD_LOGIC;
         res	  :	OUT STD_LOGIC_VECTOR(n-1 downto 0));
END AdderSub;

ARCHITECTURE addsub OF AdderSub IS
	SIGNAL x_vec, y_vec: std_logic_vector(n-1 DOWNTO 0);
	SIGNAL c_vec : std_logic_vector(n DOWNTO 0);
	SIGNAL Zsig : std_logic_vector(n-1 DOWNTO 0)  := (others => 'Z');

BEGIN
	c_vec(0) <= '1' WHEN ((sub_cont = "001" or sub_cont = "010") and not (x = Zsig or y = Zsig)) ELSE
				'0';
	x_tmp  : for i in 0 to n-1 generate
	x_vec(i) <= 'Z'			WHEN (x = Zsig) ELSE
				(x(i) xor c_vec(0))  WHEN ((sub_cont = "000" or sub_cont = "001" or sub_cont = "010") and not (x = Zsig)) ELSE
				 '0';
	end generate;
	
	y_vec <= 	(OTHERS => 'Z') WHEN y = Zsig ELSE
				y 				WHEN ((sub_cont = "000" or sub_cont = "001") and not(y = Zsig)) ELSE -- for add/sub
				(OTHERS => '0') WHEN (sub_cont = "010" and not (y = Zsig)) ELSE -- for negative x
				(OTHERS => '0');

	first: FA port map(xi => x_vec(0),yi => y_vec(0),cin => c_vec(0),s => res(0),cout => c_vec(1));
-- Make the rest of the FA operations
	rest : for i in 1 to n-1 generate
		chain : FA port map(xi => x_vec(i),yi => y_vec(i),cin => c_vec(i),s => res(i),cout => c_vec(i+1));
	end generate;
	
	cout <= c_vec(n);

END addsub;