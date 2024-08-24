library ieee;
use ieee.std_logic_1164.all;
use work.aux_package.all;
-----------------------------------------------------------------

entity ALU is
	generic(bus_size : integer := 16);
	port(A, B : in std_logic_vector(bus_size-1 downto 0);
		OPC   : in std_logic_vector(3 downto 0);
		Cflag, Zflag, Nflag : out std_logic;
		C	  : out std_logic_vector(bus_size-1 downto 0)
		);
end ALU;
architecture dfl of ALU is
	signal Atemp, Btemp, result : std_logic_vector(bus_size-1 downto 0);
	signal c_vec : std_logic_vector(bus_size downto 0);
	constant zero_vec : std_logic_vector(bus_size-1 downto 0) := (others => '0');
-- A::y, B::x
begin
	c_vec(0) <= '1' WHEN (OPC = "0001") ELSE
				'0';
	for_loop  : for i in 0 to bus_size-1 generate
		Btemp(i) <= (B(i) xor c_vec(0)); -- ones compelement
	end generate;

	Atemp <= 	A;

--	first: FA port map(xi => Btemp(0),yi => Atemp(0),cin => c_vec(0),s => result(0),cout => c_vec(1));
-- Make the FA operations
	all : for i in 0 to bus_size-1 generate
		chain : FA port map(xi => Btemp(i),yi => Atemp(i),cin => c_vec(i),s => result(i),cout => c_vec(i+1));
	end generate;

	Cflag <= c_vec(bus_size) when (OPC = "0000" or OPC = "0001") else
			 unaffected; -- requested to keep unaffected
	Zflag <='1' when ((result = zero_vec and (OPC = "0000" or OPC = "0001")) or ((Atemp and Btemp) = zero_vec and OPC = "0010") 
						or ((Atemp or Btemp) = zero_vec and OPC = "0011") or ((Atemp xor Btemp) = zero_vec and OPC = "0100")) else
			'0' when (OPC = "0000" or OPC = "0001" or OPC = "0010" or OPC = "0011" or OPC = "0100") else
			unaffected;
			
	Nflag <= result(bus_size-1) when (OPC = "0000" or OPC = "0001" or OPC = "0010" or OPC = "0011" or OPC = "0100") else
			 unaffected;
	C	  <= result when (OPC = "0000" or OPC = "0001") else
			 (Atemp and Btemp) when OPC = "0010" else -- is done concurrent to adder
			 (Atemp or Btemp) when OPC = "0011" else
			 (Atemp xor Btemp) when OPC = "0100" else
			 unaffected;
end dfl;