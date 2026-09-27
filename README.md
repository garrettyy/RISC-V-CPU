
# RISC-V 32-Bit CPU and FPGA System

## Overview
This project features a custom 32-bit RISC-V processor built from scratch in SystemVerilog.

Currently, the CPU successfully runs a real-time bare-metal software application (a crawling Snake animation) on a Basys 3 FPGA. A video demonstration of this working on the physical hardware is included in the repository.


https://github.com/user-attachments/assets/b49799b7-60f1-4f75-a8e8-e7608a30277d


<img width="3681" height="2591" alt="BF6F1D92-E367-4972-8367-19C32E7E3AA8_1_201_a" src="https://github.com/user-attachments/assets/ca3e8b9b-f755-42e1-81db-29e3e95c95c5" />

## Architecture & Implementation
* **Reference Schematic vs. Custom Design**: The baseline architecture was inspired by standard academic single-cycle RISC-V datapaths (see the included schematic image). However, the implementation diverges from the basic reference to support a more robust instruction set. Most notably, it features an extended write-back multiplexer network before the Register File to explicitly handle storing `PC + 4` during `JAL` and `JALR` instructions, as well as bypassing the ALU to load immediate values directly during `LUI`.
* **Single-Cycle Datapath**: The core currently features a single-cycle datapath including a control unit, a 32x32 register file, and an ALU.
* **Optimized ALU**: The ALU features hardware resource sharing to minimize FPGA slice utilization (e.g., reusing the adder for subtraction and comparison operations).
* **Advanced Instruction Support**: The datapath natively supports `AUIPC` (Position Independent Code) and `JALR` (Register Jumps) by routing the Program Counter (PC) directly through the ALU operands.
* **MMIO Wrapper (`top.sv`)**: The top-level wrapper instantiates the RISC-V core and routes a specific memory address space (`0x00007FF0`) to memory-mapped I/O (MMIO). This allows the CPU's assembly instructions to directly control a multiplexed 4-digit 7-segment display on the Basys 3 FPGA via hardware-driven clock division and refresh counters.

## Key Design Decisions

- **ALU Hardware Resource Sharing (Area vs. Speed Tradeoff):** Instead of instantiating separate adder, subtractor, and comparator hardware blocks, the ALU heavily reuses a single core adder. Subtraction is executed via two's complement, and Set-Less-Than operations evaluate the flags of this shared adder's output rather than doing independent comparisons. This explicit hardware reuse reduced CARRY4 primitive utilization on the FPGA by 62%, saving logic area at the expense of a slightly deeper combinational path.
- **Verification-Driven Bug Resolution (SLT Overflow):** During verification with a self-checking testbench, a critical edge-case bug was discovered in the ALU's `SLT` (Set Less Than) logic. A naive subtraction-based comparison (relying solely on the sign bit of `A - B`) failed during arithmetic overflow—for example, subtracting a large negative number from a large positive number incorrectly evaluated as a negative result. To resolve this without adding a dedicated comparator, I engineered a hardware fix that explicitly calculates subtraction overflow (`assign overflow = (A[31] ^ B[31]) & (A[31] ^ adder_result[31]);`) and XORs this flag with the sum's sign bit to correct the logic inversion. This ensures 100% accurate signed comparisons across all mathematical boundaries.
- **Datapath Routing for Advanced Instructions:** Unlike typical academic datapaths, the Program Counter (PC) is routed directly into the primary ALU input multiplexer (`ALUSrc1`). This allows the ALU to natively compute `AUIPC` (Add Upper Immediate to PC) without needing a dedicated separate adder. It also streamlines `JALR` by calculating the jump target directly in the ALU (`rs1 + imm`).
- **Hardware/Software Partitioning (MMIO):** The top-level wrapper handles memory-mapped I/O (MMIO) by trapping writes to address `0x00007FF0`. Crucially, rather than implementing a hardware hex-to-7-segment decoder, the design exposes raw LED segment control to the software. The Snake assembly program manually calculates the specific active-low bit patterns required for animation and writes them directly to the display register. This tradeoff shifts complexity into the software, drastically simplifying the hardware peripheral footprint.
- **Decoupled Clock Domains for Display:** The CPU and memories run on a 10 MHz clock derived from a clock divider, providing the software loop delays enough time to create visible animation speeds. However, the multiplexed 4-digit 7-segment display uses an independent refresh counter to cycle the anodes at ~380 Hz. This ensures the physical display remains flicker-free regardless of the CPU's execution speed.

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
