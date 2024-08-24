LAB 3 - Digital System Design
Participants: Romi Lustig & Omer Pintel
List of DUT files - used in the lab.
--------------------------------------------

top.vhd:
This file defines the top-level entity and architecture for the design.

Generic parameters: bus_size (bus size), Awidth (registers size), prog_data_size (data size), data_data_size (data size), prog_addr_size (address size), data_addr_size (address size), and dept (memory size).
Inputs: rst, clk, ena,
Prog_wren, ProgMem_Data_in, ProgMem_writeAddr, Data_wren, TBactive, DataMem_Data_in, Data_writeAddr, Data_readAddr.
Outputs: tb_done, DataMem_Data_out.
Submodules: Datapath, Control.

The top module combines both submodules a whole digital system design. There is a program, written already in the system's memory (discussed more in the Datapath.vhd submodule) - and using the top module it performs the given code.

----------------------------------
Control.vhd

1st submodule:
LOGIC OF SUBMODULE - 
inputs are: status signals (bits)
outputs are: control signals, "test bend done" signal

The logic is of a finite state machine (FSM), that manages the control signals. It is connected to the Datapath.vhd module in order to control the operations done in that submodule.

Types of operations:
- Reset - done when a 'done' bit is on. Resets all control signals.
- Fetch - gets the following opcode. (done for all opcodes)
- Decode - decodes instructions in order to determine which type they are. (done for all opcodes).

-R-Type - 2 steps (execute and write back)
	- Includes "if"'s to control which operation to do (within the region).
-J-Type - 1 step (execute)
	- Includes "if"'s to control which operation to do (within the region).
-I-Type - Two options:
	1. I Type mov - if operation "mov". 1 step (execute).
	2. I Type ld/st - if operation "ld"/"st".
		- 3 steps (execute, write back, memory).
		- Includes "if"'s to control which operation to do (within the region).

----------------------------------
Datapath.vhd

LOGIC OF SUBMODULE -
inputs are: control signals, data, clk
outputs are: status signals, data

This submodule is responsible for managong the data flow within the system. It performs arithmetic and logical operations when required. The operations that need to be done are being transfered from the Control.vhd unit.

The way this module does all operations is done with components (submodules) within the unit. The components are:

1. Data Memory - memory of 64 words (16 bits each) for the data used.
2. Program Memory - memory of 64 words (16 bits each) for the program's opcodes.
3. PCunit - controls the flow of the program counter, jumps when needed.
4. IRunit - controls the decoding step, using the OPCdecoder unit.
5. OPCdecoder - decodes which operation is on, and send the status signals.
6. ALU - for arithmetic operations.
7. RF - register file (given to us).
8. Main BUS - B directional BUS (given to us).

All components are connected using signals, in order to make sure all orders are performed correctly.
----------------------------------

Enjoy!
