FINAL PROJECT


Participants: Romi Lustig & Omer Pintel
--------------------------------------------

MCU.vhd:


The MCU (Microcontroller Unit) serves as the primary component of the system, integrating a MIPS-based CPU, memory units, and different peripherals (GPIO, interrupt controllers, etc.). The MCU is built using a Harvard architecture, allowing separate pathways for instruction and data, which enhances performance and efficiency.



Inputs:
- 

Clock
- 
Reset

- Control signals
- 
Address and control buses

Outputs:
- 

Data bus

- Control signals to peripherals

- Status outputs


Functionality:

The MCU module acts as the central unit within the system, coordinating operations between the MIPS core and connected peripherals. It executes tasks by fetching instructions, processing data, and managing input/output operations.
The MCU's ability to handle interrupts and communicate with peripheral devices makes it integral to the overall functionality of the project.



--------------------------------------------
MIPS.vhd:

This module implements a MIPS single-cycle processor architecture, a critical component of the MCU. The MIPS processor operates by executing one instruction per clock cycle, allowing for streamlined and efficient data processing. It supports a range of instructions from the MIPS instruction set and utilizes a Harvard architecture for optimized performance.



Inputs:
- 

Instruction: Instruction bus for fetching commands.
- 
clk: Clock signal.
- 
rst: Reset signal.

- Control signals (e.g., MemRead, MemWrite)

Outputs:
- 

ALU_result: Result from ALU operations.
- 
read_data: Data read from memory.
- 
RegWrite: Control signal for register data writing.


Functionality:

The MIPS component processes instructions through distinct stages: Fetch, Decode, Execute, Memory Access, and Control (No need for a WB stage - due to the fact that the functionality is with a single cycle). This module's role is crucial, as it defines how the system executes commands and manages data. The processor fetches instructions based on the Program Counter (PC), decodes them to understand the required operations, executes the commands via the ALU, accesses memory when needed, and writes back results to registers. These operations enable the MIPS core to perform complex calculations and control tasks efficiently.

The design also incorporates dedicated data and instruction caches (DTCM and ITCM), which further enhance processing speed by allowing faster access to frequently used data and instructions.

--------------------------------------------


GPIO.vhd

:
Inputs:


- ACK: Acknowledgment signal.
- 
MemRead, MemWrite_Control_Bus: Control signals for memory operations.
- 
clk: Clock signal.

- rst: Reset signal.

- Address_Bus: 32-bit bus for addressing.
- 
BTOUT: PWM-related input.
- 
Switches: 8-bit input for switches.

- DataBus: 32-bit bidirectional bus for data transfer.

Outputs:


- HEX0 to HEX5: 7-segment display outputs.

- LEDs: 8-bit output for LEDs.
- 
PWM: Pulse Width Modulation output.
- 
CS_vec_out: 7-bit control signal vector.


Functionality:

The GPIO module interfaces with various peripherals, handling both inputs and outputs. It connects to HEX displays, LEDs, and switches, allowing the MCU to interact with external hardware through simple data exchanges on the DataBus.


--------------------------------------------
InterruptController.vhd:


Inputs:


- reset: Reset signal.
- 
clock: Synchronization clock input.
- 
MemReadBus, MemWriteBus: Signals for controlling memory operations.

- AddressBus: 12-bit address bus.

- DataBus: 32-bit bidirectional data bus.
- 
IntrSrc: 8-bit vector of interrupt sources.

- CS_5: Chip select signal for specific key inputs.
- 
INTA: Interrupt Acknowledge signal.

- GIE: Global Interrupt Enable signal.

Outputs:
- 

INTR: Interrupt request signal.


Functionality:

This module manages multiple interrupt sources, prioritizing them with a priority encoder. It interacts with the MCU to allow reading and writing of interrupt-related data via the DataBus, using flags to monitor and trigger interrupts when conditions are met. The controller can distinguish between various interrupt types and assigns them to specific vectors, which are then used by the MCU to handle interrupt service routines appropriately.

--------------------------------------------

There are also two other peripheral copmonents: a Divider (serves as an hardware accelerator), and a Basic Timer - who's output is the PWM signal mentioned earlier.
Both components can interrupt the main MIPS comonent, and are handled in the Interrupt Controller component.

--------------------------------------------


Enjoy!
