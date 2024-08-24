LIBRARY ieee;
USE ieee.std_logic_1164.all;

package aux_package is

-----------------------------------------------------------------
-----------------------------------------------------------------
component top is
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
end component;
-----------------------------------------------------------------
component Control is
	-- generic(bus_size : integer := 16);
	port(mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st : in std_logic; -- gets from OPCDecoder
		Nflag, Zflag, Cflag : in std_logic; -- gets from ALU
		rst, ena, clk : in std_logic;
		Mem_wr, Mem_out, Mem_in, Cout, Cin, Ain, RFin, RFout, IRin, PCin, Imm1_in, Imm2_in : out std_logic;
		OPC : out std_logic_vector(3 downto 0);
		RFaddr, PCsel : out std_logic_vector(1 downto 0);
		tb_done : out std_logic
		);
end component;
-----------------------------------------------------------------
component Datapath is
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
end component;
-----------------------------------------------------------------
component OPCDecoder is
	-- generic(bus_size : integer := 16);
	port(Op   : in std_logic_vector(3 downto 0);
		mov, done, and_bit, or_bit, xor_bit, jnc, jc, jn, jmp, sub, add, ld, st : out std_logic
		);
end component;
-----------------------------------------------------------------
component IRunit is
	generic(bus_size : integer := 16;
			Awidth : integer := 4);
	port(Instruction : in std_logic_vector(bus_size-1 downto 0);
		IRin : in std_logic;
		RFaddr: in std_logic_vector(1 downto 0);
		reg_address, Op : out std_logic_vector(3 downto 0);
		Imm1, Imm2 : out std_logic_vector(bus_size-1 downto 0);
		offset_addr : out std_logic_vector(7 downto 0)
		);
end component;
-----------------------------------------------------------------
component RF is
generic( Dwidth: integer:=16;
		 reg_width: integer:=4);
port(	clk,rst,WregEn: in std_logic;	
		WregData:	in std_logic_vector(Dwidth-1 downto 0);
		WregAddr,RregAddr:	
					in std_logic_vector(3 downto 0);
		RregData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
-----------------------------------------------------------------
component ALU IS
	generic(bus_size : integer := 16);
	port(A, B : in std_logic_vector(bus_size-1 downto 0);
		OPC   : in std_logic_vector(3 downto 0);
		Cflag, Zflag, Nflag : out std_logic;
		C	  : out std_logic_vector(bus_size-1 downto 0)
		);
end component;
-----------------------------------------------------------------
component FA is
	PORT (xi, yi, cin: IN std_logic;
			  s, cout: OUT std_logic);
end component;
-----------------------------------------------------------------
component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end component;
-----------------------------------------------------------------
component BidirPinBasic is
	port(   writePin: in 	std_logic;
			readPin:  out 	std_logic;
			bidirPin: inout std_logic
	);
end component; --bidirPinBasic
-----------------------------------------------------------------
component ProgMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
-----------------------------------------------------------------
component PCunit is
	generic(bus_size : integer := 16;
			Awidth: integer := 6);
	port(PCin, clk : in std_logic;
		PCsel : in std_logic_vector (1 downto 0);
		IR7_0 : in std_logic_vector (7 downto 0);
		PC : out std_logic_vector(Awidth-1 downto 0) := (others => '0'));
end component;
-----------------------------------------------------------------
component dataMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
-----------------------------------------------------------------
-----------------------------------------------------------------

end aux_package;

