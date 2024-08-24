LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
use ieee.numeric_std.all;  -- For std_logic_vector arithmetic
--------------------------------------------------------
entity PCunit is
	generic(bus_size : integer := 16;
			Awidth: integer := 6);
	port(PCin, clk : in std_logic;
		PCsel : in std_logic_vector (1 downto 0);
		IR7_0 : in std_logic_vector (7 downto 0);
		PC : out std_logic_vector(Awidth-1 downto 0) := (others => '0'));
end PCunit;

architecture dfl of PCunit is
	signal curr_PC, next_PC : std_logic_vector(Awidth-1 downto 0) := (others => '0');
	signal full_offset_addr : std_logic_vector(7 downto 0); -- IR[7:0]
	constant zero_vec : std_logic_vector(Awidth-1 downto 0) := (others => '0');
	alias offset_addr is full_offset_addr(Awidth-1 downto 0); -- IR[5:0] correct address to add to PC
begin
	full_offset_addr <= IR7_0;

-- NEXT PC UPDATE RULE --
	next_PC <=  std_logic_vector(signed(curr_PC) + 1) when PCsel = "01" else
				std_logic_vector(signed(curr_PC) + 1 + signed(offset_addr)) when PCsel = "10" else
				zero_vec when PCsel = "11" else
				unaffected;
				
	PC <= curr_PC;

PC_update: process(clk, PCin)
		begin
			if (rising_edge(clk) and PCin = '1') then -- synchronic part only
				curr_PC <= next_PC;
			end if;
	end process;
end dfl;
