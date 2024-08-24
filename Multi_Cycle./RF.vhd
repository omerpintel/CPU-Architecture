library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity RF is
generic( Dwidth: integer:=16;
		 reg_width: integer:=4);
port(	clk,rst,WregEn: in std_logic;	
		WregData:	in std_logic_vector(Dwidth-1 downto 0);
		WregAddr,RregAddr:	
					in std_logic_vector(3 downto 0);
		RregData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end RF;
--------------------------------------------------------------
architecture behav of RF is

type RegFile is array (0 to 2**reg_width-1) of 
	std_logic_vector(Dwidth-1 downto 0);
signal sysRF: RegFile;

begin			   
  process(clk,rst)
  begin
	if (rst='1') then
		sysRF(0) <= (others=>'0');   -- R[0] is constant Zero value 
	elsif (clk'event and clk='1') then
	    if (WregEn='1') then
		    -- index is type of integer so we need to use 
			-- buildin function conv_integer in order to change the type
		    -- from std_logic_vector to integer
			sysRF(conv_integer(WregAddr)) <= WregData;
			-- report 		"***** Register File Content *****"
				-- & LF & 	"R[0]  = " & to_hstring(sysRF(0))
				-- & LF & 	"R[1]  = " & to_hstring(sysRF(1))
				-- & LF & 	"R[2]  = " & to_hstring(sysRF(2))
				-- & LF & 	"R[3]  = " & to_hstring(sysRF(3))
				-- & LF & 	"R[4]  = " & to_hstring(sysRF(4))
				-- & LF & 	"R[5]  = " & to_hstring(sysRF(5))
				-- & LF & 	"R[6]  = " & to_hstring(sysRF(6))
				-- & LF & 	"R[7]  = " & to_hstring(sysRF(7))
				-- & LF & 	"R[8]  = " & to_hstring(sysRF(8))
				-- & LF & 	"R[9]  = " & to_hstring(sysRF(9))
				-- & LF & 	"R[10] = " & to_hstring(sysRF(10))
				-- & LF & 	"R[11] = " & to_hstring(sysRF(11))
				-- & LF & 	"R[12] = " & to_hstring(sysRF(12))
				-- & LF & 	"R[13] = " & to_hstring(sysRF(13))
				-- & LF & 	"R[14] = " & to_hstring(sysRF(14))
				-- & LF & 	"R[15] = " & to_hstring(sysRF(15))
				-- & LF &  "******** UPDATED ********"
				-- & LF & 	"R[" & to_string(WregAddr) & "] = " & to_hstring(WregData)
				-- & LF & 	"*******************";
	    end if;
	end if;
  end process;
	
  RregData <= sysRF(conv_integer(RregAddr));

end behav;
