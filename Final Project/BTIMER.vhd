--------------- Basic Timer Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;
-------------- ENTITY --------------------
ENTITY BTIMER IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
		MCLK	: IN 	STD_LOGIC;
		reset	: IN 	STD_LOGIC;
		BTCTL	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0); -- control register
		BTCCR0	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0); -- compare register 0
		BTCCR1	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0); -- compare register 1
		BTIFG	: OUT 	STD_LOGIC; -- inturupt flag
		BTOUT	: OUT	STD_LOGIC  -- PWM signal out
		);
END BTIMER;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF BTIMER IS
	SIGNAL CLK		: STD_LOGIC;
	SIGNAL DIV		: integer range 0 to 3;
	--SIGNAL DIV_CNT	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	SIGNAL BTCNT	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL BTCL0	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BTCL1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL PWM		: STD_LOGIC;
	
	signal counter : std_logic_vector(2 downto 0) := "000";
    signal clk_reg : std_logic := '0';

	ALIAS BTIPx		IS BTCTL(2 DOWNTO 0);
	ALIAS BTSSEL	IS BTCTL(4 DOWNTO 3);
	ALIAS BTHOLD	IS BTCTL(5);
	ALIAS BTOUTEN	IS BTCTL(6);
	ALIAS BTOUTMD	IS BTCTL(7);
	
BEGIN
	---------- Select Clock Section ----------
		-- Choose divide with BTSSEL
	-- WITH BTSSEL SELECT DIV	<=
		-- 0	WHEN "00", -- 1
		-- 1	WHEN "01", -- 2
		-- 2	WHEN "10", -- 4
		-- 3	WHEN "11", -- 8
		-- 0	WHEN OTHERS;
		
		-- Generate CLK 
		
		
	process(MCLK)
    begin
        if rising_edge(MCLK) then
            if RESET = '1' then
                counter <= "000";
                clk_reg <= '0';
            else
                case BTSSEL is
                    when "00" => 
                        clk_reg <= MCLK;
                    when "01" => 
                        if counter(0) = '1' then
                            clk_reg <= not clk_reg;
                        end if;
                        counter <= counter + 1;
                    when "10" => 
                        if counter(1) = '1' then
                            clk_reg <= not clk_reg;
                        end if;
                        counter <= counter + 1;
                    when "11" => 
                        if counter(2) = '1' then
                            clk_reg <= not clk_reg;
                        end if;
                        counter <= counter + 1;
                    when others =>
                        clk_reg <= '0';
                end case;
            end if;
        end if;
    end process;

    CLK <= clk_reg;	
		
		
	-- PROCESS(MCLK, reset, CLK)
		-- VARIABLE DIV_CNT	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	-- BEGIN
		-- IF reset = '1' THEN
			-- CLK 	<= '0';
			-- DIV_CNT := "0000";
		-- ELSIF(rising_edge(MCLK)) THEN
			-- IF(DIV = X"1") THEN
				-- DIV_CNT := "0000";
				-- CLK <= NOT CLK;
			-- ELSE
			-- DIV_CNT := DIV_CNT + 1;
				-- IF (to_integer(DIV_CNT) = DIV) THEN
					-- DIV_CNT := "0000";
					-- CLK <= NOT CLK;	
				-- END IF;
			-- END IF;
		-- END IF;
	-- END PROCESS;
	
	
	
	-- PROCESS(MCLK, reset, CLK)
	-- VARIABLE DIV_CNT :STD_LOGIC_VECTOR(3 downto 0) := "0000";
	-- BEGIN
		-- IF reset = '1' THEN
			-- DIV_CNT := "000" & not(MCLK);
		-- ELSIF(rising_edge(MCLK)) THEN
			-- DIV_CNT := DIV_CNT + 1;
		-- ELSIF(falling_edge(MCLK)) THEN
			-- DIV_CNT := DIV_CNT + 1;
		-- END IF;
		-- CLK <= DIV_CNT(DIV);
	-- END PROCESS;
	

	
	-- Update BTCL0,BTCL1 every clock
	PROCESS (MCLK) BEGIN
		IF (falling_edge(MCLK)) THEN
				BTCL0 <= BTCCR0;
				BTCL1 <= BTCCR1;
		END IF;
	END PROCESS;
	
	
	---------- PWM Generation Section ----------
	PROCESS (CLK) BEGIN --was Addr in PROCESS sensivty
		IF reset = '1' THEN
			PWM <= BTOUTMD;
		ELSIF (falling_edge(CLK)) THEN
			IF (BTOUTEN = '0') THEN
				PWM	<= BTOUTMD; -- PWM defult value
			ELSIF (BTCNT = BTCL0 OR BTCNT = BTCL1) THEN
				PWM	<= NOT PWM;
			END IF;
		END IF;
	END PROCESS;
	BTOUT	<= PWM;

	
	---------- Basic Timer Interrupt Section ----------	
	PROCESS(MCLK, CLK, reset) --was Addr in PROCESS sensivty
	BEGIN
		IF (reset = '1') THEN -- was OR IRQ_OUT = 1
			BTCNT <= X"00000000";
		ELSIF (rising_edge(CLK)) THEN
			--IF (IRQ_OUT = '1') THEN
			--	BTCNT <= X"00000000";
			IF(BTCNT = BTCL0 AND BTOUTEN = '1') THEN
				BTCNT <= X"00000000";
			-- ELSIF(Addr = X"820" AND BTWrite = '1') THEN
				-- if BTCNT came as an INPUT (Store Word)
				-- BTCNT <= BTCNT_io;
			ELSIF(BTHOLD = '0') THEN 
				BTCNT <= BTCNT + 1;
			END IF;
		END IF;
	END PROCESS;
	
	--BTCNT <= BTCNT_io WHEN Addr = X"820" AND BTWrite = '1' ELSE	
		-- Select the Basic Timer IFG from BTCNT
	WITH BTIPx SELECT BTIFG <= 
		BTCNT(25)	WHEN	"111",
		BTCNT(23) 	WHEN	"110",
		BTCNT(19) 	WHEN	"101",
		BTCNT(15) 	WHEN	"100",
		BTCNT(11) 	WHEN	"011",
		BTCNT(7) 	WHEN	"010",
		BTCNT(3) 	WHEN	"001", 
		BTCNT(0) 	WHEN	"000",
		'0'		  	WHEN	OTHERS;

END structure;