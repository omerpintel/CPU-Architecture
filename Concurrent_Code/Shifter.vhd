library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aux_package.all;

--------------------------------------------------------
ENTITY Shifter IS
  GENERIC (n: INTEGER := 8; k: INTEGER := 3);
  PORT (
    Y: IN std_logic_vector (n-1 downto 0);
    X: IN std_logic_vector (n-1 downto 0);
    dir: IN std_logic_vector (2 downto 0);
    res: OUT std_logic_vector (n-1 downto 0);
    cout: OUT std_logic
  );
END Shifter;

--------------------------------------------------------
ARCHITECTURE shft OF Shifter IS
  subtype res_vec is std_logic_vector (n-1 downto 0);
  type mat is array (0 to n-1) of res_vec;
  signal my_mat: mat;
  signal c_vec: std_logic_vector(0 to n-1);
  signal zero_vec: std_logic_vector(n-1 DOWNTO 0) := (others => '0');
  signal Zsig :  STD_LOGIC_VECTOR (n-1 DOWNTO 0):= (others => 'Z'); -- high z n size vector

BEGIN
  -- Initialization
  init : for i in 0 to n-1 generate
    my_mat(0)(i) <= Y(i) WHEN dir = "000" or dir = "001" ELSE
					'0';
  end generate;

  c_vec(0) <= '0';

  shifting: for j in 1 to n-1 generate
    my_mat(j) <= ('0' & my_mat(j-1)(n-1 downto 1)) WHEN dir = "001" ELSE
                 (my_mat(j-1)(n-2 downto 0) & '0') WHEN dir = "000" ELSE
				 zero_vec;
    c_vec(j) <= my_mat(j-1)(0) WHEN dir = "001" ELSE
                my_mat(j-1)(n-1) WHEN dir = "000" ELSE
				'0';
  end generate;

  res <= 	Zsig when (X = Zsig or Y = Zsig or dir = "ZZZ") else
			my_mat(to_integer(unsigned(X(k-1 downto 0))));
  cout <= 	'Z' when (X = Zsig or Y = Zsig or dir = "ZZZ") else
			c_vec(to_integer(unsigned(X(k-1 downto 0))));
END shft;