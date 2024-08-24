LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
--------------------------------------------------------
entity Control is
	-- generic(bus_size : integer := 16);
	port(mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st : in std_logic; -- gets from OPCDecoder
		Nflag, Zflag, Cflag : in std_logic; -- gets from ALU
		rst, ena, clk : in std_logic;
		Mem_wr, Mem_out, Mem_in, Cout, Cin, Ain, RFin, RFout, IRin, PCin, Imm1_in, Imm2_in : out std_logic;
		OPC : out std_logic_vector(3 downto 0);
		RFaddr, PCsel : out std_logic_vector(1 downto 0);
		tb_done : out std_logic
		);
end Control;

architecture dfl of Control is
	type state is (reset, fetch, decode, Rtype1, Rtype2, Jtype, Itype_mov, Itype_ldst1, Itype_ldst2, Itype_ldst3);
	signal curr_state, next_state: state;
begin

FSM: process(mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st, Nflag, Zflag, Zflag, curr_state)
	begin
		case curr_state is
			------ STATE reset ------
			when reset =>
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '0';
				OPC <= "0101"; -- opcode not in use
				Ain <= '0';
				RFin <= '0';
				RFout <= '0';
				RFaddr <= "00";
				IRin <= '0';
				PCin <= '1'; -- resets PC
				PCsel <= "11";
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '1';
				if done = '0' then
					next_state <= fetch;
				end if;
			------ STATE fetch ------
			when fetch =>
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '0';
				OPC <= "0101"; -- opcode not in use
				Ain <= '0';
				RFin <= '0';
				RFout <= '0';
				RFaddr <= "00";
				IRin <= '1';
				PCin <= '0';
				PCsel <= "00";
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				next_state <= decode;
			when decode =>
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '0';
				OPC <= "0101"; -- opcode not in use
				Ain <= '1';
				RFin <= '0';
				RFout <= '1'; -- REG-A <- R[rb]
				RFaddr <= "10";
				IRin <= '0';
				PCin <= '0';
				PCsel <= "00";
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				if (ld = '1' or st = '1') then
					next_state <= Itype_ldst1;
				elsif (jmp = '1' or jc = '1' or jnc = '1' or jn = '1') then
					next_state <= Jtype;
				elsif (mov = '1') then
					next_state <= Itype_mov;
				elsif (add = '1' or sub = '1' or and_bit = '1' or or_bit = '1' or xor_bit = '1') then
					next_state <= Rtype1;
				elsif (done = '1') then
					next_state <= reset;
				else
					PCin <= '1';
					PCsel <= "01"; -- update opcode when recived unused opcode
					next_state <= fetch;
				end if;
				
			------ STATE Rtype ------
			when Rtype1 => -- FIRST RTYPE
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '1';

				Ain <= '0';
				RFin <= '0';
				RFout <= '1'; -- ALU-B <- R[rc]
				RFaddr <= "11";
				IRin <= '0';
				PCin <= '0';
				PCsel <= "00";
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				if (add = '1') then
					OPC <= "0000"; -- opcode add
				elsif (sub = '1') then
					OPC <= "0001"; -- opcode sub
				elsif (and_bit = '1') then
					OPC <= "0010"; -- opcode and
				elsif (or_bit = '1') then
					OPC <= "0011"; -- opcode or
				elsif (xor_bit = '1') then
					OPC <= "0100"; -- opcode xor
				end if;
				next_state <= Rtype2;
				
			when Rtype2 => -- SECOND RTYPE
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '1'; -- BUS <- ALU operation result
				cin <= '0';
				OPC <= "0101"; -- unused opcode
				Ain <= '0';
				RFin <= '1'; -- R[ra <- result
				RFout <= '0';
				RFaddr <= "01"; -- choose R[ra]
				IRin <= '0';
				PCin <= '1'; -- next opcode
				PCsel <= "01"; -- PC <- PC+1
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				next_state <= fetch;
				
			------ STATE Jtype ------
			when Jtype =>
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '0';
				OPC <= "0101"; -- opcode not in use
				Ain <= '0';
				RFin <= '0';
				RFout <= '0';
				RFaddr <= "10"; -- don't care
				IRin <= '0';
				PCin <= '1';
				
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				
				if ((jmp = '1') or (jc = '1' and Cflag = '1') or (jnc = '1' and Cflag = '0') or (jn = '1' and Nflag = '1')) then
					PCsel <= "10";
				else 
					PCsel <= "01";
				end if;
				next_state <= fetch;
				
			------ STATE Itype ------
			when Itype_mov => -- ITYPE FOR MOV OPC
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '0';
				OPC <= "0101"; -- opcode not in use
				Ain <= '0';
				RFin <= '1'; -- R[ra] <- Imm1
				RFout <= '0';
				RFaddr <= "01"; -- choose R[ra]
				IRin <= '0';
				PCin <= '1';
				PCsel <= "01"; --PC <- PC+1
				Imm1_in <= '1';
				Imm2_in <= '0';
				tb_done <= '0';
				next_state <= fetch;
				
			when Itype_ldst1 => -- FIRST ITYPE FOR LD/ST OPC
				Mem_wr <= '0';
				Mem_out <= '0';
				Mem_in <= '0';
				cout <= '0';
				cin <= '1'; -- REG-C <- R[rb] + Imm2
				OPC <= "0000"; -- add opcode
				Ain <= '0';
				RFin <= '0';
				RFout <= '0';
				RFaddr <= "10"; -- don't care
				IRin <= '0';
				PCin <= '0';
				PCsel <= "00";
				Imm1_in <= '0';
				Imm2_in <= '1';
				tb_done <= '0';
				next_state <= Itype_ldst2;
				
			when Itype_ldst2 => -- SECOND ITYPE FOR LD/ST OPC
				Mem_wr <= '0';
				Mem_out <= '0';
				
				cout <= '1'; -- Data Memory <- address (ALU result)
				cin <= '0';
				OPC <= "0000"; -- don't care
				Ain <= '0';
				RFin <= '0';
				RFout <= '0';
				RFaddr <= "10"; -- don't care
				IRin <= '0';
				PCin <= '0';
				PCsel <= "00";
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				
				if(st = '1') then
					Mem_in <= '1';
				else Mem_in <= '0'; -- ld case included
				end if;
				
				next_state <= Itype_ldst3;
			
			when Itype_ldst3 => -- THIRD ITYPE FOR LD/ST OPC
				
				
				Mem_in <= '0';
				cout <= '0';
				cin <= '0';
				OPC <= "0000"; -- don't care
				Ain <= '0';
				
				
				RFaddr <= "01"; -- R[ra]
				IRin <= '0';
				PCin <= '1'; -- update PC
				PCsel <= "01"; -- PC <- PC+1
				Imm1_in <= '0';
				Imm2_in <= '0';
				tb_done <= '0';
				
				if(st = '1') then
					Mem_wr <= '1';
					Mem_out <= '0';
					RFin <= '0';
					RFout <= '1';
				else -- if ld = '1'
					Mem_wr <= '0';
					Mem_out <= '1';
					RFin <= '1';
					RFout <= '0';
				end if;
				
				next_state <= fetch;
		end case;
	end process;

CLK_PRO: process(clk, rst)
	begin
		if (rst = '1') then
			curr_state <= reset; -- asynchronic part
		elsif (rising_edge(clk) and ena = '1') then -- synchronic part
			curr_state <= next_state;
			--report "curr_state = " & to_string(curr_state);
		end if;
	end process;

end dfl;
		