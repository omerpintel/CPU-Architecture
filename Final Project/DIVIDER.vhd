--------------- divider Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;
-------------- ENTITY --------------------
ENTITY DIVIDER IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
        DIVIDEND : in std_logic_vector(31 downto 0);
        DIVISOR  : in std_logic_vector(31 downto 0);
        DIVCLK   : in std_logic;
        RST      : in std_logic;
        ENA	     : in std_logic;
        DIVIFG   : out std_logic;
        RESIDUE  : out std_logic_vector(31 downto 0);
        QUOTIENT : out std_logic_vector(31 downto 0)
		);
END DIVIDER;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF DIVIDER IS
    signal current_dividend : std_logic_vector(63 downto 0);
    signal current_divisor  : std_logic_vector(63 downto 0);
    signal quotient_sig     : std_logic_vector(31 downto 0);
    signal residue_sig      : std_logic_vector(31 downto 0);
    signal count            : integer range 0 to 32;
    signal state            : std_logic;
	
BEGIN
    process (DIVCLK, RST)
	variable temp_dividend : std_logic_vector(63 downto 0);
    begin
        if RST = '1' then
            current_dividend <= (others => '0');
            current_divisor  <= (others => '0');
            quotient_sig         <= (others => '0');
            residue_sig          <= (others => '0');
            count            <= 0;
            DIVIFG           <= '0';
            state            <= '0';

        elsif rising_edge(DIVCLK) then
			if state = '0' then
				if ENA = '1' then
				-- Initialize
				current_dividend <= (X"0000000"& "000" & DIVIDEND & '0');
				current_divisor  <= (DIVISOR & X"00000000");
				quotient_sig     <= (others => '0');
				residue_sig      <= DIVIDEND;
				count            <= 32;
				DIVIFG           <= '0';
				state            <= '1';
				end if;
				
			elsif state = '1' then
				if count > 0 then
					-- Shift and subtract
					if (unsigned(current_dividend(63 downto 32)) >= unsigned(current_divisor(63 downto 32))) then
						temp_dividend := (unsigned(current_dividend(63 downto 32)) - unsigned(current_divisor(63 downto 32))) & current_dividend(31 downto 0);
						current_dividend <= temp_dividend(62 downto 0) & '0';
						quotient_sig <= quotient_sig(30 downto 0) & '1';
					else
						quotient_sig <= quotient_sig(30 downto 0) & '0';
						current_dividend <= current_dividend(62 downto 0) & '0';
					end if;
					
					if count = 1 then
						-- Final state
						residue_sig <= current_dividend(63 downto 32);
						DIVIFG  <= '1';
						state   <= '0';
					end if;
					count <= count - 1;
				end if;
			end if;
        end if;
    end process;

    -- Output assignment
    RESIDUE <= residue_sig;
    QUOTIENT <= quotient_sig;
	
END structure;