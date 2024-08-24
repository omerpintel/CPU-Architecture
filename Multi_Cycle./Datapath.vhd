LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.aux_package.all;
--------------------------------------------------------
entity Datapath is
	generic(bus_size : integer := 16;
			prog_data_size : integer := 16;
			prog_addr_size : integer := 6;
			data_data_size : integer := 16;
			data_addr_size : integer := 6;
			reg_width : integer := 4;
			dept:   integer:=64);
	port(clk, rst: in std_logic;
		-- inputs from control unit
		Mem_wr, Mem_out, Mem_in, Cout, Cin, Ain, RFin, RFout, IRin, PCin, Imm1_in, Imm2_in : in std_logic;
		OPC : in std_logic_vector(3 downto 0);
		RFaddr, PCsel : in std_logic_vector(1 downto 0);
		 -- inputs from tb
		 -- PROGRAM
		Prog_wren : in std_logic; -- enable bit
		ProgMem_Data_in : in std_logic_vector(prog_data_size-1 downto 0);
		ProgMem_writeAddr : in std_logic_vector(prog_addr_size-1 downto 0);
		-- DATA
		TB_Data_wren, TBactive: in std_logic := '0';
		TB_DataMem_Data_in: in std_logic_vector(data_data_size-1 downto 0);
		TB_Data_writeAddr, TB_Data_readAddr : in std_logic_vector(data_addr_size-1 downto 0);
		
		 -- outputs to control unit
		mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st : out std_logic; -- out from OPCdecoder
		Nflag, Zflag, Cflag : out std_logic := '0'; -- out from ALU
		-- outputs to tb, DATA
		DataMem_Data_out : out std_logic_vector(data_data_size-1 downto 0)
	);
end Datapath;

architecture dfl of Datapath is
--	signal store : std_logic;
	signal main_BUS : std_logic_vector(bus_size-1 downto 0) := (others => '0');
	-- for Immidiates 
	signal Imm1, Imm2 : std_logic_vector(bus_size-1 downto 0) := (others => '0');
	
	-- for RF
	signal RF2Bus, Bus2RF : std_logic_vector(bus_size-1 downto 0) := (others => '0');
	
	-- for ALU
	signal REG_A, B, REG_C_in, REG_C_out : std_logic_vector(bus_size-1 downto 0) := (others => '0');
	
	-- for Data Memory
	signal DataMem2Bus : std_logic_vector(bus_size-1 downto 0) := (others => '0');
	alias Bus2Data_readAddr is main_BUS(data_addr_size-1 downto 0);
	alias Bus2Data_writeAddr is main_BUS(data_addr_size-1 downto 0);
	signal Data_wren : std_logic := '0';
	signal DataMem_Data_in: std_logic_vector(data_data_size-1 downto 0) := (others => '0');
	signal Data_writeAddr, Data_readAddr, FF2writeAddr : std_logic_vector(data_addr_size-1 downto 0) := (others => '0');
	
	-- for Program Memory
	signal ProgMem_readAddr : std_logic_vector(prog_addr_size-1 downto 0) := (others => '0');
	signal ProgMem_DataOut : std_logic_vector(prog_data_size-1 downto 0) := (others => '0');
	
	-- for IR
	signal IR2RF : std_logic_vector(3 downto 0) := (others => '0');
	signal IR2OPCDecoder : std_logic_vector(3 downto 0) := (others => '0');
	signal offset : std_logic_vector(7 downto 0) := (others => '0');
	
