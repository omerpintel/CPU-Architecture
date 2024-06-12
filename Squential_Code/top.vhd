LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------------
entity top is
	generic (
		n : positive := 8 ;
		m : positive := 7 ;
		k : positive := 3
	); -- where k=log2(m+1)
	port(
		rst,ena,clk : in std_logic;
		x : in std_logic_vector(n-1 downto 0);
		DetectionCode : in integer range 0 to 3;
		detector : out std_logic
	);
end top;
------------- complete the top Architecture code --------------
architecture arc_sys of top is
	subtype x_vec is std_logic_vector(n-1 downto 0);
	type x_mat is array(0 to 1) of x_vec; 
	signal x_old: x_mat; -- two std vectors: same as x_j (creates 2 FFs)
	signal result: std_logic_vector(n-1 downto 0);
	signal valid, cout: std_logic;
begin
Module_Adder: Adder 	generic map(n)	 port map(a => x_old(0), b => x_old(1), cin => '1', s => result, cout=>cout);
process1:	process(clk, rst) 
			-- first process two samples array
			begin
				if(rst='1') then --asynchronic part
					x_old(0) <= (others=> '0'); -- x[j-1]
					x_old(1) <= (others=> '1'); -- x[j-2]
				elsif (rising_edge(clk) and ena = '1') then -- synchronic part
					x_old(1) <= not(x_old(0)); -- update ones' complement x[j-2] for substration 
					x_old(0) <= x; -- update x[j-1]
				end if;
			end process;
	
process2:	process(DetectionCode, result) 
			-- second process single adder based condition logic
			begin
				case DetectionCode is -- check condition based on detection code
					when 0 =>
						if result = 1 then
							valid <= '1';
						else
							valid <= '0';
						end if;
					when 1 =>
						if result = 2 then
							valid <= '1';
						else
							valid <= '0';
						end if;
					when 2 =>
						if result = 3 then
							valid <= '1';
						else
							valid <= '0';
						end if;
					when 3 =>
						if result = 4 then
							valid <= '1';
						else
							valid <= '0';
						end if;
					when others =>
						valid <= '0';
				end case;
			end process;
	
process3:	process (clk, rst)
			-- third process raise up indicator when there are more than m valid results
			variable counter: integer:=0; -- creates 1 FF
			begin
				if(rst='1') then -- asynchronic part
					counter := 0;
					detector <= '0';
				elsif (rising_edge(clk) and ena = '1') then -- synchronic part
					case valid is -- updates counter and detector if needed
					when '1' =>
						counter := counter + 1;
					if counter >= m then
						detector <= '1';
					else
						detector <= '0';
					end if;
					when others =>
						counter := 0;
						detector <= '0';
					end case;
				end if;
			end process;
end arc_sys;