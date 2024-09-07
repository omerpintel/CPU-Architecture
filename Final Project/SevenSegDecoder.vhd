LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
--------------------------------------------------------
entity SevenSegDecoder is
	generic(hex_size : integer := 4; -- number of bits for hexadecimal
            seg_size : integer := 7 -- 7 segment display
    );

	port( -- INPUTS:
        num : in std_logic_vector(hex_size-1 downto 0);
        -- OUPUTS:
        seven_seg_of_num : out std_logic_vector(seg_size-1 downto 0)
    );
end SevenSegDecoder;

architecture sevenseg of SevenSegDecoder is
	signal num_sig : std_logic_vector(3 downto 0); -- should always work! (hex size is always 4)
	signal seven_seg_of_num_sig : std_logic_vector(seg_size-1 downto 0);	
begin
	num_sig <= num;
	seven_seg_of_num <= seven_seg_of_num_sig;
	
    with num_sig select -- selection of the representation of each number (0 means on, 1 means off)
    seven_seg_of_num_sig <= "1000000" when "0000", -- 0
                        "1111001" when "0001", -- 1
                        "0100100" when "0010", -- 2
                        "0110000" when "0011", -- 3
                        "0011001" when "0100", -- 4
                        "0010010" when "0101", -- 5
                        "0000010" when "0110", -- 6
                        "1111000" when "0111", -- 7 
                        "0000000" when "1000", -- 8 
                        "0010000" when "1001", -- 9
                        "0001000" when "1010", -- A
                        "0000011" when "1011", -- B
                        "1000110" when "1100", -- C
                        "0100001" when "1101", -- D
                        "0000110" when "1110", -- E
                        "0001110" when "1111", -- F
                        "1111111" when others; -- off

end sevenseg;