begin
--	store <= st;
	OPCdecoder_Module : OPCdecoder port map(IR2OPCDecoder, mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st);
	IR_Module : IRunit generic map (bus_size, reg_width) port map(ProgMem_DataOut, IRin, RFaddr, IR2RF, IR2OPCDecoder, Imm1, Imm2, offset);
	RF_Module : RF generic map (bus_size, reg_width) port map(clk, rst, RFin, Bus2RF, IR2RF, IR2RF, RF2Bus);
	ALU_Module : ALU generic map (bus_size) port map(REG_A, B, OPC, Cflag, Zflag, Nflag, REG_C_in);
	ProgMem_Module : progMem generic map (prog_data_size, prog_addr_size, dept) port map(clk, Prog_wren, ProgMem_Data_in, ProgMem_writeAddr, ProgMem_readAddr, ProgMem_DataOut);
	PC_Module : PCunit generic map (bus_size, prog_addr_size) port map(PCin, clk, PCsel, offset, ProgMem_readAddr);
	DataMem_Module : dataMem generic map (data_data_size, data_addr_size, dept) port map(clk, Data_wren, DataMem_Data_in, Data_writeAddr, Data_readAddr, DataMem2Bus);
	
	-- Outputs --
	DataMem_Data_out <= DataMem2Bus;

	-- DATA MEMORY MUXES --
		Data_wren <= TB_Data_wren when TBactive = '1' else
					 Mem_wr;
		DataMem_Data_in <= TB_DataMem_Data_in when TBactive = '1' else
					 main_BUS;
		Data_readAddr <= TB_Data_readAddr when TBactive = '1' else
					Bus2Data_readAddr;
		Data_writeAddr <= TB_Data_writeAddr when TBactive = '1' else
						  FF2writeAddr;
						  
	
	writeAddr: process(Mem_in)
		begin
			if(falling_edge(Mem_in)) then
					FF2writeAddr <= Bus2Data_writeAddr;
			end if;
		end process;
		
	ALU_Registers: process(clk)
	begin
		if (rising_edge(clk)) then
			if (Ain = '1') then
				REG_A <= main_BUS;
			end if;
			if(Cin = '1') then
				REG_C_out <= REG_C_in;
			end if;
		end if;
	end process;

	Bus_RF_out: 	BidirPin		generic map(bus_size)	port map(RF2Bus, RFout, Bus2RF, main_BUS);
	Bus_Cout: 		BidirPin		generic map(bus_size)	port map(REG_C_out, Cout, B, main_BUS); 
	Bus_Mem_out: 	BidirPin		generic map(bus_size)	port map(DataMem2Bus, Mem_out, Bus2RF, main_BUS);
	Bus_Imm1_in: 	BidirPin		generic map(bus_size)	port map(Imm1, Imm1_in, Bus2RF, main_BUS);
	Bus_Imm2_in: 	BidirPin		generic map(bus_size)	port map(Imm2, Imm2_in, B, main_BUS);
	
process(clk)
    begin
		if rising_edge(clk) then
			report "****Datapath Debug Section******"
			& LF & "time =      " & to_string(now) 
			& LF & "REG_A =     " & to_string(REG_A)
			& LF & "B =         " & to_string(B)
			& LF & "REG_C_in =  " & to_string(REG_C_in)
			& LF & "REG_C_out = " & to_string(REG_C_out)
			& LF & "Cflag =     " & to_string(CFlag)
			& LF & "Nflag =     " & to_string(NFlag)
			& LF & "Zflag =     " & to_string(ZFlag)			
			& LF & "OPC =       " & to_string(OPC)
			& LF & "FULL INSTRUCTION =       " & to_hstring(ProgMem_DataOut)
			& LF & "*****************"
			& LF & "IR2RF =              " & to_string(IR2RF)
			& LF & "Bus2RF =  " & to_string(Bus2RF) 
			& LF & "RF2Bus = " & to_string(RF2Bus) 
 			& LF & "Data_readAddr = " & to_string(Data_readAddr) 
			& LF & "DataMem2Bus = " & to_string(DataMem2Bus) 
			
			& LF & "TBactive = " & to_string(TBactive) 
			
			& LF & "main_BUS =           " & to_string(main_BUS) 
			& LF & "Bus2Data_readAddr =     " & to_string(Bus2Data_readAddr) 	
			& LF & "Bus2Data_writeAddr =     " & to_string(Bus2Data_writeAddr)			
			& LF & "FF2writeAddr =     " & to_string(FF2writeAddr)
			& LF & "****** Status *********"
			& LF & "Mem_wr =    " & to_string(Mem_wr)
			& LF & "Mem_in =    "  & to_string(Mem_in) 
			& LF & "Mem_out =   " & to_string(Mem_out)
			& LF & "Cout =      " & to_string(Cout)
			& LF & "Cin =       " & to_string(Cin)
			& LF & "OPC =       " & to_string(OPC)
			& LF & "Ain =       " & to_string(Ain)
			& LF & "RFin =      " & to_string(RFin)
			& LF & "RFout =     " & to_string(RFout)
			& LF & "RFaddr =    " & to_string(RFaddr)
			& LF & "IRin =      " & to_string(IRin) 
			& LF & "PCin =      " & to_string(PCin) 
			& LF & "PCsel =     " & to_string(PCsel) 
			& LF & "Imm1_in =   " & to_string(Imm1_in) 
			& LF & "Imm2_in =   " & to_string(Imm2_in)
--			& LF & "st = 		" & to_string(store)
			;
			assert not(st)
			report "I AM IN STORE OPCODE"
			severity note;
			
		end if;
end process;
end dfl;