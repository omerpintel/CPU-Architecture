LABS - VHDL Concurrent Codes
Participants: Romi Lustig & Omer Pintel
List of DUT files - used in the lab.
----------------------------------

top.vhd:
This file defines the top-level entity and architecture for the design.

Generic parameters: n (input size), k (log2(n)), and m (2^k-1).
Inputs: Y_i (first input), X_i (second input), and ALUFN_i (ISA code function).
Outputs: ALUout_o (result), Nflag_o (neg flag), Cflag_o (carry flag), Zflag_o (zero flag), and Vflag_o (overflow flag).
Submodules: AdderSub (ALUFN_i[4:3]="01"), Logic (ALUFN_i[4:3]="11"), and Shifter (ALUFN_i[4:3]="10"), TBD later on.

----------------------------------

AdderSub.vhd:
This component can do basic arithmetic operations, it utilizes a full adder (FA) component to perform addition or subtraction based on the control signal.
Generic parameter: n (input size same as top)
Inputs: x (second input), y (first input), sub_cont (control signal := (ALUFN_i[2:0])).
Outputs: cout (carry out), res (result).
sub_cont := "000" Res = Y+X
	    "001" Res = Y-X
	    "010" Res = Neg(Y)

----------------------------------

Shifter.vhd:
This component can do shifting operation. It shifts the input vector Y based on the shift direction provided in dir and the amount of shifting provided in X.
Generic parameters: n (input size same as top), k (same as top).
Inputs: Y (Input to shift), X (Number of shifts := X[0:k-1]), dir (shift direction := (ALUFN_i[2:0])).
Outputs: res (result), cout (carry out).
dir := "000" SHL Y,X(k-1 to 0)
       "001" SHR Y,X(k-1 to 0)

----------------------------------

Logic.vhd:

This Component performs logical operations such as NOT, OR, AND, XOR, NOR, NAND, and XNOR based on the control signal op_type.
Generic parameter: n (input size same as top).
Inputs: x (second input), y (first input), op_type := (ALUFN_i[2:0]).
Output: res (result).
op_type := "000" Res = not(y)
           "001" Res = y or x
           "010" Res = y and x
           "011" Res = y xor x
           "100" Res = y nor x
           "101" Res = y nand x
           "111" Res = y xnor x
           
----------------------------------

aux_package.vhd:
This file serves as a package containing component declarations for all modules used in the design. 

----------------------------------

FA.vhd:
This file contains the architecture for the full adder (FA) component.


Enjoy!
