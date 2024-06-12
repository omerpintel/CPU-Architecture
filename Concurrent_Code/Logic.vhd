library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aux_package.all;
--------------------------------------------------------
entity Logic is
	generic( n: integer :=8);
	port (x,y	  :	IN  STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  op_type : IN  STD_LOGIC_VECTOR (2 DOWNTO 0); 
		  res     : OUT STD_LOGIC_VECTOR(n-1 downto 0));
end Logic;
---------------------------------------
architecture log of Logic is
	signal Zsig :  STD_LOGIC_VECTOR (n-1 DOWNTO 0):= (others => 'Z'); -- high z n size vector

begin
	result: for i in 0 to n-1 generate
		res(i) <=   'Z' 			when (x = Zsig or y = Zsig or op_type = "ZZZ") else
						 not (y(i)) when op_type = "000" else
					y(i) or   x(i)  when op_type = "001" else
					y(i) and  x(i)  when op_type = "010" else
					y(i) xor  x(i)  when op_type = "011" else
					y(i) nor  x(i)  when op_type = "100" else
					y(i) nand x(i)  when op_type = "101" else
					y(i) xnor x(i)  when op_type = "111" else '0';
	end generate;
end log;