library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- For std_logic_vector arithmetic
use work.aux_package.all;
--------------------------------------------------------
entity IRunit is
	generic(bus_size : integer := 16;
			Awidth : integer := 4);
	port(Instruction : in std_logic_vector(bus_size-1 downto 0);
		IRin : in std_logic;
		RFaddr: in std_logic_vector(1 downto 0);
		reg_address, Op : out std_logic_vector(3 downto 0);
		Imm1, Imm2 : out std_logic_vector(bus_size-1 downto 0);
		offset_addr : out std_logic_vector(7 downto 0)
		);
end IRunit;

architecture dfl of IRunit is
	signal full_instruction : std_logic_vector(bus_size-1 downto 0);
	alias opcode is full_instruction(bus_size-1 downto (bus_size-1)-3);
	alias ra is full_instruction((bus_size-1)-4 downto (bus_size-1)-7);
	alias rb is full_instruction((bus_size-1)-8 downto (bus_size-1)-11);
	alias rc is full_instruction((bus_size-1)-12 downto 0); -- also IR3_0
	alias IR7_0 is full_instruction(7 downto 0);

begin
	full_instruction <= Instruction when IRin = '1' else unaffected;
	reg_address <=  ra when RFaddr = "01" else
				rb when RFaddr = "10" else
				rc when RFaddr = "11" else
				(others => '0') when RFaddr = "00" else
				unaffected;
	Op <= opcode when IRin = '1';
	Imm1 <= std_logic_vector(resize(signed(IR7_0), Imm1'length)) when IRin ='1' else unaffected;
	Imm2 <= std_logic_vector(resize(signed(rc), Imm2'length)) when IRin ='1' else unaffected;
	offset_addr <= IR7_0 when IRin = '1' else unaffected;

end dfl;