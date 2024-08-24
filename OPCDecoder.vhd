LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
--------------------------------------------------------
entity OPCDecoder is
	-- generic(bus_size : integer := 16);
	port(Op   : in std_logic_vector(3 downto 0);
		mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st : out std_logic
		);
end OPCDecoder;
architecture dfl of OPCDecoder is

begin
	add <= '1' when Op = "0000" else '0';
	sub <= '1' when Op = "0001" else '0';
	and_bit <= '1' when Op = "0010" else '0';
	or_bit <= '1' when Op = "0011" else '0';
	xor_bit <= '1' when Op = "0100" else '0';
	jmp <= '1' when Op = "0111" else '0';
	jc <= '1' when Op = "1000" else '0';
	jnc <= '1' when Op = "1001" else '0';
	mov <= '1' when Op = "1100" else '0';
	ld <= '1' when Op = "1101" else '0';
	st <= '1' when Op = "1110" else '0';
	done <= '1' when Op = "1111" else '0';
--- NEW OPCODE
	jn <= '1' when Op = "1010" else '0';
end dfl;