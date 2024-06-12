LABS - VHDL Sequential Code
Participants: Romi Lustig & Omer Pintel
List of DUT files - used in the lab.
--------------------------------------------

top.vhd:
This file defines the top-level entity and architecture for the design.

Generic parameters: n (input size), k (log2(n)), and m (number of our choice).
Inputs: X[j] (input - signal; changes in time), rst (reset button), clk (clock), ena (enable button), DetectionCode(integer - number for detection).
Output: detecotor (bit).
Submodule: Adder (Inputs: X[j-1], -X[j-2]); this module has been given to us already.

In the top.vhd file - there are 3 processes:

----------------------------------

Process number 1:

Sensitivity list - clk, rst

This process is a clock-based process. It samples the signal X[j] in the following times: X[j-1], X[j-2] (one & two clocks prior).
It has two parts:
- Asynchronic part: Checks whether 'rst' button is on. If it is: reset the whole system, and delete pervious samples saved.
- Synchronic part: When clock & enable is on -
	1. Save X[j-1] in X[j-2] *
	2. Save X[j] in X[j-1] **

* In code: saves not(X[j-1]) -> X[j-2], easier for process 2 (will be described later).

** Saves X[j] only after process is finished. Saved in a signal - so there's delay in 1 clock (easier than variable to use here).

----------------------------------

Process number 2:

Sensitivity list - DetectionCode, result.

This process is NOT a clock-based process. It is a "single adder based condition logic": Meaning - 
result = X[j-1] - X[j-2] (does it in 2 complement, meaning: X[j-1] + not(X[j-2]) + cin='1')
It changes the 'valid' signal based on:
a. Detection code
b. result

valid = '1' if result == DetectionCode's conditions. *
	'0' if result != DetectionCode's conditions.

* DetectionCode's conditions -
	If:
	- DetectionCode == 0 then: check if result == 1;
	- DetectionCode == 1 then: check if result == 2;
	- DetectionCode == 2 then: check if result == 3;
	- DetectionCode == 3 then: check if result == 4;

----------------------------------

Process number 3:

Sensitivity list - clk, rst

This process is a clock-based process. It raises up an indicator when there have been more than m valid results.
It has two parts:
- Asynchronic part: Checks whether 'rst' button is on. If it is: reset the whole system, meaning - 
	a. counter <- 0
	b. detector <- 0

- Synchronic part: When clock & enable is on -
	a. If valid = '1':
		- update counter.
		- if counter >= m: detector <- 1;
	2. If valid != '1' (meaning:: '0'):
		- same as reset - 
			a. counter <- 0
			b. detector <- 0

Enjoy!