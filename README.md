# RISC-V 32-Bit CPU and FPGA System

## Overview
This project features a custom 32-bit RISC-V processor built from scratch in SystemVerilog.

Currently, the CPU successfully runs a real-time bare-metal software application (a crawling Snake animation) on a Basys 3 FPGA. A video demonstration of this working on the physical hardware is included in the repository.

## Architecture & Implementation
* **Reference Schematic vs. Custom Design**: The baseline architecture was inspired by standard academic single-cycle RISC-V datapaths (see the included schematic image). However, the implementation diverges from the basic reference to support a more robust instruction set. Most notably, it features an extended write-back multiplexer network before the Register File to explicitly handle storing `PC + 4` during `JAL` and `JALR` instructions, as well as bypassing the ALU to load immediate values directly during `LUI`.
* **Single-Cycle Datapath**: The core currently features a single-cycle datapath including a control unit, a 32x32 register file, and an ALU.
* **Optimized ALU**: The ALU features hardware resource sharing to minimize FPGA slice utilization (e.g., reusing the adder for subtraction and comparison operations).
* **Advanced Instruction Support**: The datapath natively supports `AUIPC` (Position Independent Code) and `JALR` (Register Jumps) by routing the Program Counter (PC) directly through the ALU operands.
* **MMIO Wrapper (`top.sv`)**: The top-level wrapper instantiates the RISC-V core and routes a specific memory address space (`0x00007FF0`) to memory-mapped I/O (MMIO). This allows the CPU's assembly instructions to directly control a multiplexed 4-digit 7-segment display on the Basys 3 FPGA via hardware-driven clock division and refresh counters.

## Memory Initialization (ROM & RAM)
The CPU's instruction memory and data memory are initialized using SystemVerilog's `$readmemh` system task. I have included two specific text files in this repository so the project can be simulated and synthesized out-of-the-box:
* **`insmem_rv32.txt`**: Contains the compiled RISC-V machine code (hexadecimal instructions) loaded directly into `ROM.sv` to run the software application.
* **`datamem_h.txt`**: Pre-loads the Data Memory (`data_mem.sv`) with required animation frames (7-segment display hexadecimal patterns) and the software delay limits.

*(Note for Vivado: When generating a bitstream, ensure these `.txt` files are added to the project as Design Sources so the synthesizer correctly flashes the initial states into the FPGA's block RAM).*

## Future Roadmap


### 1. Full RV32I Base Compliance
To achieve 100% compliance with the base RV32I specification, the following architectural additions are planned:
* **Complete B-Type Branch Logic**: Expand the PC branching logic beyond `BEQ` to natively evaluate `BNE`, `BLT`, `BGE`, `BLTU`, and `BGEU` by leveraging ALU flags and a dedicated branch evaluator.
* **Byte and Half-Word Memory Addressing**: Implement `LB`, `SB`, `LH`, `SH`, `LBU`, and `LHU` by adding a byte-enable mask to the Data Memory, allowing selective 8-bit or 16-bit slice writes and applying sign/zero-extension on loads.

### 2. Pipelined Microarchitecture
Once the single-cycle core is fully compliant and verified, the next major architectural evolution is a transition to a **5-stage pipelined design** (Fetch, Decode, Execute, Memory, Writeback). This will involve:
* Adding pipeline registers between stages.
* Designing a Hazard Unit to handle data forwarding and stalls.
* Implementing branch prediction or branch flushing logic.

### 3. Advanced Design Verification (DV)
Moving beyond basic visual waveform simulation, the project will incorporate industry-standard verification methodologies:
* **Automated Self-Checking Directed Tests**: Developing a SystemVerilog testbench with an inline assembler to programmatically generate machine code, execute it, and assert (`$fatal`) against expected Register File and Data Memory states.
