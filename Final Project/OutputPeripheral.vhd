--------------- Output Peripheral Module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
--------------------------------------------------------
ENTITY OutputPeripheral IS -- THIS PERIPHERAL IS USED FOR 6 (SEVEN SEGMENT) HEX DISPLAY & 10 LEDS
	GENERIC (SevenSeg		: BOOLEAN := TRUE;  -- Using 7 segment display
			 PWM_out		: BOOLEAN := FALSE; -- Using PWM
			 OutputSize		: INTEGER := 7); -- 7 for hexadecimal (seven segment), 8 for LEDs, 1 for pwm

	PORT( 
		MemRead		: IN	STD_LOGIC;
		clk			: IN 	STD_LOGIC;
		rst			: IN 	STD_LOGIC;
		MemWrite	: IN	STD_LOGIC;
		CS			: IN 	STD_LOGIC;
		valid		: IN	STD_LOGIC;
		Data		: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		BTOUT		: IN 	STD_LOGIC; -- pwm 
		GPOutput	: OUT	STD_LOGIC_VECTOR(OutputSize-1 DOWNTO 0) -- change to leds when needed
		);
END OutputPeripheral;


ARCHITECTURE dlf OF OutputPeripheral IS
	SIGNAL data_sig	: STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => 'Z');
	signal pwm_sig_vec : STD_LOGIC_VECTOR(OutputSize-1 downto 0) := (others => 'Z');
BEGIN
	pwm_sig_vec(0) <= BTOUT;
	
	PROCESS(clk)
	BEGIN
	IF ( rst = '1') THEN -- unsychronic part
		data_sig	<= X"00";
	ELSIF (falling_edge(clk)) THEN -- : synchronic part - falling edge (to write at the end of a cycle)
		IF (MemWrite = '1') AND (CS = '1') AND (valid = '1') THEN
			data_sig <= Data;
		END IF;
	END IF;
	END PROCESS;
	
	Data	<=	data_sig when (MemRead = '1') AND (CS = '1') AND (valid = '1') else
				(others => 'Z'); 

--- FOR SEVEN SEGMENT DISPLAY:

	SEG: 
		if (SevenSeg = TRUE and PWM_out = FALSE) generate
			SevenSegDecode: SevenSegDecoder 
							PORT MAP(num => data_sig(3 downto 0), seven_seg_of_num => GPOutput);		
		end generate seg;

	NOT_SEG:
		if(SevenSeg = FALSE and PWM_out = FALSE) generate -- CHECK IF POSSIBLE
			GPOutput <= data_sig;
		end generate not_seg;
		
	FOR_PWM:
		if(PWM_out = TRUE and SevenSeg = FALSE) generate
			GPOutput <= pwm_sig_vec;
		end generate FOR_PWM;

END dlf;