# 32-bit Single-Cycle RISC-V Processor using VHDL

## Project Overview

This project presents the design and implementation of a 32-bit single-cycle RISC-V processor using VHDL. The processor was developed and simulated using Xilinx Vivado.

The design integrates the major components of a RISC-V processor, including the Program Counter, Instruction Memory, Register File, ALU, Control Unit, Immediate Generator, Data Memory, and multiplexers into a complete single-cycle datapath.

The functionality of individual modules as well as the complete datapath was verified using VHDL testbenches and behavioral simulation.

---

## Features

- 32-bit RISC-V processor architecture
- Single-cycle datapath implementation
- Modular VHDL design
- Arithmetic and logical operations
- Immediate instruction support
- Load and store operations
- Branch instruction support
- Register file implementation
- Instruction and data memory
- Main Decoder and ALU Decoder
- Individual module-level verification
- Complete datapath simulation and verification

---

## Tools and Technologies

- VHDL
- Xilinx Vivado
- RISC-V Instruction Set Architecture (ISA)
- RTL Design
- FPGA Design and Simulation

---

## Main Design Modules

The processor consists of the following VHDL modules:

- `program_counter.vhd` - Maintains the address of the current instruction.
- `instruction_memory.vhd` - Stores and provides instructions to the processor.
- `register_file.vhd` - Implements the processor's register file.
- `alu.vhd` - Performs arithmetic and logical operations.
- `alu_decoder.vhd` - Generates the required ALU control signals.
- `main_decoder.vhd` - Generates the main processor control signals.
- `sign_extend.vhd` - Generates the required immediate values from instructions.
- `data_memory.vhd` - Implements memory for load and store operations.
- `alusrc_mux.vhd` - Selects the appropriate ALU input.
- `resultsrc_mux.vhd` - Selects the data to be written back to the register file.
- `pcsrc_mux.vhd` - Selects the next Program Counter value.
- `pcplus4_adder.vhd` - Calculates PC + 4 for sequential instruction execution.
- `pctarget_adder.vhd` - Calculates the branch target address.
- `datapath.vhd` - Integrates the processor components into the complete datapath.

---

## Processor Operation

In the single-cycle architecture, each instruction completes its execution within one clock cycle.

The basic instruction flow is:

**Instruction Fetch → Instruction Decode → Execute → Memory Access → Write Back**

The Program Counter provides the instruction address to the Instruction Memory. The instruction is decoded by the control logic, and operands are read from the Register File. The ALU performs the required operation, after which the result is either written directly to the Register File or used for memory access.

For branch instructions, the branch condition determines whether the next PC value is PC + 4 or the calculated branch target address.

---

## Verification

Individual processor components were verified using dedicated VHDL testbenches, including:

- ALU
- ALU Decoder
- Main Decoder
- Program Counter
- Instruction Memory
- Data Memory
- Register File
- Sign Extension
- Multiplexers
- Adders
- Complete Datapath

The complete processor datapath was also tested using a final simulation program to verify arithmetic operations, memory operations, register write-back, and branch execution.

---

## Final Datapath Test

The final processor simulation verifies the execution of a sequence of instructions including:

- `ADDI` - Immediate arithmetic operation
- `ADD` - Register arithmetic operation
- `SW` - Store data into memory
- `LW` - Load data from memory
- `BEQ` - Conditional branch operation

The branch functionality was verified by checking that the processor correctly skips the intended instruction when the branch condition is satisfied.

---

## Simulation and Design Results

The repository includes:

- VHDL source files
- Module-level VHDL testbenches
- Complete datapath testbench
- Final simulation waveform
- Vivado elaborated/synthesized schematic
- Dataflow design
- FPGA floorplan view

These results demonstrate the functional verification and implementation flow of the designed processor using Xilinx Vivado.

---

## Project Structure

    ├── VHDL Design Files
    ├── VHDL Testbench Files
    ├── schematics_final.pdf
    ├── waveform_final.png
    ├── floorplan_view.pdf
    ├── dataflow_design.pdf
    └── README.md

---

## Author

Developed as part of a Summer Internship Project.

**Project:** Design and Simulation of a 32-bit Single-Cycle RISC-V Processor using VHDL and Xilinx Vivado
