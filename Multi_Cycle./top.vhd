LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
--------------------------------------------------------
entity top is
	generic(bus_size : integer := 16;
		Awidth: integer := 4;
		prog_data_size : integer := 16;
		data_data_size : integer := 16;
		prog_addr_size : integer := 6;
		data_addr_size : integer := 6;
		dept:   integer:=64);

	port(rst, clk, ena : in std_logic; -- for both control & datapath
	-- Input (DATAPATH)
	 -- PROGRAM
		Prog_wren : in std_logic; -- enable bit
		ProgMem_Data_in : in std_logic_vector(prog_data_size-1 downto 0);
		ProgMem_writeAddr : in std_logic_vector(prog_addr_size-1 downto 0);
		-- DATA
		Data_wren, TBactive: in std_logic;
		DataMem_Data_in: in std_logic_vector(data_data_size-1 downto 0);
		Data_writeAddr, Data_readAddr : in std_logic_vector(data_addr_size-1 downto 0);
	-- Output
		tb_done : out std_logic; -- CONTROL UNIT
		DataMem_Data_out : out std_logic_vector(data_data_size-1 downto 0)); -- DATAPATH UNIT
end top;

architecture dfl of top is
-- Signals between Datapath and Control unit
	signal Mem_wr, Mem_out, Mem_in, Cout, Cin, Ain, RFin, RFout, IRin, PCin, Imm1_in, Imm2_in : std_logic;
	signal OPC : std_logic_vector(3 downto 0);
	signal RFaddr, PCsel : std_logic_vector(1 downto 0);
	signal mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st, Nflag, Zflag, Cflag : std_logic;
	
begin
	Control_Unit : Control port map(mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st,
									Nflag, Zflag, Cflag,
									rst, ena, clk,
									Mem_wr, Mem_out, Mem_in, Cout, Cin, Ain, RFin, RFout, IRin, PCin, Imm1_in, Imm2_in,
									OPC, RFaddr, PCsel, tb_done);
	Datapath_Unit : Datapath 	generic map (bus_size, prog_data_size, prog_addr_size, data_data_size, data_addr_size, Awidth, dept)
								port map	(clk, rst,
											Mem_wr, Mem_out, Mem_in, Cout, Cin, Ain, RFin, RFout, IRin, PCin, Imm1_in, Imm2_in,
											OPC, RFaddr, PCsel,
											Prog_wren, ProgMem_Data_in, ProgMem_writeAddr,
											Data_wren, TBactive, DataMem_Data_in, Data_writeAddr, Data_readAddr,
											mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st,
											Nflag, Zflag, Cflag,
											DataMem_Data_out);
end dfl;
