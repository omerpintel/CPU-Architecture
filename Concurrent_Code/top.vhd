LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
-------------------------------------
ENTITY top IS
  GENERIC (n : INTEGER := 8;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
  PORT 
  (  
	Y_i,X_i: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  ALUout_o: OUT STD_LOGIC_VECTOR(n-1 downto 0);
		  Nflag_o,Cflag_o,Zflag_o,Vflag_o: OUT STD_LOGIC
  ); -- Zflag,Cflag,Nflag,Vflag
END top;
------------- complete the top Architecture code --------------
ARCHITECTURE struct OF top IS 
	subtype n_size_vec IS std_logic_vector (n-1 DOWNTO 0);
	TYPE mat IS ARRAY (2 DOWNTO 0) OF n_size_vec; -- will be used for answers (each vec is the output for each component)
	SIGNAL ans_mat : mat;

	SIGNAL Xaddsub, Yaddsub, Xlog, Ylog, Xshft, Yshft : n_size_vec; -- input signals
	SIGNAL sub_FN : std_logic_vector(2 DOWNTO 0); -- submodule control
	SIGNAL Zsig : n_size_vec := (others => 'Z'); -- high z n size vector
	SIGNAL ALUout : n_size_vec; -- saves relevant answer in relation to ALUFN
	SIGNAL carry_vec: std_logic_vector(2 DOWNTO 0); -- carry for each one of the results
	constant zero_vec : n_size_vec := (others => '0');
	
BEGIN
--------------------- insert signal to correct component ----------------------------
	Xaddsub <= X_i 					WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE Zsig;
	Yaddsub <= Y_i 					WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE Zsig;
	Xlog <= X_i 					WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE Zsig;
	Ylog <= Y_i 					WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE Zsig;
	Xshft <= X_i					WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE Zsig;
	Yshft <= Y_i 					WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE Zsig;
	sub_FN <= ALUFN_i(2 DOWNTO 0);
	Module_A	: AdderSub 	GENERIC MAP(n)	 PORT MAP(x => Xaddsub, y => Yaddsub, sub_cont => sub_FN, cout => carry_vec(0), res => ans_mat(0));
	Module_B	: Logic		GENERIC MAP(n)	 PORT MAP(x => Xlog, y => Ylog, op_type => sub_FN, res => ans_mat(1)); 
	Module_C	: Shifter 	GENERIC MAP(n,k) PORT MAP(Y => Yshft, X => Xshft, dir => sub_FN, res => ans_mat(2), cout => carry_vec(2));

-------------------- insert answers -------------------------------------------------
	ALUout <= 	ans_mat(0) WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE -- Module_A
				ans_mat(1) WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE -- Module_B
				ans_mat(2) WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE -- Module_C
				zero_vec;
								
	ALUout_o <= ALUout; 
	
	Vflag_o <= '1' WHEN (ALUFN_i(2 DOWNTO 0) = "000" and Xaddsub(n-1) = '0' and Yaddsub(n-1) = '0' and ALUout(n-1) = '1') ELSE
		'1' WHEN (ALUFN_i(2 DOWNTO 0) = "000" and Xaddsub(n-1) = '1' and Yaddsub(n-1) = '1' and ALUout(n-1) = '0') ELSE
		'1' WHEN (ALUFN_i(2 DOWNTO 0) = "001" and Xaddsub(n-1) = '1' and Yaddsub(n-1) = '0' and ALUout(n-1) = '1') ELSE
		'1' WHEN (ALUFN_i(2 DOWNTO 0) = "001" and Xaddsub(n-1) = '0' and Yaddsub(n-1) = '1' and ALUout(n-1) = '0') ELSE
		'0';

	Zflag_o <= '1' WHEN (ALUout = zero_vec) ELSE
			   '0';
			   
	Cflag_o <= 	carry_vec(0) WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE -- Module_A
				'0'			 WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE -- Module_B
				carry_vec(2) WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE -- Module_C
				'0';
	                                                     
	Nflag_o <= '1' WHEN ALUout(n-1) = '1' ELSE
			   '0';   
	
END struct;